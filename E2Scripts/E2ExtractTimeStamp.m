function [timestamp, position]=E2ExtractTimeStamp(data);

% decodes the values and positions of Manchester encoded time stamps in
% data.
% Returns   timestamp - values of time stamps
%           position  - position of time stamps

nbits=22;    % how many bits are there in the timestamp;

if isa(data,'double')   % sometimes we want timestamp from daq files which were extracted in native format. In that case the values are much bigger.
    threshold=1;
else
    threshold=100;
end

data=data>threshold;
transitions=sparse([0; diff(data)]);    % vector of bit transitions
transpos=find(transitions);     % positions of the transitions
width=[diff(transpos); 0];      % pulse widths
maxwidth=max(width);
% pulse widths
% startpulse - maxwidth/2 to maxwidth
% fullpulse (full bit) - maxwidth/4 to maxwidth/2
% halfpulse (half bit) - 0 to maxwidth/4
halfmin=1;
halfmax=maxwidth/4;
fullmin=maxwidth/4;
fullmax=maxwidth/2;

startpulsesidx=width>fullmax;    % start pulses (0/1)
startpulsespos=find(startpulsesidx);% start pulses positions
startpulses=width(startpulsesidx);

% the start pulse consists of one long logical high pulse followed by one
% long logical low pulse. Now we should get rid of any incomplete start
% pulses that might appear in the beginning or in the end of the transmission 
following=diff(startpulsespos);
if ~isequal(following(1),1)     % the first start pulse is incomplete
    startpulsespos(1)=[];
end
if ~isequal(following(end),1)   % the last start pulse is incomplete
    startpulsespos(end)=[];
end

nstartpulses=length(startpulsespos)/2;  % total number of start pulses. 
                                        % This still might not equal total number of time stamps 
                                        % because the last time stamp
                                        % following the last start pulse
                                        % might be incomplete

timestamp=zeros(nstartpulses,1);        % all timestamps
position=zeros(nstartpulses,1);         % position of the timestamp. In our case this equals the high to low 
                                        % transition in the start pulse.
                                        
startpulsetrans=reshape(startpulsespos,2,nstartpulses);
startpulsetrans=startpulsetrans(2,:);         % start of the time stamp equals the start of the second half 
                                              % of the start pulse    
position=transpos(startpulsetrans);                                              
                              
h=waitbar(0,'Processing timestamp ');

for pulse=1:nstartpulses
    waitbar(pulse/nstartpulses,h,['Processing timestamp ' num2str(pulse)]);
    if pulse<nstartpulses                         % stamptranspos contains positions of the pulse transitions in the current time stamp                                             
        x=data(position(pulse)+1:position(pulse+1)-1);
    else
        x=data(position(pulse)+1:end);
    end
        trans=[0; diff(x)];
        trpo=find(trans);
        stampwidth=[diff(trpo); 0];
        stamptrans=trans(trpo);

    pulses=(stampwidth>=fullmin)+1;

    sumpulses=sum(pulses);
    
    value=[];
    
    switch sumpulses
        case nbits*2-2
            pulses=[1; pulses];
            pulses(end+1)=1;
            value=0;                % value of the first transition (in this case we know it will be 0
        case nbits*2-1
            pulses(end+1)=1;
            value=1;                % value of the first transition. We ASSUME it will be 1
        case nbits*2
            value=1;                % value of the first transition. We ASSUME it will be 1
        otherwise
            if pulse==nstartpulses
                position(end)=[];
                timestamp(end)=[];
                close(h);
                return;
            else
                %position(pulse)=[];
                timestamp(pulse)=-1;
                %close(h);
                disp('Something is wrong and I don''t know what!');
            end
    end
   if ~isempty(value) 
    if ~isequal(stamptrans(1),1)
        close(h);
            if pulse==nstartpulses
                position(end)=[];
                timestamp(end)=[];
                return;
            else
                error('Something is wrong. First transition in a time stamp is not up!');
            end
    end
    if ~isequal(stamptrans(end),1)
        close(h);
            if pulse==nstartpulses
                position(end)=[];
                timestamp(end)=[];
                return;
            else
                error('Something is wrong. Last transition in a time stamp is not up!');
            end
    end

    bits=zeros(1,nbits*2);                       % we're looking for 32 bit number encoded in 64 bits
    bitpos=1;
    for i=1:length(pulses)      % all pulse widths in the time stamp
        bits(bitpos:bitpos+pulses(i)-1)=value;
        bitpos=bitpos+pulses(i);
        value=1-value;
    end
        
    doublebits=reshape(bits,2,nbits);
    check=sum(doublebits);                % in each column there should be exactly one 1
    checkones=find(check==1);
    if ~isequal(length(checkones),nbits)     % if it's not true, we should have started with 0 instead of 1
        bits=[0 bits(1:end-1)];
        doublebits=reshape(bits,2,nbits);    
        check=sum(doublebits);                % in each column there should be exactly one 1
        checkones=find(check==1);
        if ~isequal(length(checkones),nbits)     % if it's not true, we should have started with 0 instead of 1
            close(h);
            error('Cannot decode the time stamp!');
        end
    end
    
    bits=doublebits(1,:);
    n=0:nbits-1;
    bitvalues=2.^n;

    timestamp(pulse)=sum(bitvalues.*bits);
   
   end %~isempty(value) 
    
end %pulse=1:nstartpulses

close(h);