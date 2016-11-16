function testBB(expdate, session, filenum1, filenum2)
%usage: testBB(expdate, session, filenum1, filenum2)
%tests mua BB data for significance
%compares the 25 ms ON response to the 400 ms OFF response
%for usable data, they should NOT be significantly different
%

doplot=1;

global pref
if isempty(pref) Prefs; end
username=pref.username;

godatadir(expdate, session, filenum1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file 1:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

datafile1=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate, username, session, filenum1);
eventsfile1=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate, username, session, filenum1);
D=load(datafile1);
E=load(eventsfile1);
event1=E.event;
scaledtrace1=D.nativeScaling*double(D.trace) +D.nativeOffset;
clear D E
nstd=7;

samprate=1e4;
high_pass_cutoff=300; %Hz
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace1=filtfilt(b,a,scaledtrace1);
thresh1=nstd*std(filteredtrace1);
fprintf('\nusing spike detection threshold of %.4f mV (%d sd)', thresh1, nstd);
refract=5;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes1=find(abs(filteredtrace1)>thresh1);
dspikes1=spikes1(1+find(diff(spikes1)>refract));
dspikes1=[spikes1(1) dspikes1'];

%get freqs/amps
j=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, 'tone')
        j=j+1;
        allfreqs1(j)=event1(i).Param.frequency;
        allamps1(j)=event1(i).Param.amplitude;
        alldurs1(j)=event1(i).Param.duration;
    end
end
k=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, '2tone')
        k=k+1;
        all2tonefreqs1(k)=event1(i).Param.frequency;
        allprobefreqs1(k)=event1(i).Param.probefreq;
        allSOAs1(k)=event1(i).Param.SOA;
    end
end
freqs1=unique(allfreqs1);
SOAs1=unique(allSOAs1);
twotonefreqs1=unique(all2tonefreqs1);
probefreqs1=unique(allprobefreqs1);
amps1=unique(allamps1);
durs1=unique(alldurs1);
numfreqs1=length(freqs1);
numamps1=length(amps1);
numdurs1=length(durs1);

M11=[];
M21=[];
nreps11=zeros(numfreqs1, numamps1, numdurs1);
nreps21=zeros(length(twotonefreqs1), numamps1, numdurs1);

%extract the traces into a big matrix M11 (tone alone)
j=0;
baseline=0;
tracelength=600;
for i=1:length(event1)
    if strcmp(event1(i).Type, 'tone')  | strcmp(event1(i).Type, 'whitenoise')
        if isfield(event1(i), 'soundcardtriggerPos')
            pos=event1(i).soundcardtriggerPos;
        else
            pos=event1(i).Position_rising;
        end

        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)

            if strcmp(event1(i).Type, 'tone')
                freq=event1(i).Param.frequency;
                dur=event1(i).Param.duration;
            elseif strcmp(event1(i).Type, 'whitenoise')
                dur=event1(i).Param.duration;
                freq=-1;
            end
            amp=event1(i).Param.amplitude;
            findex= find(freqs1==freq);
            aindex= find(amps1==amp);
            dindex= find(durs1==dur);
            nreps11(findex, aindex, dindex)=nreps11(findex, aindex, dindex)+1;
            spiketimes1=dspikes1(dspikes1>start & dspikes1<stop); % spiketimes in region
            spiketimes1=(spiketimes1-pos)*1000/samprate;%covert to ms after tone onset
            M11(findex,aindex,dindex, nreps11(findex, aindex, dindex)).spiketimes=spiketimes1;
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps11))), max(max(max(nreps11))))
fprintf('\ntotal num spikes: %d', length(dspikes1))

%extract the traces into a big matrix M2 (2tone )
j=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, '2tone')
        if isfield(event1(i), 'soundcardtriggerPos')
            pos=event1(i).soundcardtriggerPos;
        else
            pos=event1(i).Position_rising;
        end

        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)

            if strcmp(event1(i).Type, '2tone')
                freq=event1(i).Param.frequency;
                dur=event1(i).Param.duration;
            end
            amp=event1(i).Param.amplitude;
            findex= find(twotonefreqs1==freq);
            aindex= find(amps1==amp);
            dindex= find(durs1==dur);
            nreps21(findex, aindex, dindex)=nreps21(findex, aindex, dindex)+1;
            spiketimes1=dspikes1(dspikes1>start & dspikes1<stop); % spiketimes in region
            spiketimes1=(spiketimes1-pos)*1000/samprate;%covert to ms after tone onset
            M21(findex,aindex,dindex, nreps21(findex, aindex, dindex)).spiketimes=spiketimes1;
        end
    end
