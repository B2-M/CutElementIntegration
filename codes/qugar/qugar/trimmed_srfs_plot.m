% REF_TRIMMED_SRFS: refinement operator for non-conforming multi-patch surfaces.
%
%  Copyright (C) 2023 Pablo Antolin <pablo.antolin@epfl.ch>
% 
%  See the attached LICENSE file.
%

function trimmed_srfs_plot (trim_srf_multipatch, varargin)
% NRBPLOT_TRIM_SRFS: Plots a single trimmed surface.
%
% Calling Sequence:
%
%   trimmed_srfs_plot(trim_srf_multipatch)
%   trimmed_srfs_plot(trim_srf_multipatch, 'option1', value1, ...)
%
% INPUT:
%
%   trim_srf_multipatch: Multi-patch trimmed surfaces reparameterization
%                        (output of trimmed_srfs)
%
%   [p,v]:    Property/Value options:
%            
%              Name         |  Default value  |  Description
%           ----------------+-----------------+-----------------------------------------------------------
%             nsub_per_elem |      [3 3]      |  Number of subdivisions per element
%                           |                 |
%             param_domain  |      false      |  Wether if the geometrical domain must be plotted.
%                           |                 |
%             knots         |      true       |  Wether if knot lines must be plotted
%                           |                 |
%             tiles         |      false      |  Wether if reparameterization tiles must be plotted
%                           |                 |
%             labels        |      false      |  Wether if boundary labels must be plotted
%                           |                 |
%             quad_pts      |      false      |  Wether if quadrature points (if present) must be plotted
%                           |                 |
%             color         |   summer green  |  Color to use for the surfaces
%                           |                 |
%
% See also:
%
%   nrbkntplot


if (nargin < 1)
    error ('nrbplot_trim_srf: Needs a trimmed surface to plot!');
end

options = parse_input(varargin{:});

n_srfs = numel(trim_srf_multipatch.trim_srfs);
if (options.param_domain)
    if (n_srfs > 1)
        plot_parametric_separate_files(trim_srf_multipatch, options, varargin{:});
        return;
    end
end

hold_flag = ishold;
hold on;

solid_colors = generate_solid_colors(trim_srf_multipatch, options.labels, options.color);
bound_colors = generate_bound_colors(trim_srf_multipatch);

bound_id = 1;
for i = 1 : n_srfs

    trim_srf = trim_srf_multipatch.trim_srfs(i);

    solid_color = solid_colors(i, :);
    n_bounds = numel(trim_srf.boundaries);
    bound_colors_srf = bound_colors(bound_id:bound_id + n_bounds-1, :);
    bound_id = bound_id + n_bounds;

    plot_trimmed_surface(trim_srf, options, solid_color, bound_colors_srf);

end

if (options.labels)
    plot_interfaces(trim_srf_multipatch.interfaces, options.nsub_per_elem, bound_colors(bound_id:end, :));
end

if (options.quad_pts)
    plot_interfaces_quad_pts(trim_srf_multipatch);
end

if (options.labels)
    create_colorbar(trim_srf_multipatch, options);
end


axis equal;

if (~hold_flag)
    hold off
end

end

function options = parse_input(varargin)

% Default values
options.knots = true;
options.tiles = false;
options.quad_pts = false;
options.labels = false;
options.param_domain = false;
options.nsub_per_elem = [3 3];
options.color = [];


