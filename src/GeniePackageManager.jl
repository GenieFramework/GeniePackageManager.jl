module GeniePackageManager

using Genie
using Genie.Renderer.Json
using Genie.HTTPUtils.HTTP
using Pkg
using Base64

const PKGLISTURL = "https://raw.githubusercontent.com/JuliaRegistries/General/master/Registry.toml"
const defaultroute = "/geniepackagemanager"
const viewpath = abspath(joinpath(@__DIR__, "..", "views", "index.html"))

function register_routes(defaultroute = defaultroute)
  route("$defaultroute") do
    serve_file(viewpath)
  end

  route("$defaultroute/list", list_packages)

  # REST ENDPOINTS
  route("$defaultroute/:package::String/add", add, method = POST)
  route("$defaultroute/:package::String/:version::String/add", add_with_version, method = POST)
  route("$defaultroute/:package::String/dev", dev, method = POST)
  route("$defaultroute/:package::String/remove", remove_package, method = POST)
  route("$defaultroute/:package::String/update", update_package, method = POST)

  route("$defaultroute/updateall", update_all_packages)
  route("$defaultroute/addurl", add_with_url)
  route("$defaultroute/addurldev", add_with_url_dev)

  Genie.Configuration.isdev() && route("$defaultroute/exit", () -> exit(0))

  nothing
end

function list_packages()
  deps = Pkg.dependencies()
  installs = Dict{String, Vector{Any}}()

  for (uuid, dep) in deps
    dep.is_direct_dep || continue
    moddevdir = false

    if haskey(ENV, "JULIA_PKG_DEVDIR")
      moddevdir = true
    end

    if dep.version === nothing
      installs[dep.name] = ["", ""]
    elseif moddevdir && occursin(ENV["JULIA_PKG_DEVDIR"], dep.source)
      installs[dep.name] = [dep.version, "dev"]
    elseif !moddevdir && !isempty(findall(x -> x == "dev", splitpath(dep.source)))
      installs[dep.name] = [dep.version, "dev"]
    else
      installs[dep.name] = [dep.version, ""]
    end
  end

  return installs |> json
end

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

function add_with_url()
  try
    giturl = String(base64decode(params(:url)))
    Pkg.add(url=giturl)
    return Dict(:status => "ok", :message => "Package $giturl added") |> json
  catch e
    return Dict("error" => e) |> json
  end
end

function add_with_url_dev()
  try
    giturl = String(base64decode(params(:url)))
    Pkg.develop(url=giturl)
    return Dict(:status => "ok", :message => "Package $giturl added") |> json
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

function update_all_packages()
  try
    Pkg.update()
    return Dict(:status => "ok", :message => "All packages updated") |> json
  catch e
    return Dict("error" => e) |> json
  end
end

end # module GeniePackageManager
