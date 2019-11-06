"""
This file contains all the functions that necessary to extract data from GNSS stations that the
Earth Observatory of Singapore (EOS-SG) maintains.

"""

function eosload(reg)

    @debug "$(Dates.now()) - Loading information on available GNSS/GPS stations provided by the Earth Observatory of Singapore (EOS-SG)."
    allstn = readdlm(joinpath(@__DIR__,"GNSS-EOS-SG.txt"),',',comments=true);

    @debug "$(Dates.now()) - Filtering out for stations in the $(regionfullname(reg)) region."
    scoord = allstn[:,2:3]; stations = allstn[ispointinregion.(scoord,reg),:]; nstns = size(stn,1);

    @info "$(Dates.now()) - There are $(nstns) stations maintained by the Earth Observatory of Singapore (EOS-SG) in the $(regionfullname(reg)) region with Zenith Wet Delay data."

    return stations

end

function eosresortsave(zwd::AbstractArray,sig::AbstractArray,
    info::AbstractArray,yrii::Integer,root::AbstractString)

    ndays = Dates.daysinyear(dt::TimeType); nhours = 144;
    zwd = reshape(zwd,nhours,ndays); sig = reshape(sig,nhours,ndays);

    fnc = "$(info[1])-$(info[2])-$(yrii).nc"

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

    @info "$(Dates.now()) - Saving GPM Near-RealTime (Late) precipitation data to netCDF file $(fnc) ..."
    ncwrite(zwd,fnc,var_zwd);
    ncwrite(sig,fnc,var_sig);
    ncwrite(lon,fnc,var_lon);
    ncwrite(lat,fnc,var_lat);
    ncwrite(z,fnc,var_z);

    @debug "$(Dates.now()) - NetCDF.jl's ncread causes memory leakage.  Using ncclose() as a workaround."
    ncclose()

end

function eosextractyear(gnssdata::AbstractArray,info::AbstractArray,
    yrArray::AbstractArray,yrii::Integer)

    yrdates = convert(Array,DateTime(yrii,1,1):Minute(10):DateTime(yrii+1,1,1));
    gnssdata = gnssdata[yrArray==yrii,:];
    zwd = zeros(size(yrdates)); sig = zeros(size(yrdates));

    for ti = 1 : size(yrdates,1)
        try jj = findfirst(isequal(yrdates[ti]),gnssdata[:,1])
               zwd[ti] = gnssdata[jj,2]; sig[ti] = gnssdata[jj,3]
        catch; zwd[ti] = NaN; sig[ti] = NaN;
        end
    end

    return zwd,sig

end