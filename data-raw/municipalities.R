counties_file <- fs::path("data-raw", "counties.txt")
gz_2000_file <- fs::path("data-raw", "gazetteer_2000.txt")

counties <- readr::read_tsv(counties_file, col_types = "cc")
gz_2000 <- readr::read_fwf(gz_2000_file,
                           readr::fwf_widths(c(2, 10, 60), c("state","GEOID","municipality"))
) |> dplyr::mutate(municipality = stringr::str_trim(municipality),
                   GEOID = as.character(GEOID)) |>
  dplyr::filter(municipality != "County subdivisions not defined") |>
  dplyr::select(-state) |>
  dplyr::mutate(COUNTY_GEOID = stringr::str_sub(GEOID, 1, 5)) |>
  dplyr::left_join(counties, by=c("COUNTY_GEOID"="GEOID")) |>
  dplyr::select(GEOID, county, municipality)


municipalities <- gz_2000 |>
  dplyr::mutate(GEOID_Y2K = GEOID,
                first_year = 2000,
                final_year = 2021) |>
  dplyr::relocate(GEOID_Y2K)

municipality_updates <- tibble::tribble(
  ~GEOID,      ~final_year,
  "3401309220", 2009, # Caldwell boro changed GEOID from 09220 to 09250
  "3402177210", 2007, # Washington twp (Mercer) became Robbinsville in 2008
  "3402568670", 2004, # South Belmar became Lake Como in 2005
  "3402918130", 2006, # Dover twp (Ocean) became Toms River in 2007
  "3403179820", 2008, # West Paterson became Woodland Park in 2009
  "3402160900", 2012, # Princeton borough became just-plain Princeton in 2013
  "3402160915", 2012, # Princeton twp was absorbed by Princeton boro in 2013
)

municipality_inserts <- tibble::tribble(
  ~GEOID_Y2K,  ~GEOID,      ~county,          ~municipality,         ~first_year,~final_year,
  "3401309220","3401309250","Essex County",   "Caldwell borough",     2010,      2021,
  "3402177210","3402163850","Mercer County",  "Robbinsville township",2008,      2021,
  "3402568670","3402537560","Monmouth County","Lake Como borough",    2005,      2021,
  "3402918130","3402973125","Ocean County",   "Toms River township",  2007,      2021,
  "3403179820","3403182423","Passaic County", "Woodland Park borough",2009,      2021,
  "3402160900","3402160900","Mercer County",  "Princeton",            2013,      2021,
)

municipalities <- municipalities |>
  dplyr::rows_update(municipality_updates, by="GEOID") |>
  dplyr::bind_rows(municipality_inserts) |>
  dplyr::mutate(first_year = as.integer(first_year)) |>
  dplyr::mutate(final_year = as.integer(final_year)) |>
  dplyr::arrange(GEOID_Y2K, first_year)

PRINCETON_TWP_GEOID  <- "3402160900"
PRINCETON_BORO_GEOID <- "3402160915"

usethis::use_data(PRINCETON_BORO_GEOID, PRINCETON_TWP_GEOID, counties,
                  overwrite = TRUE)
usethis::use_data(municipalities, internal = TRUE, overwrite = TRUE)
