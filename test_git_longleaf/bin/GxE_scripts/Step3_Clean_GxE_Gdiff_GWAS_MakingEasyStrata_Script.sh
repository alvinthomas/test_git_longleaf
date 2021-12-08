 ### THIS IS A SCRIPT TO CREATE R SCRIPTS FOR QUANTITATIVE TRAITS THAT WILL BE AUTOMATICALLY SUBMITTED TO LONGLEAF AND CREATE QQPLOTS AT VARYING EFFECTIVE Ns

##########################TO DO:
######## 1. DOWNLOAD R MODULE
######## 2. OPEN R AND TYPE THE FOLLOWING, WITH YOUR PATH TO HOME DIR: install.packages("/path2/Rpackages/EasyStrata_16.0.tar.gz", lib="/path2/Rlibs/",repos=NULL)
######## 3. SAVE, QUIT, AND THEN PROCEED WITH THE REST OF THIS SCRIPT

###########TO DO:
### PLEASE FILL IN mydir WITH YOUR DIR
### PLEASE ADD/REMOVE ANY GWAS DATASETS
### PLEASE ADD/REMOVE ANY TRAITS
### PLEASE ADJUST EFFECTIVE Ns AS NEEDED, FROM LOWEST (EffN_1) TO HIGHEST (EffN_3)
##########################################################

## FILL IN DIRECTORY
wd="/proj/EPI889/users/migraff/AMR_GWAS/GxE"
mkdir ${wd}/results_cleaned

out_dir="${wd}/results_cleaned"

