%% Contributers: 
%    Florian Kummer, Technische Universität Darmstadt
%    Michael Loibl, University of the Bundeswehr Munich
%    Benjamin Marussig, Graz University of Technology  
%    Guilherme H. Teixeira, Graz University of Technology  
%    Teoman Toprak, Technische Universität Darmstadt
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

function save_video(n_frames,names,figures)
%
    %To no delete the .png in the end
    if~exist('figures','var')
        figures=0;
    end
 %
    %load the images
    images=cell(n_frames,1);
    for i=1:n_frames
        images{i}=imread([names.path names.file 'position_' num2str(i) '.png']);
    end
    % create the video writer with 1 fps
    writerObj = VideoWriter([names.path names.file 'Video.avi']);
    writerObj.FrameRate = 3;
 %
    % set the seconds per image
    secsPerImage = ones(1,n_frames);
 %
    % open the video writer
    open(writerObj);
 %
    % write the frames to the video
    for u=1:length(images)
        % convert the image to a frame
        frame = im2frame(images{u});
        for v=0.1:secsPerImage(u) 
            writeVideo(writerObj, frame);
        end
    end
    % close the writer object
    close(writerObj);
 %
 %
    if figures==0
        %delete pngs
        for i=1:n_frames
            delete ([names.path names.file 'position_' num2str(i) '.png']);
            delete ([names.path names.file 'position_' num2str(i) '.fig']);
        end
    end
end