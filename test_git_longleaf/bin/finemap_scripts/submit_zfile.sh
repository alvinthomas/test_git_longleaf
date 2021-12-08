sbatch --mem=65g -t 7:00:00 -n 2 -o logs/T2D_AMR_chr10_114758349_zfile.log --wrap="R CMD BATCH jobs_zfile/zfile_T2D_AMR_chr10_114758349.R"
sbatch --mem=65g -t 7:00:00 -n 2 -o logs/BMI_AMR_chr2_638144_zfile.log --wrap="R CMD BATCH jobs_zfile/zfile_BMI_AMR_chr2_638144.R"
sbatch --mem=65g -t 7:00:00 -n 2 -o logs/BMI_AMR_chr3_185786406_zfile.log --wrap="R CMD BATCH jobs_zfile/zfile_BMI_AMR_chr3_185786406.R"
sbatch --mem=65g -t 7:00:00 -n 2 -o logs/BMI_AMR_chr16_53800954_zfile.log --wrap="R CMD BATCH jobs_zfile/zfile_BMI_AMR_chr16_53800954.R"
