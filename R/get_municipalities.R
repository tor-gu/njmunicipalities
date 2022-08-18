#' Get a list of NJ municipalities, by year
#'
#' @description
#' Return the list of NJ municipalities that existed in the
#' specified year, using the name of the municipality as it was
#' known in that year, and the US Census GEOID in use in that year.
#'
#' To use the GEOIDs from a different year, specify `geoid_year`.
#' If `year` < 2013 and `geoid_year` >= 2013, then the `GEOID` for
#' for Princeton township will the GEOID in use until 2013, when
#' the township ceased to exist.
#'
#' @examples
#' # Return all municipalities in existence in 2005, using 2005 names
#' # and GEOIDs
#' get_municipalities(2005)
#'
#' # Return all municipalities from the year 2000, using the GEOIDs
#' # in use in 2021.
#' get_municipalities(2000, geoid_year=2021)
#'
#' @param year The year, from 2000 to 2021. The default is 2021.
#' @param geoid_year The
#' @return A table with `GEOID`, `county` and `municipality`
#' @export
get_municipalities <- function(year = 2021, geoid_year = year) {
  if (year < 2000 | year > 2021) {
    stop("Cannot return municialities for year = ", year)
  }
  if (geoid_year < 2000 | geoid_year > 2021) {
    stop("Cannot return municialities with geoid_year = ", geoid_year)
  }
  if (year == geoid_year) {
    municipalities |>
      dplyr::filter(year >= first_year, year <= final_year) |>
      dplyr::select(GEOID, county, municipality)
  } else {
    municipalities |>
      dplyr::filter(year >= first_year, year <= final_year) |>
      dplyr::rows_update(
        municipalities |>
          dplyr::filter(geoid_year >= first_year,
                        geoid_year <= final_year) |>
          dplyr::select(GEOID_Y2K, GEOID),
        by = "GEOID_Y2K",
        unmatched = "ignore"
      ) |>
      dplyr::select(GEOID, county, municipality)
  }
}
