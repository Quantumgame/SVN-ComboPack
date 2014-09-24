%%fft_mem.m
%usage:
% fft_mem(dir) to load files from disk
% fft_mem(dir, M) to work from M video data file in memory
% This is code for pre-filtering and then running an FFT on the time-series
%video of a rat/mouse response to auditory stimulus. This runs the entire
%analysis in memory in order to save time. The code was written and tested
%on a computer with 16GB RAM, and as such is currently optimized for this
%setup, as well as a parallelized part(not currently implemented) which is
%optimized for a 4-core machine.
%Authors: Mike Wehr, Vasha Dutell

function fft_mem(varargin)
begin = tic;
dir=varargin{1};
cd(dir);
load('stimparams.mat');
%grab our stimparam variables
spf=stimparams.series_period_frames;
sp=stimparams.series_periodicity;
fps = stimparams.FPS;

%% load in raw video data -
%grabs each individual M-*.mat file which contains 100-frame chunks and
%collects them all into a large matrix M. This has been use to test this
%code, but because everything is now done in memory, when this is copied into
%imstim2 and done right after data is collected, there will be no need to
%do the read-in.
loading = tic;
if nargin==2
    M=varargin{2};
elseif nargin==1 %load raw video data
    fprintf('\nloading movie...')
    basefilename='M';
    nfiles=size(ls(sprintf('%s-*.mat', basefilename)),1);
    fn=sprintf('%s-0.mat', basefilename);
    load(fn);
    %     chunksize=size(m,4); %number of frames in each mat-file
    %     nframes=nfiles*chunksize;
    %     %M=zeros(512, 512, nframes, 'single'); (Use for vectorized filter - see note ~line 42)
    %     M=zeros(512, 512, nframes, 'uint16');
    %     for k=1:nfiles
    %         %     index=[k k+chunksize-1];
    %         %     if k+chunksize-1>nframes index=[k nframes];end
    %         fprintf('\nfile %d', k)
    %         fn=sprintf('%s-%d.mat', basefilename, k);
    %         load(fn);
    %         chunksize=size(m,4);
    %         fprintf('\tframes %d - %d', 1+(k-1)*chunksize,(k)*chunksize)
    %
    %         %I figured out how to do on-chip spatial and temporal binning so I took out
    %         %the imreduce step
    %         %     for j=1:chunksize
    %         %         m2(:,:,j) = impyramid(squeeze(m(:,:,1,j)), 'reduce'); %2x2 binning
    %         %     end
    %
    %         %collect timeseries chunks into one large (512x512xnframes) matrix
    %         %***NOTE: in the case of vectorized filtering, M must be cast as
    %         %single when reading in because it isoriginally uint16, and after
    %         %the filter works on the data and
    %         %normalizes it to around zero, when the vectorized filtering replaces
    %         %the filtered pixel in the matrix, it is cast back to uint16 and
    %         %data is lost.
    %         M(:,:,(1+(k-1)*chunksize):k*chunksize)=m;
    %         %M(:,:,(1+(k-1)*chunksize):k*chunksize)=single(m); use this for
    %         %vectorized filter
    %     end
end
fprintf('\nLoading ')
toc(loading);
%size(M)

