##CREATE a GWAS/ folder and put your unzip GWAS results into that folder
#Change $2==${i} or $3=={i} to the column number for chromosome in the GWAS
#Change the other column numbers to those needed which are: chr, pos, snpID, effect_allele, other_allele, effect allele frequency, beta, se, pvalue

for i in 2 3 16;do
sbatch --wrap="awk '{if (NR==1) printf \"%s %s %s %s %s %s %s %s %s\\n\", \$1,\$2,\$3,\$4,\$5,\$6,\$13,\$14,\$15;  else if (NR!=1 && \$2==${i}) print \$1,\$2,\$3,\$4,\$5,\$6,\$13,\$14,\$15 }' ../AMR_GWAS/results_cleaned/CLEANED.GWAS_BMI_allchr.txt > GWAS/CLEANED.BMI.GWAS.chr${i}.out"
done


for i in 10;do
sbatch --wrap="awk '{if (NR==1) printf \"%s %s %s %s %s %s %s %s %s\\n\", \$1,\$3,\$4,\$5,\$6,\$7,\$18,\$19,\$20;  else if (NR!=1 && \$3==${i}) print \$1,\$3,\$4,\$5,\$6,\$7,\$18,\$19,\$20 }' ../AMR_GWAS/results_cleaned/CLEANED.GWAS_T2D_allchr.txt > GWAS/CLEANED.T2D.GWAS.chr${i}.out"
done


##create a GWAS/ folder and put your unzip GWAS results into that folder
##then run this script as: $bash 0split_GWAS_by_chr.sh

