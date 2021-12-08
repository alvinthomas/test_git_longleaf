#edit mkdir to what you want your output directory to be
mkdir /proj/EPI889/users/migraff/AMR_GWAS
mkdir /proj/EPI889/users/migraff/AMR_GWAS/results_bychr

phen_dir="/proj/EPI889/projects/AMRdata/phenotype_data"
software="/proj/EPI889/bin/software/SUGEN/SUGEN"
id_col="ID" 
fam_col="FID"
vcf="/proj/EPI889/projects/AMRdata/genetic_data/chr"

#Edit out_dir directory to your output folder
out_dir="/proj/EPI889/users/migraff/AMR_GWAS/results_bychr"

for i in `seq 1 22`;do	
	sbatch --mem=2g -t 5:00:00 -n 1 -o AMRdata_BMI_quant_chr${i}.slurmlog \
--wrap="${software} --pheno ${phen_dir}/Simulated_GWAS_PHEN_PC_FINAL.txt  \
--id-col ${id_col} --family-col ${fam_col} \
--vcf ${vcf}${i}.subset.dose.vcf.gz \
--formula BMI=Age+Sex+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10 \
--unweighted --model linear \
--out-prefix ${out_dir}/GWAS_BMI_chr${i} --dosage"
done



for i in `seq 1 22`;do
	sbatch --mem=2g -t 5:00:00 -n 1 -o AMRdata_T2D_binary_chr${i}.slurmlog \
--wrap="${software} --pheno ${phen_dir}/Simulated_GWAS_PHEN_PC_FINAL.txt  \
--id-col ${id_col} --family-col ${fam_col} \
--vcf ${vcf}${i}.subset.dose.vcf.gz \
--formula T2D=Age+Sex+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10 \
--score --unweighted --model logistic \
--out-prefix ${out_dir}/GWAS_T2D_chr${i} --dosage"
done
	
