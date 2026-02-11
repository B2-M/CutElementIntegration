%
%  Copyright (C) 2023 Pablo Antolin <pablo.antolin@epfl.ch>
% 
%  See the attached LICENSE file.
%

clear all;
clc;
close all;

lx = 2.2;
ly = 0.41;
square = nrbsquare([0,0], lx, ly, 1);
square.knots{1} = [0,0,lx,lx];
square.knots{2} = [0,0,ly,ly];

loop_0 = struct();
loop_0(1).curve = nrbline([0,0],[lx,0]);
loop_0(1).label = 8; % This is optional;
loop_0(2).curve = nrbline([lx,0],[lx,ly]);
loop_0(2).label = 7; % This is optional;
loop_0(3).curve = nrbline([lx,ly],[0,ly]);
loop_0(3).label = 9; % This is optional;
loop_0(4).curve = nrbline([0,ly],[0,0]);
loop_0(4).label = 6; % This is optional;

loop_1 = struct();
loop_1(1).curve = nrbcirc(0.05,[0.2,0.2]);
loop_1(1).label = 5; % This is optional

trimmed_srf.srf = square;
trimmed_srf.trim_loops = {loop_0, loop_1};

% debug_prefix = "debug_info_path";
% trimmed_srfs_to_step(trimmed_srf, debug_prefix);

n_refs = 5;
reparam_degree = 3;
n_min_reparam_elems = 1;
reparam = ref_trimmed_srfs(n_refs, trimmed_srf, 'reparam_deg', reparam_degree, 'nb_reparam_elems', n_min_reparam_elems);

ref_id = 4;
trimmed_srfs_plot(reparam(ref_id), 'labels', true, 'tiles', true);

