"""
This file istarts the ClimateGNSS module by creating the root directory and by
specifying whether the data is to be downloaded or analyzed.  Functionalities
include:
    - Creation of root directory

"""

function gnssroot(dataID::AbstractString)

    path = joinpath("$(homedir())","research","data","GNSS-$(dataID)");
    @warn "$(Dates.now()) - No directory path was given.  Setting to default path: $(path) for ClimateGNSS data downloads."

    if isdir(path)
        @info "$(Dates.now()) - The default path $(path) exists and therefore can be used as a directory for ClimateGNSS data download and analysis from $(dataID)."
    else
        if dataID == "EOS-SG"
            error("$(Dates.now()) - The path $(path) does not exist.  Since you are using EOS-SG GNSS data, please move the data to this directory first before proceeding further.")
        else
            @warn "$(Dates.now()) - The path $(path) does not exist.  A new directory will be created here.  Therefore if you have already uploaded the data, make sure that $(path) is the correct location."
            @info "$(Dates.now()) - Creating path $(path) to hold GNSS data."
            mkpath(path)
        end
    end

    return Dict("raw"=>joinpath(path,"raw"),
                "data"=>joinpath(path,"data"),
                "ana"=>joinpath(path,"ana"));

end

function gnssroot(path::AbstractString,dataID::AbstractString)

    path = joinpath(path,"GNSS-$(dataID)");

    if isdir(path)
        @info "$(Dates.now()) - The directory $(path) exists and therefore can be used for ClimateGNSS data download and analysis from $(dataID)."
    else
        if dataID == "EOS-SG"
            error("$(Dates.now()) - The path $(path) does not exist.  Since you are using EOS-SG GNSS data, please move the data to this directory first before proceeding further.")
        else
            @warn "$(Dates.now()) - The path $(path) does not exist.  A new directory will be created here.  Therefore if you have already uploaded the data, make sure that $(path) is the correct location."
            @info "$(Dates.now()) - Creating path $(path) to hold GNSS data."
            mkpath(path)
        end
    end

    return Dict("raw"=>joinpath(path,"raw"),
                "data"=>joinpath(path,"data"),
                "ana"=>joinpath(path,"ana"));

end
