?October 2021
**Running FINEMAP using imputed data for LD**
**(LDstore2 used to create the LDmatrices from imputed data)**
Further details: http://www.christianbenner.com/
These scripts create a lot of folders to help me keep track of things, but these can be removed if they are annoying.  Also, I’m not the best programmer so maybe there is a way to collapse to fewer steps.)
**Step A.** **Before running this pipeline, you will need an input file (e.g. input\_regions.txt) with columns indicating the regions of interest that you want to finemap.**  It has the following columns, but no header (2 regions as examples are shown below):
Trait	chromosome	position	start	end	snpID	samplesize	Ancestry
TRAIT	1	14730800	14230800	15230800	rs78025940 	9582	HA
TRAIT	2	43561780	43061780	44061780	rs7563201 	9582	HA
**Step B.** **If your GWAS isn’t split by chromosome, it can help make things run more quickly if you split it.**  The following script can be used to do this and is detailed below:
**0split_GWAS_by_chr.sh**
```
##create a GWAS/ folder and put your unzip GWAS results into that folder
#Change $2 to the column number for chromosome in the GWAS
#Change the other column numbers to those needed which are: chr, pos, snpID, effect_allele, other_allele, effect allele frequency, beta, se, pvalue
##then run this script as: $bash split_GWAS_by_chr.sh
for i in `seq 1 22`;do
sbatch --wrap="awk '\$2=${i} {print \$2,\$3,\$4,\$5,\$6,\$7,\$9,\$14,\$15,\$16}' GWAS/CLEANED.GWAS.out.metal > GWAS/CLEANED.GWAS.chr${i}.out"
done
##then run this script as: $bash 0split_GWAS_by_chr.sh
```
**Step C.** **Extract variants from the regions of interest for the LD matrix using imputed data**. This will require imputed data to be in the bgen format.  To convert from vcf to bgen format you can use qctool v2 (<https://www.well.ox.ac.uk/~gav/qctool_v2/>).  Once the data are in bgen format you will use bgenix (<https://enkre.net/cgi-bin/code/bgen/dir?ci=trunk> )  to get the order and exact SNPs in the data.   
**1get_bgen_regions.sh**
```
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
sbatch --mem=15g -n 1 -t 24:00:00 -o LD/${ancestry}_${trait)_chr${chr}_${pos}_bgenregion.log --wrap="/proj/epi/CVDGeneNas/migraff/bin/gavinband-bgen-44fcabbc5c38/build/apps/bgenix -g /path2_BGEN_files/chr${chr}.bgen -list -incl-range ${chr}:${start}-${stop} > LD/${ancestry}_${trait}_chr${chr}_${pos}_bgen.region"
done
```
