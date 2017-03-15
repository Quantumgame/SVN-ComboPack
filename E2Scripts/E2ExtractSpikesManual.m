function [spike_vector, filtswpvec] = E2ExtractSpikesManual(raw_sweep,threshold,remove_downward_spikes)
% This code takes a raw voltage sweep, hipass filters, thresholds for spikes,
% culls "fake" spikes due to downward "spikes" in raw trace, create spike 
% vector which is 1 for the times of all spikes, and zero elsewhere.
%
% function spike_vector = E2ExtractSpikes(raw_sweep,threshold,remove_downward_spikes)
%
% inputs:
%  raw_sweep is the actual voltage data to find the spikes in
%  threshold is the voltage threshold for spike height as measured relative to voltage just prior to the spike
%  if remove_downward_spikes == 1, then do not include "spikes" which are predominantly downward going; 
%     I usually set this to one to avoid misidentifying downward electrical noise spikes as action potentials
%
% output: spike_vector, same size as sweep, which is a vector of ones for spikes, and zeros eslewhere 
%

if nargin<3
    remove_downward_spikes=1;
end

if nargin<2
    threshold=1;
end

window_half_width = 10; %half-width of window for excluding downward "spikes" in raw data from appearing in spike_vector
sweep_spike_heights = sparse(zeros(size(raw_sweep)));
% High Pass filter the sweep:
%Tony provided a useful high-pass filter he made with the Filter analysis tool:
%equiripple, minimum order, Fs=4000; Fstop =20 ; Fpass=500; astop=60; apass=1;
Den = 1; 
Num=[-2.9419,-7.7633,-16.2976,-28.7498,-44.7001,-62.8034,-80.9099,-96.4457,-106.9520,889.3317,...
        -106.9520,-96.4457,-80.9099,-62.8034,-44.7001,-28.7498,-16.2976,-7.7633,-2.9419]/1000;

 filtswpvec=filtfilt(Num, Den, raw_sweep); 

 high_points = find(filtswpvec > threshold); % includes all points above filtspikethresh
%  sweep_spike_heights = zeros(size(raw_sweep));

 % Now get single spike time for each spike even if several points are above threshold per spike
 if ~isempty(high_points)
    high_point_count = length(high_points);
    if high_point_count == 1 %if only one spike which is only one point wide 
        sweep_spike_heights(high_points) = filtswpvec(high_points);
    else %if more than one spike, or if more than one point width to one spike
        for k = 1:(high_point_count + 1)
            if k == 1 % for the first hight point
                current_max_point = high_points(1);
                current_max = filtswpvec(high_points(1));
            elseif k == high_point_count + 1  % no more high points to consider  
                sweep_spike_heights(current_max_point) = current_max;
            elseif high_points(k) == (high_points(k-1)+1) %if still looking at the same bump
                if filtswpvec(high_points(k)) > current_max %update max point if we're higher than last max for this bump
                    current_max_point = high_points(k);
                    current_max = filtswpvec(high_points(k));   
                end
            else % if looking at a new bump  %MODIFIED THIS TO REMOVE BUG ON 06/29/01
                sweep_spike_heights(current_max_point) = current_max; %create spike height from last bump
                current_max = filtswpvec(high_points(k));
                current_max_point = high_points(k);
            end
        end
    end

    %NOW REMOVE SPURIOUS SPIKES ARISING FROM DOWNWARD ELECTRICAL NOISE "SPIKES" IN UNFILTERED TRACE
    if remove_downward_spikes == 1
        filtspkpoints = find(sweep_spike_heights(:));
        for j = 1:length(filtspkpoints)
            if min(filtswpvec(max([filtspkpoints(j)-window_half_width,1]):...
                    min([filtspkpoints(j)+window_half_width,length(raw_sweep)]))) < ...
                    -sweep_spike_heights(filtspkpoints(j))
                sweep_spike_heights(filtspkpoints(j)) = 0;
            end
        end
    end
 end

 spike_vector = ceil(sweep_spike_heights/1000);
