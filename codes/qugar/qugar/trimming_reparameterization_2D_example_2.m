%
%  Copyright (C) 2023 Pablo Antolin <pablo.antolin@epfl.ch>
% 
%  See the attached LICENSE file.
%

clear all;
clc;
close all;


square = nrbsquare([0,0], 1, 1, 1);


loop_0 = struct();
loop_0(1).curve = nrbline([0,1],[0.4,1]);
loop_0(1).label = 1; % This is optional;
loop_0(2).curve = nrbcirc(0.1, [0.5, 1], pi, 2 * pi);
% loop_0(2).label = 6; % This is optional;
loop_0(3).curve = nrbline([0.6,1],[1,1]);
loop_0(3).label = 7; % This is optional;
loop_0(4).curve = nrbline([1,1],[1,0]);
loop_0(4).label = 8; % This is optional;
loop_0(5).curve = nrbline([1,0],[0,0]);
loop_0(5).label = 9; % This is optional;
loop_0(6).curve = nrbline([0,0],[0,1]);
% loop_0(6).label = 10; % This is optional;

loop_1 = struct();
loop_1(1).curve = nrbcirc(0.1, [0.25, 0.35]);
loop_1(1).label = 11;

trimmed_srf.srf = square;
trimmed_srf.trim_loops = {loop_0, loop_1};

debug_prefix = "debug_info_path";
trimmed_srfs_to_step(trimmed_srf, debug_prefix);
 
n_refs = 5;
reparam_degree = 2;
n_min_reparam_elems = 1;
reparam = ref_trimmed_srfs(n_refs, trimmed_srf, 'reparam_deg', reparam_degree, 'nb_reparam_elems', n_min_reparam_elems);

ref_id = 5;
trimmed_srfs_plot(reparam(ref_id), 'labels', true, 'quad_pts', true, 'tiles', true);
