%
%  Copyright (C) 2023 Pablo Antolin <pablo.antolin@epfl.ch>
% 
%  See the attached LICENSE file.
%

clear all;
clc;
close all;


square = nrbsquare([0,0], 1, 1, 1);
R = 0.1;

loop_0 = struct();
loop_0(1).curve = nrbline([0,1],[0.4,1]);
loop_0(1).label = 1; % This is optional;
loop_0(2).curve = nrbcirc(R, [0.5, 1], pi, 2 * pi);
% loop_0(2).label = 6; % This is optional;
loop_0(3).curve = nrbline([0.6,1],[1,1]);
loop_0(3).label = 7; % This is optional;

loop_0(4).curve = nrbline([1,1],[1,0]);
loop_0(4).label = 8; % This is optional;
loop_0(5).curve = nrbline([1,0],[0,0]);
loop_0(6).label = 9; % This is optional;
loop_0(6).curve = nrbline([0,0],[0,1]);
% loop_0(6).label = 10; % This is optional;

loop_1 = struct();
loop_1(1).curve = nrbcirc(R, [0.25, 0.35]);
loop_1(1).label = 11;

trimmed_srf.srf = square;
trimmed_srf.trim_loops = {loop_0, loop_1};

n_refs = 5;
reparam_degree = 2;
n_quad_pts = 3;
reparam = ref_trimmed_srfs(n_refs, trimmed_srf, 'reparam_deg', reparam_degree, 'nb_quad_pts', n_quad_pts);

% Plotting result.
ref_id = 5;
trimmed_srfs_plot(reparam(ref_id), 'labels', true, 'quad_pts', true, 'tiles', true);

% Computing area of the trimmed domain.
breaks = cell(1, 2);
trim_srf = reparam(ref_id).trim_srfs(1);
srf = trim_srf.srf;
breaks{1} = unique(srf.knots{1});
breaks{2} = unique(srf.knots{2});

exact_area = 1 - pi * R ^ 2 - 0.5 * pi * R ^ 2;

h = 1 / (numel(breaks{1}) - 1);
area = trim_srf.nb_non_trim_elems * h * h;

for i = 1 : trim_srf.nb_trim_elems
    area = area + sum(trim_srf.trim_elems(i).quad_weights);
end

format long
fprintf("Relative area error %f\n", abs(exact_area - area) / exact_area);


% Computing lenghts of boundaries
for bound_id = 1 : numel(trim_srf.boundaries)
    b = trim_srf.boundaries(bound_id);

    label = b.label;

    length = b.nb_non_trim_elems * h;
    for i = 1 : b.nb_reparam_elems
        length = length + sum(b.reparam_elems(i).quad_weights);
    end
    fprintf("Length of boundary with label %d: %f\n", label, length);
end

