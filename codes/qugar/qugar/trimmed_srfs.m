% TRIMMED_SRFS: generator of non-conforming multi-patch surfaces.
%
%  Copyright (C) 2023 Pablo Antolin <pablo.antolin@epfl.ch>
% 
%  See the attached LICENSE file.
%
%
% POSSIBLE CALLING SEQUENCES:
%
%     output = trimmed_srfs (trim_srfs,  'option1', value1, ...);
%     output = trimmed_srfs (step_fname, 'option1', value1, ...);
%
% DESCRIPTION:
%
% This function creates a (non-conforming) multipatch from a collection of disconnected
% trimmed surfaces or loaded from a STEP file.
% The generated output consists of the reparameterization of trimmed surfaces and their
% interfaces and (optionally) quadrature rules ready to compute integrals.
% The created reparameterizations may be used for numerical integration and/or for visualization purposes.
%
% This function can be used as well for a single trimmed surface. Notice that in this case
% interfaces may still exist (e.g., the closure edge a cylindrical geometry).
%
%
% INPUTS:
%     
%    trim_srfs:       Collection of (2D or 3D) trimmed surfaces.
%
%    step_fname:      Name (path) of a STEP file containing a shell-like geometry.
%
%    'option', value: Additional optional parameters, currently available options are:
%            
%             Name             |   Default value    
%           -------------------+---------------------
%             nb_quad_pts      |   0
%                              |
%             reparam_deg      |   Maximum degree in curves and surfaces.
%                              |
%             tolerance        |   1.0e-12
%                              |
%             nb_reparam_elems |   1
%
% Further details about the input parameters are provided in the section INPUT DETAILS included below.
%   
% OUTPUT:
%
%     output: object containing the following fields
%
%     FIELD_NAME    (SIZE)                    DESCRIPTION
%
%     rdim          (scalar)                  Dimension of the physical space (either 2D or 3D).
%
%     trim_srfs     (1 x T struct-array)      T trimmed surfaces.
%
%     interfaces    (1 x I struct-array)      I interfaces between trimmed surfaces.
%
% Further details about the generated output are provided in the section OUTPUT DETAILS included below.
%
%
% INPUTS DETAILS:
%
% trim_srfs: Collection of (2D or 3D) trimmed surfaces that form a (non-conforming) multi-patch geometry.
%   Even if the surfaces are defined as a collection of disconnected trimmed surfaces, coincident boundaries
%   will be identified (up to geometric tolerance) and the surfaces will be merged as a multi-patch geometry.
%
%   Each single trimmed surface is defined through a base spline surface (2D or 3D) and a collection
%   of trimming loops that delimit the active region of the surface's parametric domain.
%   Thus, trim_srfs is a struct array, with as many entries trimmed surfaces in the model,
%   that presents two fields: srf and trim_loops.
%
%   .srf: (1 x 1 struct-array) Spline surface (2D or 3D) to be trimmed. Defined using the NURBS toolbox format.
%
%   .label: (scalar) Optional parameter for setting a label associated to the trimmed surface.
%      The label must be a non negative integer number. Surfaces with non assigned label will be automatically
%      given non-repeated negative label values starting at -1. Same label can be assigned to several trimmed surfaces.
%
%   .trim_loops: (1 x L cell-array) Collection of 2D curves that delimit the surface's parametric domain to be trimmed
%      by forming a series of L nested closed loops.
%      The images of the curves must be fully contained in the surface's parametric domain. 
%
%      Each loop is defined as a group of concatenated curves that form a closed, non self-intersecting,
%      simply connected, curve (a loop), whose enclosed region must have non-zero area.
%      The curves of a single loop must be sorted and oriented such that the last point of a curve
%      coincides with the first point of the next one, and the last point of the last curve coincides
%      with the first point of the first curve.
%   
%      Each loop is defined as a 1 x S struct-array (assuming S segments) whose fields are:
%
%        .curve: (1 x 1 struct-array) 2D curve piece using the NURBS toolbox format.
%        .label: (scalar) Optional parameter for setting a label associated to the boundary corresponding to
%           this segment. The label must be a non negative integer number.
%           Boundaries with non assigned label will be automatically given non-repeated negative
%           label values starting at -1. Same label can be assigned to connected or disconnected
%           groups of segments. The labels will be needed for computing quantities on boundaries.
%
%      Note 1: If the trim_loops field is not defined, or it is defined but empty,
%        then, the function assumes that one trimming loop exists that corresponds
%        to the outer boundary of the parametric domain of geometry.
%        I.e., the geometry's parametric domain is fully active and therefore the
%        surface is not trimmed.
%        In addition, in the case of a single trimming loop, instead of a cell array
%        with one entry, it is possible to directly defined as a single 1 x S struct-array
%        of S segments (with curve and label fields).
%
%      Note 2: In case in which more than one loop is defined, one (outer) loop must enclose
%        all the others (inner), not being possible to have more than one level of nestness.
%        Thus, one simply connected region will be generated.
%
%      Note 3: No a priori orientation is assumed for inner and outer loops.
%        Internally, the function re-orients the outer loops in counter-clockwise fashion
%        and the inner ones in clockwise way.
%
%
% step_fname: Name (path) of a STEP file containing a shell geometry.
%   Right now, this file must contain a single multi-patch shell-like.
%   If the faces conforming the geometry are not spline-based, they will be transformed into splines.
%   In addition, at this moment, entities' labels are not managed yet.
%
%   Note that this feature is still experimental (and possibly unstable), and it will likely fail
%   if you try to submit complicated STEP files containing assemblies and other arrangements.
%
%
% IMPORTANT NOTE: trim_srfs and step_fname are mutually exclusive input arguments.
% 
%
% nb_quad_pts: (scalar) Number of (Gauss) quadrature points per direction to be used for integration.
%   This quadrature rule will be applied in combination with the created reparameterization tiles
%   (see the OUTPUT DETAILS section) for generating tailor-made quadratures for the cut
%   elements' interior and boundaries.
%
%
% reparam_deg: (scalar) Degree to be used for the reparameterization of the trimmed Bezier elements.
%   If not set, the default value is choosen as the maximum degree among all the surfaces and
%   trimming loops of the defined geometries (either in trim_srfs or the given STEP file).
%
%   Note that in the case of a geometry loaded from a STEP file, very high degrees may be
%   present. In those cases, using the default value will make the reparameterization of the cut
%   elements and boundaries computationally expensive.
%   In those situations it is strongly recommended to provided a value for 'reparam_deg'.
%
%   If you don't know how to choose this degree, set it equal to the degree of the discretization
%   of the solution of the problem you are solving. For further details, see:
%     Antolin, Buffa, Martinelli "Isogeometric analysis on V-reps: first results",
%     Computer Methods in Applied Mechanics and Engineering 355 (2019): 976-1002.
%
%
% nb_reparam_elems: Number of elements to be used for the reparameterization every edge of a
%   trimmed Bezier element. Default value is 1. If you don't know what to set, use the default value.
%   If the code is unable to use only one element for every edge, it will generate more automatically.
%
%
% tolerance: Tolerance value to be used in the geometric computations. Default value is 1.0e-12.
%   The tolerance cannot be specified in the case in which the geometry is defined through a STEP file.
%   In that case, the tolerances defined in the file will be used instead.
%
%   Note that geometries generated using commercial CAD systems have limited tolerances and precisions.
%   E.g., OpenCASCADE geometric kernel (used by the FreeCAD modeler) limits its lowest precision to 1.0e-8.
%   This is due to the fact that a precision value in the order of 1.0e-3 may be good enough for most CAD applications.
%   However, it may be insufficient for analysis, specially when convergence studies are performance.
%
%
% OUTPUT DETAILS:
%
% output: The output of this function consists in the reparmeterization of the individual trimmed surfaces
%   and their interfaces, and (optionally) quadrature rules.
%   This output allows to compute integrals on trimmed surfaces (and their interfaces) as well as visualize them.
%   output is a single struct with two fields: trim_srfs and interfaces.
%
%   Below, a synthetic hierarchical description of the output in terms of its members, types, and
%   dimensions is provided.
%
%     .rdim                                 (scalar)
%     .trim_srfs                            (1 x T struct-array)    T is the number of trimmed surfaces.
%        -srf                               (1 x 1 struct-array)
%        -label                             (scalar)
%        -nb_non_trim_elems                 (scalar)
%        -nb_trim_elems                     (scalar)
%        -non_trim_elem_ids                 (1 x nb_non_trim_elems vector)
%        -trim_elem_ids                     (1 x nb_trim_elems vector)
%        -trim_elems                        (1 x nb_trim_elems struct-array)
%           +elem_id                        (scalar)
%           +nb_tiles                       (scalar)
%           +nb_pts                         (scalar)
%           +tiles                          (1 x nb_tiles struct-array)
%           +quad_pts                       (2 x nb_pts matrix)
%           +quad_weights                   (1 x nb_pts vector)
%        -boundaries                        (1 x B struct-array)    B is the number of boundaries.
%           +param_side                     (scalar)
%           +label                          (scalar)
%           +interface                      (Boolean)
%           +nb_non_trim_elems              (scalar)
%           +nb_reparam_elems               (scalar)
%           +non_trim_elem_ids              (1 x nb_non_trim_elems vector)
%           +reparam_elem_ids               (1 x nb_reparam_elems vector)
%           +reparam_elems                  (1 x nb_reparam_elems struct-array)
%              >elem_id                     (scalar)
%              >nb_tiles                    (scalar)
%              >nb_pts                      (scalar)
%              >tiles                       (1 x nb_tiles struct-array).
%              >quad_pts                    (2 x nb_pts matrix)
%              >quad_weights                (1 x nb_pts vector)
%              >normals                     (rdim x nb_pts matrix)
%
%     .interfaces                           (1 x I struct-array)    I is the number of interfaces.
%        -curve                             (1 x 1 struct-array)
%        -label                             (scalar)
%        -srfs_info                         (1 x 2 struct-array)
%           +srf_id_in_list                 (scalar)
%           +param_side                     (scalar)
%           +rev_tiles                      (Boolean)
%        -conforming                        (Boolean)
%        -nb_segs                           (scalar)
%        -inters_segs                       (1 x nb_segs struct-array)
%           +nb_pts                         (scalar)
%           +srfs_seg                       (1 x 2 struct-array)
%              >elem_id                     (scalar)
%              >tile                        (1 x 1 struct-array)
%              >quad_pts                    (2 x nb_pts matrix)
%              >quad_weights                (1 x nb_pts vector)
%              >normals                     (rdim x nb_pts matrix)
%
%   A detailed description of the members above is provided below.
%
%     .rdim: (scalar) Dimension of the physical space (either 2D or 3D).
%
%     .trim_srfs: (1 x T struct-array) Collection of T trimmed surfaces.
%        Notice that T may be different from the number of trimmed surfaces passed in the input.
%        The struct contains the following fields:
%
%        -srf: (1 x 1 struct-array) Non-trimmed spline surface (with the format of the NURBS toolbox).
%
%        -label: (scalar) Trimmed surface's label. User given labels are non negative values, while negative
%           labels are set automatically for the surfaces that don't present an assigned label (as described above).
%
%        -nb_non_trim_elems: (scalar) Number of non trimmed active elements.
%           This corresponds to the length of the array 'non_trim_elem_ids'.
%
%        -nb_trim_elems: (scalar) Number of trimmed active elements.
%           This corresponds to the length of the arrays 'trim_elem_ids' and 'trim_elems'.
%
%        -non_trim_elem_ids: (1 x nb_non_trim_elems vector) Ids of the active non trimmed elements.
%
%        -trim_elem_ids: (1 x nb_trim_elems vector) Ids of the trimmed elements.
%
%        -trim_elems: (1 x nb_trim_elems struct-array) Trimmed elements.
%           Every entry of the array corresponds to a single trimmed Bezier element of the original domain.
%           The struct contains the following fields:
%
%           +elem_id: (scalar) Id of the element.
%           +nb_tiles: (scalar) Number of tiles of the reparameterization.
%           +nb_pts: (scalar) Number of quadrature points.
%           +tiles: (1 x nb_tiles struct-array) Collection of tiles that reparameterize the interior
%              of trimmed element. Every tile is a 2D Bezier, rational or not, with the format of the NURBS toolbox.
%           +quad_pts: (2 x nb_pts matrix) Coordinates of the quadrature points.
%              Each column corresponds to a point, and the (two) rows to the x and y coordinates.
%              The position of points is referred to the parametric domain of 'surface'.
%              I.e., they don't need to be re-scaled from the unit reference domain to the
%              parametric domain of the element.   
%           +quad_weights: (1 x nb_pts vector) Weights associated to the quadrature points.
%              The weights are referred to the parametric domain of 'surface' and don't require to be re-scaled
%              by multiplying them with the area of the parametric element.
%      
%        Example:
%          The A-th trimmed element of the B-th trimmed surface can be accessed through
%          'trim_elem = output.trim_srfs(B).trim_elems(A)'.
%          Its element id (respect to the geometry grid) is 'elem_id=trim_elem.elem_id'
%          and the interior active part of the element is reparameterized using 'nb_tiles',
%          where 'nb_tiles=trim_elem.nb_tiles'. 'trim_elem.tiles(I)', with I in the range
%          [1,nb_tiles], is a 2D Bezier patch with the format of the NURBS toolbox.
%          In the same way, the J-th quadrature point and weight can be accessed as
%          'trim_elem.quad_pts(:,J)' and 'trim_elem.quad_weights(J)'.
%
%
%        -boundaries: (1 x B struct-array) Information about the B boundaries of the current trimmed surface.
%           One entry per boundary. The struct contains the following fields:
%
%           +param_side: (scalar) Id of the original parametric side (of the surface's domain) the boundary lays on,
%              if any. If 'param_side' is in the range [1,4], the boundary corresponds to Umin, Umax, Vmin, or Vmax,
%              respectively. Otherwise, if the boundary doesn't lay on any parametric side, or only part of it does,
%              'param_side' is set to 0. In the same way, if different parts of the boundary lay on different
%               parametric sides, 'param_side' is set to 0.
%           +label: (scalar) Boundary's label. User given labels are non negative values, while negative labels
%              are set automatically for the boundaries that don't present an assigned label (as described above).
%           +interface: (Boolean) Wether the current boundary is at one, and only one, interface between two surfaces
%              (or the same, like in the cylinder case). In the case in which the boundary's label is associated to
%              several segments of a trimming loop, this value is set to false.
%           +nb_non_trim_elems: (scalar) Number of non trimmed (active) elements that 'touch' that specific boundary.
%              For boundaries whose 'param_side' is set to 0, this value is always 0.
%              This corresponds to the length of the array 'non_trim_elem_ids'.
%           +nb_reparam_elems: (scalar) Number of elements that present a piece of the boundary that is reparameterized.
%              This corresponds to the length of the arrays 'reparam_elem_ids' and 'reparam_elems'.
%           +non_trim_elem_ids: (1 x nb_non_trim_elems vector) Ids of the (active) non trimmed elements that
%              'touch' that specific boundary. For boundaries whose param_side is set to 0, this array will be empty.
%           +reparam_elem_ids: (1 x nb_reparam_elems vector) Ids of the elements that present a piece of
%              the boundary that is reparameterized.
%           +reparam_elems: (1 x nb_reparam_elems struct-array) Reparameterized elements.
%              The struct contains the following fields:
%
%              >elem_id: (scalar) Id of the element.
%              >nb_tiles: (scalar) Number of tiles that reparameterize the boundary of the element.
%              >nb_pts: (scalar) Number of quadrature points.
%              >tiles: (1 x nb_tiles struct-array) Collection of tiles that reparameterize the element's boundary.
%                 Every tile is a 1D Bezier, rational or not, with the format of the NURBS toolbox.
%                 Note that, in principle, these curves are not the traces of (volumetric) reparameterization
%                 tiles of the element's interior.                   
%              >quad_pts: (2 x nb_pts matrix) Coordinates of the quadrature points.
%                 Each column corresponds to a point, and the (two) rows to the x and y coordinates.
%                 The position of points is referred to the parametric domain of 'surface'.
%                 I.e., they don't need to be re-scaled from the unit reference domain to the
%                 parametric domain of the element.   
%              >quad_weights: (1 x nb_pts vector) Weights associated to the quadrature points.
%                 The weights are referred to the parametric domain of 'surface' and don't require to be re-scaled
%                 by multiplying with the area of the parametric element.
%              >normals: (rdim x nb_pts matrix) Unit normal vectors at the quadrature points.
%                 These are the normal in the physical (Euclidean) domain, not the parametric one, pointing outwards.
%      
%        Example:
%          We want to compute quantities for a boundary with label K. So, we
%          have to iterate along all the elements that 'touch' that boundary.
%          The following code snippet does the job:
%
%            for f = 1 : numel(output.faces)
%              for i = 1 : numel(output.faces(f).boundaries)
%                if output.faces(f).boundaries(i).label == K
%
%                   bound = output.faces(f).boundaries(i);
%
%                   if bound.param_side > 1
%                     for elem_id = bound.non_trim_elem_ids
%                       %% Your code here for the non trimmed element elem_id.
%                       %% The local param_side of the element 'touches' the
%                       %% the global boundary K.
%                     end
%                   end
% 
%                  for j = 1 : bound.nb_reparam_elems
%                    elem_id =  bound.reparam_elem_ids(j);
%                    reparam_elem = bound.reparam_elems(j);
% 
%                    for j = reparam_elem.nb_tiles 
%                      tile = reparam_elem.tiles(j);
%                      %% Your code here for operating with tile,
%                      %% that is a Bezier curve with NURBS toolbox format.
%                    end
%
%                    % Or, reparam_elem.quad_pts, reparam_elem.normals, ...
% 
%                  end % for j
%           
%                end % if label == K
%              end % for i
%            end % for f
%
%
%        Example:
%          Imagine now that we want to compute quantities for all the
%          boundaries that 'touch' the Vmax boundary of the original domain.
%          The following code snippet does the job:
%
%            vmax = 4;
%            for f = 1 : numel(output.faces)
%              for i = 1 : numel(output.faces(f).boundaries)
%                if output.faces(f).boundaries(i).param_side == vmax
%
%                  bound = output.faces(f).boundaries(i);
%
%                  for elem_id = bound.non_trim_elem_ids
%                    %% Your code here for the non trimmed element elem_id.
%                    %% The local param_side of the element 'touches' the
%                    %% the global boundary Vmax.
%                  end
% 
%                  for j = 1 : bound.nb_reparam_elems
%                    elem_id =  bound.reparam_elem_ids(j);
%                    reparam_elem = bound.reparam_elems(j);
% 
%                    for k = reparam_elem.nb_tiles 
%                      tile = reparam_elem.tiles(k);
%
%                      %% Your code here for operating with tile,
%                      %% that is a Bezier curve with NURBS toolbox format.
%                    end % for k
%
%                    % Or, reparam_elem.quad_pts, reparam_elem.normals, ...
% 
%                  end % for j
%           
%                end % if param_side == vmax
%              end % for i
%            end % for f
%
%     .interfaces: (1 x I struct-array) I interfaces between trimmed surfaces.
%        Each entry corresponds to a (potentially non-conforming) interface between two trimmed surfaces,
%        or one single surface (recall the cylindrical shape case mentioned in the description section).
%        The struct contains the following fields:
%
%        -curve: (1 x 1 struct-array) Spline curve (2D or 3D) describing the full interface in the physical
%               domain (in NURBS toolbox format). Note that this curve may be a high-order spline curve, or a
%               piecewise linear, with lots of control points.
%
%        -label: (scalar) Label for the interface. At this moment, this label is set as a unique negative
%           number, independent from the labels of the boundaries.  This labeling policy may change in the future.
%
%        -srfs_info: (1 x 2 struct-array) Struct array containing information of both trimmed surface at the interface.
%           It contains two entries, one per each trimmed surface. Their fieldnames are:
%
%           +srf_id_in_list: (scalar) Id of the trimmed surface referred to the output trimmed surfaces list.
               Indices start at 1.
%           +param_side: (scalar) Id of the original parametric side (of the surface's domain) the
%              interface lays on, if any. If 'param_side' is in the range [1,4], the boundary corresponds to Umin,
%              Umax, Vmin, or Vmax, respectively. Otherwise, if the boundary doesn't lay on any parametric side,
%              or only part of it does, 'param_side' is set to 0.
%           +rev_tiles: (Boolean) Whether the tiles are reversed. The interface tiles are reversed when the element's
%              interior, of the current surface is on the right, side of the curve, instead of the left.
%              I.e., outer loops are counter-clockwise oriented, while inner ones are clockwise.
%              This has an effect on the computation of the normal vector using the tile, that needs to be reversed.
%
%        -conforming: (Boolean) Whether the interface between the trimmed surfaces is conforming.
%           I.e., the trace of both surfaces coincide at the interface.
%
%        -nb_segs: (scalar) Number of intersection segments.
%
%        -inters_segs: (1 x nb_segs struct-array) Collection of segments describing the interface intersection.
%           Each segment is created such as it 'touches' only one element of each side of the interface.
%           Thus, such segment is suitable for computing integrals along the interface involving, for instance,
%           basis functions defined on both sides. The struct contains the following fields:
%
%           +nb_pts: (scalar) Number of quadrature points.
%
%           +srfs_seg: (1 x 2 struct-array) Struct array containing information of the segment of both surfaces
%              at the interface. It contains two entries, one per surface. Their fieldnames are:
%
%              >elem_id: (scalar) Index of the element the segment 'touches' in the current surface.
%                 Indices start at 1.
%              >tile: (1 x 1 struct-array) Integration tile curve for the segment. This curve is contained in the
%                 parametric domain of the current trimmed surface.
%                 Notice that this segment may not be a Bezier curve and may is not subjected to the input
%                 options 'reparam_deg' and 'nb_reparam_elems'. However, it is guaranteed that its parametric
%                 domain is [0, 1]. It is defined using NURBS toolbox format.
%              >quad_pts: (2 x nb_pts matrix) Coordinates of the quadrature points on this surface side.
%                 Each column corresponds to a point, and the (two) rows to the x and y coordinates.
%                 The position of points is referred to the parametric domain of the trimmed surface.
%                 I.e., they don't need to be re-scaled from the unit reference domain to the
%                 parametric domain of the element.   
%              >quad_weights: (1 x nb_pts vector) Weights associated to the quadrature points on this surface side.
%                 The weights are referred to the parametric domain of this trimmed surface and don't require
%                 to be re-scaled by multiplying them with the area of the parametric element.
%              >normals: (rdim x nb_pts matrix) Unit normal vectors at the quadrature points on this side.
%                 These are normals in the physical (Euclidean) domain, not the parametric one. They point outwards.
%
