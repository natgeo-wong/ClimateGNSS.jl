"""
Dump all the resort scripts here.  Currently supports:
    - EOS-SG
    - NGL-UNAVCO
"""

function eosresort(stations::AbstractArray,groot::Dict)

    for ii = 1 : size(stations,1)

        fraw  = joinpath(groot["raw"],stations[ii,1],"$(stations[ii,2]).tdpzwd");
        info  = stations[ii,:];
        gdata = readdlm(fraw,Float64,comments=true); gdata = gdata[:,2:end];
        gdata[:,2] = DateTime(2000,1,1,12,0,0) + Millisecond.(gdata[:,2]);
        yr = Dates.year.(gdata[:,2]);

        for yrii = yrbeg : yrend
            zwd,sig = eosextractyear(gdata,info,yr,yrii);
            eosresortsave(zwd,sig,stationinfo,yrii,groot["data"]);
        end

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
