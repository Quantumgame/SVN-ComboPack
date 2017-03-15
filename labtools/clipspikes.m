function clipped_trace=clipspikes(trace, varargin)
%filters out spikes to produce only subthreshold trace
%usage: clipped_trace=clipspikes(trace, [thresh], [cutoff], [baseline], [samprate])
%thresh: clips off spikes above this threshold (above baseline) defaults to 20 mV
%cutoff: low pass filter freq, defaults to 80 Hz
%baseline: resting membrane potential, defaults to estimated value
%samprate: defaults to 10000 Hz

if nargin==1
    thresh=20;
    cutoff=80;
    baseline=[];
    samprate=10e3;
elseif nargin==2
    thresh=varargin{1};
    cutoff=80;
    baseline=[];
    samprate=10e3;
elseif nargin==3
    thresh=varargin{1};
    cutoff=varargin{2};
    baseline=[];
    samprate=10e3;
elseif nargin==4
    thresh=varargin{1};
    cutoff=varargin{2};
    baseline=varargin{3};
    samprate=10e3;
elseif nargin==5
    thresh=varargin{1};
    cutoff=varargin{2};
    baseline=varargin{3};
    samprate=varargin{4};
end

if isempty(thresh)
    thresh=20;
end
if isempty(cutoff)
    cutoff=80;
end
if isempty(samprate)
    samprate=10e3;
end
if isempty(baseline)
    % get vrest
    [n, x]=hist(trace, 200);
    baseline=x(find(n==max(n)));
    baseline=baseline(1);
end

clipped_trace=trace;
clipped_trace(find(clipped_trace>baseline+thresh))=baseline+thresh;
[b,a]=butter(5, cutoff/(samprate/2));
clipped_trace=filtfilt(b, a, clipped_trace);

%     t=1:length(trace);
%     t=t/samprate;
%     figure
%     plot(t, trace, t, clipped_trace, 'r')



