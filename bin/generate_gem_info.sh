# Build an informative list of all Gems used by the project - this will take a minute to run
mkdir -p .gempendencies

echo "Calling 'gem info' for every gem in the project...patience is a virtue..."
for gem in `bundle list | sed 's/  \* \(.*\) (.*/\1/g' | grep -v " "`
do echo "------------------------ $gem -----------------------------------"
  gem info $gem | grep -v "Installed at"
done | tee .gempendencies/gem_info.txt

echo "Building License Counts"
echo "#---#---#---#---#---#---#---#---#---#---#---#---#---#---#" | tee -a .gempendencies/gem_info.txt
echo "                        Licenses " | tee -a .gempendencies/gem_info.txt
echo "#---#---#---#---#---#---#---#---#---#---#---#---#---#---#" | tee -a .gempendencies/gem_info.txt
grep "License[s]*" .gempendencies/gem_info.txt | sed 's/.*License[s]*: \(.*\)/\1/g' | sort | uniq -c | sort -n -r | tee -a .gempendencies/gem_info.txt

echo "Building Prolific Author Counts"
echo "#---#---#---#---#---#---#---#---#---#---#---#---#---#---#" | tee -a .gempendencies/gem_info.txt
echo "                      Top Gem Authors " | tee -a .gempendencies/gem_info.txt
echo "#---#---#---#---#---#---#---#---#---#---#---#---#---#---#" | tee -a .gempendencies/gem_info.txt
grep "Author[s]*:" .gempendencies/gem_info.txt | sed 's/.*Author[s]*: \(.*\)/\1/g' | sort | uniq -c | sort -n -r | head -n 15 | tee -a .gempendencies/gem_info.txt

echo "#---#---#---#---#---#---#---#---#---#---#---#---#---#---#" | tee -a .gempendencies/gem_info.txt
echo "                      Total Gem Count " | tee -a .gempendencies/gem_info.txt
echo "#---#---#---#---#---#---#---#---#---#---#---#---#---#---#" | tee -a .gempendencies/gem_info.txt
grep "Author[s]*:" .gempendencies/gem_info.txt | wc -l | tee -a .gempendencies/gem_info.txt

echo "We done - check out gem_info.txt for results"
