using BinDeps

@BinDeps.setup

function version_check(name, handle)
    fptr = Libdl.dlsym_e(handle, :GDALVersionInfo)
    if fptr == C_NULL  # lookup failure
        return false
    end
    versionptr = ccall(fptr,Cstring,(Cstring,),"RELEASE_NAME")
    versionstring = unsafe_string(versionptr)
    gdalversion = convert(VersionNumber, versionstring)
    gdalversion >= v"2.1.0"
end

libgdal = library_dependency("libgdal",
                             aliases=["gdal","gdal201", "gdal202",
                             "gdal_w32","gdal_w64","libgdal-20"],
                             validate=version_check)

if is_windows()
    using WinRPM
    push!(WinRPM.sources, "http://download.opensuse.org/repositories/home:yeesian/openSUSE_Leap_42.2")
    WinRPM.update()
    provides(WinRPM.RPM, "gdal", [libgdal], os = :Windows)
end

if is_unix()
    using Conda
    # conda-forge has an up to date gdal recipe
    # https://github.com/conda-forge/gdal-feedstock
    Conda.add_channel("conda-forge")
    ENV["LD_LIBRARY_PATH"]="$(Pkg.dir())/Conda/deps/usr/lib"
    provides(Conda.Manager, "libgdal", libgdal)
end

@BinDeps.install Dict(:libgdal => :libgdal)