%%   *WORKING COPY*
%Notes:
%{
%filter out slow variation & create FFT together in loop
%9/25/12 - Using this as working copy. Fastest running time (excluding read-in)
%is 4 minutes.(no casting M to single in beginning.We still haven't figured
%out how to get an effective filter in a format
%such that it will work with imfilter and effectively perform vectorized
%filtering rather than going through the loop as we do here.  So, we leave
%this as the working version which takes more time(this takes 3.7 minutes, and
%the vectorized version should take about 2), but this version works correctly. If a
%suitable method for vectorized filtering is found, this block can be
%commented out and the vectorized filtering code section used instead.

%9/17/12 - Removed unwrap() from Phase computation and saved more time.
%9/14/12 - Changed F and Phase to single precision and now analysis takes 5
%minutes :DD
%9/6/12 - This method works and can read in file, filter, run fft, and
%produce amplitude and phase maps in 371 seconds ~ 6.2 minutes :D
%}
if(1)
    filterfft = tic;
    fprintf('\nRemoving slow variation and calculating FFT for %d pixels(512*512)...\n',512*512)
    %make our filter - tested different versions and order=1,cuttoff=.02
    %seems sufficient. Order is later doubled because of filtfilt.
    order = 1;
    cuttoff = .02;
    [b,a]=butter(order, cuttoff/(fps/2), 'high');
    
    %minimum for n in n-point fft
    nframes=size(M, 4);
    NFFT = 2^nextpow2(nframes);
    %only need to save up to nyquist
    NFFT2 = 1022;
    if NFFT<512 %for very short videos, usually for testing purposes
        NFFT2=2*(NFFT-1);
    end
    %pre-allocate matrices
    F=zeros(512,512,NFFT2/2+1,'single');
    Phase=F;
    wb=waitbar(0, 'Removing slow variation and calculating FFT');
    fftw('planner','patient'); %Added to speed up fft calculation - 8/10/12 Vasha Dutell
    for j=1:(512*512)
        m = mod(j-1,512)+1;
        n = floor((j-1)/512)+1;
        if mod(j,5000)==0;waitbar(j/(512*512), wb);end
        %if mod(j,10000)==0;fprintf('\n');end
        %waitbar(j/(512*512), wb)
        ts = double(M(m,n,:));
        %filtfilt is needed to remove the phase shift introduced by
        %filtering one direction but not the other. Filtfilt also only
        %takes doubles so M must be cast to a double before being filtered
        %(see line above)-filtfilt also doubles our order.
        fts = single(filtfilt(b,a,ts)); %filter sv removal - cast back to
        %single before fft to save time
        f=fft(fts, NFFT)/nframes; %do fft (n=NFFT for n-point)
        F(m,n,:)=abs(f(1:NFFT2/2+1));
        %Phase(m,n,:)=unwrap(angle(f(1:NFFT2/2+1)), 2*pi); %removed unwrap to save time - 9/17/12
        Phase(m,n,:)=angle(f(1:NFFT2/2+1));
    end
     close(wb)
    fprintf('\n')
    toc(filterfft)
end

%}
%% vectorize fft split into parts ***ALMOST WORKING***
%NOTES:
%{
%Vectorized fft which is split into parts and put in a loop. This is MUCH
%faster than running an fft individually on each pixel, but gets close to
maxing out RAM, and until filtering can also be vectorized, is no faster
because the loop must be entered anyway in order to perform filtering.

The problem with this block working is the implementation of a butterworth
filter applied to the matrix M using imfilter. The problem has been posted
in the forum on Mathworks Answers as as of 9/25/12 there has been no answer
posted. The text of the question posted on the forum is below:

http://www.mathworks.com/matlabcentral/answers/48973
******************************************************************
Hi all- I'm trying to use imfilter to apply a 1-D Butterworth filter
to each pixel of a time series... I'm using imfilter to vectorize my
filtering instead of looping over each pixel. The only ways to create
a Butterworth filter I can find are...

[a,b] = butter(...) - numerator and denominator form
[z,p,k] = butter(...) - zero & pole form
[A,B,C,D] = butter(...) - state space form
d=fdesign.highpass(...);hd=design(d,'butter'...); - filter object form

From the documentation in imfilter and fspecial, it looks like imfilter
takes a filter as a 'correlation kernel'.. I see there are functions to
convert z-p to 'SOS' form,'transfer function polynomials','state-space'
form, but none to get the 'correlation kernel' out of it which I can use
to apply the filter using imfilter. And as for the filter object created
with fdesgin, the only thing I can get out of it is the 'SOS matrix', and
the 'scale values'.

Is there a way to get this correlation kernel for a Butterworth filter
so that I can apply it using imfilter? So for example I would have a
filter b which I could make 1-D and apply to my matrix with...

b=myfilter;
H = ones(1,1,length(b));
H(1,1,:)=b;
M_filtered=imfilter(M,H)

Forgive me if I'm missing something obvious about filter design(I'm no
expert yet) and thanks in advance!
*********************************************************************

