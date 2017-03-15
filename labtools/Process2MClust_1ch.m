function Process2MClust_1ch(expdate, session, filenum, varargin)
% extracts spike waveforms from single-electrode data into a file that can be read
% by MClust using the WehrlabLoadingEngine
% %hard-coded for 1 channel!
%output is "tetrode" data with a copy of channel 1 on the other 3 dummy channels 
%
% usage: Process2MClust_1ch(expdate, session, filenum, [monitor], [thresh])
% (thresh is optional, default is thresh=3sd
% thresh can be a single number in number of standard deviations
% or to use an absolute threshold (in mV) pass [-1 mV] as the thresh
%  argument, where mV is the desired threshold
% mw 12-18-2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

monitor=1; %0=off; 1=on
if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==3
    nstd=3;
elseif nargin==4
    nstd=3;
    monitor=varargin{1};
    if isempty(monitor) monitor=1;end
elseif nargin==5
    nstd=varargin{2};
    monitor=varargin{1};
    if isempty(nstd) nstd=3;end
    if isempty(monitor) monitor=1;end
else
    error('wrong number of arguments');
end

lostat=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

[D E S]=gogetdata(expdate,session,filenum);
event=E.event;
if isempty(event) fprintf('\nno tones\n'); end
scaledtrace1=D.nativeScaling*double(D.trace)+ D.nativeOffset;
user=whoami;

% [datafile2, eventsfile, stimfile]=getfilenames(expdate, session, filenum, [user], '3');
% if exist(datafile2, 'file')
%     D2=load(datafile2);
%     scaledtrace2=D2.nativeScaling*double(D2.trace)+ D2.nativeOffset;
% end
% 
% [datafile3, eventsfile, stimfile]=getfilenames(expdate, session, filenum, [user], '4');
% if exist(datafile3, 'file')
%     D2=load(datafile3);
%     scaledtrace3=D2.nativeScaling*double(D2.trace)+ D2.nativeOffset;
% end

% [datafile4, eventsfile, stimfile]=getfilenames(expdate, session, filenum, [user], '5');
% if exist(datafile4, 'file')
%     D2=load(datafile4);
%     scaledtrace4=D2.nativeScaling*double(D2.trace)+ D2.nativeOffset;
% end
% 
% clear D E S D2


fprintf('\nextracting spike waveforms');

samprate=1e4;
if lostat==-1 lostat=length(scaledtrace1);end

high_pass_cutoff=300; %Hz
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace1=filtfilt(b,a,scaledtrace1);
% filteredtrace2=filtfilt(b,a,scaledtrace2);
% filteredtrace3=filtfilt(b,a,scaledtrace3);
% filteredtrace4=filtfilt(b,a,scaledtrace4);
if length(nstd)==2
    if nstd(1)==-1
        thresh1=nstd(2);
        nstd=thresh1/std(filteredtrace1);
        fprintf('\nusing absolute spike detection threshold of %.1f mV (%.1f sd)', thresh1, nstd);
    end
elseif length(nstd)==1
    thresh1=nstd*std(filteredtrace1);
%     thresh2=nstd*std(filteredtrace2);
%     thresh3=nstd*std(filteredtrace3);
%     thresh4=nstd*std(filteredtrace4);
    fprintf('\nusing spike detection threshold of %.4f mV', [thresh1  ]);
    fprintf('\nwhich is %g sd', nstd);
% elseif length(nstd)==4
%     thresh1=nstd(1)*std(filteredtrace1);
%     thresh2=nstd(2)*std(filteredtrace2);
%     thresh3=nstd(3)*std(filteredtrace3);
%     thresh4=nstd(4)*std(filteredtrace4);
%     fprintf('\nusing spike detection threshold of %.4f mV', [thresh1 thresh2 thresh3 thresh4 ]);
%         fprintf('\nwhich is %g sd', nstd);
else
error('thresh should be 1 or 2 elements')
end
refract=8;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes1=find(abs(filteredtrace1)>thresh1);
dspikes1=spikes1(1+find(diff(spikes1)>refract));
% spikes2=find(abs(filteredtrace2)>thresh2);
% dspikes2=spikes2(1+find(diff(spikes2)>refract));
% spikes3=find(abs(filteredtrace3)>thresh3);
% dspikes3=spikes3(1+find(diff(spikes3)>refract));
% spikes4=find(abs(filteredtrace4)>thresh4);
% dspikes4=spikes4(1+find(diff(spikes4)>refract));
try
    dspikes1=[spikes1(1); dspikes1(:)];
%     dspikes2=[spikes2(1) dspikes2];
%     dspikes3=[spikes3(1) dspikes3];
%     dspikes4=[spikes4(1) dspikes4];
    % %convert to ms
    % dspikes1= dspikes1*1000/samprate;
    % dspikes2= dspikes2*1000/samprate;
    % dspikes3= dspikes3*1000/samprate;
    % dspikes4= dspikes4*1000/samprate;
    
catch
    fprintf('\n\ndspikes is empty on at least one channel; either cell never spiked or the nstd is set too high\n');
end

%collect waveforms into matrix
%winsize=32; length of waveform window in samples
% Make n x 4 x npoints matrix, where n is number of spikes and npoints is number of samples per spike.

dspikes1=reshape(dspikes1, 1, prod(size(dspikes1)));
% dspikes2=reshape(dspikes2, 1, prod(size(dspikes2)));
% dspikes3=reshape(dspikes3, 1, prod(size(dspikes3)));
% dspikes4=reshape(dspikes4, 1, prod(size(dspikes4)));
% allspikes=sort([dspikes1 dspikes2 dspikes3 dspikes4]);
allspikes=sort([dspikes1]);

%%%%%%%%%%%%%%%%%%
%visually check thresholds before extraction
if (monitor)
region=1:10*1e4; %10 seconds
    offset=range(filteredtrace1(region));
    figure
    dt=1:length(filteredtrace1(region)); %in samples
    plot(dt, filteredtrace1(region))
    hold on
    plot(dspikes1, thresh1*ones(size(dspikes1)), 'r*')
    L1=line(xlim, thresh1*[1 1]);
    L2=line(xlim, thresh1*[-1 -1]);
    set([L1 L2], 'color', 'g');
    text(-15e3, 0*offset, 'Ch 1')
    
%     plot(dspikes2, 1*offset+thresh2*ones(size(dspikes2)), 'r*')
%     L1=line(xlim, 1*offset+thresh2*[1 1]);
%     L2=line(xlim, 1*offset+thresh2*[-1 -1]);
%     set([L1 L2], 'color', 'g');
%     text(-15e3, 1*offset, 'Ch 2')
%     
%     plot(dspikes3, 2*offset+thresh3*ones(size(dspikes3)), 'r*')
%     L1=line(xlim, 2*offset+thresh3*[1 1]);
%     L2=line(xlim, 2*offset+thresh3*[-1 -1]);
%     set([L1 L2], 'color', 'g');
%         text(-15e3, 2*offset, 'Ch 3')
% 
%     plot(dspikes4, 3*offset+thresh4*ones(size(dspikes4)), 'r*')
%     L1=line(xlim, 3*offset+thresh4*[1 1]);
%     L2=line(xlim, 3*offset+thresh4*[-1 -1]);
%     set([L1 L2], 'color', 'g');
%         text(-15e3, 3*offset, 'Ch 4')
% 
    xlim([ 0 region(end)])
    pos=get(gcf, 'pos');
    pos(1)=pos(1)-pos(3);
    set(gcf, 'pos', pos);
       ButtonName = nonmodalquestdlg('Are thresholds OK?', ...
                         'Thresh Check', ...
                         'OK', 'Cancel', 'OK');
   switch ButtonName,
     case 'Cancel',
      disp('Aborting extraction.');
      return
   end % switch

end   %%%%%%%%%%%%%%%%%%
    
wb = waitbar(0,'extracting spike waveforms');
j=0;
for i=1:length(allspikes)
    waitbar(i/length(allspikes), wb)
    pos=allspikes(i);
    if i>1
        f=pos>(allspikes(i-1)+22);
    else f=1;
    end
    if f & pos>9 & pos<length(scaledtrace1)-22 %need pre and post-spike window space
        j=j+1; %j separate index because some spikes are excluded (if picked up on multiple channels)
        t(j)=pos/10;
        %assigning a copy of ch1 to other 3 channels, should be able to use
        %same loading engine
        wf(j,1,:)=scaledtrace1((pos-9):(pos+22));
        wf(j,2,:)=scaledtrace1((pos-9):(pos+22));
        wf(j,3,:)=scaledtrace1((pos-9):(pos+22));
        wf(j,4,:)=scaledtrace1((pos-9):(pos+22));
        uniquespiketimes(j)=pos;
    end
end
numspikes=j;
close(wb)

% write data into a .mat file
outfilenamem=sprintf('%s-%s-%s-wf.mat', expdate,session,filenum);
save(outfilenamem, 'wf', 't')

%write a binary .tt file in neuralynx format (hopefully)
%each record is 176 bytes: 8 for timestamp, 40 for params, 128 for waveform
%(4x32?)
% outfilename=sprintf('%s-%s-%s-wf.tt', expdate,session,filenum);
% fid=fopen(outfilename, 'wb');
% for i=1:length(t)
%     fwrite(fid, t(i), 'uint8');
%     fwrite(fid, 1:5, 'uint8'); %dummy param
%     fwrite(fid, wf(i,:,:), 'uint8');
% end
% fclose(fid);
%there's no way this is going to work

fprintf('\ntotal num spikes: %d', numspikes)
fprintf('\nwrote output file\n%s\n', outfilenamem)

if (monitor)
    region=1:length(filteredtrace1);
    offset=range(filteredtrace1(region));
    figure
    dt=1:length(filteredtrace1(region)); %in samples
    plot(dt, filteredtrace1(region), dt, scaledtrace1(region)+offset)
    %,dt, filteredtrace2(region)+1*offset,dt, filteredtrace3(region)+2*offset, dt, filteredtrace4(region)+3*offset)
    hold on
    plot(uniquespiketimes, thresh1*ones(size(uniquespiketimes)), 'r*')
    L1=line(xlim, thresh1*[1 1]);
    L2=line(xlim, thresh1*[-1 -1]);
    set([L1 L2], 'color', 'g');
    
