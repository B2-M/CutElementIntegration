module Gridap_main_julia

using Gridap
using Gridap.ReferenceFEs
using Gridap.Arrays
using Gridap.CellData
using Gridap.Fields
using GridapEmbedded
using GridapEmbedded.CSG
using GridapEmbedded.LevelSetCutters

export bulk_computation, flux_computation, interface_computation

#-----------------------------------------------------
function bulk_computation(domain_input,interfaces,degree)

  # # global function to avoid world age problem
  global function_handle

  # generate background mesh
  dim = length(domain_input["xmin"])
  n = 2^domain_input["n_refs"]
  if dim==2
    domain = (domain_input["xmin"][1],domain_input["xmax"][1],domain_input["xmin"][2],domain_input["xmax"][2])
    bgmodel = CartesianDiscreteModel(domain,(n,n))
  elseif dim==3
    domain = (domain_input["xmin"][1],domain_input["xmax"][1],domain_input["xmin"][2],domain_input["xmax"][2],
      domain_input["xmin"][3],domain_input["xmax"][3])
    bgmodel = CartesianDiscreteModel(domain,(n,n,n))
  end

  reffe = ReferenceFE(lagrangian,Float64,1)
  Ω_bg = Triangulation(bgmodel)
  # writevtk(Ω_bg,"bg_trian")
  V_bg = FESpace(Ω_bg,reffe)
  println(interfaces)
  println(typeof(interfaces))
  println(interfaces[1])
  println(typeof(interfaces[1]))
  for i in eachindex(interfaces)
    println(i)
    φh = interpolate(interfaces[i], V_bg)
    Base.dump(interfaces[i])
    Base.show(φh)
    if i==1
      global geo = DiscreteGeometry(φh,bgmodel)
    else
      global geo = intersect(geo,DiscreteGeometry(φh,bgmodel))
    end
  end

  # Cut the background model
  cutgeo = cut(bgmodel,geo)

  # # Get active cells
  # Ω_act = Triangulation(cutgeo,ACTIVE)
  # writevtk(Ω_act,"act_trian")

  # subtriangulating cut elements
  Ω = Triangulation(cutgeo,PHYSICAL)
  # writevtk(Ω,"phys_trian")

  if isa(Ω,Gridap.Geometry.BodyFittedTriangulation)==false
    dΩ = Measure(Ω,degree)

    # compute area
    area = sum(∫(1.0)*dΩ)
    println("The computed area is: $area")
    global area = 0.0

    #-------------------------------------------------------------
    # extract quadrature points for trimmed elements
    Qₕ = CellQuadrature(Ω.a,degree)
    Qₕ_cell_data = get_data(Qₕ)
    num_cell = length(Qₕ_cell_data)
    Qₕ_cell_point = get_cell_points(Qₕ) # cell_point of Qₕ
    points = Qₕ_cell_point.cell_phys_point
    weights = Qₕ.cell_weight

    # transfer points to output fields
    cell_map = get_cell_map(Qₕ.trian)
    cell_Jt = lazy_map(∇,cell_map)
    cell_Jtx = lazy_map(evaluate,cell_Jt,Qₕ.cell_point)
    els_trim = [Vector{Any}() for _ in 1:num_cell]
    els_trim_ID = zeros(num_cell,1)
    for i in 1:num_cell
      points_cell = points[i]
      weights_cell = weights[i]
      for j in eachindex(weights_cell)
        global area = area + weights_cell[j]*det(cell_Jtx[i][j])
        if dim==2
          QP = [points_cell[j][1],points_cell[j][2],weights_cell[j]*det(cell_Jtx[i][j])]
        elseif dim==3
          QP = [points_cell[j][1],points_cell[j][2],points_cell[j][3],weights_cell[j]*det(cell_Jtx[i][j])]
        end
        push!(els_trim[i], QP)  # Append the pair to the corresponding cell
      end
      els_trim_ID[i] = Ω.a.subcells.cell_to_bgcell[i]
    end

    #-------------------------------------------------------------
    # extract quadrature points for untrimmed elements
    Qₕ = CellQuadrature(Ω.b,degree)
    Qₕ_cell_data = get_data(Qₕ)
    num_cell = length(Qₕ_cell_data)
    Qₕ_cell_point = get_cell_points(Qₕ) # cell_point of Qₕ
    points = Qₕ_cell_point.cell_phys_point
    weights = Qₕ.cell_weight

    # transfer points to output fields
    cell_map = get_cell_map(Qₕ.trian)
    cell_Jt = lazy_map(∇,cell_map)
    cell_Jtx = lazy_map(evaluate,cell_Jt,Qₕ.cell_point)
    els_untrim = [Vector{Any}() for _ in 1:num_cell]
    els_untrim_ID = zeros(num_cell,1)
    for i in 1:num_cell
      points_cell = points[i]
      weights_cell = weights[i]
      for j in eachindex(weights_cell)
        global area = area + weights_cell[j]*det(cell_Jtx[i][j])
        if dim==2
          QP = [points_cell[j][1],points_cell[j][2],weights_cell[j]*det(cell_Jtx[i][j])]
        elseif dim==3
          QP = [points_cell[j][1],points_cell[j][2],points_cell[j][3],weights_cell[j]*det(cell_Jtx[i][j])]
        end
        push!(els_untrim[i], QP)  # Append the pair to the corresponding cell
      end
      els_untrim_ID[i] = Ω.b.tface_to_mface[i]
    end

    println("The computed area (sum of weights) is: $area")

    println("The area consists of $num_cell cells.")
    println("The requested variable has type: $Qₕ") # CellQuadrature
    println("The requested variable has type: $Qₕ_cell_data") # cell of GenericQuadrature
  else
    els_trim = []
    els_trim_ID = []
    els_untrim = []
    els_untrim_ID = []
  end

  return els_trim,els_trim_ID,els_untrim,els_untrim_ID
