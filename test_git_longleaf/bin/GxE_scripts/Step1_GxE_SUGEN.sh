#edit mkdir to your folder and output directory name you want to create
mkdir  /proj/EPI889/users/migraff/AMR_GWAS/GxE
mkdir  /proj/EPI889/users/migraff/AMR_GWAS/GxE/results_bychr

module load gcc

phen_dir="/proj/EPI889/projects/AMRdata/phenotype_data"
software="/proj/EPI889/bin/software/SUGEN/SUGEN"
id_col="ID" 
fam_col="FID"
vcf="/proj/EPI889/projects/AMRdata/genetic_data/chr"

#edit out_dir to your output directory
out_dir="/proj/EPI889/users/migraff/AMR_GWAS/GxE/results_bychr"


#Run GxE - approach 1
for i in `seq 1 22`;do
sbatch --mem=2g -t 5:00:00 -n 1 -o GxSex_BMI_chr${i}.slurmlog --wrap="${software} --pheno ${phen_dir}/Simulated_GWAS_PHEN_PC_FINAL.txt  --id-col ${id_col} --family-col ${fam_col} --vcf ${vcf}${i}.subset.dose.vcf.gz --formula BMI=Age+Sex+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10 --unweighted --model linear --ge Sex --ge-output-detail --robust-variance --out-prefix ${out_dir}/GxSex_BMI_chr${i} --dosage"
done

#Run stratified exposure; no exposure - approach 2
for i in `seq 1 22`;do
sbatch --mem=2g -t 5:00:00 -n 1 -o BMI_female_chr${i}.slurmlog --wrap="${software} --pheno ${phen_dir}/Simulated_GWAS_PHEN_PC_FINAL.txt  --id-col ${id_col} --family-col ${fam_col} --vcf ${vcf}${i}.subset.dose.vcf.gz --formula BMI=Age+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10 --unweighted --model linear --out-prefix ${out_dir}/BMI_female_chr${i} --dosage --robust-variance --subset \"Sex=0\""
done

for i in `seq 1 22`;do
sbatch --mem=2g -t 5:00:00 -n 1 -o BMI_male_chr${i}.slurmlog --wrap="${software} --pheno ${phen_dir}/Simulated_GWAS_PHEN_PC_FINAL.txt --id-col ${id_col} --family-col ${fam_col} --vcf ${vcf}${i}.subset.dose.vcf.gz --formula BMI=Age+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10 --unweighted --model linear --out-prefix ${out_dir}/BMI_male_chr${i} --dosage --robust-variance --subset \"Sex=1\""
done


