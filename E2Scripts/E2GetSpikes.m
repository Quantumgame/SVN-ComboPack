function spikePos=E2GetSpikes(data, nativeScaling, nativeOffset)

% Gets the positions of spikes in the data vector
% Uses E2ExtractSpikes to do the spike detection
% Input:
%       data            -   data vector
%       nativeScaling   -   
%       nativeOffset    -   scaling factors if the input is in int16
% Output:
%       spikePos        -   vector with POSITIONS of spikes in data vectors
%                           empty if unsuccessful
%

spikePos=[];

if nargin<1 | isempty(data)
	return;
end

if nargin<2 | isempty(nativeScaling)
	nativeScaling=1;
end

if nargin<1 | isempty(nativeOffset)
	nativeOffset=1;
end

% default parameters for E2ExtractSpikes
remove_downward_spikes=0;
threshold=[];   % tries to determine the threshold itself

spikes=E2ExtractSpikes(nativeScaling.*double(data)+nativeOffset,threshold,remove_downward_spikes);

spikePos=find(spikes==1);    %get the positions of spikes in data
