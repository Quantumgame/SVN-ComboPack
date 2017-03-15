function PlotWheelLFP(varargin)

%plots evoked LFP size and wheel velocity
%
%extracts wheel velocity from a photodiode signal
%pointed at a rat running wheel
%assumes the wheel has a disk with black and white wedges
%assumes diode data is in AxopatchData2
%usage:
% PlotWheelLFP(expdate, session, filename)
% PlotWheelLFP(expdate, session, filename, [diameter], [numwedges], [level])
%
%optional inputs
% diameter: diameter of wheel in cm, default is 7 cm
% numwedges: number of wedges around the wheel (including black, gray, &
% white), default is 12
%level: plot only a single RLF level
%
%example calls:
%PlotWheelLFP('060311', '001', '005', 22.5, 12, 60)
%PlotWheelLFP('060311', '001', '005', [], [], 60)

level=[];
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    diameter=17;
    numwedges=12;
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    diameter=varargin{4};
    numwedges=12;
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    diameter=varargin{4};
    numwedges=varargin{5};
elseif nargin==6
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    diameter=varargin{4};
    numwedges=varargin{5};
    level=varargin{6};
else
    error('wrong number of arguments');
end
if isempty(diameter)
    diameter=17;
end
if isempty(numwedges)
    numwedges=12;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wheel_stopped=2; %in seconds; for inter-peak intervals longer than this, set wheel velocity to zero
refract=100; %eliminate noisy peaks by enforcing refractory period, in samples
nstd=.5; %threshold for peak detection, in s.d.
high_pass_cutoff=1; %Hz

fprintf('\nsetting velocity to 0 if no peak detected in %.1f seconds', wheel_stopped );
fprintf('\nwheel diameter %.1f cm, with %d colored wedges around it', diameter, numwedges );


global pref
if isempty(pref) Prefs; end
username=pref.username;
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
datafile2=strrep(datafile, 'AxopatchData1', 'AxopatchData2');
[D E S]=gogetdata(expdate,session,filenum);
godatadir(expdate, session, filenum)
D2=load(datafile2);

%cd /Users/mikewehr/Documents/Analysis/042211-abe-001
%%D=load(datafile);
scaledtrace=D2.nativeScaling*double(D2.trace)+ D2.nativeOffset;


