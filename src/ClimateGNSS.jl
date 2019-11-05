module ClimateGNSS

# Main file for the ClimateERA module that downloads and processes ECMWF
# reanalysis data.

## Modules Used
using Dates, DelimitedFiles, Printf
using NetCDF, Glob, JLD2, FileIO
using ClimateEasy

## Exporting the following functions:
#export
#        fun

## Including other files in the module

include("startup.jl")

end # module
