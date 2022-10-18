using Test
using Pkg
using Genie
using TestSetExtensions
import Genie.HTTPUtils.HTTP
import Genie.Renderers.Json.JSONParser.JSON3

@testset "GeniePackageManager.jl API test" begin

    @testset "add package by name i.e. PrettyTables.jl" begin
        response = HTTP.post(API_URL * "/PrettyTables" * "/add")
        @test response.status == Genie.Router.OK
    end

    @testset "add package by name and extension i.e. GeniePlugins.jl" begin
        response = HTTP.post(API_URL * "/GeniePlugins.jl" * "/add")
        @test response.status == 200
    end

    @testset "add package by package version BSON@0.2.5" begin
        response = HTTP.post(API_URL * "/BSON/0.2.5" * "/add")
        @test response.status == 200
    end

    @testset "update package by name" begin
        response = HTTP.post(API_URL * "/BSON" * "/update")
        @test response.status == 200
    end

    @testset "remove package by name i.e. BSON" begin
        response = HTTP.post(API_URL * "/BSON" * "/remove")
        @test response.status == Genie.Router.OK
    end
 
    @testset "add package to dev i.e. SearchLight" begin
        response = HTTP.post(API_URL * "/SearchLight" * "/dev")
        @test response.status == 200
    end

    @testset "add package by git url host-org-name" begin
        response = HTTP.post(API_URL * "/gitlab/braneproject/Bitcoin" * "/addurl")
        @test response.status == 200
    end

    @testset "update all packages" begin
        response = HTTP.get(API_URL * "/updateall")
        @test response.status == 200
    end
end