% highpass filter
samprate=1e4;
fprintf('\nhigh-pass filtering at %.2f Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace=filtfilt(b,a,scaledtrace);

t=1:length(scaledtrace);t=t/samprate; %t is in seconds
% plot(t, filteredtrace,t,scaledtrace);

%peak detection
thresh=nstd*std(filteredtrace);
if thresh>1
    fprintf('\nusing peak detection threshold of %.1f mV (%g sd)', thresh, nstd);
elseif thresh<=1
    fprintf('\nusing peak detection threshold of %.4f mV (%g sd)', thresh, nstd);
end
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
pos_peaks=find((filteredtrace)>thresh); %positive peaks (region above threshold )
neg_peaks=find((filteredtrace)<-thresh); %negative peaks (region above threshold )

% dpos_peaks=pos_peaks(1+find(diff(pos_peaks)>refract)); % positive-going threshold crossings
% dneg_peaks=neg_peaks(1+find(diff(neg_peaks)>refract)); % negative-going threshold crossings

% trying actual peak detection
dpos_peaks=pos_peaks(1+find(diff(pos_peaks)>refract)); % positive-going threshold crossings
dneg_peaks=neg_peaks(1+find(diff(neg_peaks)>refract)); % negative-going threshold crossings


try
    dpos_peaks=[pos_peaks(1) dpos_peaks'];
    dneg_peaks=[neg_peaks(1) dneg_peaks'];
catch
    fprintf('\n\npeaks is empty; either the wheel never moved or the nstd is set too high\n');
    return
end

i=0;
for p=dpos_peaks %indexes of threshold crossings
    i=i+1;
    q=dneg_peaks(min(find(dneg_peaks>p)));
    if isempty(q)
        q=length(filteredtrace);
    end
    peak=p+find(filteredtrace(p:q)==max(filteredtrace(p:q)));
    pos_peak(i)=peak(1);
end
% plot(t(pos_peak), filteredtrace(pos_peak), 'ks')

i=0;
for p=dneg_peaks %indexes of threshold crossings
    i=i+1;
    q=dpos_peaks(min(find(dpos_peaks>p)));
    if isempty(q)
        q=length(filteredtrace);
    end
    peak=p+find(filteredtrace(p:q)==min(filteredtrace(p:q)));
    neg_peak(i)=peak(1);
end
% plot(t(neg_peak), filteredtrace(neg_peak), 'r^')





% add back in time to first peak and time to eof
% dpos_peaks=[1 dpos_peaks length(t)];
% dneg_peaks=[1 dneg_peaks length(t)];

%convert to seconds
spos_peak=pos_peak/samprate;
sneg_peak=neg_peak/samprate;
sdpos_peaks=dpos_peaks/samprate;
sdneg_peaks=dneg_peaks/samprate;
spos_peaks=pos_peaks/samprate;
sneg_peaks=neg_peaks/samprate;
%
% figure
% h=plot(t, filteredtrace, 'c');
% plot(t, filteredtrace,'c',t,scaledtrace-min(scaledtrace)+max(abs(filteredtrace)));
% hold on
%  plot(spos_peaks, thresh*ones(size(spos_peaks)), 'g.')
%  plot(sneg_peaks, -thresh*ones(size(sneg_peaks)), 'c.')
% % plot(sdpos_peaks, thresh*ones(size(sdpos_peaks)), 'r*')
% % plot(sdneg_peaks, -thresh*ones(size(sdneg_peaks)), 'm*')
% plot(spos_peak, filteredtrace(pos_peak), 'k^')
% plot(sneg_peak, filteredtrace(neg_peak), 'kv')
%  L1=line(xlim, thresh*[1 1]);
%  L2=line(xlim, thresh*[-1 -1]);
%  set([L1 L2], 'color', 'm', 'linestyle', '--');
% %pause(.5)
% %close
% % set(gcf, 'pos',[21 80 1839 471])
% zoom on

wheel_circumference=diameter*pi;
wedge_distance=3*wheel_circumference/numwedges; %distance e.g. from black to black
fprintf('\ncomputed distance from black to black: %.1f cm', wedge_distance);



IPI_pos=diff(sdpos_peaks); %inter-peak-interval in seconds
IPI_pos(find(IPI_pos>wheel_stopped))=nan; %remove stationary periods longer than wheel_stopped
inst_ang_vel_pos=1./IPI_pos; %instantaneous angular velocity based on positive peaks
inst_ang_vel_pos(isnan(inst_ang_vel_pos))=0;
% % smooth vel with 5pt median filter
% finst_ang_vel_pos=inst_ang_vel_pos;
% for i=3:length(finst_ang_vel_pos)-2
%     finst_ang_vel_pos(i)=median(inst_ang_vel_pos(i-2:i+2));
% end

% inst_vel_pos=vel_sign.*wedge_distance.*inst_ang_vel_pos(1:minlength-1);
%inst_vel_pos=fvel_sign_pos(2:end).*wedge_distance.*inst_ang_vel_pos;
inst_vel_pos=wedge_distance.*inst_ang_vel_pos;

vel_pos=zeros(size(t));
%for i=1:minlength-1%length(dpos_peaks)-1
for i=1:length(dpos_peaks)-1
    vel_pos(dpos_peaks(i):dpos_peaks(i+1))=inst_vel_pos(i)*ones(size(dpos_peaks(i):dpos_peaks(i+1)));
end

IPI_neg=diff(sdneg_peaks); %inter-peak-interval
IPI_neg(find(IPI_neg>wheel_stopped))=nan; %remove stationary periods longer than wheel_stopped
inst_ang_vel_neg=1./IPI_neg; %instantaneous angular velocity based on negitive peaks
inst_ang_vel_neg(isnan(inst_ang_vel_neg))=0;
% % smooth vel with 5pt median filter
% finst_ang_vel_neg=inst_ang_vel_neg;
% for i=3:length(finst_ang_vel_neg)-2
%     finst_ang_vel_neg(i)=median(inst_ang_vel_neg(i-2:i+2));
% end



% inst_ang_vel_neg is number of neg peaks long
% vel_neg is length(t) long

% if length(inst_ang_vel_neg)>length(vel_sign)
% vel_sign=[vel_sign vel_sign(end)];
% end
% inst_vel_neg=vel_sign.*wedge_distance.*inst_ang_vel_neg(1:minlength-1);
% inst_vel_neg=fvel_sign_neg(2:end).*wedge_distance.*inst_ang_vel_neg;
inst_vel_neg=wedge_distance.*inst_ang_vel_neg;
vel_neg=zeros(size(t));
%for i=1:minlength-1%length(dneg_peaks)-1
for i=1:length(dneg_peaks)-1
    vel_neg(dneg_peaks(i):dneg_peaks(i+1))=inst_vel_neg(i)*ones(size(dneg_peaks(i):dneg_peaks(i+1)));
end
%vel should be in units of cm/s

% smooth vel with npt median filter
fvel_pos=vel_pos;
fvel_neg=vel_neg;
% takes a really long time! Doesn't do much good, either.
% n=1000;
% for i=(1+n):length(fvel_pos)-n
%     fvel_pos(i)=median(fvel_pos(i-n:i+n));
% end
% for i=(1+n):length(fvel_neg)-n
%     fvel_neg(i)=median(fvel_neg(i-n:i+n));
% end


% h=plot(t, 10*fvel_pos, 'r',t, 10*fvel_neg, 'b');
% set(h, 'linewi', 1.5)


% title(sprintf('Mean across trials %s. %s-%s-%s ',trialstring, expdate,session, filenum))
mean_vel=mean([fvel_pos; fvel_neg]);



plot(t, mean_vel, 'k', 'linewidth', 2)
grid on
xlabel('time, s')



figure
plot(t, mean_vel, 'k.-')
grid on
xlabel('time, s')
ylabel('velocity, cm/s')
title(sprintf('%s %s %s', expdate, session, filenum))
%keyboard
t_vel=t;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function PlotRLF_timecourse_LFP(varargin)
%plots time course of responses for each tone frequency and level
%(useful for observing time course before/during/after drug application)
%usage:
%   PlotRLF_timecourse_LFP(expdate, session, filenum, [xlimits], [ylimits] [stepsize])
%     xlimits, and stepsize are optional
%     default xlimits are 0:300
%     stepsize (in minutes) is the time interval to plot each point in the time course (default: 2 minute)
%
%example call: PlotRLF_timecourse_LFP('071509', '001', '001', [0 100], [], 2)


event=E.event;
%stim=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
clear D E S
xlimits=[0 300];
tracelength=diff(xlimits); %in ms

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'tonetrain')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.toneduration;
    elseif strcmp(event(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'grating')
        j=j+1;
        allfreqs(j)=event(i).Param.angle*1000;
        allamps(j)=event(i).Param.spatialfrequency;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'clicktrain')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.clickduration; %        alldurs(j)=event(i).Param.duration; gives trial duration not tone duration
    end
end
freqs1=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs1);
numamps=length(amps);
numdurs=length(durs);
M1=[];
nreps=zeros(numfreqs, numamps, numdurs);
samprate=1e4;
%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'tonetrain') |strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'clicktrain')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if isempty(pos)
                pos=event(i).Position_rising;
            end
        else
            pos=event(i).Position_rising;
        end
        
        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop<=length(scaledtrace)
                if strcmp(event(i).Type, 'tone')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.duration;
                elseif  strcmp(event(i).Type, 'tonetrain')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.toneduration;
                elseif  strcmp(event(i).Type, 'grating')
                    freq=event(i).Param.angle*1000;
                    dur=event(i).Param.duration;
                elseif strcmp(event(i).Type, 'whitenoise')
                    dur=event(i).Param.duration;
                    freq=-1;
                elseif strcmp(event(i).Type, 'clicktrain')
                    dur=event(i).Param.clickduration;
                    freq=-1;
                end
                amp=event(i).Param.amplitude;
                findex= find(freqs1==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
                M1(findex,aindex,dindex, nreps(findex, aindex, dindex),:)=scaledtrace(region);
                T1(findex,aindex,dindex, nreps(findex, aindex, dindex))=pos/samprate; %position in seconds
            end
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))

traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1=mean(M1(:,:,:,traces_to_keep,:), 4);
else
    for aindex=1:numamps
        for findex=1:numfreqs
            for dindex=1:numdurs
                mM1(findex, aindex, dindex,:)=mean(M1(findex, aindex, dindex, 1:nreps(findex, aindex, dindex),:), 4);
                %                 mM1stim(findex, aindex, dindex,:)=mean(M1stim(findex, aindex, dindex, 1:nreps(findex, aindex, dindex),:), 4);
            end
        end
    end
end

% try to load exper structure
user=whoami;
expfilename=sprintf('%s-%s-%s-%s.mat', expdate, user, session, filenum);
expstructurename=sprintf('exper_%s', filenum);
if exist(expfilename)==2 %try current directory
    load(expfilename)
    exp=eval(expstructurename);
    timemarks=exp.timemark.param.timemarks.value;
    notes=exp.timemark.param.notes.value;
else %try data directory
    cd ../../..
    try
        cd(sprintf('Data-%s-backup',user))
        cd(sprintf('%s-%s',expdate,user))
        cd(sprintf('%s-%s-%s',expdate,user, session))
    end
    if exist(expfilename)==2
        load(expfilename)
        exp=eval(expstructurename);
        if isfield(exp, 'timemark')
            timemarks=exp.timemark.param.timemarks.value;
            notes=exp.timemark.param.notes.value;
        else
            timemarks=[];
            notes=[];
            fprintf('\nno timemarks in exper structure.')
        end
    else
        timemarks=[];
        notes=[];
        fprintf('\ncould not find exper structure. Cannot plot timemarks.')
    end
