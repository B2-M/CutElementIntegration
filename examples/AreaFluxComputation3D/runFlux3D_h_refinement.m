function [out_vol,out_objQuadData,names] = runFlux3D_h_refinement( objIntegrators, testCaseId, ...
    n_refs_min, n_refs_max, varargin )

% example call: see example_ellipsoid_1_flux.m

% check input
%% Contributers: 
%    Florian Kummer, Technische Universität Darmstadt
%    Michael Loibl, Universtiy of the Bundeswehr Munich
%    Benjamin Marussig, Graz University of Technology  
%    Guliherme H. Teixeira, Graz University of Technology  
%    Muhammed Toprak, Technische Universität Darmstadt
%  
%
%% Copyright (C) 2025, Graz University of Technology 
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
% notice, this list of conditions and the following disclaimer in the 
% documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
% contributors may be used to endorse or promote products derived from 
% this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
% “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER 
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if isempty(objIntegrators)
    error('There is no objIntegrator input defined.')
end
bInclude = false(length(objIntegrators),1);
for i = 1 : length( objIntegrators )

    if ~isa(objIntegrators{i},"AbstractIntegrator")
        error("Error: the first input must contain subclasses of AbstractIntegrator; not a %s.", class(objIntegrators{i}) )
    end
        
    if isCompatibleWithPlatform( objIntegrators{i} ) 
        bInclude(i) = true;
    else
        warning("runFlux3D_h_refinement: %s has been excluded since it does not run on current platform.", class(objIntegrators{i}) );
    end

end
objIntegrators = objIntegrators( bInclude );

objTest = getTestCase3D( testCaseId );
if ~isa(objTest,'TestCase') 
    error("Error: the second input must be an ID of a test case (see getTestCase2D ).")
end

[flag_plot_error,flag_plot_points,flag_plot_interface,alpha] = ...
    set_3D_plot_options(varargin{:});

% prepare output
[error_log, names] = local_set_up_log_data(testCaseId, ...
    objIntegrators, n_refs_max, n_refs_min);

% reference solution
exact_measure = objTest.references.exact_inside;

% run study
out_vol = zeros(n_refs_max-n_refs_min+1,length(objIntegrators));
out_objQuadData = cell(n_refs_max-n_refs_min+1,length(objIntegrators));
for n_refs = n_refs_min : n_refs_max
    
    % set background mesh subdivisions
    objTest.domain.n_refs = n_refs;
    h_elem = prod(objTest.domain.getElementLengths);

    % figure
    if ( flag_plot_points || flag_plot_interface )
        hold off;   % creates a new figure if none is open
    end
    % use different integration tools
    m_count = 1;
    markers = ["o","square","x","+"];
    for i = 1 : length( objIntegrators )

        % integrate
        try 
            tic
          [measure,objQuadData] = objIntegrators{i}.computeVolumeViaFlux3D( objTest );
            integ_time = toc;
        catch catched_error
            warning("%s failed for testCase %i", objIntegrators{i}.Name, testCaseId)
            disp(catched_error.getReport);
            %
            error_log(i).data( n_refs-n_refs_min+1, 1) = NaN;
            error_log(i).data( n_refs-n_refs_min+1, 2) = NaN;
            error_log(i).data( n_refs-n_refs_min+1, 3) = -1;
            error_log(i).data( n_refs-n_refs_min+1, 4) = 0;
            error_log(i).data( n_refs-n_refs_min+1, 5) = 0;
            %
            continue
        end

        % errors
        err.rel = compute_rel_error(measure,exact_measure);
        err.abs = compute_abs_error(measure,exact_measure);
        
        % store results
        error_log(i).data( n_refs-n_refs_min+1, 1) = err.rel;
        error_log(i).data( n_refs-n_refs_min+1, 2) = err.abs;
        error_log(i).data( n_refs-n_refs_min+1, 3) = h_elem;
        error_log(i).data( n_refs-n_refs_min+1, 4) = objQuadData.nb_interfaces_pts;
        error_log(i).data( n_refs-n_refs_min+1, 5) = integ_time;

        % store results to output
        out_vol(n_refs-n_refs_min+1,i) = measure;
        out_objQuadData{n_refs-n_refs_min+1,i} = objQuadData;  

        % write quad data points files
        name_table = [names.file 'refs_' num2str(n_refs) '_' names.integrators{i}];
        write_quaddata_to_table(objQuadData, name_table, names.path )

        % plot points
        if flag_plot_points
            plot_quad_pts( objQuadData, 'interface', markers(m_count), 'LineWidth',1.5);     
            hold on;
            if m_count == 4
                m_count = 1;
            else
                m_count = m_count + 1;
            end
        end

    end

    if ( flag_plot_points || flag_plot_interface )
        % plot mesh
        plot_mesh(objTest.domain);
        hold on
        % plot domain
        if flag_plot_interface
            resolution = [10,10];
            plot_domain(objTest.interface.parametric{1},resolution,'FaceAlpha',alpha)
            hold on
        end
        xlabel('x');
        ylabel('y');
        legend(names.integrators)
        figname = [names.path names.file 'refs_' num2str(n_refs) '.fig' ];
        savefig(figname)
        figname = [names.path names.file 'refs_' num2str(n_refs) '.pdf' ];
        saveas(gcf,figname);
    end

end

% write log file
write_error_to_table(error_log, names.integrators, names.cols, names.file, names.path )


if flag_plot_error
    % plot convergence graph
    hold off
    for i = 1 : length(names.integrators)
        name_logfile_i = convertStringsToChars(join([names.file names.integrators{i} '.csv'],''));
        plot_error_h_refinement('relError', name_logfile_i, names.path, 'nb quadpts interface' );
        hold on
    end
    title('')
    legend(names.integrators,"Location","southeast") 
    figname = [names.path names.file 'error.fig' ];
    savefig(figname)  
    figname = [names.path names.file 'error.pdf' ];
    saveas(gcf,figname);
end

end

%--------------------------------------
% Local functions
%--------------------------------------
function [error_log, names] = local_set_up_log_data(testCaseId, ...
    objIntegrators, n_refs_max, n_refs_min)

n_rows = n_refs_max-n_refs_min+1;
name_path = './examples/AreaFluxComputation3D/results/';
name_test = ['runFlux3D_tC_' num2str(testCaseId)];
name_cols = {'relError','absError','h','nbQuadptsInterface',...
        'IntegrationTime_sec_'};
[error_log, names] = set_up_log_data( objIntegrators, n_rows, ...
    name_path, name_test, name_cols);

end


