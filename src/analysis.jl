"""
This file initializes the ClimateERA module by setting and determining the
ECMWF reanalysis parameters to be analyzed and the regions upon which the data
are to be extracted from.  Functionalities include:
    - Setting up of reanalysis module type
    - Setting up of reanalysis parameters to be analyzed
    - Setting up of time steps upon which data are to be downloaded
    - Setting up of region of analysis based on ClimateEasy

"""

function gnssancread(fnc::AbstractArray,epar::Dict,nhr::Integer,ii::Integer,yr::Integer)

    nhr = daysinyear(yr-1) * nhr;

    dyr1 = erancread(fnc[ii],epar); dim = size(dyr1)

    if !(ii==1); d2 = erancread(fnc[ii-1],epar);
    else;        d2 = ones(dim[1],dim[2],nhr) * NaN;
    end

    return cat(d2,d1,dims=3);

end

function gnssancsave(dysm::AbstractArray,ddhr::AbstractArray,dvar::AbstractArray,
                    fnc::AbstractString,nlon::Integer,nlat::Integer,nhr::Integer)

    fnc = replace(fnc,"era"=>"gnssa");
    if isfile(fnc)
       @info "$(Dates.now()) - Unfinished netCDF file $(fnc) detected.  Deleting."
       rm(fnc);
    end

    nccreate(fnc,"longitude")

end
