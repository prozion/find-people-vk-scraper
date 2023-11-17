#!/usr/bin/env Rscript

library(googlesheets4)
library(dplyr)

sf <- function(x, y) {
  x = ifelse(x == y, x + 1, x)
  x^3*y^3/(y - x)^2
}

people <- read.table("~/cache/find_people/ds_red/ds_in_red_groups.csv", sep="\t", head = T)
# people <- read_sheet("https://docs.google.com/spreadsheets/d/1E6km2A9b1bTw00OEHrVd7jFxctkV-exte7muEuAr2eo")

sorted_people <- people |> transform(rate = sf(ds_count, red_count)) |> arrange(desc(rate)) |> select(-rate)

write.table(sorted_people, "~/cache/find_people/ds_red/ds_in_red_groups_sorted_2.csv", sep = "\t", row.names = F)
sheet_write(sorted_people, "https://docs.google.com/spreadsheets/d/1E6km2A9b1bTw00OEHrVd7jFxctkV-exte7muEuAr2eo", sheet="Sheet3")
