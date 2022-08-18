#' @export
get_municipalities <- function(year = 2021, geoid_year = year) {
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
