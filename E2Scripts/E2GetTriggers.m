function [triggers_rising, triggers_falling]=E2GetTriggers(data)
% recovers position of triggers from the data vector. Triggers are recorded
% as short pulses in the data. The rising edge of the pulse is considered
% to be the position of the trigger
% Input:
%	data            -   vector containing trigger pulses
% Output:
%	triggers        -   vector containing position of triggers (in samples);
%                       empty if unsuccessful
%
%


triggers_rising=[];
triggers_falling=[];

if nargin<1 | isempty(data)
	return;
end

data=data(:);       % convert possible row vector into a column vector

if isa(data,'double') % if the data is not in 'double' format, it was extracted from daq file in the 'native', i.e. int16 format and the values are much bigger.
    threshold=1;
%     fprintf('\nrawdata isa=double and threshold for soundcard triggers is 1\n');
%mw 051308 using soundcard triggering, (with amplitude calibration), trig doesn't reach 1
threshold=.25; %this was probably due to a faulty BNC cable
else
    threshold=100;
%     fprintf('\nrawdata isa ~= double and threshold for soundcard triggers is 100\n');
end 

% instead of specifying some number, I'll use half the range (mw 12-11-08)
%threshold=min(data)+range(data)/2;


data=data>threshold;
% oneAtStart=(data(1)==1);
% data=[diff(data); 0];	%now, here's the deal with diff. Positions of 1 in diff(trig) are exactly one position (sample)
				% to the left from the positions of the (first of each trigger) 1 in the original trig. So it means
				% that the trigger occured somewhere in between. And because we have to choose, we assume that the start
				% of the trigger is the last 0 before the first 1 in the original trig, which corresponds to 1 in diff(trig).
				% If you want to use the first 1 in the original trig as a start of the trigger, replace the line with:
				% data=[0; diff(data)];
try data=sparse([0; diff(data)]);
catch
    %this is a hack to deal with very large data 
    %mak 20Sep2013
    data1=data(1:floor(length(data)/2));
    data1=sparse([0; diff(data1)]);
    data2=data((floor(length(data)/2)+1):end);
    data2=sparse([0; diff(data2)]);

    data=[data1;data2];
    clear data1 data2
end


% if triggeratstart
% 	data(1)=oneAtStart;
% end

% changed: foma 2004-07-29: triggers were changed to falling edge, because
% that is what actually triggers the data acquisition board
triggers_rising=find(data==1);  % get the absolute positions (in samples) RISING EDGE
triggers_falling=find(data==-1);  % get the absolute positions (in samples) FALLING EDGE
