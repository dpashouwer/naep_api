# TITLE: [enter]
# AUTHOR(S): [enter]

# DESCRIPTION: [enter a few comments about what this script does]

# Load packages - first pacman, installing if necessary, then others
if (!require("pacman")) install.packages("pacman"); library(pacman)
pacman::p_load(here, readxl, tidyverse, janitor, httr) # add more here as needed
if (!suppressPackageStartupMessages(require("tntpr"))) {pacman::p_load(devtools); devtools::install_github("tntp/tntpr")}; pacman::p_load(tntpr)

# Functions

naep_api <- function(type = "data", 
                     subject = "writing", 
                     grade = "8", 
                     subscale = "WRIR", 
                     variable = "GENDER", 
                     jurisdiction = "NP", 
                     stattype = "MN:MN", 
                     Year = "2011") {
  
  url <- modify_url(url = "https://www.nationsreportcard.gov", 
                    path = "DataService/GetAdhocData.aspx", 
                    query = list(type = type, 
                                 subject = subject, 
                                 grade = grade, 
                                 subscale = subscale, 
                                 variable = variable, 
                                 jurisdiction = jurisdiction, 
                                 stattype = stattype, 
                                 Year = Year)) %>% 
    str_replace_all("%3A", ":")
  
  resp <- GET(url)
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  
  parsed <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
  
  structure(
    list(
      content = parsed, 
      path = url, 
      response = resp
    ), 
    class = "naep_api"
  )
}

test <- naep_api(type = "data", 
         subject = "mathematics", 
         grade = "8", 
         subscale = "MRPCM", 
         variable = "SDRACE", 
         jurisdiction = "LA", 
         stattype = "MN:MN", 
         Year = "2017")


test$content$result %>% 
  bind_rows() %>% 
  arrange(desc(value))
