 ### THIS IS A SCRIPT TO CREATE R SCRIPTS FOR TRAITS THAT WILL BE AUTOMATICALLY SUBMITTED TO LONGLEAF AND CLEAN AND CREATE PLOTS

##########################TO DO (If you want in your own directory  otherwise can use downloaded version here:
####	/proj/EPI889/bin/software/EasyStrata/
######## 1. DOWNLOAD R MODULE
######## 2. OPEN R AND TYPE THE FOLLOWING, WITH YOUR PATH TO HOME DIR: install.packages("/path2/Rpackages/EasyStrata_16.0.tar.gz", lib="/path2/Rlibs/",repos=NULL)
######## 3. SAVE, QUIT, AND THEN PROCEED WITH THE REST OF THIS SCRIPT

###########TO DO:
### PLEASE FILL IN wd=" " WITH YOUR DIR
### (FOR NOW, WE WILL USE EFFECTIVE N (EffN) AS 10 FOR QUANTITATIVE TRAIT [BMI] AND 20 FOR BINARY TRAIT [T2D])
##########################################################

## Edit wd to your directory
wd="/proj/EPI889/users/migraff/AMR_GWAS"
mkdir ${wd}/results_cleaned

out_dir="${wd}/results_cleaned"

#Edit Easystrata directory to your folder
echo "library(EasyStrata,lib.loc=\"/proj/EPI889/bin/software/\")
EasyStrata(\"/proj/EPI889/users/migraff/AMR_GWAS/EasyStrata_Clean_GWAS_BMI.ecf\")"> ${wd}/run.EasyStrata_Clean_GWAS_BMI.R

## add value for Effective N (EffN)
EffN=10

echo "#########################################################################################################
## add path to your path where results, plots, etc will be output
DEFINE	--pathOut ${out_dir}

		## Define column names and column classes. Alter to match .metal files if needed.
        --acolIn CHROM;POS;VCF_ID;REF;ALT;ALT_AF;ALT_AC;N_INFORMATIVE;N_REF;N_HET;N_ALT;N_DOSE;BETA;SE;PVALUE
        --acolInClasses numeric;numeric;character;character;character;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric
		--strMissing NA
		--strSeparator TAB

## INPUT: Define path to the imputed results.
EASYIN --fileIn ${wd}/results_combined/GWAS_BMI_allchr.txt

START EASYSTRATA

################ merge in imuptation quality and rsid


MERGE	--colInMarker VCF_ID
	--fileRef /proj/EPI889/projects/AMRdata/annotation_qc/allchr.subset.info.rsid
	--strMissing NA
	--strSeparator TAB
	--colRefMarker SNP
	--blnInAll 1
	--blnRefAll 0


##Add EffN
ADDCOL --rcdAddCol Rsq*2*ALT_AF*(1-ALT_AF)*N_INFORMATIVE --colOut EffN

#Rename some columns
RENAMECOL --colInRename VCF_ID --colOutRename SNPID
RENAMECOL --colInRename N_INFORMATIVE --colOutRename N

################
## Cleaning

## Remove monomorphic SNPs:
CLEAN   --rcdClean (ALT_AF==0)|(ALT_AF==1)
        --strCleanName numDrop_Monomorph
        --blnWriteCleaned 0

## Missings:
CLEAN   --rcdClean is.na(PVALUE)
        --strCleanName numDrop_Missing_P
        --blnWriteCleaned 0
CLEAN   --rcdClean is.na(BETA)
        --strCleanName numDrop_Missing_BETA
        --blnWriteCleaned 0
CLEAN   --rcdClean is.na(SE)
        --strCleanName numDrop_Missing_SE
        --blnWriteCleaned 0
CLEAN   --rcdClean is.na(ALT_AF)
        --strCleanName numDrop_Missing_EAF
        --blnWriteCleaned 0
CLEAN   --rcdClean is.na(N)
        --strCleanName numDrop_Missing_N
        --blnWriteCleaned 0
		
## Sanity checks:
CLEAN   --rcdClean PVALUE<0|PVALUE>1
        --strCleanName numDrop_invalid_P
        --blnWriteCleaned 0
GETNUM  --rcdGetNum PVALUE==0
        --strGetNumName num_Pval0

## Poor imputation quality:
CLEAN   --rcdClean Rsq<0.3
        --strCleanName lowinfo
        --blnWriteCleaned 0

###### EffN < your EffN; can redo later if inflated
CLEAN   --rcdClean EffN<${EffN}
        --strCleanName loweffN${EffN}
        --blnWriteCleaned 0

## QQplot. With and without known loci : pvalue

QQPLOT
        --acolQQPlot PVALUE
        --astrColour black
        --strPlotName EffN${EffN}

#calculate lambda; suppress GC correction for now
GC      --colPval PVALUE
        --blnSuppressCorrection 1
        --strTag PVALUE.EffN${EffN}
		
		
#### Manhattan plot ; MHplot 
MHPLOT  --colMHPlot PVALUE
        --colInChr CHROM
        --colInPos POS
        --numPvalOffset 0.5
        --fileAnnot /proj/EPI889/projects/AMRdata/annotation_qc/MH_annot_BMI_list.txt
        --blnYAxisBreak 1
        --numYAxisBreak 22
        --anumAddPvalLine 5e-6;5e-8
        --astrAddPvalLineCol orange;red
        --anumAddPvalLineLty 6;6
#       --numWidth 1600 (this is the default; published papers/posters might need better resolution)
#       --numHeight 600 (this is the default; published papers/posters might need better resolution)

###### Set Indep loci based on distance 
INDEP --rcdCriterion PVALUE<5e-6 
--colIndep PVALUE 
--blnIndepMin 1 
--colInChr CHROM
--colInPos POS
--numPosLim 500000 
--blnAddIndepInfo 0 
--blnStepDown 0


################
## Write the cleaned file

WRITE	--strMode txt
		--strPrefix CLEANED
		--strSep TAB
		--strMissing NA

		
STOP EASYSTRATA 


####################################################################################################################################################################" > ${wd}/EasyStrata_Clean_GWAS_BMI.ecf


sleep 1
sbatch --mem=5g -t 10:00:00 -n 1  --wrap="R CMD BATCH ${wd}/run.EasyStrata_Clean_GWAS_BMI.R"  --job-name="EasyStrata_BMI"


#Edit EasyStrata directory to your folder
echo "library(EasyStrata,lib.loc=\"/proj/EPI889/projects/software/\")
EasyStrata(\"/proj/EPI889/users/migraff/AMR_GWAS/EasyStrata_Clean_GWAS_T2D.ecf\")"> ${wd}/run.EasyStrata_Clean_GWAS_T2D.R


EffN=20

echo "#########################################################################################################
## add path to your path where results, plots, etc will be output
DEFINE	--pathOut ${out_dir}

		## Define column names and column classes. Alter to match .metal files if needed.
        --acolIn GROUP_ID;CHROM;POS;VCF_ID;REF;ALT;ALT_AF;ALT_AC;N_INFORMATIVE;N_REF;N_HET;N_ALT;N_DOSE;ALT_AF_CASE;N_CASE;U;V;BETA;SE;PVALUE
        --acolInClasses character;numeric;numeric;character;character;character;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric
		--strMissing NA
		--strSeparator TAB

## INPUT: Define path to the imputed results.
EASYIN --fileIn ${wd}/results_combined/GWAS_T2D_allchr.txt

START EASYSTRATA

################ merge in imuptation quality and rsid

MERGE	--colInMarker VCF_ID
	--fileRef /proj/EPI889/projects/AMRdata/annotation_qc/allchr.subset.info.rsid
	--strMissing NA
	--strSeparator TAB
	--colRefMarker SNP
	--blnInAll 1
	--blnRefAll 0


##Add EffN; rename columns
ADDCOL --rcdAddCol Rsq*2*ALT_AF*(1-ALT_AF)*N_INFORMATIVE --colOut EffN

RENAMECOL --colInRename VCF_ID --colOutRename SNPID
RENAMECOL --colInRename N_INFORMATIVE --colOutRename N


################
## Cleaning

## Remove monomorphic SNPs:
CLEAN   --rcdClean (ALT_AF==0)|(ALT_AF==1)
        --strCleanName numDrop_Monomorph
        --blnWriteCleaned 0

## Missings:
CLEAN   --rcdClean is.na(PVALUE)
        --strCleanName numDrop_Missing_P
        --blnWriteCleaned 0
CLEAN   --rcdClean is.na(BETA)
        --strCleanName numDrop_Missing_BETA
        --blnWriteCleaned 0
CLEAN   --rcdClean is.na(SE)
        --strCleanName numDrop_Missing_SE
        --blnWriteCleaned 0
CLEAN   --rcdClean is.na(ALT_AF)
        --strCleanName numDrop_Missing_EAF
        --blnWriteCleaned 0
CLEAN   --rcdClean is.na(N)
        --strCleanName numDrop_Missing_N
        --blnWriteCleaned 0
		
## Sanity checks:
CLEAN   --rcdClean PVALUE<0|PVALUE>1
        --strCleanName numDrop_invalid_P
        --blnWriteCleaned 0
GETNUM  --rcdGetNum PVALUE==0
        --strGetNumName num_Pval0

## Poor imputation quality:
CLEAN   --rcdClean Rsq<0.3
        --strCleanName lowinfo
        --blnWriteCleaned 0

###### EffN < your EffN; can redo later if inflated
CLEAN   --rcdClean EffN<${EffN}
        --strCleanName loweffN${EffN}
        --blnWriteCleaned 0

## QQplot. With and without known loci : pvalue

QQPLOT
        --acolQQPlot PVALUE
        --astrColour black
        --strPlotName EffN${EffN}

#calculate lambda; supress GC correction
GC      --colPval PVALUE
        --blnSuppressCorrection 1
        --strTag PVALUE.EffN${EffN}
		
		
####Manhattan plot MHplot 

MHPLOT --colMHPlot PVALUE
	--colInChr CHROM
	--colInPos POS
	--numPvalOffset 0.5
	--fileAnnot /proj/EPI889/projects/AMRdata/annotation_qc/MH_annot_T2D_list.txt
  --blnYAxisBreak 1
  --numYAxisBreak 22
  --anumAddPvalLine 5e-6;5e-8
  --astrAddPvalLineCol orange;red
  --anumAddPvalLineLty 6;6

###### Set Indep loci based on distance 
INDEP --rcdCriterion PVALUE<5e-6 
--colIndep PVALUE 
--blnIndepMin 1 
--colInChr CHROM
--colInPos POS
--numPosLim 500000 
--blnAddIndepInfo 0 
--blnStepDown 0


################
## Write the cleaned file

WRITE	--strMode txt
		--strPrefix CLEANED
		--strSep TAB
		--strMissing NA

		
STOP EASYSTRATA 


####################################################################################################################################################################" > ${wd}/EasyStrata_Clean_GWAS_T2D.ecf

sleep 1
sbatch --mem=5g -t 10:00:00 -n 1  --wrap="R CMD BATCH ${wd}/run.EasyStrata_Clean_GWAS_T2D.R"  --job-name="EasyStrata_T2D"



