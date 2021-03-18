# Build an informative list of all Gems used by the project - this will take a minute to run
echo "Calling 'gem info' for every gem in the project...patience is a virtue..."
for gem in `bundle list | sed 's/  \* \(.*\) (.*/\1/g' | grep -v " "`
do echo "------------------------ $gem -----------------------------------"
  gem info $gem | grep -v "Installed at"
done | tee gem_info.txt

echo "Building License Counts"
echo "#---#---#---#---#---#---#---#---#---#---#---#---#---#---#" | tee -a gem_info.txt
echo "                        Licenses " | tee -a gem_info.txt
echo "#---#---#---#---#---#---#---#---#---#---#---#---#---#---#" | tee -a gem_info.txt
grep "License[s]*" gem_info.txt | sed 's/.*License[s]*: \(.*\)/\1/g' | sort | uniq -c | sort -n -r | tee -a gem_info.txt

echo "Building Prolific Author Counts"
echo "#---#---#---#---#---#---#---#---#---#---#---#---#---#---#" | tee -a gem_info.txt
echo "                      Top Gem Authors " | tee -a gem_info.txt
echo "#---#---#---#---#---#---#---#---#---#---#---#---#---#---#" | tee -a gem_info.txt
grep "Author[s]*:" gem_info.txt | sed 's/.*Author[s]*: \(.*\)/\1/g' | sort | uniq -c | sort -n -r | head -n 15 | tee -a gem_info.txt

echo "#---#---#---#---#---#---#---#---#---#---#---#---#---#---#" | tee -a gem_info.txt
echo "                      Total Gem Count " | tee -a gem_info.txt
echo "#---#---#---#---#---#---#---#---#---#---#---#---#---#---#" | tee -a gem_info.txt
grep "Author[s]*:" gem_info.txt | wc -l | tee -a gem_info.txt

echo "We done - check out gem_info.txt for results"
