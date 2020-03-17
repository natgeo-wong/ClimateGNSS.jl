## DateString Aliasing

yrmo2dir(date::TimeType) = Dates.format(date,dateformat"yyyy/mm")
yrmo2str(date::TimeType) = Dates.format(date,dateformat"yyyymm")
yr2str(date::TimeType)   = Dates.format(date,dateformat"yyyy")
ymd2str(date::TimeType)  = Dates.format(date,dateformat"yyyymmdd")
mo2str(date::TimeType)   = Dates.format(date,dateformat"mm")

yrmo2str(yr::Integer,mo::Integer) = @sprintf("%04d%02d",yr,mo)
mo2str(mo::Integer) = @sprintf("%02d",mo)
dy2str(dy::Integer) = @sprintf("%02d",dy)

function extractdate(startdate::TimeType,finish::TimeType);

    yrs = Dates.year(start);  mos = Dates.month(start);  dys = Dates.day(start);
    yrf = Dates.year(finish); mof = Dates.month(finish); dyf = Dates.day(finish);
    ndy = Dates.value((finish-start)/Dates.day(1));
    dvecs = Date(yrs,mos); dvecf = Date(yrf,mof);

    dvec = convert(Array,dvecs:Month(1):dvecf);

    return dvec,dys,dyf,ndy

end

bold() = Crayon(bold=true)
reset() = Crayon(reset=true)

function real2int16!(
    outarray::Array{Int16}, inarray::Array{<:Real}
)

    if size(outarray) != size(inarray)
        dout = [i for i in size(outarray)];
        din  = [i for i in size(inarray)];
        if (dout[1:end-1] != din[1:end] && dout[1:end] != din[1:end-1]) ||
            prod(dout) != prod(din)
            error("$(Dates.now()) - output array is not of the same size as the input array")
        end
    end

    for ii = 1 : length(inarray)

        inarray[ii] = (inarray[ii] - 0.5) * 65534

        if inarray[ii] < -32767; inarray[ii] = -32768
        elseif inarray[ii] > 32767; inarray[ii] = -32768
        end

        outarray[ii] = round(Int16,inarray[ii])

    end

    return

end
