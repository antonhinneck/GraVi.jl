include("C:/Users/Anton Hinneck/Desktop/Libya/GraphVisualization.jl/src/GraphVisualization.jl")
include("C:/Users/Anton Hinneck/juliaPackages/GitHub/PowerGrids.jl/src/PowerGrids.jl")
using .PowerGrids, .GraphVisualization
dir = @__DIR__
cd(dir)

set_csv_path("C:/Users/Anton Hinneck/Documents/Git/pglib2csv/pglib/2020-08-21.19-54-30-275/csv")
PowerGrids.csv_cases(verbose = true)
PowerGrids.select_csv_case(48)
case = PowerGrids.loadCase() # 118 Bus ieee

graph = PowerGrids.toGraph(case)
GraphVisualization.plot(graph, [600, 600]; export_dir = dir)
