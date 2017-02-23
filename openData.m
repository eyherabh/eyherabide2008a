function spikes = openData(filename,addsptimes)
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
    % Opens data files with spike trains.
    %
    % This function is currently limited to extract the spike times within each trial.
    %
    % INPUT ARGUMENTS:
    %
    %   - filename: The name of the data file with the spike times
    %   - addsptimes: The increment in size of the vector of variable size internally 
    %   containing the spike times. To improve speed, addspikes should be just barely more
    %   than the estimated number of spikes to be loaded. The default is 100000.
    %
    % EXAMPLE:
    %
    % spikeTimes = openData('datafolder/session/spikedata.dat');
    %
    % OUTPUT ARGUMENTS:
    %
    %   - spikes: A sparse matrix with rows indicating the trial and columns indicating
    %   spikes times. A spike is indicated with 1 and a silence with 0. Notice that the
    %   column indexes are equal to the spike times in multiples of 0.1 milliseconds, and
    %   that the first column corresponds to the stimulus onset (that is, the column
    %   indexes are equal to the spikes times shifted 0.1 milliseconds into the future).
    %
    % VERSION CONTROL
    % 
    % V1.000 Hugo Gabriel Eyherabide, University of Helsinki (07 Dec 2016)
    % 
    % Should you find bugs, please contact Hugo Gabriel Eyherabide (neuralinfo@eyherabidehg.com)
    %
    % LICENSE
    % 
    % Copyright (c) 2016, Hugo Gabriel Eyherabide 
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

    
    % Parameter controlling how the list of spike times is increased in case of necessity
    if nargin<2 || isempty(addsptimes) || ~isnumeric(addsptimes) || addsptimes<2
        addsptimes = 100000; % Default value
    else
        addsptimes = ceil(addsptimes); % To ensure that the number is an integer.
    end
    
    % Checks if file exists and opens it
    assert(exist(filename,'file')>0,'The file does not exist');
    datafile = fopen(filename,'r');
    
    % Reads spikes times
    numsptimes = addsptimes;
    sptimes = zeros(numsptimes,1);
    dataline = fgetl(datafile);
    indl = 0;
    while ischar(dataline)
        aux = sscanf(dataline,'%d');
        if ~isempty(aux)
            indl = indl+1;
            if indl>numsptimes
                sptimes    = [sptimes;zeros(addsptimes,1)];
                numsptimes = numsptimes+addsptimes;
            end
            sptimes(indl) = aux;
        end
        dataline = fgetl(datafile);
    end
    fclose(datafile);
    numsptimes = indl;
    sptimes = sptimes(1:numsptimes)/100;
    sptrials = cumsum([1;diff(sptimes)<0]);
    spikes = sparse(sptrials,sptimes+1,ones(numsptimes,1));
end