end
#-----------------------------------------------------
function flux_computation(domain_input,interfaces,degree)
  # CellQuadrature.integrate() might help to evaluate a normal vector on a quadrature
  # point because this function is called when an integral is computed. However,
  # the information which we already obtain seems sufficient for our current project.

  # # global function to avoid world age problem
  global function_handle

  # generate background mesh
  dim = length(domain_input["xmin"])
  n = 2^domain_input["n_refs"]
  if dim==2
    domain = (domain_input["xmin"][1],domain_input["xmax"][1],domain_input["xmin"][2],domain_input["xmax"][2])
    bgmodel = CartesianDiscreteModel(domain,(n,n))
  elseif dim==3
    domain = (domain_input["xmin"][1],domain_input["xmax"][1],domain_input["xmin"][2],domain_input["xmax"][2],
      domain_input["xmin"][3],domain_input["xmax"][3])
    bgmodel = CartesianDiscreteModel(domain,(n,n,n))
  end

  reffe = ReferenceFE(lagrangian,Float64,1)
  Ω_bg = Triangulation(bgmodel)
  V_bg = FESpace(Ω_bg,reffe)
  for i in eachindex(interfaces)
    φh = interpolate(interfaces[i], V_bg)
    Base.dump(interfaces[i])
    Base.show(φh)
    if i==1
      global geo = DiscreteGeometry(φh,bgmodel)
    else
      global geo = intersect(geo,DiscreteGeometry(φh,bgmodel))
    end
  end

  # Cut the background model
  cutgeo = cut(bgmodel,geo)

  # subtriangulating cut elements
  Ω = Triangulation(cutgeo,PHYSICAL)
  Γd = EmbeddedBoundary(cutgeo)
  n_Γ = get_normal_vector(Γd)

  # Setup Lebesgue measures
  dΓd = Measure(Γd,degree)

  #-------------------------------------------------------------
  # compute volume/measure by flux
  r(x) = x  # position vector
  f(u) = sum(∫(0.5*(n_Γ⊙u))*dΓd)
  volume = f(r)

  #-------------------------------------------------------------
  # extract quadrature points for trimmed elements
  Qₕ = CellQuadrature(Ω.a,degree) # only take trimmed cells
  cell_quad = dΓd.quad
  cell_points = get_cell_points(dΓd.quad)
  points = cell_points.cell_phys_point
  weights = dΓd.quad.cell_weight

  # transfer points to output fields
  cell_map = get_cell_map(cell_quad.trian)
  cell_Jt = lazy_map(∇,cell_map)
  cell_Jtx = lazy_map(evaluate,cell_Jt,cell_quad.cell_point)
  # cell_map = get_cell_map(Qₕ.trian)
  # cell_Jt = lazy_map(∇,cell_map)
  # cell_Jtx = lazy_map(evaluate,cell_Jt,cell_quad.cell_point)

  els_trim,els_trim_ID = add_QPs_interface(points,weights,cell_Jtx,Ω,dim)

  return els_trim,els_trim_ID,volume