end

%accumulate across trials (M11)
for dindex=[1:numdurs1]
    for aindex=[numamps1:-1:1]
        for findex=1:numfreqs1
            spiketimes1=[];
            for rep=1:nreps11(findex, aindex, dindex)
                spiketimes1=[spiketimes1 M11(findex, aindex, dindex, rep).spiketimes];
            end
            mM11(findex, aindex, dindex).spiketimes=spiketimes1;
        end
    end
end
%accumulate across trials(M21)
for dindex=[1:numdurs1]
    for aindex=[numamps1:-1:1]
        for findex=1:length(twotonefreqs1)
            spiketimes1=[];
            for rep=1:nreps21(findex, aindex, dindex)
                spiketimes1=[spiketimes1 M21(findex, aindex, dindex, rep).spiketimes];
            end
            mM21(findex, aindex, dindex).spiketimes=spiketimes1;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file 2:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

datafile2=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate, username, session, filenum2);
eventsfile2=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate, username, session, filenum2);
D=load(datafile2);
E=load(eventsfile2);
event2=E.event;
scaledtrace2=D.nativeScaling*double(D.trace) +D.nativeOffset;
clear D E


samprate=1e4;
high_pass_cutoff=300; %Hz
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace2=filtfilt(b,a,scaledtrace2);
thresh2=nstd*std(filteredtrace2);
fprintf('\nusing spike detection threshold of %.1f mV (%d sd)', thresh2, nstd);
refract=5;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes2=find(abs(filteredtrace2)>thresh2);
dspikes2=spikes2(1+find(diff(spikes2)>refract));
dspikes2=[spikes2(1) dspikes2'];

%get freqs/amps
j=0;
for i=1:length(event2)
    if strcmp(event2(i).Type, 'tone')
        j=j+1;
        allfreqs2(j)=event2(i).Param.frequency;
        allamps2(j)=event2(i).Param.amplitude;
        alldurs2(j)=event2(i).Param.duration;
    end
end
k=0;
for i=1:length(event2)
    if strcmp(event2(i).Type, '2tone')
        k=k+1;
        all2tonefreqs2(k)=event2(i).Param.frequency;
        allprobefreqs2(k)=event2(i).Param.probefreq;
        allSOAs2(k)=event2(i).Param.SOA;
    end
end
freqs2=unique(allfreqs2);
SOAs2=unique(allSOAs2);
twotonefreqs2=unique(all2tonefreqs2);
probefreqs2=unique(allprobefreqs2);
amps2=unique(allamps2);
durs2=unique(alldurs2);
numfreqs2=length(freqs2);
numamps2=length(amps2);
numdurs2=length(durs2);

M12=[];
M22=[];
nreps12=zeros(numfreqs2, numamps2, numdurs2);
nreps22=zeros(length(twotonefreqs2), numamps2, numdurs2);

%extract the traces into a big matrix M12 (tone alone)
j=0;
baseline=0;
tracelength=600;
for i=1:length(event2)
    if strcmp(event2(i).Type, 'tone')  | strcmp(event2(i).Type, 'whitenoise')
        if isfield(event2(i), 'soundcardtriggerPos')
            pos=event2(i).soundcardtriggerPos;
        else
            pos=event2(i).Position_rising;
        end
        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)

            if strcmp(event2(i).Type, 'tone')
                freq=event2(i).Param.frequency;
                dur=event2(i).Param.duration;
            elseif strcmp(event2(i).Type, 'whitenoise')
                dur=event2(i).Param.duration;
                freq=-1;
            end
            amp=event2(i).Param.amplitude;
            findex= find(freqs2==freq);
            aindex= find(amps2==amp);
            dindex= find(durs2==dur);
            nreps12(findex, aindex, dindex)=nreps12(findex, aindex, dindex)+1;
            spiketimes2=dspikes2(dspikes2>start & dspikes2<stop); % spiketimes in region
            spiketimes2=(spiketimes2-pos)*1000/samprate;%covert to ms after tone onset
            M12(findex,aindex,dindex, nreps12(findex, aindex, dindex)).spiketimes=spiketimes2;
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps12))), max(max(max(nreps12))))
fprintf('\ntotal num spikes: %d', length(dspikes2))

