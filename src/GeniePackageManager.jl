module GeniePackageManager

using Genie
using Genie.Renderer.Json.JSON3
using Pkg
using TOML

function install(dest::String; force = false)
  src = abspath(normpath(joinpath(@__DIR__, "..", Genie.Plugins.FILES_FOLDER)))

  for f in readdir(src)
    isdir(f) || continue
    Genie.Plugins.install(joinpath(src, f), dest, force = force)
  end
end

struct PkgManagerError <: Exception
    msg::String
end

pkgerror(msg::String...) = throw(PkgManagerError(join(msg)))
Base.showerror(io::IO, err::PkgManagerError) = print(io, err.msg)

# try to call realpath on as much as possible
function safe_realpath(path)
    isempty(path) && return path
    if ispath(path)
        try
            return realpath(path)
        catch
            return path
        end
    end
    a, b = splitdir(path)
    return joinpath(safe_realpath(a), b)
end

function find_project_files()
  project_files = String[]

  for project_file in [Base.active_project(), joinpath(dirname(Base.active_project()), "Manifest.toml")]
    project_file === nothing && pkgerror("no active project")

    @assert project_file isa String &&
        (isfile(project_file) || !ispath(project_file) ||
         isdir(project_file) && isempty(readdir(project_file)))

    push!(project_files,(safe_realpath(project_file)))
  end
  return project_files
end

function list_packages()
  # find project files
  (project_file, manifest_file) = find_project_files()
  @info project_file
  @info manifest_file

  # parse project.toml
  deps = TOML.parsefile(project_toml)["deps"]
  # parse manifest.toml

  deps_info = Vector[]

  for key in keys(deps)
    push!(deps_dict, TOML.parsefile("Manifest.toml")["deps"][key])
  end

  
end

function add()
end

function remove_package()
end

function update()
end

function update_package()
end


end # module GeniePackageManager
