using Test
using TestSetExtensions

include("testapp/app.jl")
up()

include("../src/GeniePackageManager.jl")

using Main.GeniePackageManager

Main.GeniePackageManager.register_routes()
Main.GeniePackageManager.deps_routes()

const API_URL = "http://localhost:8000/geniepackagemanager/api/v1"

@testset ExtendedTestSet "GeniePackageManager.jl test" begin
    @includetests ARGS
end