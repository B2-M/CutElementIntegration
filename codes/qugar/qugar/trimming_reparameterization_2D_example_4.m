%
%  Copyright (C) 2023 Pablo Antolin <pablo.antolin@epfl.ch>
% 
%  See the attached LICENSE file.
%

clear all;
clc;
close all;


R = 0.26;

% Plate with hole
loop_1(1).curve = nrbline([0, R], [0, 1]);
loop_1(1).label = 1;
loop_1(2).curve = nrbline([0, 1], [1, 1]);
loop_1(2).label = 4;
loop_1(3).curve = nrbline([1, 1], [1, 0]);
loop_1(3).label = 2;
loop_1(4).curve = nrbline([1, 0], [R, 0]);
% loop_1(4).label = 3;
loop_1(5).curve = nrbcirc(R, [0,0], 0.0, pi/2);
loop_1(5).label = 5;
square_1 = nrbsquare([0,0], 1, 1);
square_1 = nrbkntins(square_1, {linspace(0.1, 0.9, 5), linspace(0.1, 0.9, 3)});

trimmed_srf(1).srf = square_1;
trimmed_srf(1).trim_loops = {loop_1};
trimmed_srf(1).label = 1;


% Right square
loop_2(1).curve = nrbline([0, 0], [0, 1]);
loop_2(1).label = 2;
loop_2(2).curve = nrbline([0, 1], [1, 1]);
loop_2(2).label = 4;
loop_2(3).curve = nrbline([1, 1], [1, 0]);
loop_2(3).label = 12;
loop_2(4).curve = nrbline([1, 0], [0, 0]);
loop_2(4).label = 3;

square_2 = nrbsquare([1,0],1,1);
square_2 = nrbkntins(square_2, {linspace(0.1, 0.9, 5), linspace(0.1, 0.9, 3)});
trimmed_srf(2).srf = square_2;
trimmed_srf(2).trim_loops = {loop_2};
trimmed_srf(2).label = 2;

% Bottom square
square_3 = nrbsquare([R,-1],1-R,1);
trimmed_srf(3).srf = square_3;
trimmed_srf(3).trim_loops = {};
trimmed_srf(3).label = 3;

reparam_degree = 2;
n_quad_pts = 3;
reparam = trimmed_srfs(trimmed_srf, 'reparam_deg', reparam_degree, 'nb_quad_pts', n_quad_pts);

% Plotting result.
trimmed_srfs_plot(reparam, 'labels', true, 'quad_pts', true, 'tiles', true);

% Computing area of the trimmed domains.


param_areas = [1 - 0.5 * pi * R ^ 2, 1, 1];
for i = 1 : numel(reparam.trim_srfs)

trim_srf = reparam.trim_srfs(i);
srf = trim_srf.srf;
breaks = cell(1, 2);
breaks{1} = unique(srf.knots{1});
breaks{2} = unique(srf.knots{2});


area = 0;

for elem_id = trim_srf.non_trim_elem_ids
    area = area + get_element_area(breaks, elem_id);
end

for j = 1 : trim_srf.nb_trim_elems
    area = area + sum(trim_srf.trim_elems(j).quad_weights);
end

format long
fprintf("Surface %d: Relative area error %f\n", i, abs(param_areas(i) - area) / param_areas(i));


% Computing lenghts of boundaries
for bound_id = 1 : numel(trim_srf.boundaries)
    b = trim_srf.boundaries(bound_id);

    label = b.label;

    length = 0;
    for elem_id = b.non_trim_elem_bd_ids
      length = length + get_element_sides_length(breaks, elem_id, b.param_side);
    end

    for j = 1 : b.nb_reparam_elems
        length = length + sum(b.reparam_elems(j).quad_weights);
    end
    fprintf("  Length of boundary with label %d: %f\n", label, length);
end

end

% Computing lengths of interfaces
for i = 1 : numel(reparam.interfaces)
intf = reparam.interfaces(i);
length_1 = 0;
length_2 = 0;

for seg = intf.inters_segs
    length_1 = length_1 + sum(seg.srfs_seg(1).quad_weights);
    length_2 = length_2 + sum(seg.srfs_seg(2).quad_weights);
end
    fprintf("Interface with label %d\n", intf.label);
    fprintf("  First parametric length %f\n", length_1);
    fprintf("  First parametric length %f\n", length_2);
end

function length = get_element_sides_length(breaks, elem_id, side)

elem_id_dir = get_element_indices(breaks, elem_id);

if side == 1 || side == 2
length = breaks{2}(elem_id_dir(2)+1) - breaks{2}(elem_id_dir(2));
else
length = breaks{1}(elem_id_dir(1)+1) - breaks{1}(elem_id_dir(1));
end


end

function area = get_element_area(breaks, elem_id)

elem_id_dir = get_element_indices(breaks, elem_id);
ndim = numel(breaks);

area = 1;
for dir = 1 : ndim
    area = area * (breaks{dir}(elem_id_dir(dir)+1) - breaks{dir}(elem_id_dir(dir)));
end

end

function elem_id_dir = get_element_indices(breaks, elem_id)
ndim = numel(breaks);
nel_dir = get_nel_dir(breaks);
indices = cell(1, ndim);
[indices{:}] = ind2sub (nel_dir, elem_id);
elem_id_dir = [indices{:}];
end

function nel_dir = get_nel_dir(breaks)
ndim = numel(breaks);
nel_dir = zeros(1, ndim);
for dir = 1 : ndim
    nel_dir(dir) = numel(breaks{dir}) - 1;
end
end
