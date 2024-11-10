MIN_YEAR <- 2000
MAX_YEAR <- 2022
YEARS <- MIN_YEAR:MAX_YEAR

#' Internal function get_municipalities_
#'
#' Given a year and a reference year, return a list of all
#' municipalities matching the year, and include GEOID of the
#' reference year as a separate column, GEOID_ref.
#' @param year Year
#' @param geoid_reference_year GEOID reference year
get_municipalities_ <- function(year = MAX_YEAR, geoid_reference_year = year) {
  if (year == geoid_reference_year) {
    municipalities |>
      dplyr::filter(year >= first_year, year <= final_year) |>
      dplyr::mutate(GEOID_ref = GEOID) |>
      dplyr::select(GEOID_ref, GEOID, county, municipality)
  } else {
    reference <- municipalities |>
      dplyr::filter(geoid_reference_year >= first_year,
                    geoid_reference_year <= final_year) |>
      dplyr::select(GEOID_Y2K, GEOID_ref = GEOID)
    municipalities |>
      dplyr::filter(year >= first_year, year <= final_year) |>
      dplyr::left_join(reference, by="GEOID_Y2K") |>
      dplyr::select(GEOID_ref, GEOID, county, municipality)
  }
}


#' Get a list of NJ municipalities, by year
#'
#' Return the list of NJ municipalities that existed in the
#' specified year, using the name of the municipality as it was
#' known in that year, and the US Census GEOID in use in that year.
#'
#' To use the GEOIDs from a different year, specify `geoid_year`.
#' If `year` < 2013 and `geoid_year` >= 2013, then the `GEOID` for
#' Princeton township will the GEOID in use until 2013, when
#' the township ceased to exist.
#'
#' The reference-year GEOID will replace the actual GEOID, unless
#' `geoid_ref_as_ref_column` is `TRUE`, in which case the reference
#' year GEOID will be put in a separate column called `GEOID_ref`.
#'
#' @param year The year, from 2000 to 2022. The default is 2022.
#' @param geoid_year The year to use for GEOIDs
#' @param geoid_ref_as_ref_column If TRUE, add a separate column for the reference GEOID
#' @return A table with `GEOID`, `county` and `municipality`
#' @examples
#' # Return all municipalities in existence in 2005, using 2005 names
#' # and GEOIDs
#' get_municipalities(2005)
#'
#' # Return all municipalities from the year 2000, using the GEOIDs
#' # in use in 2021.
#' get_municipalities(2000, geoid_year=2021)
#'
#' # Return all municipalities from the year 2008, with the year
#' # 2000 GEOID in a separate column.
#' get_municipalities(2008, geoid_year=2000, geoid_ref_as_ref_column=TRUE)
#'
#' @export
get_municipalities <- function(year = MAX_YEAR, geoid_year = year,
                               geoid_ref_as_ref_column = FALSE) {
  if (!dplyr::between(year, MIN_YEAR, MAX_YEAR)) {
    stop("Cannot return municipalities for year = ", year)
  }
  if (!dplyr::between(geoid_year, MIN_YEAR, MAX_YEAR)) {
    stop("Cannot return municipalities with geoid_year = ", geoid_year)
  }
  if (geoid_ref_as_ref_column) {
    get_municipalities_(year, geoid_year)
  } else {
    get_municipalities_(year, geoid_year) |>
      dplyr::select(GEOID = GEOID_ref, county, municipality)
  }
}

#' Get a cross-reference table for GEOIDs
#'
#' @description
#' Given a reference year and a list of years, return a table of
#' cross references of the form `~year, ~GEOID_ref, ~GEOID`
#'
#' @param reference_year Reference year
#' @param years Years
#' @return Cross reference table
#' @examples
#' # Cross reference 2012 and 2013 GEOIDs against a 2010 reference,
#' # and sort by the reference GEOID.
#' get_geoid_cross_references(2010, 2012:2013) %>%
#'   dplyr::arrange(GEOID_ref)
#' @export
get_geoid_cross_references <- function(reference_year, years) {
  if (!dplyr::between(reference_year, MIN_YEAR, MAX_YEAR)) {
    stop("Cannot return municipalities for reference_year = ", reference_year)
  }
  if (!all(dplyr::between(years, MIN_YEAR, MAX_YEAR))) {
    stop("Cannot return municipalities with years = ",
         stringr::str_c(utils::head(setdiff(years, YEARS), 5), collapse=" "))
  }

  years |> unique() |>
    purrr::set_names() |>
    purrr::map(get_municipalities_, geoid_reference_year = reference_year) |>
    purrr::map(dplyr::select, GEOID_ref, GEOID) |>
    dplyr::bind_rows(.id = "year") |>
    dplyr::mutate(year = as.integer(year))
}