*NOTE: if this filtering problem is solved and this fitlering method is
sucessfully implemented, need to change the read-in block to
make M single and cast each m to single before adding them to the large M.
This is because the vectorized filter stores the filtered M back in the
same matrix variable, and the filtered data is centered about zero, so data
is lost if M is not int-16. In the case of copying this code into imstim2,
simply add the line M=single(M); before applying the filter as the read-in
step will not be present.

If this issue is resolved also consider conv2 (with parameter 'same') instead of imfilter...seems
it can give faster results in some cases.
%}
if(0)
    filterfft = tic;
    fprintf('\nRemoving slow variation and calculating FFT for 512*512 pixels...\n')
    
    %things I've looked into trying to figure out how to define the filter
    order = 2;
    cuttoff = .02;
    cuttoff_pi_rads = cuttoff*2*pi;
    d=fdesign.highpass('N,F3dB',order,cuttoff_pi_rads);
    hd = design(d,'butter');
    hdf=hd.ScaleValues;
    H = ones(1,1,length(hdf));
    H(1,1,:)=hdf;
    fprintf('Running imfilter...\n')
    justfilter=tic;
    %[z,p,k]=butter(order, cuttoff/(fps/2), 'high');
    %sos=zp2sos(z,p,k);
    M=imfilter(M,H);
    M=flipdim(M,3);
    M=imfilter(M,H);
    fprintf('\n')
    toc(justfilter)
    %d=fdesign.bandpass('N,Fp1,Fp2,Ap',order,cuttoff,cuttoff/(fps/2),1);
    %cuttoff_param = .5*sp;
    %cuttoff = cuttoff_param/(fps/2);
    
    %filter should be applied like this:
    %b = 1-D (butterworth?) filter (must be in 'convolution kernel' form -
    %this is the appropriate form for imfilter)
    %H = ones(1,1,length(b));
    %H(1,1,:)=b; %make the filter 1-d as to only operate on the third
    %dimension.
    %run imfilter then flip dimension and run again to remove phase
    %shift. This also doubles the order of our filter.
    %M = imfilter(flipdim(imfilter(M, H, 'replicate'),3),H,'replicate');
    fprintf('Running fft...\n')
    NFFT = 2^nextpow2(nframes);
    NFFT2 = 1022;
    F=zeros(512,512,NFFT2/2+1,'single');
    Phase=F;
    fft_time = tic;
    %64x512 chunks is the largest chunk size possible to break up the fft
    %into and not max out memory on our current 16GB RAM machine.
    split_i = 64;
    for j=1:split_i:(512-split_i+1)
        fprintf('%d,',j);
        ts = M(j:(j+split_i-1),:,:);
        f=fft(ts, NFFT,3)/nframes;
        F(j:(j+split_i-1),:,:)=abs(f(:,:,1:NFFT2/2+1));
        Phase(j:(j+split_i-1),:,:)=angle(f(:,:,1:NFFT2/2+1));
    end
    toc(fft_time);
    fprintf('\n')
    fprintf('Total elapsed time (not including read-in):')
    toc(filterfft)
