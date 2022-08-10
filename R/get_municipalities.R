#' @export
get_municipalities <- function(year = 2021, geoid_year = year) {
  if (year == geoid_year) {
    municipalities |>
      dplyr::filter(year >= FirstYear, year <= FinalYear) |>
      dplyr::select(GEOID, County, Municipality)
  } else {
    municipalities |>
      dplyr::filter(year >= FirstYear, year <= FinalYear) |>
      dplyr::rows_update(
        municipalities |>
          dplyr::filter(geoid_year >= FirstYear,
                        geoid_year <= FinalYear) |>
          dplyr::select(GEOID_Y2K, GEOID),
        by = "GEOID_Y2K",
        unmatched = "ignore"
      ) |>
      dplyr::select(GEOID, County, Municipality)
  }
}
