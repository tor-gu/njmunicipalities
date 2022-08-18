
<!-- README.md is generated from README.Rmd. Please edit that file -->

# njmunicipalities

<!-- badges: start -->

[![R-CMD-check](https://github.com/tor-gu/njoaguof/workflows/R-CMD-check/badge.svg)](https://github.com/tor-gu/njoaguof/actions)
<!-- badges: end -->

This is a data package for R that contains every every county and
municipality in New Jersey, from 2000 to 2021.

## Installation

You can install the development version of njmunicipalities from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("tor-gu/njmunicipalities")
```

## Example

``` r
library(njmunicipalities)
# Municipality list for 2007
#get_municipalities(2007)

# County list
head(counties, n=3)
#>   GEOID            County
#> 1 34001   Atlantic County
#> 2 34003     Bergen County
#> 3 34005 Burlington County
```

## Changes in NJ municipalites, 2000-2021

Over the period 2000-2021, there have been several changes to the list
of municipalities in New Jersey:

-   In 2005, South Belmar became Lake Como. The US Census assigned a new
    GEOID to Lake Como.
-   In 2007, Dover township in Ocean County became Toms River and was
    assigned a new GEOID.
-   In 2008, Washington township in Mercer County became Robbinsville
    township and was assigned a new GEOID.
-   In 2009, West Paterson became Woodland Park, and was assigned a new
    GEOID.
-   In 2010, Caldwell borough was assigned a new GEOID from the the US
    Census, though there was no name change at this time.
-   In 2013, Princeton borough and Princeton township merged. The merged
    municipality retained the Princeton borough GEOID, though the US
    Census started using the name ‘Princeton’ in place of ‘Princeton
    borough’ for the merged municipality.