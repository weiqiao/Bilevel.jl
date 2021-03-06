mutable struct VariableSelector
    vars::Dict{Symbol, UnitRange{Int}}
    num_vars::Int

    function VariableSelector()
        new(Dict{Symbol, UnitRange{Int}}(), 0)
    end
end

(vs::VariableSelector)(name::Symbol) = vs.vars[name]
(vs::VariableSelector)(x::AbstractArray{T}, name::Symbol) where T = x[vs.vars[name]]

function add_var!(selector::VariableSelector, name::Symbol, size::Int)
    if haskey(selector.vars, name)
        throw(ArgumentError("Variable name '$name' already exists"))
    end
    if size < 1
        throw(ArgumentError("Variable size must be greater than 0"))
    end
    selector.vars[name] = selector.num_vars .+ (1:size)
    selector.num_vars += size
    
    selector.num_vars
end

mutable struct ConstraintSelector
    cons::Dict{Symbol, UnitRange{Int}}
    eqs::Vector{Int}
    ineqs::Vector{Int}
    num_cons::Int
    num_eqs::Int
    num_ineqs::Int
    
    function ConstraintSelector()
        new(Dict{Symbol, UnitRange{Int}}(), [], [], 0, 0, 0)
    end
end

function add_eq!(selector::ConstraintSelector, name::Symbol, size::Int)
    if haskey(selector.cons, name)
        throw(ArgumentError("Constraint name '$name' already exists"))
    end
    if size < 1
        throw(ArgumentError("Constraint size must be greater than 0"))
    end
    
    selector.cons[name] = selector.num_cons .+ (1:size)
    push!(selector.eqs, collect(selector.cons[name])...)

    selector.num_cons += size
    selector.num_eqs += size
    
    selector.num_eqs
end

function add_ineq!(selector::ConstraintSelector, name::Symbol, size::Int)
    if haskey(selector.cons, name)
        throw(ArgumentError("Constraint name '$name' already exists"))
    end
    if size < 1
        throw(ArgumentError("Constraint size must be greater than 0"))
    end
    
    selector.cons[name] = selector.num_cons .+ (1:size)
    push!(selector.ineqs, collect(selector.cons[name])...)

    selector.num_cons += size
    selector.num_ineqs += size
    
    selector.num_ineqs
end

(cs::ConstraintSelector)(name::Symbol) = cs.cons[name]