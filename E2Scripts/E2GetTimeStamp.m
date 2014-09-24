function expLogTimestamp=E2GetTimeStamp(data)

% processes data vector and extracts timestamps (Manchester encoded) from it.
% Input:
%       data                -   data vector with Manchester encoded timestamp
% Output:
%       expLogTimestamp     -   structure with all timestamps formatted as
%                               events
% Output is empty if unsuccessful

expLogTimestamp=[];

if nargin<1 | isempty(data)
    return;
end

[timestamp,position]=E2ExtractTimeStamp(data);

nstamps=length(timestamp);
[expLogTimestamp(1:nstamps).type]=deal('timestamp');      % create an empty structure of proper size with all elements of type 'timestamp'
[expLogTimestamp(1:nstamps).position]=deal(0);

for n=1:nstamps
    expLogTimestamp(n).position=position(n);            % position in samples!
    expLogTimestamp(n).param.value=timestamp(n);
end