%extract the traces into a big matrix M2 (2tone )
j=0;
for i=1:length(event2)
    if strcmp(event2(i).Type, '2tone')
        if isfield(event2(i), 'soundcardtriggerPos')
            pos=event2(i).soundcardtriggerPos;
        else
            pos=event2(i).Position_rising;
        end
        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)

            if strcmp(event2(i).Type, '2tone')
                freq=event2(i).Param.frequency;
                dur=event2(i).Param.duration;
            end
            amp=event2(i).Param.amplitude;
            findex= find(twotonefreqs2==freq);
            aindex= find(amps2==amp);
            dindex= find(durs2==dur);
            nreps22(findex, aindex, dindex)=nreps22(findex, aindex, dindex)+1;
            spiketimes2=dspikes2(dspikes2>start & dspikes2<stop); % spiketimes in region
            spiketimes2=(spiketimes2-pos)*1000/samprate;%covert to ms after tone onset
            M22(findex,aindex,dindex, nreps22(findex, aindex, dindex)).spiketimes=spiketimes2;
        end
    end
end

%accumulate across trials (M12)
for dindex=[1:numdurs2]
    for aindex=[numamps2:-1:1]
        for findex=1:numfreqs2
            spiketimes2=[];
            for rep=1:nreps12(findex, aindex, dindex)
                spiketimes2=[spiketimes2 M12(findex, aindex, dindex, rep).spiketimes];
            end
            mM12(findex, aindex, dindex).spiketimes=spiketimes2;
        end
    end
end
%accumulate across trials(M22)
for dindex=[1:numdurs2]
    for aindex=[numamps2:-1:1]
        for findex=1:length(twotonefreqs2)
            spiketimes2=[];
            for rep=1:nreps22(findex, aindex, dindex)
                spiketimes2=[spiketimes2 M22(findex, aindex, dindex, rep).spiketimes];
            end
            mM22(findex, aindex, dindex).spiketimes=spiketimes2;
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%

if        numfreqs1 >2 | numamps1>1 |  numdurs1>1 | ...
        numfreqs2 >2 | numamps2>1 |  numdurs2>1
    error('wrong number of freqs/amps/durations in stimulus')
end

if doplot
    figure; hold on
    [n1, x1]=hist(mM11(1,1,1).spiketimes, 200);
    [n2, x2]=hist(mM12(1,1,1).spiketimes, 200);
    if durs1==25
        plot(x1, n1,'b', x2-durs2, n2, 'r')
    elseif durs1==400
        plot(x1-durs1, n1,'b', x2, n2, 'r')
    end
end

    win=100;
    if durs1==25 & SOAs1==100 %bb25
        % store the ON response in A
        % A=ON response to 25ms
        % B=OFF response to 400 ms
        start=0;
        stop=start+win;
        for rep=1:nreps11
            A1=find(M11(1,1,1, rep).spiketimes>start);
            A2=find(M11(1,1,1, rep).spiketimes<stop);
            A(rep)=length(intersect(A1, A2));
        end
    elseif durs1==400 & SOAs1==500 %bb400
        % store the OFF response in B
        % A=ON response
        % B=OFF response
        start=durs1;
        stop=start+win;
        for rep=1:nreps11
            B1=find(M11(1,1,1, rep).spiketimes>start);
            B2=find(M11(1,1,1, rep).spiketimes<stop);
            B(rep)=length(intersect(B1, B2));
        end
    end
    if durs2==25 & SOAs2==100 %bb25
        % store the ON response in A
        % A=ON response to 25ms
        % B=OFF response to 400 ms
        start=0;
        stop=start+win;
        for rep=1:nreps12
            A1=find(M12(1,1,1, rep).spiketimes>start);
            A2=find(M12(1,1,1, rep).spiketimes<stop);
            A(rep)=length(intersect(A1, A2));
        end
    elseif durs2==400 & SOAs2==500 %bb400
        % store the OFF response in B
        % A=ON response
        % B=OFF response
        start=durs2;
        stop=start+win;
        for rep=1:nreps12
            B1=find(M12(1,1,1, rep).spiketimes>start);
            B2=find(M12(1,1,1, rep).spiketimes<stop);
            B(rep)=length(intersect(B1, B2));
        end
    end

    [h, p]=     ttest2(A, B, .001);
    if h
        fprintf('\n\nnot usable data: ttest says the ON-25 and OFF-400 are different at p<%.4f', p)
    else
        fprintf('\n\nUsable data: ttest says the ON-25 and OFF-400 are the same (p<%.4f)', p)
    end
    sum(A)
    sum(B)
    