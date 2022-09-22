module GeniePackageManager

using Genie
using Genie.Renderer.Json
using Pkg
using TOML

function install(dest::String; force = false)
  src = abspath(normpath(joinpath(@__DIR__, "..", Genie.Plugins.FILES_FOLDER)))

  for f in readdir(src)
    isdir(f) || continue
    Genie.Plugins.install(joinpath(src, f), dest, force = force)
  end
end

function list_packages()
  deps = Pkg.dependencies()
  installs = Dict{String, VersionNumber}()
  for (uuid, dep) in deps
    dep.is_direct_dep || continue
    dep.version === nothing && continue
    installs[dep.name] = dep.version
  end
  return installs |> json
end

function add()
  package = params(:package)
  Pkg.add(package)
end

function remove_package()
  package = params(:package)
  Pkg.rm(package)
end

end # module GeniePackageManager
