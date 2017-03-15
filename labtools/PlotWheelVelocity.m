function varargout=PlotWheelVelocity(varargin)

%extracts wheel speed from a photodiode signal
%pointed at a rat running wheel
%assumes the wheel has black and white 1 cm stripes
%assumes data is on AxopatchData2
%usage:
% PlotWheelVelocity(expdate, session, filename)
% PlotWheelVelocity(expdate, session, filename, [stripe_width])
%
%optional inputs
% stripe_width: width of stripes in cm, default is 1 cm
%
%optional outputs
% [velocity]=PlotWheelVelocity(expdate, session, filename, [stripe_width])
% if an output is requested, no plotting is done.

% note: we have abandoned any attempt to compute direction (from gray
%wedges), only speed is computed.
profile on -history



if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    stripe_width=1;
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    stripe_width=varargin{4};
else
    error('wrong number of arguments');
end
if nargout>0; doplot=0;
else doplot=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


wheel_stopped=2; %in seconds; for inter-peak intervals longer than this, set wheel velocity to zero
refract=50; %eliminate noisy peaks by enforcing refractory period, in samples
nstd=1.0; %threshold for peak detection, in s.d.
high_pass_cutoff=1; %Hz
low_pass_cutoff=50; %Hz
scr_sz=get(0, 'screensize');

fprintf('\nsetting velocity to 0 if no peak detected in %.1f seconds', wheel_stopped );
fprintf('\nstripe width %.1f cm', stripe_width );


global pref
if isempty(pref) Prefs; end
username=pref.username;
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
datafile2=strrep(datafile, 'AxopatchData1', 'AxopatchData2');
[D1 E S D]=gogetdata(expdate,session,filenum);

%cd /Users/mikewehr/Documents/Analysis/042211-abe-001
%%D=load(datafile);
scaledtrace=D.nativeScaling*double(D.trace)+ D.nativeOffset;
event=E.event;
samprate=1e4;
clear E D S

old_scaledtrace=scaledtrace;

%digitally remove cross-talk from hardware trigger
%I think this is due to low batteries in the photodiode circuit
if(1)
    for i=1:length(event)
        PR=event(i).Position_rising;
        PF=event(i).Position;
        offset=  mean(scaledtrace(PR+1:PR+11))-mean(scaledtrace(PR-11:PR-1));
        scaledtrace(PR:PF-1)= scaledtrace(PR:PF-1) - offset;
    end
end


% bandpass filter
fprintf('\nband-pass filtering from %.2f Hz to %.2f Hz', high_pass_cutoff, low_pass_cutoff);
[b,a]=butter(1,  high_pass_cutoff/(samprate/2), 'high');
[b1,a1]=butter(1, low_pass_cutoff/(samprate/2));
filteredtrace=filtfilt(b,a,scaledtrace);
filteredtrace=filtfilt(b1,a1,filteredtrace);


if doplot
    figure; hold on
    t=1:length(scaledtrace);t=t/samprate; %t is in seconds
    plot(t(1:30*samprate), old_scaledtrace(1:30*samprate)+mean(old_scaledtrace), 'k');
    plot(t(1:30*samprate), scaledtrace(1:30*samprate), 'b');
    plot(t(1:30*samprate), filteredtrace(1:30*samprate), 'm');
    set(gcf, 'pos',[20 80 scr_sz(3)-100 420])
    title('first 30 seconds of photodiode trace: raw (k), cleaned (b), and filtered (m)')
end



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


all_peak=sort([pos_peak neg_peak]);



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

nfilteredtrace=filteredtrace./max(abs(filteredtrace));

if doplot
    figure
    h=plot(t, filteredtrace, 'c');
    hold on
    %  plot(spos_peaks, thresh*ones(size(spos_peaks)), 'g.')
    %  plot(sneg_peaks, -thresh*ones(size(sneg_peaks)), 'c.')
    plot(spos_peak, filteredtrace(pos_peak), 'k^')
    plot(sneg_peak, filteredtrace(neg_peak), 'kv')
    L1=line(xlim, thresh*[1 1]);
    L2=line(xlim, thresh*[-1 -1]);
    set([L1 L2], 'color', 'm', 'linestyle', '--');
    set(gcf, 'pos',[60 200 scr_sz(3)-100 420])
    xlim([0 30])
    title('first 30 seconds')
    
    figure
    h=plot(t, 10*nfilteredtrace, 'c');
    hold on
    % plot(spos_peaks, thresh*ones(size(spos_peaks)), 'g.')
    % plot(sneg_peaks, -thresh*ones(size(sneg_peaks)), 'c.')
    plot(spos_peak, 10*nfilteredtrace(pos_peak), 'k^')
    plot(sneg_peak, 10*nfilteredtrace(neg_peak), 'kv')
    
end

%note: 05-31-2011
%we are going to abandon the attempt to compute direction, and just
%compute speed. We'll switch to black-and-white wedges only. The
%algorithm wasn't very robust with respect to varying speed, and the
%rats only run forwards anyway.

%note 11-11-11
%we have switched to stripes instead of wedges, so the distance travelled can be
%read directly from the stripes. No more angular velocity.




IPI_pos=diff(spos_peak); %inter-peak-interval in seconds

