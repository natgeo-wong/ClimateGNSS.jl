"""
Dump all the resort scripts here.  Currently supports:
    - EOS-SG
    - NGL-UNAVCO
"""

function gnssfol(groot::AbstractString,stationname::AbstractString)
    gfol = joinpath(groot,stationname)
    if !isdir(gfol)
        @info "$(Dates.now()) - GNSS Zenith Wet Delay data directory for $(stationname) does not exist."
        @info "$(Dates.now()) - Creating data directory $(gfol)."; mkpath(gfol);
    end
    return gfol
end

function gnssresort(dataID::AbstractString,region,path::AbstractString)

    groot = gnssroot(path,dataID);
    if dataID == "EOS-SG"
        stations = eosload(region); eosresort(stations,groot);
    #elseif dataID == "NGL-UNAVCO"
    #    stations = nglload(region); nglresort(stations,groot);
    else
        error("$(Dates.now()) - $(dataID) is currently not a data resource supported by ClimateGNSS.jl.  Should you be interested, please consider approaching Nathanael Wong (nathanaelwong@fas.harvard.edu) to contribute to ClimateGNSS.jl and create an additional functionality for $(dataID).")
    end

end
