## purpose: aggregate cleaned data sources
## contributors: Catalina Moreno, Drew Levitt, Matthew Chan
## last updated: 03/03/2020

## enforce data schema
data_mod <- readxl::read_excel("schema.xlsx", sheet = "master_table")

string_var <- dat_mod_col_names <- data_mod %>% 
  filter(!str_detect(STATUS, "remove|REMOVE|eliminate")) %>% 
  filter(type %in% "string") %>% pull(field)

## point to raw data sources 
read_loc <- "food-data/Cleaned_data_files/"
file_list <- list.files(read_loc)

## row-bind data sets
all_datasets <- vector("list", length = length(file_list)) 
for(i in 1:length(file_list)) {
  all_datasets[[i]] <- suppressWarnings(read_csv(paste0(read_loc, file_list[i]))) %>% 
    mutate_at(.vars = string_var, as.character) 
}

all_datasets <- bind_rows(all_datasets)

## assign uid
all_datasets <- all_datasets %>% mutate(id = 1:n())

## pass thru geocode step
suppressWarnings(source("geocoding.R"))## runs geocoding (requires a google api key)

## write out
readr::write_csv(food, "merged_datasets.csv")