end
%}
%% filter out slow variation & create FFT in one step parallelized *NOT WORKING*
%{
%9/25/12 - Leaving this in here because if we can't get imfilter working,
if we could get this working it would definetly speed everything up, but
the weird error - see next note - is hindering us here. This was created
for a computer with 4 cores, but could possibly futher speed up ananlysis on a
computer with more cores at its disposal.
%9/14/12 This doesn't work - there is an error in SPMD saying filtfilt
%requires imput of double, even though it is casted to a double. It works
%fine outside the spmd block. WEIRD. -Vasha
if(0)
    filterfft_par = tic;
    fprintf('\nremoving slow variation and calculating FFT for %d pixels(512*512) - parallelized...\n',512*512)

    %need to permute in this case so we can distribute to workers over last
    %nonsingleton dimension
    fprintf('\npermuting M in preparation for distribution...')
    M=permute(M, [3 1 2]);
   
    order = 2;
    cuttoff = .02;
    [b,a]=butter(order, cuttoff/(fps/2), 'high');
    NFFT = 2^nextpow2(nframes);
    NFFT2 = 1022;
    NFFT2 = 200;
    fprintf('\ncreating distribued F...')
    dF=distributed(zeros(512,512,NFFT2/2+1,'single'));
    fprintf('\ncreating distribued Phase...')
    dPhase=distributed(zeros(512,512,NFFT2/2+1,'single'));
    fprintf('\ncreating distribued M...')
    dM = distributed(M);
    fftw('planner','patient'); %Added to speed up fft calculation - 8/10/12 Vasha Dutell
    fprintf('\nrunning spmd block...\n')
    spmd
        %[frames,rows,cols] = size(getLocalPart(M));
        %for j=1:cols
        %for j=((labindex-1)*512*512/numlabs+1):((labindex)*512*512/numlabs)
        for m=1:512
            for n=1:128
                ts = double(dM(:,m,n));
                %fts = single(filtfilt(b,a,ts)); %filter sv removal
                %f=fft(fts, NFFT)/nframes;
                f=fft(single(ts), NFFT)/nframes;
                dF(m,n,:)=abs(f(1:NFFT2/2+1));
                %dPhase(m,n,:)=unwrap(angle(f(1:NFFT2/2+1)), 2*pi);
                dPhase(m,n,:)=angle(f(1:NFFT2/2+1));

            end
        end
    end
    
    Phase = gather(dPhase);
    F = gather(dF);
%{
    spmd
        Md = codistributed(M);
        for j=
            m = mod(j-1,512)+1;
            n = floor((j-1)/512)+1;
            ts = double(Md(:,m,n));
            fts = filtfilt(b,a,ts); %filter sv removal
            f=fft(ts, NFFT)/nframes;
            F(m,n,:)=abs(f(1:NFFT2/2+1));
            %Phase(m,n,:)=unwrap(angle(f(1:NFFT2/2+1)), 2*pi);
            Phase(m,n,:)=angle(f(1:NFFT2/2+1));
%}
 
fprintf('\n')
toc(filterfft_par)
end
%}
%% filter out slow variation separately - good for testing fft separately.
%{

if(1)
    filter = tic;
    fprintf('\nRemoving slow variation for %d pixels(512*512)...\n',512*512)
    order = 2;
    cuttoff = .02;
    [b,a]=butter(order, cuttoff/(fps/2), 'high');
    for j=1:(512*512)
        m = mod(j-1,512)+1;
        n = floor((j-1)/512)+1;
        if mod(j,1000)==0;fprintf('%d ', j);end
    	if mod(j,10000)==0;fprintf('\n');end
        %filtfilt is needed to remove the phase shift introduced by
        %filtering one direction but not the other. Filtfilt also only
        %takes doubles so M must be cast to a double before being filtered
        M(m,n,:) = filtfilt(b,a,double(M(m,n,:))); %filter sv removal
    end
fprintf('\n')
toc(filter)
end
%}
%% calculate FFT separately - good for testing filter separately.
%{
if(1)
    fprintf('\nCalculating FFT for %d pixels(512*512)\n',512*512)
    NFFT = 2^nextpow2(nframes);
    NFFT2 = 1022;
    F=zeros(512,512,NFFT2/2+1,'double');
    Phase=F;
    fftw('planner','patient'); %Added to speed up fft calculation - 8/10/12 Vasha Dutell
    for j=1:512*512
        m = mod((j-1),512)+1;
        n = floor((j-1)/512)+1;
        if mod(j,1000)==0;fprintf('%d ', j);end
    	if mod(j,10000)==0;fprintf('\n');end
        ts = M(m,n,:);
        %do fft
        f=fft(ts, NFFT)/nframes;
        F(m,n,:)=abs(f(1:NFFT2/2+1));
        Phase(m,n,:)=angle(f(1:NFFT2/2+1));
    end
end
%}
%% fully vectorized fft (all at once) *NOT WORKING ON 16-GB RAM SETUP*
%{
%this doesn't work on our current setup with 16GB RAM because we don't have
enough memory to do large vectorized operations on M while it's also stored in
memory. The problem comes in needing to do an n-point fft where n=1022, so
there must be M=512x512x(~4200), Mfft=512x512x1022, both in memory, along
with the need for RAM to do the fft calculation. Could work on a 32GB
machine though, possibly even without the splitting M into parts and the
fft into parts.

if(0)
    fft_time=tic;
    %fftw('planner','patient'); %Added to speed up fft calculation - 8/10/12 Vasha Dutell
    
    %split into 4 parts so we don't max out memory - had to take out NFFT2
    %and use [] instead because can't save smaller size in M than 4600 and
    %not enough memory to hold another larger matrix in memory to write into.
    NFFT = 2^nextpow2(nframes);
    NFFT2 = 1022;
    fprintf('Running Vecotrized FFT...\n')

    %split M into two parts - this allows us to conserve RAM by deleting
    %half of M when memory is starting to get very full
    M1=M(:,1:256,:);
    M2=M(:,257:512,:);
    clear M;
    
    ffth = zeros(512,256,NFFT ,'single');
    ffth(:,1:64,:)=fft(M1(:,1:64,:),NFFT,3)/nframes;
    ffth(:,65:128,:)=fft(M1(:,65:128,:),NFFT,3)/nframes;
    ffth(:,129:192,:)=fft(M1(:,129:192,:),NFFT,3)/nframes;
    ffth(:,193:256,:)=fft(M1(:,193:256,:),NFFT,3)/nframes;
    clear M1;
    
    fprintf('done with M1')
    ffth(:,1:64,:)=fft(M2(:,1:64,:),NFFT,3)/nframes;
    ffth(:,65:128,:)=fft(M2(:,65:128,:),NFFT,3)/nframes;
    ffth(:,129:192,:)=fft(M2(:,129:192,:),NFFT,3)/nframes;
    ffth(:,193:256,:)=fft(M1(:,193:256,:),NFFT,3)/nframes;
    clear M2;

    fprintf('\n')
    toc(fft_time)
    F=zeros(512,512,NFFT2/2+1,'single');
    Phase=F;
    F=abs(ffth(:,:,1:NFFT2/2+1));
    Phase=angle(ffth(:,:,1:NFFT2/2+1));
    fprintf('\n')
end
%}
%% Create Phase & Amplitude Maps
fprintf('\ncomputing Phase & Amplitude & stimulus periodicity')
ff = fps/2*linspace(0,1,NFFT/2+1); %for Hz
ff=ff(1:NFFT/2+1);
P=Phase(:,:,1:NFFT2/2+1);
x=abs(ff-sp); %for Hz
spidx=find(x==min((x))); %spidx is the fft index corresponding to stimulus periodicity
spidx=spidx(1); %in case it's in between samples, pick one
bigPM=P(:,:,spidx); %phase map at stim periodicity
bigFM=F(:,:,spidx); %amplitude map at stim periodicity

%% Display Phase Map
figure
imagesc(bigPM)
colormap('HSV')%8/8/12 changed to HSV colormap - Vasha Dutell
%title(sprintf('phase map at stimulus periodicity %s-%s', expdate, session))
title(sprintf('phase map at stimulus periodicity'))
colorbar

%% Display Amplitude Map
figure
imagesc(bigFM)
%title(sprintf('amplitude map at stimulus periodicity %s-%s', expdate, session))
title(sprintf('amplitude map at stimulus periodicity'))
colorbar

%% now that we've displayed write M to disk.
%we'll want
if(1)
    fsave = tic;

    %save phase and amplitude maps at stimulus periodicity
save bigPM bigPM
save bigFM bigFM
save analparams nframes %anything else to save here?

fn=sprintf('M.dat');
    fid=fopen(fn, 'w');
    fwrite(fid, M, 'single');
    fclose(fid);
    fprintf('\nsaved file.')
    toc(fsave)
end

fprintf('\n')
fprintf('Total elapsed time (including read-in):')
toc(begin)


