%
%  Copyright (C) 2023 Pablo Antolin <pablo.antolin@epfl.ch>
% 
%  See the attached LICENSE file.
%

clear all;
clc;
close all;

plot_geometries = false;
plot_quad_pts = false;
nquad = [4 4];
reparam_degree = 2;
n_quad_pts = 3;
n_elems = 1;
degrees = [2 2];
regularity = degrees - 1;

step_file = "join.stp";
full_path = mfilename('fullpath');
directory = full_path(1:end-numel(mfilename));
step_file_path = fullfile(directory, step_file);

output = trimmed_srfs(step_file_path, 'reparam_deg', reparam_degree, 'nb_quad_pts', n_quad_pts);
trimmed_srfs_plot(output, 'labels', true, 'quad_pts', true, 'tiles', false, 'param_domain', false);
figure
trimmed_srfs_plot(output, 'labels', false, 'quad_pts', true, 'tiles', false, 'param_domain', true);



% Generating meshes for all the trimmed patches.
n_faces = length(output.trim_srfs);
meshes = cell(1, n_faces);
spaces = cell(1, n_faces);
spaces_vector = cell(1, n_faces);
rule = msh_gauss_nodes (nquad);
geometries = [];
for i = 1 : n_faces
    zeta = cell(1, 2);
    trim_srf = output.trim_srfs(i);
    srf = trim_srf.srf;
    zeta{1} = knt2brk(srf.knots{1});
    zeta{2} = knt2brk(srf.knots{2});
    [qn, qw] = msh_set_quad_nodes (zeta, rule);
    geometry = geo_load(srf);
    % meshes{i} = msh_trimming (zeta, qn, qw, geometry, trim_srf, 'der2', true, 'der3', true);
    meshes{i} = msh_trimming (zeta, qn, qw, geometry, trim_srf);

    % spaces{i} = sp_trimming (srf.knots, degrees, meshes{i});
    % spaces_vector{i} = sp_trimming_vector({spaces{i}, spaces{i}, spaces{i}}, meshes{i});
    geometries = [geometries, geometry];

end
