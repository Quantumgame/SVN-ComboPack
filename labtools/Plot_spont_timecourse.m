function Plot_spont_timecourse(expdate, session, nstd)
%usage Plot_spont_timecourse(expdate, session, thresh)
%    plots spontaneous spike rate for every tuning curve in a time series
%   (for example, at multiple time points after trauma)
%
% thresh is in number of standard deviations. If you want to use a fixed
% voltage threshold, use [-1 v]
%
%assumes you have a cell list and if using 'time' assumes there is a cell
%   array description field containing 'pre' or 'post n min'
%
%example calls:
%Plot_tone_timecourse('040209', '001', 3)
%Plot_tone_timecourse('040209', '001', [-1 600])
global pref
if isempty(pref) Prefs; end
username=pref.username;


timeaxis='time';
if nargin~=3; fprintf('\nwrong number of arguments'); return; end


cells=cell_list_NIHL_xiang;

for i=1:length(cells)
    if strcmp(cells(i).expdate, expdate) & strcmp(cells(i).session,session)
        cellnum=i;
    end
end %assumes only one match exists in the cell list


filenum=cells(cellnum).filenum(1, :);
godatadir(expdate, session, filenum)


numfiles=length(cells(cellnum).filenum);
if ~isfield(cells(cellnum), 'description') error('no description field in cell list');end
description=cells(cellnum).description;
if length(description)~=numfiles error('not all files in cell list have a description'); end

for fn=1:numfiles

    filenum=cells(cellnum).filenum(fn, :);
    datafile=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate,username, session, filenum);
    eventsfile=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate,username, session, filenum);
    try
        fprintf('\ntrying to load %s...', datafile)
        godatadir(expdate, session, filenum)
        D=load(datafile);
        E=load(eventsfile);
        fprintf('done.');
    catch
        fprintf('failed. Could not find data')
    end

    event=E.event;
    scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
    clear D E

    %find spont region (longest inter-event interval)
    clear pos
    for i=1:length(event)
        pos(i)=event(i).Position;
    end
    pos=[0 pos length(scaledtrace)];
    maxint_index=find(diff(pos)==max(diff(pos)));
    if maxint_index==length(diff(pos))
        %spont is after last event
        spont_start=event(end).Position + event(end).Param.next;
        spont_stop =length(scaledtrace);
    elseif maxint_index==1
        %spont is before first event
        spont_start=1;
        spont_stop=event(1).Position;
    else
        %spont is somewhere in middle
        %punt for now
        error('can''t locate spont segment with current algorithm. need to revise code.')
    end

    samprate=1e4;
    high_pass_cutoff=300; %Hz
    fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
    [b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
    filteredtrace=filtfilt(b,a,scaledtrace);
    if length(nstd)==2
        if nstd(1)==-1
            thresh=nstd(2);
            fprintf('\nusing absolute spike detection threshold of %.1f mV (%.1f sd)', thresh, thresh/std(filteredtrace));
        end
    else
        thresh=nstd*std(filteredtrace);
        fprintf('\nusing spike detection threshold of %.1f mV (%g sd)', thresh, nstd);
    end
    refract=5;
    fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );

    spikes=find(abs(filteredtrace)>thresh);
%     figure
%     plot(filteredtrace, 'b')
%     hold on
%     plot(thresh+zeros(size(filteredtrace)), 'm--')
%     plot(spikes, thresh*ones(size(spikes)), 'g*')
    dspikes=spikes(1+find(diff(spikes)>refract));
    dspikes=[spikes(1) dspikes'];

    %divide into 10 segments (to get std)
    spont_dur_samples=(spont_stop-spont_start);
    fprintf('\nfound %.0f s spontaneous period ', spont_dur_samples/samprate );    
    if spont_dur_samples<20*samprate*1000
        warning('\n\n\nspontaneous period is less than 20 seconds!!!!\n\n\n')
    end
    winsize=spont_dur_samples/10; %winsize in samples
    j=0;
    for start=spont_start: winsize: spont_stop
        stop=start+winsize;
        if stop<=spont_stop
            j=j+1;
            spont_spikecount=length(find(dspikes>start & dspikes<stop)); %num spikes in region
            dur=(winsize)/samprate;
            spont_spikerate(fn,j)=spont_spikecount/dur; %in Hz
        end
    end


    

    xlab='time after trauma, in minutes';
    %extract time in minutes from description field
    if strfind(description{fn}, 'pre')
        for j=1:fn
            t(j)=-5*(fn+1-j);
        end
    elseif strfind(description{fn}, 'post')
        [tok1, r]=strtok(description{fn}); %should be 'post'
        [tok2, r]=strtok(r); %should be a number
        [tok3, r]=strtok(r); %should start with 'min'
        if strcmp(tok1, 'post') & strcmp(tok3(1:3), 'min')
            t(fn)=str2num(tok2);
            t(fn)=t(fn)+5; %adding 5 minutes (half of typical TC duration) so that timepoint is centered
        else
            fprintf('\n%s-%s', cells(cellnum).expdate, cells(cellnum).session)
            fprintf('\nfile %s', cells(cellnum).filenum(fn,:))
            fprintf('\ndescription: %s\n', cells(cellnum).description{fn})
            error('can''t extract time from description')

        end
    else %neither pre nor post??
        error(sprintf('file %s is neither pre nor post??', cells(cellnum).filenum(fn,:)))
    end

end
%plot

figure
mS=mean(spont_spikerate, 2);
sS=std(spont_spikerate,[], 2)./sqrt(size(spont_spikerate, 2));

e=errorbar(t, mS, sS); %
set(e, 'marker', 'o')
line([0 0], ylim, 'linestyle', '--', 'color', 'k')


xlabel('time after trauma, minutes')
ylabel('spontaneous spike count +- S.E.M.')
title(sprintf('time course for spontaneous activity, %s-%s', expdate, session))














