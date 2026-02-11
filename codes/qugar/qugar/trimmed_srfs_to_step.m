% TRIMMED_SRFS_TO_STEP: exporter of non-conforming multi-patch surfaces to STEP files.
%
%  Copyright (C) 2023 Pablo Antolin <pablo.antolin@epfl.ch>
% 
%  See the attached LICENSE file.
%
%
% POSSIBLE CALLING SEQUENCES:
%
%     trimmed_srfs_to_step (trim_srfs, fname_prefix);
%     trimmed_srfs_to_step (trim_srfs, fname_prefix, tolerance);
%
% DESCRIPTION:
%
% This function creates a (non-conforming) multipatch from a collection of disconnected
% trimmed surfaces and dumps it to a STEP file.
% In the process, also partial geometries (as trimmed surfaces, loops, etc.) are dumped
% to STEP files.
%
% This function is conceived for helping the users of the trimmed_srfs function to debug
% the input geometry of that function.
%
%
% INPUTS:
%     
%    trim_srfs:       Collection of (2D or 3D) trimmed surfaces.
%
%    fname_prefix:    File name prefix (without extension) for the generated STEP files.
%
%    tolerance: Tolerance value to be used in the geometric computations.
%               Default value is 1.0e-12.
%
%  The details of the input argments trim_srfs and tolerance can be checked in the documenation
%  of the trimmed_srfs function.
%   
% OUTPUT:
%
%    This function returns no output MATLAB, it just generates just a collection of STEP files
%    describing the generated geometries.
%
%    In particular, a file named fname_prefix + '_final_geometry.step'  will be written for the
%    generated multi-patch geometry. In addition, for each trimmed surface in the trim_srfs input,
%    the following files will be created:
%      - One file for the non trimmed spline surface.
%        Named as fname_prefix + '_base_geometry.step'.
%      - One file for parametric domain of the non trimmed spline surface.
%        Named as fname_prefix + '_param_domain.step'.
%      - One file for each trimming loop of the trimmed surface (defined in its parametric domain).
%        Named as fname_prefix + '_trimming_loop.step'.
%      - One file for trimmed surface.
%        Named as fname_prefix + '.step'.
%
%   Note: in the case there exist more than one trimmed surface, or trimming loop per surface,
%   integer values for identifying each one of them will added to the file names.
%
