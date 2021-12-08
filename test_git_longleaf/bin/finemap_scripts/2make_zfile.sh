IFS='
'
rm submit_zfile.sh >/dev/null 2>&1
mkdir finemap
mkdir jobs_zfile
mkdir logs
for i in $(cat ${1}); do
	trait=$(echo ${i} | cut -f 1)
	chr=$(echo ${i} | cut -f 2)
	pos=$(echo ${i} | cut -f 3)
	start=$(echo ${i} | cut -f 4)
	stop=$(echo ${i} | cut -f 5)
	snpid=$(echo ${i} | cut -f 6)
	n=$(echo ${i} | cut -f 7)
	ancestry=$(echo ${i} | cut -f 8)

# prune by ancestry each trait region
rm jobs_zfile/zfile_${trait}_${ancestry}_chr${chr}_${pos}.R >/dev/null 2>&1

##create R file for each region

echo "
library(tidyverse)

#####CHANGE analysis_dir to your working directory
analysis_dir <- \"/proj/EPI889/users/migraff/finemap\"
info_dir <- \"/proj/EPI889/projects/AMRdata/annotation_qc\"


##read in variants by region that we pulled from the BGEN files; check position range, rename and select variables, LDstore2 sets LD based on allele2
snps <- read.table(file.path(analysis_dir,\"/LD/${ancestry}_${trait}_chr${chr}_${pos}_bgen.region\"), header = TRUE, comment.char=\"#\")
snps <- subset(snps, position >${start} && position <${stop})
snps <-snps %>% rename(allele1=first_allele,allele2=alternative_alleles)
snps <-snps %>% select(rsid, chromosome, position, allele1, allele2)


##merge with info or Rsq to select snps with Rsq>0.6 for best quality
info <- read.table(file.path(info_dir,\"allchr.subset.info\"), header = TRUE)

##rename some columns
info <- info %>% rename(rsid=SNP,Info=Rsq)
info = subset(info, Info>=0.6)

##merge selected variables from BGEN files with info score
snpsinfo <- merge(snps, info,by =\"rsid\", all=FALSE)

#select and order columns needed
snpsinfo <-snpsinfo %>% select(rsid, chromosome, position, allele1, allele2)

##read in gwas results
gwas <- read.table(file.path(analysis_dir,\"/GWAS/CLEANED.${trait}.GWAS.chr${chr}.out\"),header=TRUE,sep=\" \")

##rename some column and select columns needed
gwas <-gwas %>% rename(rsid=SNPID,beta_alt=BETA,alt=ALT,ref=REF,alt_af=ALT_AF,se=SE,pval=PVALUE)
gwas <-gwas %>% select(rsid, alt,ref,alt_af,beta_alt,se,pval)

##create a MAF column to include in z file for finemap
maf=ifelse(gwas\$alt_af<0.5,gwas\$alt_af, 1-gwas\$alt_af)
gwas <-cbind(maf,gwas)

##select snps with MAF>1% 
gwas <- subset(gwas, maf>0.01)

##merge GWAS results selected with SNPs filtered by info from BGEN files
gwas_snpsinfo <- merge(snpsinfo,gwas,by =\"rsid\", all=FALSE)

##orient betas to alleles in BGEN data
beta=ifelse(gwas_snpsinfo\$alt==gwas_snpsinfo\$allele2, gwas_snpsinfo\$beta_alt,gwas_snpsinfo\$beta_alt*-1)
gwas_snpsinfo <-cbind(beta,gwas_snpsinfo)

##drop any variants with non-matching alleles across BGEN And GWAS data
gwas_snpsinfo <- subset(gwas_snpsinfo, (alt==allele2 || alt==allele1) && (ref==allele2 || ref==allele1))


##not needed for anything specific, but could be helpful to have all the variables if questions arise
write.table(gwas_snpsinfo,file.path(analysis_dir,\"/finemap/${trait}_${ancestry}_chr${chr}_${pos}.allvars\"),sep=\" \", row.names=F,quote=F)

##create a z file for finemap 

gwas_snpsinfo_z1 <-gwas_snpsinfo %>% select(rsid,chromosome, position,allele1, allele2,maf,beta,se)
write.table(gwas_snpsinfo_z1,file.path(analysis_dir,\"/finemap/${trait}_${ancestry}_chr${chr}_${pos}.z\"),sep=\" \", row.names=F,quote=F)


##create a z files to calcualte the LD matrix with imputed data; don't need beta, se, maf
gwas_snpsinfo_z2 <-gwas_snpsinfo %>% select(rsid,chromosome, position,allele1, allele2)
write.table(gwas_snpsinfo_z2,file.path(analysis_dir,\"/LD/${trait}_${ancestry}_chr${chr}_${pos}.z\"),sep=\" \", row.names=F,quote=F)

" >> jobs_zfile/zfile_${trait}_${ancestry}_chr${chr}_${pos}.R
echo "sbatch --mem=65g -t 7:00:00 -n 2 -o logs/${trait}_${ancestry}_chr${chr}_${pos}_zfile.log --wrap=\"R CMD BATCH jobs_zfile/zfile_${trait}_${ancestry}_chr${chr}_${pos}.R\"" >> submit_zfile.sh
done


##Toward the top of the script after "analysis_dir" change path2 to your working directory
##run as $bash 2make_zfile.sh input_regions.txt
##will make and R script per region in a folder called: jobs_zfile/*R
##it will also create a script in current directory: submit_zfile.sh that can be used to launch these  jobs in the jobs_zfile/ folder by submitting as: $bash submit_zfile.sh

