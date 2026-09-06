# Silence an R CMD check note by declaring columns of `municipalites`
# (plus `year`) as globals.
#
# Keep this list in sync with the columns of `municipalities`
# (see data-raw/municipalities.R) plus `year`, used when binding the
# cross-reference tables together.
utils::globalVariables(c(
  "GEOID",
  "GEOID_Y2K",
  "GEOID_ref",
  "county",
  "final_year",
  "first_year",
  "municipality",
  "year"
))