echo "library(EasyStrata,lib.loc=\"/proj/EPI889/bin/software/\")
EasyStrata(\"/proj/EPI889/users/migraff/AMR_GWAS/GxE/EasyStrata_Clean_GWAS_GxE.ecf\")"> ${wd}/run.EasyStrata_Clean_GWAS_GxE.R

## add values for Effective N

EffN=20

echo "#########################################################################################################
## add path to your path where results, plots, etc will be output
DEFINE	--pathOut ${out_dir}


                ## Define column names and column classes. 
        --acolIn CHROM;POS;VCF_ID;REF;ALT;ALT_AF;ALT_AC;N_INFORMATIVE;N_REF;N_HET;N_ALT;N_DOSE;PVALUE_G;PVALUE_INTER;PVALUE_BOTH;BETA_G;BETA_Sex;BETA_G:Sex;COV_G_G;COV_G_Sex;COV_G_G:Sex;COV_Sex_Sex;COV_Sex_G:Sex;COV_G:Sex_G:Sex    
	--acolInClasses numeric;numeric;character;character;character;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric        
	--acolNewName CHROM;POS;VCF_ID;REF;ALT;ALT_AF;ALT_AC;N_INFORMATIVE;N_REF;N_HET;N_ALT;N_DOSE;PVALUE_G;PVALUE_INTER;PVALUE_BOTH;BETA_G;BETA_E;BETA_GE;VAR_G;COV_GE;COV_G_GE;VAR_E;COV_E_GE;VAR_GE
                --strMissing NA
                --strSeparator TAB

EASYIN --fileIn ${wd}/results_combined/GxSex_BMI_allchr.txt



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


############################################
##Caluclate SE
#################################################
ADDCOL --rcdAddCol sqrt(VAR_G) --colOut SE_G
ADDCOL --rcdAddCol sqrt(VAR_E) --colOut SE_E
ADDCOL --rcdAddCol sqrt(VAR_GE) --colOut SE_GE

################
## Cleaning

## Remove monomorphic SNPs:
CLEAN   --rcdClean (ALT_AF==0)|(ALT_AF==1)
        --strCleanName numDrop_Monomorph
        --blnWriteCleaned 0

## Missings:
CLEAN   --rcdClean is.na(PVALUE_INTER)
        --strCleanName numDrop_Missing_P
        --blnWriteCleaned 0
CLEAN   --rcdClean is.na(BETA_G)
        --strCleanName numDrop_Missing_BETA_G
        --blnWriteCleaned 0
CLEAN   --rcdClean is.na(ALT_AF)
        --strCleanName numDrop_Missing_EAF
        --blnWriteCleaned 0
CLEAN   --rcdClean is.na(N)
        --strCleanName numDrop_Missing_N
        --blnWriteCleaned 0
		
## Sanity checks:
CLEAN   --rcdClean PVALUE_G<0|PVALUE_G>1
        --strCleanName numDrop_invalid_P
        --blnWriteCleaned 0


## Poor imputation quality:
CLEAN   --rcdClean Rsq<0.3
        --strCleanName lowinfo
        --blnWriteCleaned 0

###### Clean in EffN < your EffN defined above(<10)
CLEAN   --rcdClean EffN<${EffN}
        --strCleanName loweffN${EffN}
        --blnWriteCleaned 0

## QQplot with all 3 pvalues

QQPLOT
        --acolQQPlot PVALUE_G;PVALUE_INTER;PVALUE_BOTH
        --astrColour black;blue;red
        --strPlotName QQ.EffN${EffN}

##Calculate lambda for each p-value; suppress GC correction
GC      --colPval PVALUE_G
        --blnSuppressCorrection 1
        --strTag PVALUE_G

GC      --colPval PVALUE_INTER
        --blnSuppressCorrection 1
        --strTag PVALUE_INTER

GC      --colPval PVALUE_BOTH
        --blnSuppressCorrection 1
        --strTag PVALUE_BOTH
		
		
######################################
## MHplot with previous hits annotated
######################################

MHPLOT  --colMHPlot PVALUE_G
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
	--strPlotName MH_PVALUE_G

MHPLOT  --colMHPlot PVALUE_INTER
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
        --strPlotName MH_PVALUE_INTER


MHPLOT  --colMHPlot PVALUE_BOTH
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
        --strPlotName MH_PVALUE_BOTH


###################################
### Create MIAMI plot with previous hits 
############################################

MIAMIPLOT       --colMIAMIPlotUp PVALUE_BOTH
                --colMIAMIPlotDown PVALUE_G
                --colInChr CHROM
                --colInPos POS
                --numPvalOffset 0.9
                --fileAnnot /proj/EPI889/projects/AMRdata/annotation_qc/MH_annot_BMI_list.txt 
                --blnYAxisBreak 1
                --numYAxisBreak 22
                --anumAddPvalLine 5e-6;5e-8
                --astrAddPvalLineCol mediumorchid1;red
                --anumAddPvalLineLty 6;6


MIAMIPLOT       --colMIAMIPlotUp PVALUE_BOTH
                --colMIAMIPlotDown PVALUE_INTER
                --colInChr CHROM
                --colInPos POS
                --numPvalOffset 0.9
                --fileAnnot /proj/EPI889/projects/AMRdata/annotation_qc/MH_annot_BMI_list.txt 
                --blnYAxisBreak 1
                --numYAxisBreak 22
                --anumAddPvalLine 5e-6;5e-8
                --astrAddPvalLineCol mediumorchid1;red
                --anumAddPvalLineLty 6;6

MIAMIPLOT       --colMIAMIPlotUp PVALUE_G
                --colMIAMIPlotDown PVALUE_INTER
                --colInChr CHROM
                --colInPos POS
                --numPvalOffset 0.9                
		--fileAnnot /proj/EPI889/projects/AMRdata/annotation_qc/MH_annot_BMI_list.txt 
                --blnYAxisBreak 1
                --numYAxisBreak 22
                --anumAddPvalLine 5e-6;5e-8
                --astrAddPvalLineCol mediumorchid1;red
                --anumAddPvalLineLty 6;6



##Get list of independent hits defined by position and pvalue; lists for each pvalue

INDEP --rcdCriterion PVALUE_G<5e-6 
        --colIndep PVALUE_G
        --blnIndepMin 1 
        --colInChr CHROM
        --colInPos POS
        --numPosLim 500000 
        --blnAddIndepInfo 0 
        --blnStepDown 0
        --strTag Indep_PvalueG

INDEP --rcdCriterion PVALUE_INTER<5e-6 
        --colIndep PVALUE_INTER
        --blnIndepMin 1 
        --colInChr CHROM
        --colInPos POS
        --numPosLim 500000 
        --blnAddIndepInfo 0 
        --blnStepDown 0
        --strTag Indep_PvalueInter


INDEP --rcdCriterion PVALUE_BOTH<5e-6 
        --colIndep PVALUE_BOTH
        --blnIndepMin 1 
        --colInChr CHROM
        --colInPos POS
        --numPosLim 500000 
        --blnAddIndepInfo 0 
        --blnStepDown 0        
	--strTag Indep_PvalueBoth

################
## Write the cleaned file

WRITE	--strMode txt
		--strPrefix CLEANED
		--strSep TAB
		--strMissing NA

		
STOP EASYSTRATA 


####################################################################################################################################################################" > ${wd}/EasyStrata_Clean_GWAS_GxE.ecf


sleep 1
sbatch --mem=5g -t 10:00:00 -n 1  --wrap="R CMD BATCH ${wd}/run.EasyStrata_Clean_GWAS_GxE.R"  --job-name="EasyStrata_BMI"



echo "library(EasyStrata,lib.loc=\"/proj/EPI889/bin/software/\")
EasyStrata(\"/proj/EPI889/users/migraff/AMR_GWAS/GxE/EasyStrata_Clean_GWAS_Gdiff.ecf\")"> ${wd}/run.EasyStrata_Clean_GWAS_Gdiff.R

## add value for effective N 
EffN=20

echo "###########################################################################################################First, we will clean each set of results by strata separately, then merge together, calculate differences between strata, and plot

## add path to your path where results, plots, etc will be output
DEFINE	--pathOut ${out_dir}

		## Define column names and column classes.
        --acolIn CHROM;POS;VCF_ID;REF;ALT;ALT_AF;ALT_AC;N_INFORMATIVE;N_REF;N_HET;N_ALT;N_DOSE;BETA;SE;PVALUE
        --acolInClasses numeric;numeric;character;character;character;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric;numeric
		--strMissing NA
		--strSeparator TAB


## INPUT: Define path to the imputed results. --fileInTag is important to distinguish results by strata once they are merged together

EASYIN --fileIn ${wd}/results_combined/BMI_male_allchr.txt
	--fileInTag male
EASYIN --fileIn ${wd}/results_combined/BMI_female_allchr.txt
	--fileInTag female



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

##Remove unused columns; these are only provided for genotyed data, so unneeded here
REMOVECOL --colRemove N_HET
REMOVECOL --colRemove N_ALT
REMOVECOL --colRemove N_REF


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


## Poor imputation quality:
CLEAN   --rcdClean Rsq<0.3
        --strCleanName lowinfo
        --blnWriteCleaned 0

###### Clean if EffN < your EffN defined above (<10)
CLEAN   --rcdClean EffN<${EffN}
        --strCleanName loweffN${EffN}
        --blnWriteCleaned 0

## QQplot

QQPLOT
        --acolQQPlot PVALUE
        --astrColour black
        --strPlotName QQ.EffN${EffN}

#calculate lambda; suppress GC correction

GC      --colPval PVALUE
        --blnSuppressCorrection 1
        --strTag PVALUE
		
		
####################################
## MHplot with previous hits annotated
#####################################
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

##Get list of independent hits defined by position and pvalue
INDEP --rcdCriterion PVALUE<5e-6 
        --colIndep PVALUE
        --blnIndepMin 1 
        --colInChr CHROM
        --colInPos POS
        --numPosLim 500000 
        --blnAddIndepInfo 0 
        --blnStepDown 0

##Merge results by strata together into on file by SNPID; this is where the --fileInTag is important
MERGEEASYIN --colInMarker SNPID
	    --blnMergeAll 0

##Calculate difference between BETAs of two input strata, correcting for correlations between strata
##blnCovCorrection: Boolean value to define whether a correction to the standard error using the covariance should be applied.
CALCPDIFF --acolBETAs BETA.male;BETA.female 
	  --acolSEs SE.male;SE.female
	  --blnCovCorrection 1
	  --colOutPdiff P.diff

##Calculate the joint (main+interaction) effect P-Value from N stratified analyses (Aschard 2010)
JOINTTEST --acolBETAs BETA.male;BETA.female
          --acolSEs SE.male;SE.female
          --colOutPjoint P.joint


##Since we only kept variants that were the same between both GWAS strata, we can rename one set and drop the other
RENAMECOL --colInRename CHROM.male --colOutRename CHROM
RENAMECOL --colInRename POS.male --colOutRename POS
REMOVECOL --colRemove CHROM.female
REMOVECOL --colRemove POS.female

RENAMECOL --colInRename chrposid.male --colOutRename chrposid
RENAMECOL --colInRename Rsq.male --colOutRename Rsq
RENAMECOL --colInRename rsid.male --colOutRename rsid
REMOVECOL --colRemove Rsq.female
REMOVECOL --colRemove chrposid.female
REMOVECOL --colRemove rsid.female

## QQplot - all strata

QQPLOT
        --acolQQPlot PVALUE.male;PVALUE.female;P.diff;P.joint
        --astrColour blue;red;green;purple
        --strPlotName QQ.EffN${EffN}.diff.joint

#calculate lambda; suppress GC correction

GC      --colPval P.diff
        --blnSuppressCorrection 1
        --strTag P.diff

GC      --colPval P.joint
        --blnSuppressCorrection 1
        --strTag P.joint

###################################
### Create MIAMI plot with previous hits annotated and different pvalues of interest
############################################

MIAMIPLOT       --colMIAMIPlotUp PVALUE.male
                --colMIAMIPlotDown PVALUE.female
                --colInChr CHROM
                --colInPos POS
                --numPvalOffset 0.9
                --fileAnnot /proj/EPI889/projects/AMRdata/annotation_qc/MH_annot_BMI_list.txt 
                --blnYAxisBreak 1
                --numYAxisBreak 22
                --anumAddPvalLine 5e-6;5e-8
                --astrAddPvalLineCol mediumorchid1;red
                --anumAddPvalLineLty 6;6


MIAMIPLOT       --colMIAMIPlotUp P.diff
                --colMIAMIPlotDown P.joint
                --colInChr CHROM
                --colInPos POS
                --numPvalOffset 0.9
                --fileAnnot /proj/EPI889/projects/AMRdata/annotation_qc/MH_annot_BMI_list.txt 
                --blnYAxisBreak 1
                --numYAxisBreak 22
                --anumAddPvalLine 5e-6;5e-8
                --astrAddPvalLineCol mediumorchid1;red
                --anumAddPvalLineLty 6;6



#####Independent hits based on position and pvalue for difference or pvalue for joint test (diff + main)

INDEP --rcdCriterion P.diff<5e-6 
        --colIndep P.diff
        --blnIndepMin 1 
        --colInChr CHROM
        --colInPos POS
        --numPosLim 500000 
        --blnAddIndepInfo 0 
        --blnStepDown 0
	--strTag Indep_P.diff


INDEP --rcdCriterion P.joint<5e-6 
        --colIndep P.joint
        --blnIndepMin 1 
        --colInChr CHROM
        --colInPos POS
        --numPosLim 500000 
        --blnAddIndepInfo 0 
        --blnStepDown 0
        --strTag Indep_P.joint

################
## Write the cleaned file

WRITE	--strMode txt
		--strPrefix CLEANED
		--strSep TAB
		--strMissing NA

		
STOP EASYSTRATA 


####################################################################################################################################################################" > ${wd}/EasyStrata_Clean_GWAS_Gdiff.ecf

sleep 1
#sbatch --mem=5g -t 10:00:00 -n 1  --wrap="R CMD BATCH ${wd}/run.EasyStrata_Clean_GWAS_Gdiff.R"  --job-name="EasyStrata_Gdiff"



