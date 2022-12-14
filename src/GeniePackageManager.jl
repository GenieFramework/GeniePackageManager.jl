module GeniePackageManager

using Genie
using Genie.Renderer.Json
using Genie.HTTPUtils.HTTP
using Pkg

const PKGLISTURL = "https://raw.githubusercontent.com/JuliaRegistries/General/master/Registry.toml"

const defaultroute = "/geniepackagemanager"

viewpath = abspath(joinpath(@__DIR__, "..", "views", "index.html"))

const assets_config = Genie.Assets.AssetsConfig(package = "GeniePackageManager.jl")

function deps_routes() :: Nothing
  if !Genie.Assets.external_assets(assets_config)

    Genie.Router.route(Genie.Assets.asset_route(assets_config, :css, file="style")) do
      Genie.Renderer.WebRenderable(
        Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), type="css", file="style")),
        :css) |> Genie.Renderer.respond
    end

    Genie.Router.route(Genie.Assets.asset_route(assets_config, :js, file="main")) do
      Genie.Renderer.WebRenderable(
        Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), type="js", file="main")),
        :javascript) |> Genie.Renderer.respond
    end
  end
  nothing
end

function register_routes(defaultroute = defaultroute)
  route("$defaultroute") do
    serve_file(viewpath)
  end

  route("$defaultroute/list", list_packages)

  # REST ENDPOINTS
  route("$defaultroute/api/v1/:package::String/add", API.V1.add, method = POST)
  route("$defaultroute/api/v1/:package::String/:version::String/add", API.V1.add_with_version, method = POST)
  route("$defaultroute/api/v1/:package::String/dev", API.V1.dev, method = POST)
  route("$defaultroute/api/v1/:package::String/remove", API.V1.remove_package, method = POST)
  route("$defaultroute/api/v1/:package::String/update", API.V1.update_package, method = POST)

  route("$defaultroute/api/v1/updateall", API.V1.update_all_packages, method = GET)
  route("$defaultroute/api/v1/addurl", API.V1.add_with_url, method = GET)
  route("$defaultroute/api/v1/addurldev", API.V1.add_with_url_dev, method = GET)
end

function list_packages()
  deps = Pkg.dependencies()
  installs = Dict{String, Vector{Any}}()

  for (uuid, dep) in deps
    dep.is_direct_dep || continue
    dep.version === nothing && continue
    dep.source === nothing && continue
    moddevdir = false
    
    if haskey(ENV, "JULIA_PKG_DEVDIR")
      moddevdir = true
    end

    if moddevdir && occursin(ENV["JULIA_PKG_DEVDIR"], dep.source)
      installs[dep.name] = [dep.version, "dev"]
    elseif !moddevdir && !isempty(findall(x -> x == "dev", splitpath(dep.source)))
      installs[dep.name] = [dep.version, "dev"]
    else
      installs[dep.name] = [dep.version, ""]
    end

  end

  return installs |> json
end

module API

module V1

using Genie
using Genie.Renderer.Json
using Genie.HTTPUtils.HTTP
using Pkg
using Base64

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

end # module V1
end # module API
end # module GeniePackageManager