end
timemarks=timemarks/60;

%find optimal axis limits
ylimits=[0 0];
for aindex=[numamps:-1:1]
    for findex=1:numfreqs
        trace1=squeeze(mM1(findex, aindex, dindex, :));
        trace1=trace1-mean(trace1(1:100));
        if min([trace1])<ylimits(1) ylimits(1)=min([trace1]);end
        if max([trace1])>ylimits(2) ylimits(2)=max([trace1]);end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot

%get numsteps
tend=max(max(max(T1)));
cmap=colormap;

for findex=1:numfreqs
    figure
    hold on
    p=0;
    for aindex=numamps:-1:1
        clear d t
        for rep=1:nreps(findex, aindex, dindex)
            %d(rep,:)=M1(findex,aindex,dindex, rep,:); % traces
            trace1=squeeze(M1(findex,aindex,dindex, rep,:)); % trace
            d(rep)=range(trace1);
            t(rep)=T1(findex,aindex,dindex, rep);     %times
        end
        c=cmap(round(size(cmap,1)*aindex/numamps),:);
        
        plot(t, d, '.-', 'color', c)
    end
    title(sprintf('RLF LFP timecourse for %s-%s-%s', expdate, session, filenum))
    legend(int2str(amps'))
end

% combined plot
figure
if isempty(level)
    for findex=1:numfreqs
        figure
        hold on
        p=0;
        for aindex=numamps:-1:1
            clear d t
            for rep=1:nreps(findex, aindex, dindex)
                %d(rep,:)=M1(findex,aindex,dindex, rep,:); % traces
                trace1=squeeze(M1(findex,aindex,dindex, rep,:)); % trace
                d(rep)=range(trace1);
                t(rep)=T1(findex,aindex,dindex, rep);     %times
            end
            c=cmap(round(size(cmap,1)*aindex/numamps),:);
            
            plot(t, d, '.-', 'color', c)
        end
        title(sprintf('RLF LFP timecourse for %s-%s-%s freq %.1f', expdate, session, filenum, freqs1(findex)/1000))
        legend(int2str(amps'))
        nmean_vel=median(d).*mean_vel./max(abs(mean_vel))-median(d);
        plot(t_vel, nmean_vel, 'k', 'linewidth', 2)
        grid on
        xlabel('time, s')
    end
    
    
    
else %level is specified
    
    for findex=1:numfreqs
        figure
        hold on
        p=0;
        
        aindex=find(amps==level);
        clear d t
        for rep=1:nreps(findex, aindex, dindex)
            %d(rep,:)=M1(findex,aindex,dindex, rep,:); % traces
            trace1=squeeze(M1(findex,aindex,dindex, rep,:)); % trace
            d(rep)=range(trace1);
            t(rep)=T1(findex,aindex,dindex, rep);     %times
        end
        c=cmap(round(size(cmap,1)*aindex/numamps),:);
        
        plot(t, d, '.-', 'color', c)
        
        
        title(sprintf('RLF LFP timecourse for %s-%s-%s freq %.1f', expdate, session, filenum, freqs1(findex)/1000))
        legend(int2str(amps'))
        nmean_vel=median(d).*mean_vel./max(abs(mean_vel))-median(d);
        plot(t_vel, nmean_vel, 'k', 'linewidth', 2)
        grid on
        xlabel('time, s')
        
    end
    
end


