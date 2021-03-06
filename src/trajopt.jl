function add_box_con!(sim_data::SimData, name::Symbol, var_name::Symbol, min::AbstractArray{T}, max::AbstractArray{T}, range::UnitRange) where T
    for n = range
        add_box_con!(sim_data, Symbol(name, n), Symbol(var_name, n), min, max)
    end

    sim_data.con_fns
end

function add_box_con_snopt!(x_min::AbstractArray{T}, x_max::AbstractArray{T}, sim_data::SimData, var_name::Symbol, min::AbstractArray{T}, max::AbstractArray{T}, range::UnitRange) where T
    for n = range
        x_min[sim_data.vs(Symbol(var_name, n))] .= min
        x_max[sim_data.vs(Symbol(var_name, n))] .= max
    end
end

function trajopt(sim_data::SimData;
                 x0=nothing,quaternion_state=false,x_min=nothing,x_max=nothing,
                 opt_tol=1e-6,major_feas=1e-6,minor_feas=1e-6,max_iter=10000,verbose=0,callback_fn=nothing)

    solver_fn = eval(sim_data.generate_solver_fn)(sim_data)

    if isa(x0, Nothing)
        # should start with some linear interpolation here

        # need a better way to do this...
        x0 = zeros(sim_data.vs.num_vars)

        # TODO use the normalize_configuration!
        if quaternion_state
            for n = 1:sim_data.N
                x0[sim_data.vs(Symbol("q", n))] .= [1., 0., 0., 0., 0., 0., 0.]
            end
        end

        for n = 1:sim_data.N-1
            x0[sim_data.vs(Symbol("h", n))] .= sim_data.Δt
        end
    end

    options = Dict{String, Any}()
    options["Derivative option"] = 1
    options["Verify level"] = -1 # -1 => 0ff, 0 => cheap
    options["Major optimality tolerance"] = opt_tol
    options["Major feasibility tolerance"] = major_feas
    options["Minor feasibility tolerance"] = minor_feas
    options["Iterations limit"] = max_iter
    
    xopt, info = snopt(solver_fn, sim_data.cs.num_eqs, sim_data.cs.num_ineqs, x0, options, x_min=x_min,x_max=x_max,callback_fn=callback_fn)

    if verbose >= 1
        println(info)
    end

    sol = eval(sim_data.extract_sol)(sim_data, xopt)

    sol
end
