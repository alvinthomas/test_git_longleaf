IFS='
'
for i in $(cat ${1}); do
	trait=$(echo ${i} | cut -f 1)
	chr=$(echo ${i} | cut -f 2)
	pos=$(echo ${i} | cut -f 3)
	start=$(echo ${i} | cut -f 4)
	stop=$(echo ${i} | cut -f 5)
	snpid=$(echo ${i} | cut -f 6)
	n=$(echo ${i} | cut -f 7)
	ancestry=$(echo ${i} | cut -f 8)
 
rm finemap/${trait}_${ancestry}_chr${chr}_${pos}.master
##header of master file required as is below : z;ld;snp;config;cred;log;n_samples

echo -e "z;ld;snp;config;cred;log;n_samples
${trait}_${ancestry}_chr${chr}_${pos}.z;${trait}_${ancestry}_chr${chr}_${pos}.ld;${trait}_${ancestry}_chr${chr}_${pos}.snp;${trait}_${ancestry}_chr${chr}_${pos}.config;${trait}_${ancestry}_chr${chr}_${pos}.cred;${trait}_${ancestry}_chr${chr}_${pos}.log;${n}" >> finemap/${trait}_${ancestry}_chr${chr}_${pos}.master
done


##run as $bash 4make_master_files.sh input_regions.txt
##output will be in this folder: finemap/*master
