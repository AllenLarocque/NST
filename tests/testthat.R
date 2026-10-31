# Run from /workspace, with the iCAMP fork loaded first (NST imports iCAMP):
#   Rscript -e 'pkgload::load_all("scratch/forks/iCAMP"); testthat::test_local("scratch/forks/NST")'
testthat::test_check("NST")
