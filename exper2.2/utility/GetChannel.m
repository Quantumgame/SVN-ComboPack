function channel=GetChannel(object,info);

% get an info structure about a hardware channel;
% hardware channel info is stored in 'pref' structure defined in prefs.m
% The structure contains (for each channel) the following information:
% number: number of channel
% channel: the 'type' of channel, i.e. 'datachannel', 'gainchannel', etc.
% name: name of the channel, e.g. 'AxopatchData', etc.
% status of the channel, e.g. permanent vs temporary
%
% Input:
% object: 'ai' or 'ao', depending from which object we want to find out the
% info
% info: anything that is known about the required channel, i.e. number,
% channel, or name.
% Output:
% channel: structure with the channel(s) info (if the search is successful),
% if multiple channels fulfil the criteria in info GetChannel returns an
% array of structures.
% or
% [] if the search is unsuccessful.

global exper pref;

channel=[];

if strcmpi(object,'ai')
    pref.ach=pref.ai_channels;
else
    if strcmpi(object,'ao')
        pref.ach=pref.ao_channels;
    else
        return;
    end
end
if isnumeric(info)              % this could be the channel number
    numbers=[pref.ach.number];  % take all channels numbers
    n=find(numbers==info);      % find the position of the one we're looking for
    if ~isempty(n)              % we found it
        channel=pref.ach(n);    % return the requested channel(s)
    end;                        
else                            % info is either name or channel
    channels={pref.ach.channel};
    names={pref.ach.name};
    status={pref.ach.status};
    nChannels=length(channels);
    found=zeros(1:nChannels);
    for channel=1:nChannels
        c=strfind(lower(channels{channel}),lower(info));
        n=strfind(lower(names{channel}),lower(info));
        s=strfind(lower(status{channel}),lower(info));
        found(channel)=sum([c n s]);    % if the string was found as a substring in any of the fields, at least one of c, n, s is non-zero, and their sum is also non-zero
    end
    found=find(found);          % find those with non-zero sums
    channel=pref.ach(found);    % and return the found channels
%     channel=pref.ach(c);         
%     if isempty(channel)         % it's not a channel
%         channel=pref.ach(n);   % so it might be a name
%     else
%         if ((~isempty(n)) && (~isequal(c,n)))        % it might be a channel, but it also might be a different name
%             channel=[];         % if the result is ambiguous, return an empty thing.
%         end;
%     end;
end;
