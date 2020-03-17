module ClimateGNSS

# Main file for the ClimateERA module that downloads and processes ECMWF
# reanalysis data.

## Modules Used
using Dates, DelimitedFiles, Printf
using NCDatasets
using GeoRegions

## Exporting the following functions:
export
        gnssroot, gnssresort, gnssanalysis, gnssfol,
        eosload, eosloadstation

## Including other files in the module

include("startup.jl")
include("resort.jl")
#include("analysis.jl")
include("eossg.jl")
#include("nglunavco.jl")

end # module
