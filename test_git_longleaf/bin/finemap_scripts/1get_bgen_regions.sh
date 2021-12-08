IFS='
'
mkdir LD
for i in $(cat ${1}); do
	trait=$(echo ${i} | cut -f 1)
	chr=$(echo ${i} | cut -f 2)
	pos=$(echo ${i} | cut -f 3)
	start=$(echo ${i} | cut -f 4)
	stop=$(echo ${i} | cut -f 5)
	snpid=$(echo ${i} | cut -f 6)
	n=$(echo ${i} | cut -f 7)
	ancestry=$(echo ${i} | cut -f 8)

sbatch --mem=15g -n 1 -t 24:00:00 -o LD/${ancestry}_${trait}_chr${chr}_${pos}_bgenregion.log --wrap="/proj/EPI889/bin/software/bgen/build/apps/bgenix -g /proj/EPI889/projects/AMRdata/genetic_data/chr${chr}.subset.bgen -list -incl-range ${chr}:${start}-${stop} > LD/${ancestry}_${trait}_chr${chr}_${pos}_bgen.region"
done


##run as $bash 1get_bgen_regions.sh input_regions.txt
##will launch jobs.  Output will go to this folder: LD/*region and *log
