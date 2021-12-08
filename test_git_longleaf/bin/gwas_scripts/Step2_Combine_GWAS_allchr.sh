#Change in_dir mkdir out_dir directories to your folder(s)
in_dir="/proj/EPI889/users/migraff/AMR_GWAS/results_bychr"
mkdir "/proj/EPI889/users/migraff/AMR_GWAS/results_combined"
out_dir="/proj/EPI889/users/migraff/AMR_GWAS/results_combined"


rm ${out_dir}/GWAS_BMI_allchr.txt
cat ${in_dir}/GWAS_BMI_chr1.wald.out > ${out_dir}/GWAS_BMI_allchr.txt

for i in `seq 2 22`;do
	cat ${in_dir}/GWAS_BMI_chr${i}.wald.out | sed 1d >> ${out_dir}/GWAS_BMI_allchr.txt

done


rm ${out_dir}/GWAS_T2D_allchr.txt
cat ${in_dir}/GWAS_T2D_chr1.score.snp.out > ${out_dir}/GWAS_T2D_allchr.txt

for i in `seq 2 22`;do
	cat ${in_dir}/GWAS_T2D_chr${i}.score.snp.out | sed 1d >> ${out_dir}/GWAS_T2D_allchr.txt

done


