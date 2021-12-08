in_dir="/proj/EPI889/users/migraff/AMR_GWAS/GxE/results_bychr"
mkdir "/proj/EPI889/users/migraff/AMR_GWAS/GxE/results_combined"
out_dir="/proj/EPI889/users/migraff/AMR_GWAS/GxE/results_combined"


for trait in BMI_male BMI_female GxSex_BMI;do 
cat ${in_dir}/${trait}_chr1.wald.out > ${out_dir}/${trait}_allchr.txt
done


for trait in BMI_male BMI_female GxSex_BMI;do
for i in `seq 2 22`;do
	cat ${in_dir}/${trait}_chr${i}.wald.out | sed 1d >> ${out_dir}/${trait}_allchr.txt
done
done



