test_that("get_municipalities handles bad year", {
  expect_error(get_municipalities(1999))
  expect_error(get_municipalities(2026))
})

test_that("get_municipalities handles bad reference year", {
  expect_error(get_municipalities(2010, 1999))
  expect_error(get_municipalities(2010, 2026))
})

test_that("get_municipalities rejects years that are not a single number", {
  expect_error(get_municipalities(c(2000, 2001)), "single year")
  expect_error(get_municipalities(integer(0)), "single year")
  expect_error(get_municipalities(NA), "must be numeric")
  expect_error(get_municipalities("2005"), "must be numeric")
  expect_error(get_municipalities(2005, c(2000, 2001)), "single year")
  expect_error(get_municipalities(2005, NA), "must be numeric")
})

test_that("get_geoid_cross_references validates its year arguments", {
  expect_error(get_geoid_cross_references(c(2000, 2001), 2010), "single year")
  expect_error(get_geoid_cross_references("2010", 2011), "must be numeric")
  expect_error(get_geoid_cross_references(2010, integer(0)), "at least one year")
  expect_error(get_geoid_cross_references(2010, NA), "must be numeric")
  expect_error(get_geoid_cross_references(2010, c(2011, NA)), "years = NA")
})

test_that("bad-year messages name the offending years", {
  expect_error(get_municipalities(1999), "for year = 1999")
  expect_error(get_municipalities(2010, 2026), "for geoid_year = 2026")
  expect_error(get_geoid_cross_references(1999, 2010), "for reference_year = 1999")
  expect_error(get_geoid_cross_references(2010, c(1998, 1999, 2011)),
               "for years = 1998 1999")
})


test_that("get_municipalities returns the correct table size", {
  muni_2000 <- get_municipalities(2000)
  muni_2012 <- get_municipalities(2012)
  muni_2013 <- get_municipalities(2013) # The year princeton township disappeared
  muni_2021 <- get_municipalities(2021)
  muni_2022 <- get_municipalities(2022) # The year pine valley disappeared
  expect_equal(nrow(muni_2000), 566)
  expect_equal(nrow(muni_2012), 566)
  expect_equal(nrow(muni_2013), 565)
  expect_equal(nrow(muni_2021), 565)
  expect_equal(nrow(muni_2022), 564)
})

test_that("get_municipalities handles Caldwell", {
  old_geoid <- "3401309220"
  new_geoid <- "3401309250"
  muni_2009 <- get_municipalities(2009) %>% dplyr::pull(GEOID)
  muni_2010 <- get_municipalities(2010) %>% dplyr::pull(GEOID)
  expect_true( old_geoid %in% muni_2009 )
  expect_false( new_geoid %in% muni_2009 )
  expect_false( old_geoid %in% muni_2010 )
  expect_true( new_geoid %in% muni_2010 )
})

test_that("get_municipalities handles Princeton", {
  twp_geoid <- "3402160915"
  boro_geoid <- "3402160900"
  muni_2012 <- get_municipalities(2012) %>% dplyr::pull(GEOID)
  muni_2013 <- get_municipalities(2013) %>% dplyr::pull(GEOID)
  expect_true( twp_geoid %in% muni_2012 )
  expect_true( boro_geoid %in% muni_2012 )
  expect_false( twp_geoid %in% muni_2013 )
  expect_true( boro_geoid %in% muni_2013 )
})

test_that("get_municipalities handles Pine Valley", {
  pv_geod <- "3400758920"
  muni_2021 <- get_municipalities(2021) %>% dplyr::pull(GEOID)
  muni_2022 <- get_municipalities(2022) %>% dplyr::pull(GEOID)
  expect_true( pv_geod %in% muni_2021 )
  expect_false( pv_geod %in% muni_2022 )
})

