"""
This file istarts the ClimateGNSS module by creating the root directory and by
specifying whether the data is to be downloaded or analyzed.  Functionalities
include:
    - Creation of root directory

"""

function gnssroot()

    path = joinpath("$(homedir)","research","data";
    @info "$(Dates.now()) - No directory path was given.  Setting to default path: $(path) for ClimateGNSS data downloads."

    if isdir(path)
        @info "$(Dates.now()) - The default path $(path) exists and therefore can be used as a directory for ClimateGNSS data downloads."
    else
        @warn "$(Dates.now()) - The path $(path) does not exist.  Creating now ..."
        mkpath(path);
    end

    return path

end

function gnssroot(path::AbstractString)
    if isdir(path)
        @info "$(Dates.now()) - The path $(path) exists and therefore can be used as a directory for ClimateGNSS data downloads."
    end
    return path
end
