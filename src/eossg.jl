"""
This file contains all the functions that necessary to extract data from GNSS stations that the
Earth Observatory of Singapore (EOS-SG) maintains.

"""

function eosload(reg)

    @info "$(Dates.now()) - Loading information on available GNSS/GPS stations provided by the Earth Observatory of Singapore (EOS-SG)."
    allstn = readdlm(joinpath(@__DIR__,"../data/GNSS-EOS-SG.txt"),',',comments=true);

    @info "$(Dates.now()) - Filtering out for stations in the $(regionfullname(reg)) region."
    lon = allstn[:,2]; lat = allstn[:,3];
    stations = allstn[ispointinregion.(lon,lat,reg),:]; nstns = size(stations,1);

    @info "$(Dates.now()) - There are $(nstns) stations maintained by the Earth Observatory of Singapore (EOS-SG) in the $(regionfullname(reg)) region with Zenith Wet Delay data."

    return stations

end

function eosloadstation(name::AbstractString)

    @info "$(Dates.now()) - Loading information on available GNSS/GPS stations provided by the Earth Observatory of Singapore (EOS-SG)."
    allstn = readdlm(joinpath(@__DIR__,"GNSS-EOS-SG.txt"),',',comments=true);

    @info "$(Dates.now()) - Finding information for station $(name)."
    allnames = allstn[:,1]; stnID = (allnames .== name);
    return allstn[stnID,:]

end

function eosresortsave(zwd::AbstractArray,sig::AbstractArray,
    info::AbstractArray,yrii::Integer,groot::AbstractString)

    ndays = Dates.daysinyear(yrii); nhours = 144;
    zwd = reshape(zwd,nhours,ndays); sig = reshape(sig,nhours,ndays);

    gfol = gnssfol(groot,info[1]); fnc = joinpath(gfol,"$(info[1])-$(yrii).nc");
    if isfile(fnc)
        @info "$(Dates.now()) - Unfinished netCDF file $(fnc) detected.  Deleting."
        rm(fnc);
    end
    
    ds = Dataset(fnc,"c");
    ds.dim["hour_of_day"] = nhours; ds.dim["day_of_month"] = nlat;

    att_zwd = Dict("units"=>"m","standard_name"=>"zenith_wet_delay",
                   "long_name"=>"Zenith Wet Delay",
                   "scale_factor"=>1/65534,"add_offset"=>0.5,
                   "missing_value"=-32768);
    att_sig = Dict("units"=>"m","standard_name"=>"zenith_wet_delay_error",
                   "long_name"=>"Zenith Wet Delay Uncertainty",
                   "scale_factor"=>0.005/65534,"add_offset"=>0.0025,
                   "missing_value"=-32768);
    att_lon = Dict("units"=>"degrees_east","long_name"=>"longitude");
    att_lat = Dict("units"=>"degrees_north","long_name"=>"latitude");
    att_z   = Dict("units"=>"m","standard_name"=>"height_above_WGS84_surface",
                   "long_name"=>"Orographic Height");

    @info "$(Dates.now()) - Creating GNSS Zenith Wet Delay netCDF file $(fnc) ..."

    vzwd = defVar(ds,"zwd",Int16,("hour_of_day","day_of_month"),attrib=att_zwd);
    vsig = defVar(ds,"sig",Int16,("hour_of_day","day_of_month"),attrib=att_sig);
    vzwd.var[:] = zwd; vsig.var[:] = sig;

    defVar(ds,"longitude",info[2],attrib=att_lon);
    defVar(ds,"latitude",info[3],attrib=att_lat);
    defVar(ds,"z",info[4],attrib=att_z);

    close(ds);

    @info "$(Dates.now()) - Zenith Wet Delay data for $(info[1]) has been saved into file $(fnc)."

end

function eosextractyear(gnssdata::AbstractArray,info::AbstractArray,
    yrArray::AbstractArray,yrii::Integer)

    yrdates = convert(Array,DateTime(yrii,1,1):Minute(10):DateTime(yrii+1,1,1)); pop!(yrdates);

    @debug "$(Dates.now()) - Extracting GNSS Zenith Wet Delay data for Year $(yrii) ..."
    gnssdata = gnssdata[findall(isequal(yrii),yrArray),:];
    zwd = zeros(size(yrdates)); sig = zeros(size(yrdates)); ei = 0;

    for ti = 1 : size(yrdates,1)
        try jj = findfirst(isequal(yrdates[ti]),gnssdata[:,2])
               zwd[ti] = gnssdata[jj,3]; sig[ti] = gnssdata[jj,4]
        catch; zwd[ti] = NaN; sig[ti] = NaN; ei = ei + 1;
        end
    end

    @debug "$(Dates.now()) - There are $(ei) entries without any valid data for Year $(yrii)."
    return zwd,sig

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
