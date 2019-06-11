function build_layout(assets)
## Function contains MILP to generate a set of feasible
## 2D coordinates for all passed assets.
##---------------------------------------------------------
## To Do: Try differnet solvers - current default is Gurobi
##---------------------------------------------------------

    vertices = [i for i in 1:length(assets)]

    @inline function get_M(assets)
        sum_x = 0
        sum_y = 0
        for i in 1:length(assets)
            sum_x += assets[i][1]
            sum_y += assets[i][2]
        end
        return maximum([sum_x, sum_y])
    end

    M = get_M(assets)

    buildLayout = Model()

    @variable(buildLayout, pos_x[vertices] >= 0)
    @variable(buildLayout, pos_y[vertices] >= 0)
    @variable(buildLayout, max_x >= 0)
    @variable(buildLayout, max_y >= 0)
    @variable(buildLayout, collsion_x[vertices, vertices], Bin)
    # 0: First element displayed at a lower x-index
    # 1: Second element displayed at a lower x-index
    #-----------------------------------------------
    @variable(buildLayout, collsion_y[vertices, vertices], Bin)
    # 0: First element displayed at a lower y-index
    # 1: Second element displayed at a lower y-index
    #-----------------------------------------------
    @variable(buildLayout, adj_angle[vertices, vertices, 4], Bin)

    @objective(buildLayout, Min, max_x + max_y)

    @constraint(buildLayout, set_max_x[v = vertices],
    pos_x[v] <= max_x)

    @constraint(buildLayout, set_max_y[v = vertices],
    pos_y[v] <= max_y)

    @constraint(buildLayout, collision_x_1[v1 = vertices, v2 = vertices; v1 != v2],
    pos_x[v1] + assets[v1][1] <= pos_x[v2] + collision_x[v1, v2] * M)

    @constraint(buildLayout, collision_x_2[v1 = vertices, v2 = vertices; v1 != v2],
    pos_x[v1] - assets[v2][1] * (1 - collision_x[v1,v2]) * M >= pos_x[v2])

    @constraint(buildLayout, collision_y_1[v1 = vertices, v2 = vertices; v1 != v2],
    pos_y[v1] + assets[v1][1] <= pos_y[v2] + collision_y[v1, v2] * M)

    @constraint(buildLayout, collision_y_2[v1 = vertices, v2 = vertices; v1 != v2],
    pos_y[v1] - assets[v2][1] * (1 - collision_y[v1,v2]) * M >= pos_y[v2])

    status = optimize!(TS, with_optimizer(Gurobi.Optimizer, OutputFlag = 0))

    coordinates = Vector{N where I <: Number, N where I <: Number}
    return coordinates
end
