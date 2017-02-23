function [h,spikes,baselines] = rasterPlots(spdata,colors,timeinterval,trials,options)
    % This software is provided as supplementary material for the following publications:
    %
    % 1- Eyherabide HG, Rokem A, Herz AVM, and Samengo I, Burst Firing is a Neural Code in
    % an Insect Auditory System, Front Comput Neurosci (2008), 2:3, doi: 10.3389/neuro.10.003.2008
    %
    % 2- Eyherabide HG, Rokem A, Herz AVM, and Samengo I, Bursts Generate a Non-reducible
    % Spike Pattern Code, Front Neurosci (2009), 2:3, doi:10.3389/neuro.01.002.2009
    %
    % 3- Eyherabide HG, Samengo I, The Information Transmitted by Spike Patterns in Single
    % Neurons, J Physiol Paris (2010), 104(3-4): 147-155, doi: 10.1016/j.jphysparis.2009.11.018
    %
    % 4- Eyherabide HG, Samengo I, Time and Category Information in Pattern-Based Codes,
    % Front Comput Neurosci (2010), 4:145, doi: 10.3389/fncom.2010.00145
    %
    % Should you use this code, we kindly request you to cite at least the most relevant of
    % the aforementioned publications.
    %
    % DESCRIPTION:
    %
    % Make raster plots of the spike trains or burst trains. 
    %
    % Examples of these raster plots can be found: 
    %  - in Figures 1, 2, and 8 of the first publication listed above;
    %  - in Figure 1 of the second publication listed above;
    %  - in Figure 4 of the third publication listed above; and
    %  - in Figures 2 and 3 of the fourth publication listed above. 
    % Eyherabide et al 2008,
    % Figure 1B of Eyherabide et al 2008,
    % in Figures 1B, 
    %
    % INPUT ARGUMENTS:
    %
    %   - spdata: It can be either a sparse matrix like the output of the
    %   function openData.m, or a cell array of matrices of the same type.
    %   - colors: Specifies the color that will be used for printing the
    %   spike trains within each of the sparse matrices given in spdata. It
    %   can be a char, a cell array or a matrix with three columns.
    %   - timeinterval: Indicates the first and the last column from spdata
    %   that will be printed. Hence, it is a vector with two integer values.
    %   - trials: Specifies which trials and in which order will be
    %   printed. 
    %   - options: Structure with the following fields
    %       - opt.depolarization: the height of spike above baseline, 0.7 by default.
    %       - opt.hyperpolarization: the depth of spike below baseline, 0.3 by default.
    %       - baseline: logical value indicating whether or not the baseline
    %         should be printed, false by default.    
    %       - trialsep: the separation between trials, 1 by default.
    %
    % EXAMPLE:
    %
    % This example prints the first 100 trials from spnow1 in black and from spnow2
    % in red, including only spikes that were fired between the columns 3000 and 10000.
    % In the case of our studies, this means spikes between 300ms and 1000ms after
    % the stimulus onset.
    %
    % spnow1 = openData('datafolder/session/spikedata1.dat');
    % spnow2 = openData('datafolder/session/spikedata2.dat');
    % h = rasterPlots({spnow1,spnow2},{'black','red'},[3000,10000],1:100);
    %
    % OUTPUT ARGUMENTS:
    %
    %   - h: the handle of the figure within which the raster plot is generated.
    %
    % VERSION CONTROL
    % 
    % V1.000 Hugo Gabriel Eyherabide, University of Helsinki (13 Jan 2017)
    % 
    % Should you find bugs, please contact Hugo Gabriel Eyherabide (neuralinfo@eyherabidehg.com)
    %
    % LICENSE
    % 
    % Copyright (c) 2017, Hugo Gabriel Eyherabide 
    % All rights reserved.
    % 
    % Redistribution and use in source and binary forms, with or without modification,
    % are permitted provided that the following conditions are met:
    % 
    % 1.  Redistributions of source code must retain the above copyright notice, 
    %     this list of conditions and the following disclaimer.
    % 
    % 2.  Redistributions in binary form must reproduce the above copyright notice, 
    %     this list of conditions and the following disclaimer in the documentation 
    %     and/or other materials provided with the distribution.
    % 
    % 3.  Neither the name of the copyright holder nor the names of its contributors 
    %     may be used to endorse or promote products derived from this software 
    %     without specific prior written permission.
    % 
    % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
    % AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
    % WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
    % IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
    % INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
    % NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
    % PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
    % WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
    % ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
    % OF SUCH DAMAGE.
    
    
    % Checking the type of data
    if isempty(spdata), error('Please provide some data'); end
    if ~iscell(spdata), spdata = {spdata}; end
    numsp = numel(spdata);
    for indsp = 1:numsp
        if ~ismatrix(spdata{indsp}), error('Some of the data provided is not a sparse matrix'); end
    end
    
    % Checking the type of colors
    if nargin<2 || isempty(colors)
        colors = {'black'};
    elseif ischar(colors)
        colors = {colors};
    elseif ismatrix(colors) && isnumeric(colors)
        if size(colors,2)~=3, error('The matrix specifying the colors must have three columns'); end
        colors = mat2cell(colors,ones(size(colors,1),1),3);
    elseif ~iscell(colors)
        error('Colors are not properly specified');
    end
    
    % Checking time interval
    if nargin<3 || isempty(timeinterval)
        timeinterval = [1,max(cellfun(@(x)size(x,2),spdata))];
    end
    
    % Checking trials
    maxtrials = max(cellfun(@(x)size(x,1),spdata));
    if nargin<4 || isempty(trials)
        trials = 1:maxtrials;
    else
        if any(trials<1) || any(trials>maxtrials), error('Trials contains invalid indexes'); end
    end
    
    % Checking options
    opt = struct(   'depolarization',0.7,...
                    'hyperpolarization',0.3,...
                    'baseline',false,...
                    'trialsep',1);
                
    if nargin>=5 && ~isempty(options)
        if isstruct(options), error('options must be a structure'); end
        fnames = fieldnames(opt);
        for indf = 1:numel(fnames);
            if isfield(options,fnames{indf})
                opt.(fnames{indf}) = options.(fnames{indf}); 
            end
        end
    end    
    
    % Make raster plots
    
    % Parameters
    numtrials = numel(trials);
    
    h = figure;
    
    % Build baselines
    if opt.baseline
        aux = repmat(1:numtrials,3,1);
        baselines = [repmat([timeinterval(:);nan],numtrials,1),aux(:)];
        line(baselines(:,1),baselines(:,2),'LineWidth',.5,'color',zeros(1,3)+.4);
    else
        baselines = [];
    end

    % Build spiketrains
    spikes = cell(numsp,1);
    for indsp = 1:numsp
        [rows,cols] = find(spdata{indsp}(trials,timeinterval(:,1):timeinterval(:,2)));
        rows = rows(:).';
        auxrows = [ rows + opt.depolarization;
                    rows - opt.hyperpolarization;
                    nan(1,numel(rows))];
        cols = cols(:).';
        auxcols = [cols; cols; nan(1,numel(cols))];
        spikes{indsp} = [auxcols(:),auxrows(:)];
        numcolors = numel(colors);
        line(spikes{indsp}(:,1),spikes{indsp}(:,2),'LineWidth',1,'color',colors{1+mod(indsp-1,numcolors)});
    end
    set(gca,'XLim',timeinterval,'YLim',[1-opt.hyperpolarization,numtrials+opt.depolarization]);
end