end

#-----------------------------------------------------
function interface_computation(domain_input,interfaces,degree)

  # # global function to avoid world age problem
  global function_handle

  # generate background mesh
  dim = length(domain_input["xmin"])
  n = 2^domain_input["n_refs"]
  if dim==2
    domain = (domain_input["xmin"][1],domain_input["xmax"][1],domain_input["xmin"][2],domain_input["xmax"][2])
    bgmodel = CartesianDiscreteModel(domain,(n,n))
  elseif dim==3
    domain = (domain_input["xmin"][1],domain_input["xmax"][1],domain_input["xmin"][2],domain_input["xmax"][2],
      domain_input["xmin"][3],domain_input["xmax"][3])
    bgmodel = CartesianDiscreteModel(domain,(n,n,n))
  end

  reffe = ReferenceFE(lagrangian,Float64,1)
  Ω_bg = Triangulation(bgmodel)
  # writevtk(Ω_bg,"bg_trian")
  V_bg = FESpace(Ω_bg,reffe)
  println(interfaces)
  println(typeof(interfaces))
  println(interfaces[1])
  println(typeof(interfaces[1]))
  for i in eachindex(interfaces)
    println(i)
    φh = interpolate(interfaces[i], V_bg)
    Base.dump(interfaces[i])
    Base.show(φh)
    if i==1
      global geo = DiscreteGeometry(φh,bgmodel)
    else
      global geo = intersect(geo,DiscreteGeometry(φh,bgmodel))
    end
  end

  # Cut the background model
  cutgeo = cut(bgmodel,geo)

  # subtriangulating cut elements
  Ω = Triangulation(cutgeo,PHYSICAL)
  Γd = EmbeddedBoundary(cutgeo)

  # Setup Lebesgue measures
  dΓd = Measure(Γd,degree)

  #-------------------------------------------------------------
  # extract quadrature points for trimmed elements
  Qₕ = CellQuadrature(Ω.a,degree) # only take trimmed cells
  cell_quad = dΓd.quad
  cell_points = get_cell_points(dΓd.quad)
  points = cell_points.cell_phys_point
  weights = dΓd.quad.cell_weight

  # transfer points to output fields
  cell_map = get_cell_map(cell_quad.trian)
  cell_Jt = lazy_map(∇,cell_map)
  cell_Jtx = lazy_map(evaluate,cell_Jt,cell_quad.cell_point)
  # cell_map = get_cell_map(Qₕ.trian)
  # cell_Jt = lazy_map(∇,cell_map)
  # cell_Jtx = lazy_map(evaluate,cell_Jt,cell_quad.cell_point)
  els_trim,els_trim_ID = add_QPs_interface(points,weights,cell_Jtx,Ω,dim)

  return els_trim,els_trim_ID
end

#-----------------------------------------------------
# helper functions
#-----------------------------------------------------
function add_QPs_interface(points,weights,cell_Jtx,Ω,dim)
  els_trim = [Vector{Any}() for _ in 1:length(weights)]
  els_trim_ID = zeros(length(weights),1)
  for i in eachindex(weights) # loop over elements
    point = points[i]
    weight = weights[i]
    for j in eachindex(weight)  # loop over QP in single element
      if dim==2
        QP = [point[j][1],point[j][2],weight[j]*norm(cell_Jtx[i][j])]
      elseif dim==3
        QP = [point[j][1],point[j][2],point[j][3],weight[j]*norm(cell_Jtx[i][j])]
      end
      push!(els_trim[i], QP)  # Append the pair to the corresponding cell
    end

    els_trim_ID[i] = Ω.a.subcells.cell_to_bgcell[i]
  end

  return els_trim, els_trim_ID
end

function call_interpolate(interfaces,V_bg)
  function_handle = eval_function(interfaces)
  return interpolate(function_handle,V_bg)
end

#-----------------------------------------------------
function eval_function(interfaces)
  func_expr = Meta.parse(interfaces)
  f = eval(:(x -> $func_expr))
  return f
end

end