%     plot(uniquespiketimes, 1*offset+thresh2*ones(size(uniquespiketimes)), 'r*')
%     L1=line(xlim, 1*offset+thresh2*[1 1]);
%     L2=line(xlim, 1*offset+thresh2*[-1 -1]);
%     set([L1 L2], 'color', 'g');
%     
%     plot(uniquespiketimes, 2*offset+thresh3*ones(size(uniquespiketimes)), 'r*')
%     L1=line(xlim, 2*offset+thresh3*[1 1]);
%     L2=line(xlim, 2*offset+thresh3*[-1 -1]);
%     set([L1 L2], 'color', 'g');
%     
%     plot(uniquespiketimes, 3*offset+thresh4*ones(size(uniquespiketimes)), 'r*')
%     L1=line(xlim, 3*offset+thresh4*[1 1]);
%     L2=line(xlim, 3*offset+thresh4*[-1 -1]);
%     set([L1 L2], 'color', 'g');
%
xlim([ 0 region(end)])
    pos=get(gcf, 'pos');
    pos(1)=pos(1)-pos(3);
    set(gcf, 'pos', pos);
    
    figure
    c=get(gca, 'colororder');
    subplot1(4, 4)
    for i=1:16 subplot1(i); axis off;end
    subplot1([4 1])
    h=plot(mean(squeeze(wf(:,1,:))));
    set(h, 'color', c(1,:))
    ylabel('Ch 1')
    axis on
    
    subplot1([3 1])
    h=plot(mean(squeeze(wf(:,2,:))));
    set(h, 'color', c(2,:))
    ylabel('Ch 2')
    axis on
    
    subplot1([2 1])
    h=plot(mean(squeeze(wf(:,3,:))));
    set(h, 'color', c(3,:))
    ylabel('Ch 3')
    axis on
    
    subplot1([1 1])
    h=plot(mean(squeeze(wf(:,4,:))));
    set(h, 'color', c(4,:))
    ylabel('Ch 4')
    axis on
end
if monitor
    num2plot=100;
    figure
    pos=get(gcf, 'pos');
    pos(1)=pos(1)+pos(3)/2;
    set(gcf, 'pos', pos);
    
    hold on
    %ylim([min(filteredtrace1) max(filteredtrace1)]);
    i=0;
    L1=line([-10 10], thresh1*[1 1]);
    L2=line([-100 100], thresh1*[-1 -1]);
    set([L1 L2], 'color', 'm')
    
    offset=.5*offset;
    for ds=uniquespiketimes(1:min(num2plot, length(uniquespiketimes)))
        xlim([-10 +10])
        region=[ds-100:ds+100];
        if min(region)<1
            region=[1:ds+100];
        end
        t=1:length(region);t=t/10;t=t-10;
        i=i+1;
        h=plot(t, filteredtrace1(region));
        h1(i,:)=h;
        h2(i)=plot(dspikes1-ds, thresh1*ones(size(dspikes1)), 'r+');
        title(sprintf('spike %d %d', i, ds))
        pause(.05)
        if i>10
            set([h1(i-10,:) h2(i-10) ], 'visible', 'off')
        end
    end
end



