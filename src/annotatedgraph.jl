abstract type AbstractAnnotatedGraph{G} end

mutable struct AnnotatedSimpleGraph{G <: AbstractSimpleGraph} <: AbstractAnnotatedGraph{G}

    Graph::G

    VertexLabels::Dict{I where I <: Integer, String}
    VertexTypes::Dict{I where I <: Integer, I where I <: Integer}
    VertexTypeLabels::Dict{I where I <: Integer, String}

    EdgeLabels::Dict{Tuple{I where I <: Integer, I where I <: Integer}, String}
    EdgeTypes::Dict{Tuple{I where I <: Integer, I where I <: Integer}, I where I <: Integer}
    EdgeTypeLabels::Dict{I where I <: Integer, String}

end
