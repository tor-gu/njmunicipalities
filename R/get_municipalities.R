MIN_YEAR <- 2000
MAX_YEAR <- 2025

#' Internal function check_year_
#'
#' Stop unless `year` is a single year within the range covered by this
#' package. Without this check, a vector, NA or character year reaches
#' `if` or `dplyr::between` and fails with an opaque message.
#' @param year Year
#' @param argument Name of the argument being checked, used in the error message
check_year_ <- function(year, argument) {
  if (!is.numeric(year)) {
    stop("`", argument, "` must be numeric, not ", class(year)[[1L]])
  }
  if (length(year) != 1L) {
    stop("`", argument, "` must be a single year, not ", length(year), " values")
  }
  if (is.na(year) || !dplyr::between(year, MIN_YEAR, MAX_YEAR)) {
    stop("Cannot return municipalities for ", argument, " = ", year)
  }
  invisible(year)
}

#' Internal function check_years_
#'
#' Stop unless `years` is a non-empty vector of years within the range
#' covered by this package. The error names up to five offending years.
#' @param years Years
check_years_ <- function(years) {
  if (!is.numeric(years)) {
    stop("`years` must be numeric, not ", class(years)[[1L]])
  }
  if (length(years) == 0L) {
    stop("`years` must contain at least one year")
  }
  bad <- years[is.na(years) | !dplyr::between(years, MIN_YEAR, MAX_YEAR)]
  if (length(bad)) {
    stop("Cannot return municipalities for years = ",
         stringr::str_c(utils::head(bad, 5), collapse = " "))
  }
  invisible(years)
}

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
#' @param year The year, from 2000 to 2025. The default is 2025.
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
  check_year_(year, "year")
  check_year_(geoid_year, "geoid_year")
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
  check_year_(reference_year, "reference_year")
  check_years_(years)

  years |> unique() |>
    purrr::set_names() |>
    purrr::map(get_municipalities_, geoid_reference_year = reference_year) |>
    purrr::map(dplyr::select, GEOID_ref, GEOID) |>
    dplyr::bind_rows(.id = "year") |>
    dplyr::mutate(year = as.integer(year))
}


