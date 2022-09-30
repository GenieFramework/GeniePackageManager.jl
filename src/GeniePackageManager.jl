module GeniePackageManager

using Genie
using GeniePlugins
using Genie.Renderer.Json
using Genie.HTTPUtils.HTTP
using Pkg
using TOML
using Random

const PKGLISTURL = "https://raw.githubusercontent.com/JuliaRegistries/General/master/Registry.toml"

function install(dest::String; force = false)
  src = abspath(normpath(joinpath(@__DIR__, "..", GeniePlugins.FILES_FOLDER)))

  for f in readdir(src)
    isdir(f) || continue
    GeniePlugins.install(joinpath(src, f), dest, force = force)
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

function get_packages() :: Dict{String,Any}
  try
    withcache(randstring(12), 24 * 60 * 60) do
      Dict("packages" => 
          [package_info["name"] for package_info in values(((HTTP.get(PKGLISTURL).body |> String) |> TOML.parse)["packages"])] 
      ) |> json
    end
  catch e
    return Dict("error" => e) |> json
  end
end

module API

module V1

using Genie
using GeniePlugins
using Genie.Renderer.Json
using Genie.HTTPUtils.HTTP
using Pkg

function add()
  try
    package = params(:package)
    Pkg.add(package)
    return Dict(:status => "ok", :message => "Package $package added") |> json
  catch e
    return Dict("error" => e) |> json
  end
end

function dev()
  try
    package = params(:package)
    Pkg.develop(package)
    return Dict(:status => "ok", :message => "Package $package added") |> json
  catch e
    return Dict("error" => e) |> json
  end
end

function add_with_version()
  try
    package = params(:package)
    version = params(:version)
    Pkg.add(name=package, version=version)
    return Dict(:status => "ok", :message => "Package $package@$version added") |> json
  catch e
    return Dict("error" => e) |> json
  end
end

function remove_package()
  try
    package = params(:package)
    Pkg.rm(package)
    return Dict(:status => "ok", :message => "Package $package removed") |> json
  catch e
    return Dict("error" => e) |> json
  end
end

function update_package()
  try
    package = params(:package)
    Pkg.update(package)
    return Dict(:status => "ok", :message => "Package $package updated") |> json
  catch e
    return Dict("error" => e) |> json
  end
end

# function update_all_packages()
#   try
#     Pkg.update()
#     return Dict(:status => "ok", :message => "All packages updated") |> json
#   catch e
#     return Dict("error" => e) |> json
#   end
# end

end # module V1
end # module API
end # module GeniePackageManager
