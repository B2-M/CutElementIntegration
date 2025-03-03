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

function [out_area,out_objQuadData,names] = runAreaComputation2D_h_refinement( ...
    objIntegrators, testCaseId, n_refs_min, n_refs_max, varargin )

% example call: see example_circle_1.m

% check input
bInclude = false(length(objIntegrators),1);
for i = 1 : length( objIntegrators )

    if ~isa(objIntegrators{i},"AbstractIntegrator")
        error("Error: the first input must contain subclasses of AbstractIntegrator; not a %s.", class(objIntegrators{i}) )
    end
        
    if isCompatibleWithPlatform( objIntegrators{i} ) 
        bInclude(i) = true;
    else
        warning("runAreaComputation2DTestCase: %s has been excluded since it does not run on current platform.", class(objIntegrators{i}) );
    end

end
objIntegrators = objIntegrators( bInclude );

objTest = getTestCase2D( testCaseId );
if ~isa(objTest,'TestCase') 
    error("Error: the second input must be an ID of a test case (see getTestCase2D ).")
end

[flag_plot_error,flag_plot_points] = set_2D_plot_options(varargin{:});

% prepare output
[error_log, names] = local_set_up_log_data(testCaseId, ...
    objIntegrators, n_refs_max, n_refs_min);

% reference solution
exact_area = objTest.references.exact_inside;

% run study
out_area = nan(n_refs_max-n_refs_min+1,length(objIntegrators));
out_objQuadData = cell(n_refs_max-n_refs_min+1,length(objIntegrators));
for n_refs = n_refs_min : n_refs_max
    
    % set background mesh subdivisions
    objTest.domain.n_refs = n_refs;
    h_elem = prod(objTest.domain.getElementLengths);    % element area

    % figure
    if flag_plot_points
        hold off;   % creates a new figure if none is open
    end
    % use different integration tools
    m_count = 1;
    markers = ["o","square","x","+"];
    for i = 1 : length( objIntegrators )

        % integrate
        try 
            tic
            [area,objQuadData] = objIntegrators{i}.computeArea2D( objTest );
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
            error_log(i).data( n_refs-n_refs_min+1, 6) = 0;
            %
            continue
        end

        % errors
        err.rel = compute_rel_error(area, exact_area);
        err.abs = compute_abs_error(area, exact_area);
        
        % store results for error plot
        error_log(i).data( n_refs-n_refs_min+1, 1) = err.rel;
        error_log(i).data( n_refs-n_refs_min+1, 2) = err.abs;
        error_log(i).data( n_refs-n_refs_min+1, 3) = h_elem;
        error_log(i).data( n_refs-n_refs_min+1, 4) = objQuadData.nb_trimmed_elems_pts;
        error_log(i).data( n_refs-n_refs_min+1, 5) = objQuadData.nb_non_trimmed_elems_pts;
        error_log(i).data( n_refs-n_refs_min+1, 6) = integ_time;
        
        % store results to output
        out_area(n_refs-n_refs_min+1,i) = area;
        out_objQuadData{n_refs-n_refs_min+1,i} = objQuadData;

        % write quad data points files
        name_table = [names.file 'refs_' num2str(n_refs) '_' names.integrators{i}];
        write_quaddata_to_table(objQuadData, name_table, names.path )

        if flag_plot_points
            % plot points
            plot_quad_pts( objQuadData, 'trimmed', markers(m_count), 'LineWidth',1.5);     
            hold on;
            if m_count == 4
                m_count = 1;
            else
                m_count = m_count + 1;
            end
        end

    end

    if flag_plot_points
        % plot mesh
        hold on
        plot_mesh(objTest.domain);
        hold on
        % plot domain
        resolution = 50;
        for c = 1 : length(objTest.interface.parametric)
            plot_domain(objTest.interface.parametric{c},resolution,'colormap',[0 0 1; 0 0 1; 0 0 1; 0 0 1; 0 0 1])
        end
        hold on
        xlabel('x');
        ylabel('y');
        legend(names.integrators)
        figname = [names.path names.file 'refs_' num2str(n_refs) '.fig' ];
        savefig(figname)
    end

end

% write log file
write_error_to_table(error_log, names.integrators, names.cols, names.file, names.path )

if flag_plot_error
    % plot convergence graph
    hold off
    for i = 1 : length(names.integrators)
        name_logfile_i = convertStringsToChars(join([names.file names.integrators{i} '.csv'],''));
        plot_error_h_refinement('relError', name_logfile_i, names.path );
        hold on
    end
    title('')
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
name_path = './examples/AreaComputation2D/results/';
name_test = ['runAreaComputation2D_tC_' num2str(testCaseId)];
[error_log, names] = set_up_log_data( objIntegrators, n_rows, name_path, name_test);

end


