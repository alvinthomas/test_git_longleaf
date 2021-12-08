IFS='
'
mv zfile_*.Rout logs/
rm LD/LD_*master >/dev/null 2>&1
rm LD/submit_ldstore2.sh >/dev/null 2>&1

##CHANGE n_LDsamples in 347 to the number of samples in your LD files; it might be the same as your GWAS, but it might also be different; here it is the same n=347
for n_LDsamples in 347;do

for i in $(cat ${1}); do
        trait=$(echo ${i} | cut -f 1)
        chr=$(echo ${i} | cut -f 2)
        pos=$(echo ${i} | cut -f 3)
        start=$(echo ${i} | cut -f 4)
        stop=$(echo ${i} | cut -f 5)
        snpid=$(echo ${i} | cut -f 6)
        n=$(echo ${i} | cut -f 7)
	ancestry=$(echo ${i} | cut -f 8)


##CHANGE p= to path where your BGEN files and .sample files are (can leave as is)
##CREATE A file with samples from your .sample file of only IDs (no header; no leading 0 0) that you want to include in the LD calculations \
###and name as follows where ${ancestry} matches up to those provided in your input regions: ${ancestry}_samples_to_include.incl
##PLACE ${ancestry}_samples_to_include.incl in your LD/ folder
##We will first make a *master file that LDstore2 needs to know where all of the files are;
##Then we will run LDstore2

p=/proj/EPI889/projects/AMRdata/genetic_data
#create LD matrix for each ancestry; trait region
####header of master file required as is below : z;bgen;bgi;sample;incl;ld;n_samples 

echo -e "z;bgen;bgi;sample;incl;ld;n_samples
${trait}_${ancestry}_chr${chr}_${pos}.z;${p}/chr${chr}.subset.bgen;${p}/chr${chr}.subset.bgen.bgi;${p}/chr${chr}.subset.sample;${ancestry}_samples_to_include.incl;${trait}_${ancestry}_chr${chr}_${pos}.ld;${n_LDsamples}" >> LD/LD_${trait}_${ancestry}_chr${chr}_${pos}.master
echo "sbatch --mem=20g -o ldstore2_${ancestry}_chr${chr}_${pos}.log --wrap=\"/proj/EPI889/bin/software/ldstore_v2.0_x86_64/ldstore_v2.0_x86_64 --in-files LD_${trait}_${ancestry}_chr${chr}_${pos}.master --write-text --read-only-bgen\"" >> LD/submit_ldstore2.sh
done
done

##run as: $bash 3make_ldstore2.sh input_regions.txt
## will make *master files in the LD/ folder needed to run ldstore2 package
##will also make a script here: LD/submit_ldstore2.sh
##go into the LD/ folder and submit as : $bash submit_ldstore2.sh
