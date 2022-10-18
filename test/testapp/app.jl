using Genie
using Genie.Renderer.Html
using Stipple
using Stipple.Pages
using Stipple.ModelStorage.Sessions
using Stipple.ReactiveTools

@handlers begin
  @out message = "Hello World!"

  @onchange isready begin
    @show "App is loaded"
  end
end

@page("/", "ui.jl")