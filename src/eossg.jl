"""
This file contains all the functions that necessary to extract data from GNSS stations that the
Earth Observatory of Singapore (EOS-SG) maintains.

"""

function eosload(reg)

    @info "$(Dates.now()) - Loading information on available GNSS/GPS stations provided by the Earth Observatory of Singapore (EOS-SG)."
    allstn = readdlm(joinpath(@__DIR__,"GNSS-EOS-SG.txt"),',',comments=true);

    @info "$(Dates.now()) - Filtering out for stations in the $(regionfullname(reg)) region."
    lon = allstn[:,2]; lat = allstn[:,3];
    stations = allstn[ispointinregion.(lon,lat,reg),:]; nstns = size(stations,1);

    @info "$(Dates.now()) - There are $(nstns) stations maintained by the Earth Observatory of Singapore (EOS-SG) in the $(regionfullname(reg)) region with Zenith Wet Delay data."

    return stations

end

function eosresortsave(zwd::AbstractArray,sig::AbstractArray,
    info::AbstractArray,yrii::Integer,groot::AbstractString)

    ndays = Dates.daysinyear(yrii); nhours = 144;
    zwd = reshape(zwd,nhours,ndays); sig = reshape(sig,nhours,ndays);

    fnc = "$(info[1])-$(yrii).nc"

    var_zwd = "zwd"; att_zwd = Dict("units" => "m");
    var_sig = "sig"; att_sig = Dict("units" => "m");
    var_lon = "lon"; att_lon = Dict("units" => "degree");
    var_lat = "lat"; att_lat = Dict("units" => "degree");
    var_z   = "z";   att_z   = Dict("units" => "m");

    if isfile(fnc)
        @info "$(Dates.now()) - Unfinished netCDF file $(fnc) detected.  Deleting."
        rm(fnc);
    end

    @info "$(Dates.now()) - Creating GPM Near-RealTime (Late) precipitation netCDF file $(fnc) ..."
    nccreate(fnc,var_zwd,"nhours",nhours,"ndays",ndays,atts=att_zwd,t=NC_FLOAT);
    nccreate(fnc,var_sig,"nhours",nhours,"ndays",ndays,atts=att_sig,t=NC_FLOAT);
    nccreate(fnc,var_lon,atts=att_lon,t=NC_FLOAT);
    nccreate(fnc,var_lat,atts=att_lat,t=NC_FLOAT);
    nccreate(fnc,var_z,atts=att_z,t=NC_FLOAT);

    @info "$(Dates.now()) - Saving GNSS Zenith Wet Delay data to netCDF file $(fnc) ..."
    ncwrite(zwd,fnc,var_zwd);
    ncwrite(sig,fnc,var_sig);
    ncwrite([info[2]],fnc,var_lon);
    ncwrite([info[3]],fnc,var_lat);
    ncwrite([info[4]],fnc,var_z);

    @debug "$(Dates.now()) - NetCDF.jl's ncread causes memory leakage.  Using ncclose() as a workaround."
    ncclose()

    gfol = joinpath(groot,info[1]);
    @info "$(Dates.now()) - Moving $(fnc) to data directory $(gfol)"

    if isfile(joinpath(gfol,fnc)); @info "$(Dates.now()) - An older version of $(fnc) exists in the $(gfol) directory.  Overwriting." end

    mv(fnc,joinpath(gfol,fnc),force=true);

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
