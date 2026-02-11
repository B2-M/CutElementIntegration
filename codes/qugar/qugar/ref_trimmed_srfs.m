% REF_TRIMMED_SRFS: refinement operator for non-conforming multi-patch surfaces.
%
%  Copyright (C) 2023 Pablo Antolin <pablo.antolin@epfl.ch>
% 
%  See the attached LICENSE file.
%
%
% CALLING SEQUENCE:
%
%     output = ref_trimmed_srfs (n_ref, trim_srfs,  'option1', value1, ...);
%
% DESCRIPTION:
%
% This function perform a series of dyadic refinements of the multi-patch
% geometry defined in 'trim_srfs'. It just calls the function 'trimmed_srfs'
% once for every dyadic refinement of the underlying surfaces, starting
% from the original (non-refined) case.
%
% The result is an array of reparameterized multi-patch trimmed surfaces.
%
% All the details about the inputs and output arguments can be found in
% the documentation of 'trimmed_srfs'.
%
% INPUTS:
%     
%    n_ref:           Number of dyadic refinement to perform.
%     
%    trim_srfs:       Collection of (2D or 3D) trimmed surfaces.
%
%    'option', value: Additional optional parameters.
%    
%    Check the documentation of the function 'trimmed_srfs' for all the
%    details about 'trim_srfs' and the available options.
%   
% OUTPUT:
%
%     Struct array with one entry per dyadic refinement, starting from the
%     non-refined geometry. I.e., the output has n_ref + 1 entries.
%     The fieldnames of the struct are:
%
%     FIELD_NAME    (SIZE)                    DESCRIPTION
%
%     rdim          (scalar)                  Dimension of the physical space (either 2D or 3D).
%
%     trim_srfs     (1 x T struct-array)      T trimmed surfaces.
%
%     interfaces    (1 x I struct-array)      I interfaces between trimmed surfaces.
%
%     Each entry of the array is equivalent to the output of a single call
%     to the function 'trimmed_srfs'. Check its documentation for further details.
%
function output = ref_trimmed_srfs (n_ref, trim_srfs, varargin)
if (n_ref < 0)
    error('ref_trimmed_srfs: Invalid number of refinements.');
end

if (ischar(trim_srfs) || isstring(trim_srfs))
  error(['ref_trimmed_srfs: Invalid geometry input. '...
      'Refinement function not implemented for geometries loaded from a STEP file.']);
end

output(1) = trimmed_srfs(trim_srfs, varargin{:});

for ref_id = 1 : n_ref
    trim_srfs = refine_geometry_dyadic(trim_srfs);
    output(ref_id + 1) = trimmed_srfs(trim_srfs, varargin{:});
end

end

function new_trim_srfs = refine_geometry_dyadic(trim_srfs)
new_trim_srfs = trim_srfs;
for i = 1 : numel(trim_srfs)
    new_trim_srfs(i).srf = refine_surface_dyadic(trim_srfs(i).srf);
end
end

function surface = refine_surface_dyadic(surface)
breaks = get_surface_breaks(surface);
new_knots = cell(1, 2);
for i = 1 : 2
    new_knots{i} = 0.5 * (breaks{i}(1:end-1) + breaks{i}(2:end));
end
surface = nrbkntins(surface, new_knots);
end

function breaks = get_surface_breaks(surface)
breaks = cell(1, 2);
for dir = 1 : 2
    breaks{dir} = unique(surface.knots{dir});
end
end
