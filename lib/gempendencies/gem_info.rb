require 'gempendencies'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'set'
require 'securerandom'

module Gempendencies

  # Build gem_info.txt

  # Cool things to build off of...
  #
  # forked repos:
  #     for file in `find gem_info -iname "curl_result.json"`; do grep -H 'fork":' $file; done | grep true
  #
  # archived repos:
  #     for file in `find gem_info -iname "curl_result.json"`; do grep -H 'archived":' $file; done | grep true
  #
  # most starred:
  #     for file in `find gem_info -iname "curl_result.json"`; do grep -H 'watchers":' $file; done | sed 's/gem_info\/\(.*\).*\/.*ers": \([0-9]*\),/\2 \1/g' | sort -n -r | head -n 20
  #
  # least starred:
  #     file in `find gem_info -iname "curl_result.json"`; do grep -H 'watchers":' $file; done | sed 's/gem_info\/\(.*\).*\/.*ers": \([0-9]*\),/\2 \1/g' | sort -n | head -n 20
  #
  # most issues:
  #     for file in `find gem_info -iname "curl_result.json"`; do grep -H 'issues":' $file; done | sed 's/gem_info\/\(.*\).*\/.*sues": \([0-9]*\),/\2 \1/g' | sort -n -r | head -n 20
  #
  #     
  # all svg files scraped and summarized:
  #     find gem_info -name "*.svg" | sed 's/..*\/.*\/.*\/\(.*\)/\1/g' | sort | uniq -c | sort -n
  #

  class GemInfo
    def initialize
      @domain_badge_labels = {}
      # note - be sure to double backslash all the CLI backslashes
      if File.exist?("gem_info.txt")
        github_urls
      else
        "You need to generate gem_info.txt - GemInfo.new.build_gem_info_txt"
      end
    end

    # uses bundler to build the gem_info.txt summarization of all gems used...
    def build_gem_info_txt
      # https://gist.github.com/deevis/3211023e2b14e85df6ca908dbc642a2d
      # https://gist.githubusercontent.com/deevis/3211023e2b14e85df6ca908dbc642a2d/raw/9fe1c9dfedc15b328cbe2e3f64f8198d56bb9795/generate_gem_info.sh
      `bin/generate_gem_info.sh`
    end

    def github_urls
      @github_urls = `grep "Homepage:" gem_info.txt | grep "github" | sed 's/.*page: \\(.*\\)/\\1/g'`.split("\n").uniq
      #puts @github_urls
      puts "Got #{@github_urls.length} github urls to process"
      @github_urls
    end

    def get_badges(url, directory)
      `rm #{directory}/unknown*.svg`
      # `rm #{directory}/*.svg`
      begin
        doc = Nokogiri::HTML(URI.open(url))
      rescue => e
        puts "Error[#{url}] : #{e.message}"
        return
      end
      articles = doc.css("#readme article")
      images = articles.css("a img")
      
      images.each do |i| 
        canonical_source = i['data-canonical-src']
        image_url = i['src']
        label = i["alt"]&.gsub(' ','_')&.downcase
        if canonical_source.nil? || canonical_source.index("yard-docs")  
          puts "Skipping: #{canonical_source || label}"
          next
        end
        extension = canonical_source.split("?").first.scan(/\....$/).first || '.svg'
        puts "   canonical_source: #{canonical_source}"
        puts "          image_url: #{image_url}"
        puts "              label: #{label}"
        domain = canonical_source.scan(/^(?:https?:\/\/)?(?:[^@\n]+@)?(?:www\.)?([^:\/\n?]+)/).flatten[0]
        if label
          (@domain_badge_labels[domain] ||= Set.new) << label 
        else
          labels = @domain_badge_labels[domain]
          if labels.nil?
            puts "  ERROR - no known labels for #{domain}"
            label = "unknown_#{SecureRandom.hex(3)}"
          elsif labels.length > 1
            puts "  ERROR - multiple possible labels for #{domain} - #{labels}"
            label = "unknown_#{SecureRandom.hex(3)}"
          else
            label = labels.to_a[0]
            puts "   derived    label: #{label}"
          end
        end
        image_name = "#{label}#{extension}"
        next if File.exist?("#{directory}/#{image_name}")
        # curl:  -L  follow redirects
        cmd = "curl -L #{canonical_source} -o #{directory}/#{image_name}"
        puts cmd
        `#{cmd}`
      end
    end

    def get_repo_json(url, file)
      cmd = "curl #{url} > #{file}"
      puts cmd
      `#{cmd}`
      if (contents = File.read(file)).index("rate limit exceeded")
        puts "Exceeded rate limit (#{url})"
        raise contents
      elsif contents.index("Moved Permanently")
        url = JSON.parse(contents)['url']
        puts "Moved Permanently to: #{url}"
        contents = get_repo_json(url, file)
      end
      sleep 0.5
      contents
    end

    def build
      if !File.exist?("gem_info.txt")
        build_gem_info_txt
      end
      @github_urls.each do |url|
        cleansed = url.gsub(/http[s]*:../, '').gsub('github.com','').gsub('github.io','').gsub("/", " ").gsub(".", "").strip
        owner, repo = cleansed.split(" ")
        if owner && repo
          url = "https://api.github.com/repos/#{owner}/#{repo}"
          # puts "#{owner} - #{repo}   :  #{url}"
          directory = "gem_info/#{owner}/#{repo}"
          `mkdir -p #{directory}`
          file = "#{directory}/curl_result.json"
          
          if File.exist?(file)
            if (contents = File.read(file)).index("Moved Permanently")
              json = JSON.parse(contents)
              url = json['url']
            elsif !contents.index("rate limit exceeded")
              puts "skipping #{file}..."
              json = JSON.parse(contents)
              get_badges(json['html_url'], directory)
              next
            end
          end

          contents = get_repo_json(url, file)
          json = JSON.parse(contents)
          get_badges(json['html_url'], directory)
        end
      end
    end # def build
  end # class GemInfo
end # module Gempendencies
