test_that("counties covers all 21 NJ counties, once each", {
  expect_equal(nrow(counties), 21)
  expect_named(counties, c("GEOID", "county"))
  expect_equal(anyDuplicated(counties$GEOID), 0L)
  expect_equal(anyDuplicated(counties$county), 0L)
})

test_that("county GEOIDs are 5-digit NJ FIPS codes held as character", {
  expect_type(counties$GEOID, "character")
  expect_true(all(grepl("^34[0-9]{3}$", counties$GEOID)))
})

test_that("county names are all of the form '<name> County'", {
  expect_type(counties$county, "character")
  expect_true(all(grepl(" County$", counties$county)))
})

test_that("every county has municipalities, and every municipality a county", {
  expect_setequal(unique(get_municipalities()$county), counties$county)
  expect_setequal(unique(get_municipalities(2000)$county), counties$county)
})

test_that("a municipality GEOID extends the GEOID of its county", {
  muni <- get_municipalities()
  expect_true(all(nchar(muni$GEOID) == 10))
  prefix <- substr(muni$GEOID, 1, 5)
  expect_true(all(prefix %in% counties$GEOID))
  # the county column must agree with the county the GEOID prefix names
  expect_identical(counties$county[match(prefix, counties$GEOID)], muni$county)
})