% Recover Param/Value pairs from argument list
for i=1:2:nargin
    Param = varargin{i};
    Value = varargin{i+1};
    if (~ischar (Param))
        error ('nrbplot_trim_srf: Parameter must be a char-array')
    elseif size(Param,1)~=1
        error ('nrbplot_trim_srf: Parameter must be a non-empty single row char-array.')
    end
    switch lower (Param)
        case 'nsub_per_elem'
            if numel (Value) == 2
                options.nsub_per_elem=reshape(Value, [1, 2]);
            elseif numel (Value) == 1
                options.nsub_per_elem=[Value, Value];
            else
                error ('nrbplot_trim_srf: Needs a trimmed surface to plot!')
            end
        case 'knots'
            options.knots = lower (Value);
            if (~isa(options.knots, 'logical'))
                error ('nrbplot_trim_srf: knots must be a boolean.')
            end
        case 'tiles'
            options.tiles = lower (Value);
            if (~isa(options.tiles, 'logical'))
                error ('nrbplot_trim_srf: tiles must be a boolean.')
            end
        case 'quad_pts'
            options.quad_pts = lower (Value);
            if (~isa(options.quad_pts, 'logical'))
                error ('nrbplot_trim_srf: quad_pts must be a boolean.')
            end
        case 'param_domain'
            options.param_domain = lower (Value);
            if (~isa(options.param_domain, 'logical'))
                error ('nrbplot_trim_srf: param_domain must be a boolean.')
            end
        case 'labels'
            options.labels = lower (Value);
            if (~isa(options.labels, 'logical'))
                error ('nrbplot_trim_srf: labels must be a boolean.')
            end
        case 'color'
            if ischar (Value)
                options.color = char2rgb (lower(Value));
            elseif numel(Value) == 3
                options.color=reshape(Value, [1, 3]);
            else
                error ('nrbplot_trim_srf: color must be either a string or an (1x3) array of values in the range [0, 1].')
            end
        otherwise
            error ('nrbplot_trim_srf: Unknown parameter: %s', Param)
    end
end

end

function plot_surface(trim_srf, options, solid_color)
plot_non_cut_elements(trim_srf, options, solid_color);
plot_cut_elements(trim_srf, options, solid_color);
end

function plot_non_cut_elements(trim_srf, options, solid_color)

breaks = get_surface_breaks(trim_srf.srf);
nel_dir = get_nel_dir(breaks);
if (options.param_domain)
    options.nsub_per_elem = [1, 1];
else
    srf = trim_srf.srf;
    for dir = 1 : 2
        if (srf.order(dir) == 2)
            options.nsub_per_elem(dir) = 1;
        end
    end
end

verts = evaluate_in_grid(trim_srf.srf, options);
nu = size(verts, 2);
nv = size(verts, 3);
verts = permute(reshape(verts, 3, nu * nv), [2 1]);


nb_elems = trim_srf.nb_non_trim_elems;
nb_cells_per_elem = prod(options.nsub_per_elem);

faces = zeros(nb_cells_per_elem * nb_elems, 4);

n1 = options.nsub_per_elem(1);
n2 = options.nsub_per_elem(2);


faces_shift = zeros(nb_cells_per_elem, 4);
for jj = 1 : n2
    for ii = 1 : n1
        face_id = ii + (jj - 1) * n1;
        faces_shift(face_id, 1) = ii - 1 + (jj - 1) * nu;
        faces_shift(face_id, 2) = faces_shift(face_id, 1) + 1;
        faces_shift(face_id, 3) = faces_shift(face_id, 2) + nu;
        faces_shift(face_id, 4) = faces_shift(face_id, 3) - 1;
    end
end

for i = 1 : nb_elems
    elem_ids = get_element_indices(trim_srf.non_trim_elem_ids(i), nel_dir);

    u0 = 1 + n1 * (elem_ids(1) - 1);
    v0 = 1 + n2 * (elem_ids(2) - 1);
    w0 = (v0 - 1) * nu + u0;
    face_id = 1 + (i - 1) * nb_cells_per_elem;

    faces(face_id:face_id+nb_cells_per_elem - 1, :) = faces_shift + w0;
end

patch('Faces', faces, 'Vertices', verts, 'FaceColor', solid_color, 'EdgeColor', 'none');

if (options.knots)
    plot_knots_non_cut_elements(trim_srf, verts, nu, options);
end

end

