abstract type AbstractPassive{T} <: AbstractObject{T} end

mutable struct Passive{T} <: AbstractPassive{T}
    name::String
    id::Int
    potential::Union{Symbol,T}
    temperature::Union{T,Missing}
    material::NamedTuple
    charge_density_model::AbstractChargeDensityModel{T}
    geometry::AbstractGeometry{T}
    geometry_positive::Vector{AbstractGeometry{T}}
    geometry_negative::Vector{AbstractGeometry{T}}

    Passive{T}() where T <: SSDFloat = new{T}()
end

function Passive{T}(dict::Dict, inputunit_dict::Dict{String,Unitful.Units}) where T <: SSDFloat
    pass = Passive{T}()
    haskey(dict, "name") ? pass.name = dict["name"] : pass.name = "external part"
    haskey(dict, "id") ? pass.id = dict["id"] : pass.id = -1
    haskey(dict,"potential") ? pass.potential = T(dict["potential"]) : pass.potential = :floating
    haskey(dict, "temperature") ? pass.temperature = T(dict["temperature"]) : pass.temperature = missing
    pass.material = material_properties[materials[dict["material"]]]
    pass.charge_density_model = if haskey(dict, "charge_density_model") 
        ChargeDensityModel(T, dict["charge_density_model"], inputunit_dict)
    else
        ZeroChargeDensityModel{T}()
    end
    pass.geometry = Geometry(T, dict["geometry"], inputunit_dict)
    pass.geometry_positive, pass.geometry_negative = get_decomposed_volumes(pass.geometry)
    return pass
end