%sometimes poorly behaved peaks/troughs produce IPI_pos of 0, which is
%impossible, so I will assume at those points that the IPI is the same as
%the previous time point (assume the world doesn't change too quickly)
bad_idxs=find(IPI_pos==0);
if ~isempty(bad_idxs)
    if bad_idxs(1)<=1 %special case if it happens on first IPI_pos
        IPI_pos(1)=IPI_pos(2);
        bad_idxs=bad_idxs(2:end);
    end
end
IPI_pos(bad_idxs)=IPI_pos(bad_idxs-1);

IPI_pos(find(IPI_pos>wheel_stopped))=nan; %remove stationary periods longer than wheel_stopped

inst_vel_pos=2*stripe_width./IPI_pos; %pos-peak to pos-peak is 2 sripes
inst_vel_pos(isnan(inst_vel_pos))=0;
inst_vel_pos(isinf(inst_vel_pos))=0;

%remove outliers with an arbitrary threshold for outliers
outs=find(diff(inst_vel_pos)>30);
while ~isempty(outs)
    outs=find(diff(inst_vel_pos)>30);
    inst_vel_pos(outs+1)=inst_vel_pos(outs);
end



% inst_ang_vel_pos=1./IPI_pos; %instantaneous angular velocity based on positive peaks
% inst_ang_vel_pos(isnan(inst_ang_vel_pos))=0;
% % smooth vel with 5pt median filter
% finst_ang_vel_pos=inst_ang_vel_pos;
% for i=3:length(finst_ang_vel_pos)-2
%     finst_ang_vel_pos(i)=median(inst_ang_vel_pos(i-2:i+2));
% end

% inst_vel_pos=vel_sign.*wedge_distance.*inst_ang_vel_pos(1:minlength-1);
%inst_vel_pos=fvel_sign_pos(2:end).*wedge_distance.*inst_ang_vel_pos;

vel_pos=zeros(size(scaledtrace));
for i=1:length(dpos_peaks)-1
    vel_pos(dpos_peaks(i):dpos_peaks(i+1))=inst_vel_pos(i)*ones(size(dpos_peaks(i):dpos_peaks(i+1)));
end

IPI_neg=diff(sdneg_peaks); %inter-peak-interval
%sometimes poorly behaved peaks/troughs produce IPI_pos of 0, which is
%impossible, so I will assume at those points that the IPI is the same as
%the previous time point (assume the world doesn't change too quickly)
bad_idxs=find(IPI_neg==0);
if ~isempty(bad_idxs)
    if bad_idxs(1)<=1 %special case if it happens on first IPI_neg
        IPI_neg(1)=IPI_pos(2);
        bad_idxs=bad_idxs(2:end);
    end
end
IPI_neg(bad_idxs)=IPI_neg(bad_idxs-1);


IPI_neg(find(IPI_neg>wheel_stopped))=nan; %remove stationary periods longer than wheel_stopped


inst_vel_neg=2*stripe_width./IPI_pos; %pos-peak to pos-peak is 2 sripes


% inst_ang_vel_neg(isnan(inst_ang_vel_neg))=0;
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
%  inst_vel_neg=wedge_distance.*inst_ang_vel_neg;
vel_neg=zeros(size(vel_pos));
for i=1:length(dneg_peaks)-1
    vel_neg(dneg_peaks(i):dneg_peaks(i+1))=inst_vel_neg(i)*ones(size(dneg_peaks(i):dneg_peaks(i+1)));
end
%vel should be in units of cm/s

% smooth vel with npt median filter
% fvel_pos=vel_pos;
% fvel_neg=vel_neg;
% takes a really long time! Doesn't do much good, either.
% n=1000;
% for i=(1+n):length(fvel_pos)-n
%     fvel_pos(i)=median(fvel_pos(i-n:i+n));
% end
% for i=(1+n):length(fvel_neg)-n
%     fvel_neg(i)=median(fvel_neg(i-n:i+n));
% end

vel_pos(isnan(vel_pos))=0;
vel_pos(isinf(vel_pos))=0;

vel_neg(isnan(vel_neg))=0;
vel_neg(isinf(vel_neg))=0;




% title(sprintf('Mean across trials %s. %s-%s-%s ',trialstring, expdate,session, filenum))
mean_vel=nanmean([vel_pos; vel_neg]);

mean_vel(isnan(mean_vel))=0;
mean_vel(isinf(mean_vel))=0;



%

% %high-pass filter velocity to remove stationary periods
% %(otherwise even very long IPIs, in between bouts of running, would produce wmall but finite velocity)
%  high_pass_cutoff=.005; %Hz
%  [b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
%  fmean_vel=filtfilt(b,a,mean_vel);
% % NOTE: the high-pass filtering doesn't work very well

if doplot
    h=plot(t, vel_pos, 'r',t, vel_neg, 'b');
    set(h, 'linewi', 1.5)
    
    h1=plot(t, mean_vel, 'k', 'linewidth', 2);
    
    set([h], 'vis', 'off')
    set([h1], 'vis', 'off')
    
    plot(t, vel_pos, 'k', 'linewidth', 2)
    
    grid on
    xlabel('time, s')
    set(gcf, 'pos',[90 400 scr_sz(3)-100 600])
    
    
    
    figure
    plot(t, vel_pos, 'k.-')
    grid on
    xlabel('time, s')
    ylabel('velocity, cm/s')
    title(sprintf('%s %s %s', expdate, session, filenum))
    
end

varargout{1}=vel_pos;
p = profile('info');

for n = 1:size(p.FunctionHistory,2)
 if p.FunctionHistory(1,n)==0
        str = 'entering function: ';
 else
        str = 'exiting function: ';
 end
 disp([str p.FunctionTable(p.FunctionHistory(2,n)).FunctionName])
end

% keyboard
fprintf('\ndone')
