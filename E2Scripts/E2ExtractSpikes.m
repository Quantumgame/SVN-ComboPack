function spike_vector=E2ExtractSpikes(raw_sweep,threshold,remove_downward_spikes)
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
% output: spike_vector, same size as sweep, which is a vector of ones for spikes, and zeros elsewhere 
%

spike_vector=[];

if nargin<3 | isempty(remove_downward_spikes)
    remove_downward_spikes=1;
end

if nargin<2
    threshold=[];   % means: try to set the threshold itself
end

if nargin<1 | isempty(raw_sweep)
    return;
end

% Hysell's low pass filter
hysell_flag = 0;
if (hysell_flag == 1)
    nbinom = 15;
    for i = 0:nbinom
      lpfb(i+1) = nchoosek(nbinom,i);
    end
    %save 'zzbinom' lpfb;

    derivb = [1 0 -1];
    lpfbn = lpfb / sum(lpfb);
    lpfa = 1;
    lpf_sweep = filtfilt(lpfbn,lpfa,raw_sweep);
    deriv_sweep = filter(derivb,lpfa,lpf_sweep);
    %save 'zzraw' raw_sweep lpf_sweep deriv_sweep;
    clear lpf_sweep;
end

window_half_width = 10; %half-width of window for excluding downward "spikes" in raw data from appearing in spike_vector
sweep_spike_heights = zeros(size(raw_sweep));
raw_sweep_length=length(raw_sweep); % raw_sweep will be deleted and we will need the length
% High Pass filter the sweep:
%Tony provided a useful high-pass filter he made with the Filter analysis tool:
%equiripple, minimum order, Fs=4000; Fstop =20 ; Fpass=500; astop=60; apass=1;
Den = 1; 
Num=[-2.9419,-7.7633,-16.2976,-28.7498,-44.7001,-62.8034,-80.9099,-96.4457,-106.9520,889.3317,...
        -106.9520,-96.4457,-80.9099,-62.8034,-44.7001,-28.7498,-16.2976,-7.7633,-2.9419]/1000;


% QUICK HACK - FIX IT!!!
if length(raw_sweep)>10000000
    filtswpvec=filtfilt(Num,Den,raw_sweep(1:round(end/2)));
    filtswpvec=[filtswpvec; filtfilt(Num,Den,raw_sweep(round(end/2)+1:end))];
else
    filtswpvec=filtfilt(Num, Den, raw_sweep);
end

%fmean = mean(deriv_sweep);
%fsd   = std(deriv_sweep);
%save 'zz_meansd' fmean fsd;

 
 raw_sweep_size=size(raw_sweep);
 clear raw_sweep; % raw_sweep can be huge, so delete it...
 sweep_spike_heights = sparse(zeros(raw_sweep_size));
 
 if isempty(threshold)      % try to determine the threshold (upper third of the filtered trace, and at least 1)
    [maxTrace, maxIdx]=max(abs(filtswpvec));
    threshold=2/3*maxTrace(1);
%    save 'zzthresh_msd' threshold fmean fsd;
    if threshold>100 % there's something spurious, this shouldn't happen in the filtered trace
        if length(maxIdx)==1    % only one spurious thing
            pos1=max(1,maxIdx-30);
            pos2=min(length(filtswpvec),maxIdx+30);
            threshold=max(abs(filtswpvec([1:pos1 pos2:end])))*2/3;
        end
    end
%     threshold=max([threshold 1]);
 end
 %high_points = find(filtswpvec > threshold); % includes all points above filtspikethresh
 
if (hysell_flag == 1)
    fsd = std(deriv_sweep);
    threshold = 4 * fsd;
    high_points = find(deriv_sweep > threshold); % includes all points above filtspikethresh
else
    high_points = find(filtswpvec > threshold); % includes all points above filtspikethresh
end

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
                    min([filtspkpoints(j)+window_half_width,raw_sweep_length]))) < ...
                    -sweep_spike_heights(filtspkpoints(j))
                sweep_spike_heights(filtspkpoints(j)) = 0;
            end
        end
    end
 end

spike_vector = sparse(ceil(sweep_spike_heights/1000)); % return sparse vector, it's way smaller
