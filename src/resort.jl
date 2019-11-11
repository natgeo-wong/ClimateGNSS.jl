"""
Dump all the resort scripts here.  Currently supports:
    - EOS-SG
    - NGL-UNAVCO
"""

function gnssfol(groot::AbstractString,stationname::AbstractString)
    gfol = joinpath(groot,fol)
    if !isdir(gfol)
        @info "$(Dates.now()) - GNSS Zenith Wet Delay data directory for $(fol) does not exist."
        @info "$(Dates.now()) - Creating data directory $(gfol)."; mkpath(gfol);
    end
    return gfol
end

function eosresort(stations::AbstractArray,groot::Dict)

    for ii = 1 : size(stations,1)

        fraw  = joinpath(groot["raw"],"$(stations[ii,1]).tdpzwd");
        info  = stations[ii,:];

        @info "$(Dates.now()) - Available data from $(stations[ii,1]) GNSS station will be extracted from file $(fraw)."
        gdata = readdlm(fraw,Any,comments=true);

        @info "$(Dates.now()) - Converting J2000 seconds data into Julia DateTime format ..."
        gdata[:,2] .= DateTime(2000,1,1,12,0,0) + Second.(gdata[:,2]);
        yr = Dates.year.(gdata[:,2]); yrbeg = minimum(yr); yrend = maximum(yr);

        @info "$(Dates.now()) - Extracting Zenith Wet Delay data from the GNSS station $(stations[ii,1]) ..."
        for yrii = yrbeg : yrend
            zwd,sig = eosextractyear(gdata,info,yr,yrii);
            eosresortsave(zwd,sig,info,yrii,groot["data"]);
        end
        @info "$(Dates.now()) - Zenith Wet Delay data from the GNSS station $(stations[ii,1]) has been extracted and saved into yearly NetCDF files."

    end

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
