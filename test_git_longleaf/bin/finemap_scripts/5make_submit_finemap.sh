IFS='
'
rm finemap/jobs/job_* > /dev/null 2>&1
rm finemap/submit_finemap.sh >/dev/null 2>&1
mkdir finemap/logs
mkdir finemap/jobs
for i in $(cat ${1}); do
	trait=$(echo ${i} | cut -f 1)
	chr=$(echo ${i} | cut -f 2)
	pos=$(echo ${i} | cut -f 3)
	start=$(echo ${i} | cut -f 4)
	stop=$(echo ${i} | cut -f 5)
	snpid=$(echo ${i} | cut -f 6)
	n=$(echo ${i} | cut -f 7)
	ancestry=$(echo ${i} | cut -f 8)
rm finemap/jobs/job_${trait}_${ancestry}_${pos}_finemap.sh >/dev/null 2>&1

##CHANGE folder path: /path2/finemapLD and Z files/ to your working directory
#redundant here since we are moving to the folder to run
#p=/finemap

sbatch --wrap="cp LD/${trait}_${ancestry}_chr${chr}_${pos}.ld finemap/${trait}_${ancestry}_chr${chr}_${pos}.ld"
echo "/proj/EPI889/bin/software/finemap_v1.4_x86_64/finemap_v1.4_x86_64 --sss --in-files ${trait}_${ancestry}_chr${chr}_${pos}.master --n-causal-snps 5" >> finemap/jobs/job_${trait}_${ancestry}_chr${chr}_${pos}_finemap.sh
echo "sbatch --mem=6g -t 1:00:00 -n 2 -o logs/finemap_${trait}_${ancestry}_chr${chr}_${pos}.log --wrap=\"bash jobs/job_${trait}_${ancestry}_chr${chr}_${pos}_finemap.sh\"" >> finemap/submit_finemap.sh
done


##run as $bash 5make_submit_finemap.sh input_regions.txt
##will create a job for each region here finemap/jobs/*sh to be run in finemap 
##will also make a script here: finemap/submit_finemap.sh to launch these individuals jobs
##go in to the finemap/ folder and check that all of the *.ld files have successfully been copied over from the LD/ folder
##go into the finemap/ folder and submit as : $bash submit_finemap.sh
