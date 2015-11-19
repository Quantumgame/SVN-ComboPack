function [timestamps stimid]=OEread_stimIDs(varargin)
%extracts timestamps and stimIDs from an Open Ephys 'all_channels.events'
%file.
%usage:  call with no arguments to use a dialog box to select the event
%file, or use expdate, session filenum to look in that data dir
% [timestamps stimid]=read_stimIDs;
% [timestamps stimid]=read_stimIDs(expdate, session filenum);


if nargin==0
    [filename, pathname] = uigetfile('*.events', 'Pick all_channels.events file');
    if isequal(filename,0) || isequal(pathname,0)
        return;
    else
        cd(pathname)
    end
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    
oepathname=getOEdatapath(expdate, session, filenum)

cd(oepathname)
%     %get OE data path from exper
%     gorawdatadir(expdate, session, filenum)
%     expfilename=sprintf('%s-%s-%s-%s.mat', expdate, whoami, session, filenum);
%     expstructurename=sprintf('exper_%s', filenum);
%     if exist(expfilename)==2 %try current directory
%         load(expfilename)
%         exp=eval(expstructurename);
%         isrecording=exp.openephyslinker.param.isrecording.value;
%         oepathname=exp.openephyslinker.param.oepathname.value;
%     else %try data directory
%         cd ../../..
%         try
%             cd(sprintf('Data-%s-backup',user))
%             cd(sprintf('%s-%s',expdate,user))
%             cd(sprintf('%s-%s-%s',expdate,user, session))
%         end
%         if exist(expfilename)==2
%             load(expfilename)
%             exp=eval(expstructurename);
%             isrecording=exp.openephyslinker.param.isrecording.value;
%             oepathname=exp.openephyslinker.param.oepathname.value;
%         else
%             fprintf('\ncould not find exper structure. Cannot get OE file info.')
%         end
%     end
%     cd(oepathname)
    
    filename='all_channels.events';
end
[data, alltimestamps, info] = load_open_ephys_data(filename);

alltimestamps=double(round2(alltimestamps, 0.01));
uniqueTimestamps=unique(alltimestamps);

j=0;timestamps=[];stimid=[];
for i=1:length(uniqueTimestamps)
    skip=0;
    [idx, val]= find(alltimestamps==uniqueTimestamps(i));
    bv=data(idx);
    bv=sort(bv);
    on=unique(info.eventId(idx));
    if length(on)>1
        warning('\nstimulus bit turned on and off at the same time??? problem with stimID byte');
        fprintf('\n bit values are'); fprintf(' %d', bv(1:end));
        skip=1;
    end
    if skip==0
    bv2=bv(2:end)-1; %strip off trigger line
    bv3=sum(2.^bv2); %convert to decimal stimid
%     if bv3==23 % troubleshooting ira
%         keyboard
%     end
    else
        bv2=NaN;
        bv3=NaN;
    end
    if on
        j=j+1;
%         if i==66;
%             keyboard;
%         end
%         elseif bv3==99
%             keyboard;
%         elseif bv3==123
%             keyboard;
%         end
% if j==477
%     stimid(j)=bv3-1;
%     timestamps(j)=uniqueTimestamps(i);
%     j=j+1;
%     %keyboard
% elseif j==479
%     stimid(j)=bv3-1;
%     timestamps(j)=uniqueTimestamps(i);
%     j=j+1;
%     %keyboard
% elseif j==1392
%     stimid(j)=bv3-1;
%     timestamps(j)=uniqueTimestamps(i);
%     j=j+1;
%     %keyboard
% end
        stimid(j)=bv3;
        timestamps(j)=uniqueTimestamps(i);
        %check if stimid is sequential, as it should be
        if j>1
            if stimid(j)==stimid(j-1)+1
                %OK
            else
%                 if stimid(j)~=0
%                     warning(sprintf('non-sequential OE stimID bytes! there is a problem with stimID bytes, %d, bit number %d,%d',j, bv3, i))
%                 end
            end
        end
    end
    
end

% for i=1:200
%     fprintf('\n%.4f %d:%d', alltimestamps(i), data(i), info.eventId(i))
% end
% figure
% hold on
% for i=1:length(alltimestamps)
%     if info.eventId(i)
%         plot(alltimestamps(i), data(i), 'ro')
%     else
%         plot(alltimestamps(i), data(i), 'bo')
%     end
% end

fprintf('\nfound %d stimuli based on OE hardware triggers', length(timestamps))
fprintf('\nread %d OE stimID bytes\n', length(stimid))

%check if stim ID are consecutive, as they should be, or if the bytes are
%corrupted somehow
figure
plot(timestamps, stimid, '-o')
title('stim ID')
% keyboard

%find AO pulses
% AO_filename='100_CH36.continuous';
% SC_filename='100_CH37.continuous';
% [AO_data, AO_alltimestamps, AO_info] = load_open_ephys_data(AO_filename);
% fprintf('\nloading AO pulses')
% [SC_data, SC_alltimestamps, SC_info] = load_open_ephys_data(SC_filename);
% AO_max=max(AO_data);
% AO_pulses=find(AO_data>max/2);
% AO_times=AO_alltimestamps(AO_pulses);





