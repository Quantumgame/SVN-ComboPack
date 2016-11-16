function lostat=getlostat(expdate,session,filenum)
% usage: getlostat('expdate','session','filenum')
% Plots a figure with the recorded trace (blue) and soundcard triggers (green)
% The user finds and enters the lostat point by zooming into the figure ensuring they aren't
% too close to the trigger and enters this value onto the command line. The lostat
% timepoint is then saved to a .mat file in the user's ProcessedData session folder
% If you later realize that the lostat is not needed, simply delete the .mat file
% last update 29apr2013 by mak. 
% 
% To update plotting functions search for 'lostat' or 'lostat1'
% 1)godatadir(expdate,session,filenum)
%   lostatfilename=sprintf('lostat-%s-%s-%s.mat',expdate,session,filenum);
%   try load(lostatfilename);catch; lostat=-1;end %#ok
% 2)if lostat==-1; lostat=length(scaledtrace);end
% 3)discarding trace is replaced with a cell counter and simply says events A:B were
% skipped:
% lostat_counter=[];
% if stop>lostat
%     lostat_counter=[lostat_counter i];
% if ~isempty(lostat_counter)
%     fprintf('\nEvents %d:%d skipped due to lostat',lostat_counter(1),lostat_counter(end))
% end
% %accumulate across trials

% 4)try out=rmfield(out,'lostat'); end % this now lives in it's own outfile


dbstop if error
global pref
if isempty(pref); Prefs; end
[D, E, ~, ~]=gogetdata(expdate,session,filenum);
event=E.event;
if isempty(event); fprintf('\nevent is empty\n'); return; end
scaledtrace=D.nativeScaling*double(D.trace)+ D.nativeOffset;
clear D E 
samprate=1e4;
high_pass_cutoff=300; %Hz
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace=filtfilt(b,a,scaledtrace);

figure; hold on
h=[min(filteredtrace) max(filteredtrace)];
for i=1:length(event)
    if isfield(event(i), 'soundcardtriggerPos')
        pos=event(i).soundcardtriggerPos;
        if isempty(pos) && ~isempty(event(i).Position_rising)
            pos=event(i).Position_rising;
        end
    else
        pos=event(i).Position_rising;
    end
%     line([pos pos],h/4,'color','g')
    line([pos pos],h*10,'color','g')
end
% plot(filteredtrace, 'b')
plot(scaledtrace, 'b')
grid on
title(sprintf('%s-%s-%s',expdate, session, filenum));
lostatfilename=sprintf('lostat-%s-%s-%s.mat',expdate,session,filenum);
prompt = {'Position cell start','Position cell lost'};
dlg_title = 'Enter lostat';
num_lines = 1;

if exist(lostatfilename,'file')==2
    load(lostatfilename)
    if length(lostat)==2
        def = {num2str(lostat(1)),num2str(lostat(2))};
        
    else
        def = {'1',num2str(lostat(1))};
    end
else
    def = {'1',num2str(length(scaledtrace))};
end
if ~exist('lostat','var')
    lostat=[1 length(scaledtrace)];
end
if lostat(1)==1 && lostat(2)==length(scaledtrace)
else
    if lostat(1)~=1
        line([lostat(1) lostat(1)],[get(gca,'ylim')],'color','k','linestyle',':','linewidth',2)
    end
    if lostat(2)~=length(scaledtrace)
        line([lostat(2) lostat(2)],[get(gca,'ylim')],'color','k','linestyle',':','linewidth',2)
    end
end
fprintf('\nPlease zoom in on the plot and determine the lostin/lostat timepoints')
fprintf('\n(Type ''return'' to continue)\n')
keyboard
lostinat = inputdlg(prompt,dlg_title,num_lines,def);

if ~isempty(lostinat)
    lostat=[str2num(lostinat{1}) str2num(lostinat{2})];
else
    lostat(1)=1;
    lostat(2)=length(scaledtrace);
end
if lostat(1)==1 && lostat(2)==length(scaledtrace)
else
    if lostat(1)~=1
        line([lostat(1) lostat(1)],[get(gca,'ylim')],'color','r','linestyle',':','linewidth',2)
    end
    if lostat(2)~=length(scaledtrace)
        line([lostat(2) lostat(2)],[get(gca,'ylim')],'color','r','linestyle',':','linewidth',2)
    end
    godatadir(expdate,session,filenum);
    if exist(lostatfilename,'file')==2;delete(lostatfilename);end
    save(lostatfilename,'lostat')
end