function plot_cut_elements(trim_srf, options, solid_color)

if (trim_srf.nb_trim_elems == 0)
    return;
end

nsub_per_tile = max(options.nsub_per_elem);
tile_samples = {linspace(0, 1, nsub_per_tile + 1), linspace(0, 1, nsub_per_tile + 1)};

surface = trim_srf.srf;
breaks = get_surface_breaks(surface);

nb_tot_tiles = sum([trim_srf.trim_elems(:).nb_tiles]);
nb_verts_per_tile = (nsub_per_tile + 1) ^ 2;
nb_cells_per_tile = nsub_per_tile ^ 2;

faces_shift = zeros(nb_cells_per_tile, 4);
for jj = 1 : nsub_per_tile
    for ii = 1 : nsub_per_tile
        face_id = ii + (jj - 1) * nsub_per_tile;
        faces_shift(face_id, 1) = ii + (jj - 1) * (nsub_per_tile + 1);
        faces_shift(face_id, 2) = faces_shift(face_id, 1) + 1;
        faces_shift(face_id, 3) = faces_shift(face_id, 2) + nsub_per_tile + 1;
        faces_shift(face_id, 4) = faces_shift(face_id, 3) - 1;
    end
end


verts = zeros(3, nb_tot_tiles * nb_verts_per_tile);

faces = zeros(nb_tot_tiles, 4);

v_id = 1;
f_id = 1;
t_id = 1;
for i = 1 : trim_srf.nb_trim_elems
    if (~options.param_domain)
        elem_domain = get_element_domain(trim_srf.trim_elem_ids(i), breaks);
    end

    for j = 1 : trim_srf.trim_elems(i).nb_tiles

        faces(f_id:f_id+nb_cells_per_tile-1, :) = faces_shift + nb_verts_per_tile * (t_id - 1);
        t_id = t_id + 1;
        f_id = f_id + nb_cells_per_tile;

        tile = trim_srf.trim_elems(i).tiles(j);
        uv_pts = nrbeval (tile, tile_samples);

        if (options.param_domain)
            verts(:, v_id:v_id + nb_verts_per_tile - 1) = uv_pts(1:3, :);
        else
            verts(:, v_id:v_id + nb_verts_per_tile - 1) = enforce_points_in_domain(uv_pts(1:3, :), elem_domain);
        end
        v_id = v_id + nb_verts_per_tile;
    end

end

if (~options.param_domain)
    verts = nrbeval(surface, verts(1:2, :));
end