test_that("get_municipalities handles reference year in past", {
  muni_2021_2000 <- get_municipalities(2021, geoid_year = 2000)
  muni_2021_2021 <- get_municipalities(2021, geoid_year = 2021)

  diff_2000 <- tibble::tribble(
    ~GEOID,       ~county,          ~municipality,
    "3401309220", "Essex County"    ,"Caldwell borough",
    "3402177210", "Mercer County"   ,"Robbinsville township",
    "3402568670", "Monmouth County" ,"Lake Como borough",
    "3402918130", "Ocean County"    ,"Toms River township",
    "3403179820", "Passaic County"  ,"Woodland Park borough",
  )

  diff_2021 <- tibble::tribble(
    ~GEOID,       ~county,           ~municipality,
    "3401309250", "Essex County",    "Caldwell borough"     ,
    "3402163850", "Mercer County",   "Robbinsville township"  ,
    "3402537560", "Monmouth County", "Lake Como borough" ,
    "3402973125", "Ocean County",    "Toms River township"       ,
    "3403182423", "Passaic County",  "Woodland Park borough",
  )

  expect_identical(
    dplyr::anti_join(muni_2021_2000, muni_2021_2021),
    diff_2000
  )
  expect_identical(
    dplyr::anti_join(muni_2021_2021, muni_2021_2000),
    diff_2021
  )
})

test_that("get_municipalities handles reference year in future", {
  muni_2000_2021 <- get_municipalities(2000, geoid_year = 2021)
  muni_2000_2000 <- get_municipalities(2000, geoid_year = 2000)

  diff_2000 <- tibble::tribble(
    ~GEOID,       ~county,          ~municipality,
    "3401309220", "Essex County"    ,"Caldwell borough",
    "3402160915", "Mercer County"   ,"Princeton township",
    "3402177210", "Mercer County"   ,"Washington township",
    "3402568670", "Monmouth County" ,"South Belmar borough",
    "3402918130", "Ocean County"    ,"Dover township",
    "3403179820", "Passaic County"  ,"West Paterson borough",
  )

  diff_2021 <- tibble::tribble(
    ~GEOID,       ~county,           ~municipality,
    "3401309250", "Essex County",    "Caldwell borough"     ,
    NA,           "Mercer County",   "Princeton township"   ,
    "3402163850", "Mercer County",   "Washington township"  ,
    "3402537560", "Monmouth County", "South Belmar borough" ,
    "3402973125", "Ocean County",    "Dover township"       ,
    "3403182423", "Passaic County",  "West Paterson borough",
  )

  expect_identical(
    dplyr::anti_join(muni_2000_2021, muni_2000_2000),
    diff_2021
  )
  expect_identical(
    dplyr::anti_join(muni_2000_2000, muni_2000_2021),
    diff_2000
  )
})

test_that("get_municipalities handles geoid_ref_as_ref_column", {
  muni_2021_2000_as_ref <- get_municipalities(2021, 2000,
                                              geoid_ref_as_ref_column = TRUE)
  expect_equal(
    nrow(muni_2021_2000_as_ref %>% dplyr::filter(GEOID_ref != GEOID)),
    5
  )
  expect_equal(
    nrow(muni_2021_2000_as_ref |> dplyr::filter(is.na(GEOID_ref))),
    0
  )

  muni_2000_2021_as_ref <- get_municipalities(2000, 2021,
                                              geoid_ref_as_ref_column = TRUE)
  expect_equal(
    nrow(muni_2000_2021_as_ref |> dplyr::filter(GEOID_ref != GEOID)),
    5
  )
  expect_equal(
    nrow(muni_2000_2021_as_ref |> dplyr::filter(is.na(GEOID_ref))),
    1
  )

})

test_that("get_geoid_cross_references handles bad years", {
  expect_error(get_geoid_cross_references(2000, 1999:2021))
  expect_error(get_geoid_cross_references(2000, 2000:2026))
})

test_that("get_geoid_cross_references handles bad reference year", {
  expect_error(get_geoid_cross_references(1999, 2010))
  expect_error(get_geoid_cross_references(2026, 2010))
})


test_that("get_geoid_cross_references handles reference in the past", {
  muni_2020_2000 <- get_municipalities(2020, 2000,
                                       geoid_ref_as_ref_column = TRUE)
  xref_2020_2000 <- get_geoid_cross_references(2000, 2020)

  expect_equal(nrow(dplyr::anti_join(muni_2020_2000, xref_2020_2000)), 0)
  expect_equal(nrow(dplyr::anti_join(xref_2020_2000, muni_2020_2000)), 0)
})

test_that("get_geoid_cross_references handles reference in the future", {
  muni_2000_2020 <- get_municipalities(2000, 2020,
                                       geoid_ref_as_ref_column = TRUE)
  xref_2000_2020 <- get_geoid_cross_references(2020, 2000)

  expect_equal(nrow(dplyr::anti_join(muni_2000_2020, xref_2000_2020)), 0)
  expect_equal(nrow(dplyr::anti_join(xref_2000_2020, muni_2000_2020)), 0)
})
