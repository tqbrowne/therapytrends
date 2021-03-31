# init.R
#
# Example R code to install packages if not already installed
#

my_packages = c("bslib", "modeldata","lubridate","timetk",
	"parsnip","rsample","plotly","gtrendsR","anytime")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}

invisible(sapply(my_packages, install_if_missing))

install.packages("modeltime_0.50.tar.gz", repos=NULL, type="source")
