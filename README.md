
<!-- README.md is generated from README.Rmd. Please edit that file -->

# njmunicipalities

<!-- badges: start -->

[![R-CMD-check](https://github.com/tor-gu/njmunicipalities/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/tor-gu/njmunicipalities/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

This is a data package for R that contains every county and municipality
in New Jersey, from 2000 to 2025.

## Installation

You can install the development version of njmunicipalities from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("tor-gu/njmunicipalities")
```

## Changes in NJ municipalites, 2000-2025

Over the period 2000-2025, there have been several changes to the list
of municipalities in New Jersey:

- In 2005, South Belmar became Lake Como. The US Census assigned a new
  GEOID to Lake Como.
- In 2007, Dover township in Ocean County became Toms River and was
  assigned a new GEOID.
- In 2008, Washington township in Mercer County became Robbinsville
  township and was assigned a new GEOID.
- In 2009, West Paterson became Woodland Park, and was assigned a new
  GEOID.
- In 2010, Caldwell borough was assigned a new GEOID from the the US
  Census, though there was no name change at this time.
- In 2013, Princeton borough and Princeton township merged. The merged
  municipality retained the Princeton borough GEOID, though the US
  Census started using the name ‘Princeton’ in place of ‘Princeton
  borough’ for the merged municipality.
- In 2022, Pine Valley was absorbed by Pine Hill.

This package will return municipality tables for any year from 2000 to
2025, and provides tools for dealing the changes from year to year.

## Examples

#### Get a table of municipalities

Function `get_municipalities` returns a table of municipalities for a
given year. The default is year 2025.

``` r
library(njmunicipalities)

# Municipality table for 2025
get_municipalities() |> head(n=5)
#> # A tibble: 5 × 3
#>   GEOID      county          municipality        
#>   <chr>      <chr>           <chr>               
#> 1 3400100100 Atlantic County Absecon city        
#> 2 3400102080 Atlantic County Atlantic City city  
#> 3 3400107810 Atlantic County Brigantine city     
#> 4 3400108680 Atlantic County Buena borough       
#> 5 3400108710 Atlantic County Buena Vista township
```

If the year is specified (from 2000 to 2025), the table will reflect the
names and US Census GEOIDs in effect for that year. Here is the list for
2007.

``` r
# Municipality list for 2007
get_municipalities(2007) |> head(n=5)
#> # A tibble: 5 × 3
#>   GEOID      county          municipality        
#>   <chr>      <chr>           <chr>               
#> 1 3400100100 Atlantic County Absecon city        
#> 2 3400102080 Atlantic County Atlantic City city  
#> 3 3400107810 Atlantic County Brigantine city     
#> 4 3400108680 Atlantic County Buena borough       
#> 5 3400108710 Atlantic County Buena Vista township
```

#### Get a table of municipalities for one year with GEOIDs from another

If the optional parameter `geoid_year` is included, the GEOIDs in the
returned table will be the ones in effect for that year. For example, to
get a municipality list with municipal names effective 2002 and GEOIDs
effective 2018:

``` r
# Municipality list for 2002 with GEOIDs from 2018
get_municipalities(2002, geoid_year = 2018) |> head(n=5)
#> # A tibble: 5 × 3
#>   GEOID      county          municipality        
#>   <chr>      <chr>           <chr>               
#> 1 3400100100 Atlantic County Absecon city        
#> 2 3400102080 Atlantic County Atlantic City city  
#> 3 3400107810 Atlantic County Brigantine city     
#> 4 3400108680 Atlantic County Buena borough       
#> 5 3400108710 Atlantic County Buena Vista township
```

If you need both GEOIDs, specify `geoid_ref_as_ref_column = TRUE`. This
will cause the GEOIDs from `geoid_year` to be returned as a separate
column (instead of replacing the `GEOID`).

``` r
# Municipality list for 2002 with GEOIDs from 2018 added as
# separate column
get_municipalities(2002, 
                   geoid_year = 2018, 
                   geoid_ref_as_ref_column = TRUE) |> 
  head(n=5)
#> # A tibble: 5 × 4
#>   GEOID_ref  GEOID      county          municipality        
#>   <chr>      <chr>      <chr>           <chr>               
#> 1 3400100100 3400100100 Atlantic County Absecon city        
#> 2 3400102080 3400102080 Atlantic County Atlantic City city  
#> 3 3400107810 3400107810 Atlantic County Brigantine city     
#> 4 3400108680 3400108680 Atlantic County Buena borough       
#> 5 3400108710 3400108710 Atlantic County Buena Vista township
```

As an illustration, consider Lake Como, which was known as “South
Belmar” before 2005, when it also had a different GEOID. We can see that
it appears as a “new” municipality in the 2005 list:

``` r
# Lake Como is the only 'new' municipality in 2005
dplyr::anti_join(
  get_municipalities(2005),
  get_municipalities(2004)
)
#> Joining with `by = join_by(GEOID, county, municipality)`
#> # A tibble: 1 × 3
#>   GEOID      county          municipality     
#>   <chr>      <chr>           <chr>            
#> 1 3402537560 Monmouth County Lake Como borough
```

If we want to see the old name and GEOID, we can include the 2004 GEOID
in the 2005 table and then join with the 2004 table:

``` r
# Differences between 2005 and 2004
get_municipalities(2005, 
                   geoid_year = 2004, 
                   geoid_ref_as_ref_column = TRUE) |>
  dplyr::anti_join(get_municipalities(2004)) |>
  dplyr::left_join(get_municipalities(2004), 
                   by = c("GEOID_ref" = "GEOID", "county"),
                   suffix = c("", "_ref"))
#> Joining with `by = join_by(GEOID, county, municipality)`
#> # A tibble: 1 × 5
#>   GEOID_ref  GEOID      county          municipality      municipality_ref    
#>   <chr>      <chr>      <chr>           <chr>             <chr>               
#> 1 3402568670 3402537560 Monmouth County Lake Como borough South Belmar borough
```

#### Generating GEOID cross reference tables

Function `get_geoid_cross_references` will return a table of `GEOID`
cross-references for a range of years to a specified reference year.
Here we map all the GEOIDs from the years 2010-2020 to their 2005 GEOID.

``` r
# Cross reference table, comparing GEOID for years 2010-2020 to 
# reference year 2005
get_geoid_cross_references(2005, 2010:2020) |>
  dplyr::arrange(GEOID_ref, year) |> 
  head(n=5)
#> # A tibble: 5 × 3
#>    year GEOID_ref  GEOID     
#>   <int> <chr>      <chr>     
#> 1  2010 3400100100 3400100100
#> 2  2011 3400100100 3400100100
#> 3  2012 3400100100 3400100100
#> 4  2013 3400100100 3400100100
#> 5  2014 3400100100 3400100100
```

#### Dealing with the Princetons

Princeton township and Princeton borough merged in 2013. Because the
merged municipality retained Princeton borough’s GEOID, Princeton
township disappears in 2013. This is one of two examples of a
disappearing municipality in the package (see [Dealing with Pine Valley
and Pine Hill](#dealing-with-pine-valley-and-pine-hill)).

The functions `get_municipality` and `get_geoid_cross_references` will
return `NA` for a reference year GEOID after 2012 for Princeton
township:

``` r
# Princeton township existed in 2000 but not 2021
get_municipalities(2000, geoid_year = 2021) |>
  dplyr::filter(is.na(GEOID))
#> # A tibble: 1 × 3
#>   GEOID county        municipality      
#>   <chr> <chr>         <chr>             
#> 1 <NA>  Mercer County Princeton township
```

For convenience in dealing with this issue, this package includes the
constants `PRINCETON_TWP_GEOID` and `PRINCETON_BORO_GEOID`.

``` r
c(PRINCETON_TWP_GEOID, PRINCETON_BORO_GEOID)
#> [1] "3402160915" "3402160900"
```

As an example, consider the municipal election data in
[`njelections`](https://github.com/tor-gu/njelections). For comparisons
across years, we may wish to combine the vote totals for the Princetons
prior to 2013:

``` r
library(njelections)
election_by_municipality_combined <-
  election_by_municipality |>
  dplyr::mutate(GEOID = dplyr::if_else(GEOID == PRINCETON_TWP_GEOID,
                                       PRINCETON_BORO_GEOID,
                                       GEOID)) |>
  dplyr::group_by(year, office, GEOID, party) |>
  dplyr::summarize(vote = sum(vote), .groups = "drop")

election_by_municipality_combined |> 
  dplyr::filter(GEOID %in% c(PRINCETON_TWP_GEOID, PRINCETON_BORO_GEOID)) |>
  head(5)
#> # A tibble: 5 × 5
#>    year office    GEOID      party               vote
#>   <int> <chr>     <chr>      <chr>              <int>
#> 1  2004 President 3402160900 Constitution Party     5
#> 2  2004 President 3402160900 Democratic          9751
#> 3  2004 President 3402160900 Green Party           12
#> 4  2004 President 3402160900 Independent          111
#> 5  2004 President 3402160900 Libertarian Party     40
```

#### Dealing with Pine Valley and Pine Hill

In 2022, Pine Valley borough was merged into Pine Hill borough.

The functions `get_municipality` and `get_geoid_cross_references` will
return `NA` for a reference year GEOID after 2021 for Pine Valley:

``` r
# Pine Valley existed in 2021 but not 2022
get_municipalities(2021, geoid_year = 2022) |>
  dplyr::filter(is.na(GEOID))
#> # A tibble: 1 × 3
#>   GEOID county        municipality       
#>   <chr> <chr>         <chr>              
#> 1 <NA>  Camden County Pine Valley borough
```

For convenience in dealing with this issue, this package includes
constants `PINE_VALLEY_BORO_GEOID` and `PINE_HILL_BORO_GEOID`.

``` r
c(PINE_VALLEY_BORO_GEOID, PINE_HILL_BORO_GEOID)
#> [1] "3400758920" "3400758770"
```

#### County list

For convenience, this package also includes a table of counties and
their GEOIDS. There have been no changes to New Jersey counties from
2000 to 2025.

``` r
# County list
counties |> head(n=5)
#> # A tibble: 5 × 2
#>   GEOID county           
#>   <chr> <chr>            
#> 1 34001 Atlantic County  
#> 2 34003 Bergen County    
#> 3 34005 Burlington County
#> 4 34007 Camden County    
#> 5 34009 Cape May County
```
