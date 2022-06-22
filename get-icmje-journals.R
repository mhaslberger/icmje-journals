if (!("rvest" %in% installed.packages())){
  install.packages("rvest")}
if (!("dplyr" %in% installed.packages())){
  install.packages("dplyr")}
library(rvest)
library(dplyr)


# ---------------------------------------------------
# Get journals following ICMJE recommendations  
# ---------------------------------------------------

# load the webpage
page <- "http://www.icmje.org/journals-following-the-icmje-recommendations/"
follwing_raw <- read_html(page)
follwing_raw
str(follwing_raw)

following <- follwing_raw %>% 
  rvest::html_nodes("body") %>% 
  rvest::html_nodes("p") %>%
  rvest::html_text() %>% 
  str_trim() %>% 
  as.data.frame()

# check how many columns have to be deleted
# and whether the extraction worked
following %>% View()

# slice the rows that are not needed
following <- following %>% 
  slice(-c(1:8, 11:12))

following <- gsub("\t", "", gsub("\r", "", gsub("\n","", gsub(" \\(.*","", following$.))))


# ---------------------------------------------------
# Get ICMJE member journals 
# ---------------------------------------------------

page <- "http://www.icmje.org/about-icmje/faqs/icmje-membership/"
member_raw <- read_html(page)
member_raw
member_raw <- member_raw %>% 
  rvest::html_nodes("body") %>% 
  rvest::html_nodes("p") %>%
  rvest::html_text() %>% 
  str_trim()
member_raw <- member_raw[3] %>% 
  str_split(",") %>% 
  as.data.frame() %>% 
  slice(-c(15:20)) 
member <- member_raw$c..Annals.of.Internal.Medicine.....British.Medical.Journal... %>% 
  str_trim() %>% 
  toupper()


# ---------------------------------------------------
# combine the list of JCMJE member and following journals and save 
# ---------------------------------------------------

icmje <- tibble(
  journal = member, 
  icmje = "ICMJE member"
) %>% rbind(
  tibble(
    journal = following, 
    icmje = "ICMJE following"
  )
)

write_csv(icmje, file = "./data/icmje_journals.csv")