patch('Faces', faces, 'Vertices', verts', 'FaceColor', solid_color, 'EdgeColor', 'none');

if (options.knots)
    plot_knots_cut_elements(trim_srf, verts, options);
end

end

function plot_knots_cut_elements(trim_srf, verts, options)

npts_per_dir = max(options.nsub_per_elem) + 1;
npts_per_tile = npts_per_dir ^ 2;
n_tiles = sum([trim_srf.trim_elems(:).nb_tiles]);

i0 = 1;
i1 = npts_per_dir;
i2 = npts_per_dir * (npts_per_dir - 1) + 1;
i3 = npts_per_dir * npts_per_dir;

local_pts_perimeter = zeros(npts_per_dir, 4);
local_pts_perimeter(:, 1) = i2:-npts_per_dir:i0;
local_pts_perimeter(:, 2) = i0:i1;
local_pts_perimeter(:, 3) = i1:npts_per_dir:i3;
local_pts_perimeter(:, 4) = i3:-1:i2;
n_perimeter = numel(local_pts_perimeter);

new_verts = nan(3, n_tiles * (n_perimeter + 1));
if (options.tiles)
    new_verts_internal = nan(3, n_tiles * (n_perimeter + 1));
end

tolerance = 1.0e-12; % For identifying common faces between tiles

t_id = 0;
internal_id = 0;
for i = 1 : trim_srf.nb_trim_elems
    for j = 1 : trim_srf.trim_elems(i).nb_tiles
        tile_j = t_id + j;
        v = (tile_j - 1) * (n_perimeter + 1) + 1;
        new_verts(:, v : v + n_perimeter - 1) = verts(1:3, local_pts_perimeter(:) + (tile_j - 1) * npts_per_tile);
    end

    % Looking for coincident boundaries.
    for j = 1 : trim_srf.trim_elems(i).nb_tiles
        tile_j = t_id + j;
        for bj = 1 : 4
            vj = (tile_j - 1) * (n_perimeter + 1) + 1;
            ids_j = vj + (bj-1) * npts_per_dir: vj + bj * npts_per_dir - 1;
            coincidence_found = false;

            for k = j + 1 : trim_srf.trim_elems(i).nb_tiles
                tile_k = t_id + k;
                for bk = 1 : 4
                    vk = (tile_k - 1) * (n_perimeter + 1) + 1;
                    ids_k = vk + bk * npts_per_dir - 1 : -1 : vk + (bk-1) * npts_per_dir;
                    if (norm(new_verts(:, ids_j) - new_verts(:, ids_k)) < tolerance)
                        if (options.tiles)
                            new_verts_internal(:, internal_id+1:internal_id + npts_per_dir) = new_verts(:, ids_j);
                            internal_id = internal_id + npts_per_dir + 1;
                        end
                        new_verts(:, ids_j) = nan;
                        new_verts(:, ids_k) = nan;
                        coincidence_found = true;
                        break;
                    end
                end
                if (coincidence_found)
                    break;
                end
            end
        end
    end

    t_id = t_id + trim_srf.trim_elems(i).nb_tiles;
end

plot3(new_verts(1, :), new_verts(2, :), new_verts(3, :), 'k');
if (options.tiles)
    plot3(new_verts_internal(1, :), new_verts_internal(2, :), new_verts_internal(3, :), 'k--');
end

end

function plot_knots_non_cut_elements(trim_srf, verts, nu, options)

n1 = options.nsub_per_elem(1);
n2 = options.nsub_per_elem(2);

breaks = get_surface_breaks(trim_srf.srf);
nel_dir = get_nel_dir(breaks);

points_mask = 0:n1;
for i = 1 : n2
    points_mask = [points_mask, points_mask(end) + nu];
end
for i = 1 : n1
    points_mask = [points_mask, points_mask(end) - 1];
end
for i = 1 : n2
    points_mask = [points_mask, points_mask(end) - nu];
end
nm = numel(points_mask);

nb_elems = trim_srf.nb_non_trim_elems;

all_pts = nan((nm + 1) * nb_elems, 3);

j = 1;
for i = 1 : nb_elems
    elem_ids = get_element_indices(trim_srf.non_trim_elem_ids(i), nel_dir);

    u0 = 1 + n1 * (elem_ids(1) - 1);
    v0 = 1 + n2 * (elem_ids(2) - 1);
    w0 = (v0 - 1) * nu + u0;

    all_pts(j : j + nm - 1, :) = verts(w0 + points_mask, :);
    j = j + nm + 1;

end

plot3(all_pts(:, 1), all_pts(:, 2), all_pts(:, 3), 'k');


end

function rgbvec = char2rgb (charcolor)
% Copied from  https://stackoverflow.com/questions/4922383/how-can-i-convert-a-color-name-to-a-3-element-rgb-vector
% Lately modified by Pablo Antolin
%function rgbvec = char2rgb (charcolor)
%
%converts a character color (one of 'r','red','g','green','b','blue','c','cyan','m','magenta','y'.'yellow','k','black','w','white') to a 3
%value RGB vector

rgbvec = zeros(1, 3);
for j = 1:length(charcolor)
    switch(lower(charcolor(j)))
        case 'r'
        case 'red'
            rgbvec = [1 0 0];
        case 'g'
        case 'green'
            rgbvec = [0 1 0];
        case 'b'
        case 'blue'
            rgbvec = [0 0 1];
        case 'c'
        case 'cyan'
            rgbvec = [0 1 1];
        case 'm'
        case 'magenta'
            rgbvec = [1 0 1];
        case 'y'
        case 'yellow'
            rgbvec = [1 1 0];
        case 'w'
        case 'white'
            rgbvec = [1 1 1];
        case 'k'
        case 'black'
            rgbvec = [0 0 0];
        otherwise
            error('nrbplot_trim_srf: invalid color string.');
    end
end
end

function plot_cut_elements_quad_pts(trim_srf, param_domain)
plot_cut_elements_interior_quad_pts(trim_srf, param_domain);
plot_cut_elements_boundaries_quad_pts(trim_srf, param_domain);
end

function plot_cut_elements_interior_quad_pts(trim_srf, param_domain)

if (min([trim_srf.trim_elems(:).nb_pts]) < 1)
    return;
end

surface = trim_srf.srf;

breaks = get_surface_breaks(surface);

nb_pts = sum([trim_srf.trim_elems(:).nb_pts]);

if (nb_pts == 0)
    return;
    
end
all_quad_pts = zeros(3, nb_pts);

j = 1;
for i = 1 : trim_srf.nb_trim_elems

    n = trim_srf.trim_elems(i).nb_pts;
    quad_pts = trim_srf.trim_elems(i).quad_pts;
    if (param_domain)
        all_quad_pts(1:2, j : j + n-1) = quad_pts;
    else
        elem_domain = get_element_domain(trim_srf.trim_elem_ids(i), breaks);
        all_quad_pts(1:2, j : j + n-1) = enforce_points_in_domain(quad_pts, elem_domain);
    end

    j = j + n;

end

if (~param_domain)
    all_quad_pts = nrbeval(surface, all_quad_pts(1:2,:));
end

plot3(all_quad_pts(1, :), all_quad_pts(2, :), all_quad_pts(3, :), 'k.');

end

function plot_cut_elements_boundaries_quad_pts(trim_srf, param_domain)

surface = trim_srf.srf;
breaks = get_surface_breaks(surface);

for bound = trim_srf.boundaries
    if (min([bound.reparam_elems(:).nb_pts]) < 1)
        continue;
    end

    for elem = bound.reparam_elems

        quad_pts = elem.quad_pts;

        if (param_domain)
            p = zeros(3, size(quad_pts, 2));
            p(1, :) = quad_pts(1, :);
            p(2, :) = quad_pts(2, :);
        else
            elem_domain = get_element_domain(elem.elem_id, breaks);
            quad_pts = enforce_points_in_domain(quad_pts, elem_domain);
            p = nrbeval(surface, quad_pts);
        end

        plot3(p(1, :), p(2, :), p(3, :), 'k.');

    end
end

end

function plot_boundary_labels(trim_srf, options, plot_interfaces, colors)

n_bounds = numel(trim_srf.boundaries);

surface = trim_srf.srf;

for i = 1 : n_bounds
    bound = trim_srf.boundaries(i);
    color = colors(i, :);
    if (~plot_interfaces && bound.interface)
        continue
    end
    plot_single_boundary_label(surface, bound, options, color);
end

end

function plot_single_boundary_label(surface, bound, options, bound_color)

plot_boundaries_non_cut_elements(surface, bound, options, bound_color);
plot_boundaries_cut_elements(surface, bound, options, bound_color);

pt = get_boundary_point(surface, bound, options.param_domain);

label = sprintf('Bound label %d', bound.label);
text(pt(1), pt(2), pt(3), label);

end

function pt = get_boundary_point(surface, boundary, param_domain)

breaks = get_surface_breaks(surface);

if (boundary.nb_non_trim_elems > 0)
    n = ceil(boundary.nb_non_trim_elems / 2);
    elem_id = boundary.non_trim_elem_bd_ids(n);
    elem_domain = get_element_domain(elem_id, breaks);
    param_side = boundary.param_side;
    act_dir = 3 - floor((param_side + 1) / 2);
    const_dir = 3 - act_dir;

    uv_pt = zeros(1, 3);
    uv_pt(act_dir) = 0.5 * sum(elem_domain(act_dir, :));
    uv_pt(const_dir) = elem_domain(const_dir, 2 - mod(param_side, 2));
    if (param_domain)
        pt = uv_pt;
    else
        pt = nrbeval(surface, uv_pt(1:2));
    end
else
    n = ceil(boundary.nb_reparam_elems / 2);
    elem = boundary.reparam_elems(n);
    tile = elem.tiles(ceil(elem.nb_tiles / 2));

    uv_pt = nrbeval(tile, 0.5);
    if (param_domain)
        pt = uv_pt;
    else
        elem_domain = get_element_domain(elem.elem_id, breaks);
        uv_pt = enforce_points_in_domain(uv_pt, elem_domain);
        pt = nrbeval(surface, uv_pt(1:2));
    end
end


end

function plot_boundaries_non_cut_elements(surface, boundary, options, bound_color)

param_side = boundary.param_side;
if (param_side == 0)
    return;
end

nel_dir = get_nel_dir(get_surface_breaks(surface));
pts = evaluate_in_grid(surface, options);

for elem_id = boundary.non_trim_elem_bd_ids

    elem_ids = get_element_indices(elem_id, nel_dir);

    u0 = 1 + options.nsub_per_elem(1) * (elem_ids(1) - 1);
    u1 = u0 + options.nsub_per_elem(1);
    v0 = 1 + options.nsub_per_elem(2) * (elem_ids(2) - 1);
    v1 = v0 + options.nsub_per_elem(2);

    if (param_side == 1)
        bound_pts = pts(:, u0, v0:v1);
    elseif (param_side == 2)
        bound_pts = pts(:, u1, v0:v1);
    elseif (param_side == 3)
        bound_pts = pts(:, u0:u1, v0);
    else
        bound_pts = pts(:, u0:u1, v1);
    end

    plot3(bound_pts(1, :), bound_pts(2, :), bound_pts(3, :), 'color', bound_color, 'LineWidth', 2);
end


end

function plot_boundaries_cut_elements(surface, boundary, options, bound_color)

breaks = get_surface_breaks(surface);

nt = max(options.nsub_per_elem) + 1;
t = linspace(0, 1, nt);
n_tiles = sum([boundary.reparam_elems(:).nb_tiles]);

all_pts = nan(3, n_tiles * (nt + 1));

t_id = 0;
for elem = boundary.reparam_elems

    elem_domain = get_element_domain(elem.elem_id, breaks);
    for tile = elem.tiles

        i0 = t_id * (nt + 1) + 1;
        i1 = i0 + nt - 1;

        pts = nrbeval(tile, t);
        if (options.param_domain)
            all_pts(:, i0:i1) = pts;
        else
            pts = enforce_points_in_domain(pts, elem_domain);
            all_pts(:, i0:i1) = nrbeval(surface, pts(1:2, :));
        end

        t_id = t_id + 1;
    end

end

plot3(all_pts(1, :), all_pts(2, :), all_pts(3, :), 'color', bound_color, 'LineWidth', 2);


end

function pts = evaluate_in_grid(surface, options)

breaks = get_surface_breaks(surface);
nel_dir = get_nel_dir(breaks);
samples = cell(1, 2);
for dir = 1 : 2
    nel_samples_dir = nel_dir(dir) * options.nsub_per_elem(dir) + 1;
    idx = 1 : (nel_dir(dir) + 1);
    idxq = linspace(min(idx), max(idx), nel_samples_dir);
    samples{dir} = interp1(idx, breaks{dir}, idxq, 'linear');
end

% Evaluating all points.
if (options.param_domain)
    pts = zeros(3, numel(samples{1}), numel(samples{2}));
    pts(1, :, :) = repmat(samples{1}, [1, 1, numel(samples{2})]);
    pts(2, :, :) = permute(repmat(samples{2}, [1, 1, numel(samples{1})]), [1, 3, 2]);
else
    pts = nrbeval (surface, samples);
end


end

function nel_dir = get_nel_dir(breaks)
ndim = numel(breaks);
nel_dir = zeros(1, ndim);
for dir = 1 : ndim
    nel_dir(dir) = numel(breaks{dir}) - 1;
end
end

function breaks = get_surface_breaks(surface)
breaks = cell(1, 2);
for dir = 1 : 2
    breaks{dir} = unique(surface.knots{dir});
end
end

function elem_ids = get_element_indices(elem_id, nel_dir)
ndim = numel(nel_dir);
indices = cell(1, ndim);
[indices{:}] = ind2sub (nel_dir, elem_id);
elem_ids = [indices{:}];
end

function elem_domain = get_element_domain(elem_id, breaks)

nel_dir = get_nel_dir(breaks);
ndim = numel(breaks);

elem_ids = get_element_indices(elem_id, nel_dir);

elem_domain = zeros(1, ndim);
for dir = 1 : ndim
    elem_domain(dir, 1) = breaks{dir}(elem_ids(dir));
    elem_domain(dir, 2) = breaks{dir}(elem_ids(dir)+1);
end
end

function pts = enforce_points_in_domain(pts, domain)
ndim = size(domain, 1);
for dir = 1 : ndim
pts(dir, :) = min(max(pts(dir, :), domain(dir, 1)), domain(dir, 2));
end
end

function pts = generate_interface_pts(interface, nsub)
curve = interface.curve;
t = linspace(curve.knots(1), curve.knots(end), nsub * interface.nb_segs + 1);
pts = nrbeval(curve, t);
end

function plot_parametric_separate_files(trim_srf_multipatch, options, varargin)
rdim = trim_srf_multipatch.rdim;
n_srfs = numel(trim_srf_multipatch.trim_srfs);
solid_colors = generate_solid_colors(trim_srf_multipatch, options.labels, options.color);
for i = 1 : n_srfs
    trm_srf = trim_srf_multipatch.trim_srfs(i);
    color = solid_colors(i, :);
    new_varargin = replace_color(color, varargin{:});
    if i > 1
    figure
    end
    patch = struct('rdim', rdim, 'trim_srfs', trm_srf, 'interfaces', []);
    trimmed_srfs_plot(patch, new_varargin{:});
    title(sprintf('Surface label %d', trm_srf.label))
end
end

function solid_colors = generate_solid_colors(trim_srf_multipatch, labels, color)

n_srfs = numel(trim_srf_multipatch.trim_srfs);

if (~isempty(color))
    solid_colors = repmat(color, [n_srfs, 1]);
elseif (labels)

    srf_labels = get_srf_labels(trim_srf_multipatch);
    if (numel(srf_labels) == 1)
        solid_colors = generate_solid_colors(trim_srf_multipatch, false, color);
        return;
    end

    colors = jet(numel(srf_labels));
    solid_colors = zeros(n_srfs, 3);
    for i = 1 : n_srfs      
        id = find(srf_labels == trim_srf_multipatch.trim_srfs(i).label, 1);
        solid_colors(i, :) = colors(id, :);
    end
else
    colormap ('summer');
    colors = colormap;
    solid_color = colors(100, :);
    solid_colors = generate_solid_colors(trim_srf_multipatch, false, solid_color);
end
end

function bound_colors = generate_bound_colors(trim_srf_multipatch)

n_bounds_and_intf = 0;
for trim_srf = trim_srf_multipatch.trim_srfs
    n_bounds_and_intf = n_bounds_and_intf + numel(trim_srf.boundaries);
end
n_bounds_and_intf = n_bounds_and_intf + numel(trim_srf_multipatch.interfaces);
bound_colors = jet(n_bounds_and_intf);

end

function plot_interfaces(interfaces, nsub_per_elem, colors)
    nsub = max(nsub_per_elem);
    for i = 1 : numel(interfaces)
        interface = interfaces(i);
        interface_color = colors(i, :);
        plot_interface(interface, nsub, interface_color);
    end
end

function plot_interface(interface, nsub, intf_color)
pts = generate_interface_pts(interface, nsub);
mid_pt = pts(:, ceil(size(pts, 2) / 2));

label = sprintf('Interface label %d', interface.label);
plot3(pts(1, :), pts(2, :), pts(3, :), 'LineWidth', 2, 'color', intf_color);
text(mid_pt(1), mid_pt(2), mid_pt(3), label);

end

function plot_interfaces_quad_pts(trim_srf_multipatch)
for interface = trim_srf_multipatch.interfaces
    trim_srf_1 = trim_srf_multipatch.trim_srfs(interface.srfs_info(1).srf_id_in_list);
    trim_srf_2 = trim_srf_multipatch.trim_srfs(interface.srfs_info(2).srf_id_in_list);
    plot_interface_quad_pts(interface, trim_srf_1, trim_srf_2);
end
end

function plot_interface_quad_pts(interface, trim_srf_1, trim_srf_2)

markers = ["ko", "kx"];

for i = 1 : 2

    if (i == 1)
        trim_srf = trim_srf_1;
    else
        trim_srf = trim_srf_2;
    end
    marker = markers(i);

    n_pts_per_seg = interface.inters_segs(1).nb_pts;
    n_pts = numel(interface.inters_segs) * n_pts_per_seg;
    pts = zeros(3, n_pts);

    surface = trim_srf.srf;
    breaks = get_surface_breaks(surface);
    j = 1;
    for seg = interface.inters_segs
        elem_domain = get_element_domain(seg.srfs_seg(i).elem_id, breaks);

        uv_pts = enforce_points_in_domain(seg.srfs_seg(i).quad_pts, elem_domain);
        pts(:, j:j+n_pts_per_seg-1) = nrbeval(surface, uv_pts);

        j = j + n_pts_per_seg;
    end

    plot3(pts(1, :), pts(2, :), pts(3, :), marker);

end
end

function plot_trimmed_surface(trim_srf, options, solid_color, bound_colors)

    plot_surface(trim_srf, options, solid_color);

    if (options.labels)
        plot_interfaces = options.param_domain;
        plot_boundary_labels(trim_srf, options, plot_interfaces, bound_colors);
    end

    if (options.quad_pts)
        plot_cut_elements_quad_pts(trim_srf, options.param_domain);
    end

end

function new_varargin = replace_color(color, varargin)

new_varargin = varargin;

for i=1:2:nargin-1
    Param = new_varargin{i};
    switch lower (Param)
        case 'color'
            new_varargin{i+1} = color;
            return;
    end
end

new_varargin{numel(new_varargin) + 1} = 'color';
new_varargin{numel(new_varargin) + 1} = color;

end

function create_colorbar(trim_srf_multipatch, options)

if (options.param_domain)
    return
end

srf_labels = get_srf_labels(trim_srf_multipatch);
n_labels = numel(srf_labels);

if (n_labels == 1)
    return
end

colormap(jet(n_labels));

c = colorbar('Ticks', linspace(0, 1, n_labels), ...
    "TickLabels", srf_labels, 'Location', 'southoutside');
c.Label.String = 'Trimmed surface label';

end

function labels = get_srf_labels(trim_srf_multipatch)
labels = [trim_srf_multipatch.trim_srfs(:).label];
labels = sort(unique(labels));
end
