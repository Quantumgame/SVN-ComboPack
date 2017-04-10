function Plotrawdata(expdate, session, filenum, varargin)

% Plots raw data and shows where triggers are
% usage:
% Plotrawdata('expdate','session','filenum', [xlimits])
%Green = soundcard trig
%Red = hardware trig
%Magenta = stim trace
%Blue = data trace

% created 27sep2010 by mak
% updated 16feb2010 by mak. It will now access data on the server
%changed daqread to only read samples specified by xlimits - mw 07.03.2014
%Prefs;
global pref
if nargin<3 | nargin>4
    error('wrong number of arguments');
end
if nargin==4
    xlimits=varargin{1};
else
   xlimits=[];
end

username=pref.username;
rig=pref.rig;
try daqfilename=sprintf('%s-%s-%s-%s',expdate,username, session, filenum);
    cd(pref.data)
    daqdir=sprintf('%s-%s\\%s-%s-%s',expdate,username,expdate,username, session);
    cd(daqdir)
    if isempty(xlimits)
        triggers=daqread(daqfilename);
    else
        triggers=daqread(daqfilename, 'samples', xlimits);
    end
    cd(pref.data)
    cd(sprintf('%s-%s',expdate, username));
    cd(sprintf('%s-%s-%s',expdate, username, session));
catch
    if ismac
        try
            cd('/Volumes/backup')

        catch
            try
            cd('/Volumes/blister')

            catch
            cd('/Volumes')
            mkdir('blister')
            !mount -t smbfs //lab@blister/Backup  /Volumes/blister
            cd('/Volumes/blister')
            end
        end
    elseif ispc
        cd('\\blister\backup')
    else error('cannot tell what kind of computer this is')
    end
    cd(rig)
    cd(sprintf('Data-%s',username))
    daqdir=fullfile(sprintf('%s-%s',expdate,username),sprintf('%s-%s-%s',expdate,username, session));
    cd(daqdir)
    if isempty(xlimits)
        triggers=daqread(daqfilename);
    else
        triggers=daqread(daqfilename, 'samples', xlimits);
    end
end
% stepsize=30; %in seconds for each figure window
% stepsize=stepsize*1e4; %converts to samplerate
% numfigs=ceil(length(triggers)/stepsize);
% windowstart=1;
% windowend=stepsize;
% for i=1:numfigs



figure
hold on


%     try
if strcmp(rig,'rig3')
    trigs_data=triggers(:,1);
    trigs_stim=triggers(:,2);
    trigs_HW=triggers(:,3);
    trigs_laser=triggers(:,4);
    trigs_SC=triggers(:,5);
    clear triggers
    
    p2=plot(trigs_stim(xlimits(1):xlimits(2))*1e4,'m'); %stim trace
    clear trigs_stim
     p1=plot(trigs_data(xlimits(1):xlimits(2))*5e2,'b');  %data trace (axopatchdata1)
     clear trigs_data
     p4=plot(trigs_laser(xlimits(1):xlimits(2))*1e3,'c'); %axopatchdata2 (second data channel)
     clear trigs_laser
    p3=plot(trigs_HW(xlimits(1):xlimits(2))*1e3,'r'); %hardware trig
    clear trigs_HW
    p5=plot(trigs_SC(xlimits(1):xlimits(2))*1e3,'g'); %soundcard trig
    clear trigs_SC
    legend('Stimuli','Data Ch1','Laser','Hardware','Soundcard','location','northwest')
else
    p5=plot(triggers(:,5),'g'); %soundcard trig
    p4=plot(triggers(:,4),'c'); %axopatchdata2 (second data channel)
    p3=plot(triggers(:,3),'r'); %hardware trig
    p2=plot(triggers(:,2),'m'); %stim trace
    p1=plot(triggers(:,1),'b');  %data trace (axopatchdata1)
    legend('Soundcard','Laser','Hardware', 'Stimuli','Data Ch1','location','northwest')

    if ~isempty(xlimits)
    set(gca, 'xticklabel', xlimits(1)+get(gca, 'xtick'))
    end
    
%     p5=plot(triggers(xlimits(1):xlimits(2),5),'g'); %soundcard trig
%     p4=plot(triggers(xlimits(1):xlimits(2),4),'c'); %axopatchdata2 (second data channel)
%     p3=plot(triggers(xlimits(1):xlimits(2),3),'r'); %hardware trig
%     p2=plot(triggers(xlimits(1):xlimits(2),2),'m'); %stim trace
%     p1=plot(triggers(xlimits(1):xlimits(2),1),'b');  %data trace (axopatchdata1)

end
%     catch
%         plot(triggers(:,5)*1e3,'g')
%         plot(triggers(:,3)*1e3,'r')
%         plot(triggers(:,2)*1e4,'m')
%         plot(triggers(:,1)*50,'b')
%     end
%     windowstart=windowstart+stepsize;
%     windowend=windowend+stepsize;
% end
% legend('Soundcard','Data Ch2', 'Hardware','Stimuli','Data Ch1')
title(sprintf('%s-%s-%s: Rawdatatrace',expdate, session, filenum));




