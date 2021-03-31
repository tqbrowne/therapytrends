# init.R
#
# Example R code to install packages if not already installed
#

my_packages = c("tidyverse","bslib", "modeldata","lubridate","timetk",
	"parsnip","rsample","plotly","gtrendsR","anytime","prophet","V8")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}

invisible(sapply(my_packages, install_if_missing))

install.packages("/app/prophet_1.0.tar.gz", repos=NULL, type="source")
install.packages("/app/modeltime_0.5.0.tar.gz", repos=NULL, type="source")
