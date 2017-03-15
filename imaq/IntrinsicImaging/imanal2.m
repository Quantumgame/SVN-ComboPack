 function imanal2(varargin)
%loads raw imaging data files, splits into full timeseries image chunks
%(like a piecewise transpose), removes slow variation, does FFT and saves
%phase and amplitude maps, does some plotting
%note: use imview.m to view the results of imanal2.m without redoing the analysis 
%
%usage: imview([expdate], [session])
% if you omit expdate and session, default is to open a dialog box for you
% to select data
%mw 06-14-2011
begin=tic;
if nargin==1
    path=varargin{1};
    cd(path)
    [p,session,e]=fileparts(path);
    [p,expdate,e]=fileparts(p);
elseif nargin==2
    expdate=varargin{1};
    session=varargin{2};
    cd c:\lab\imaq
    cd(expdate)
    cd(session)
elseif nargin==0
    expdate=datestr(now, 'mmddyy');
    cd c:\lab\imaq
    if exist(expdate, 'dir')
        cd(expdate)
    end
    
    [pathname] = uigetdir(pwd, 'Choose a data directory');
    if pathname==0
        fprintf('cancelled by user');
        return
    end
    cd(pathname)
    [p,session,e]=fileparts(pathname);
else error('imview: wrong number of arguments')
end

pwd

%note: matlab AVI disklogging only supports 8-bit, so I am now using a
%combination of getdata and save to write in chunks to .mat files
figure
fn='g.mat';
load(fn)
imagesc(g)
colormap(gray)
title('surface image (green)')

if exist('./imstimparams.mat', 'file')
    stimparams=load('imstimparams.mat');
    stimparams=stimparams.stimparams;
else
    stimparams=load('stimparams.mat');
    stimparams=stimparams.stimparams;
end
spf=stimparams.series_period_frames;
sp=stimparams.series_periodicity;
fps = stimparams.FPS;

if (1) %load and split raw video data
    fprintf('\nloading movie...')
    basefilename='M';
    nfiles=size(ls(sprintf('%s-*.mat', basefilename)),1);
    fn=sprintf('%s-1.mat', basefilename);
    load(fn);
    chunksize=size(m,4); %number of frames in each mat-file
    %m2=zeros(512,512,chunksize);
    nframes=nfiles*chunksize;
    M=zeros(512, 512, nframes, 'int16');
    for k=1:nfiles;
        %     index=[k k+chunksize-1];
        %     if k+chunksize-1>nframes index=[k nframes];end
        fprintf('\nfile %d', k)
        fn=sprintf('%s-%d.mat', basefilename, k);
        load(fn);
        chunksize=size(m,4);
        fprintf('\tframes %d - %d', 1+(k-1)*chunksize,(k)*chunksize)
        
        %I figured out how to do on-chip spatial and temporal binning so I took out
        %the imreduce step
        %     for j=1:chunksize
        %         m2(:,:,j) = impyramid(squeeze(m(:,:,1,j)), 'reduce'); %2x2 binning
        %     end
        
        M(:,:,(1+(k-1)*chunksize):k*chunksize)=m;
    end
    
    %remove slow variation
    fprintf('\nremove slow variation\n')
    sv=zeros(size(M), 'int16');
    winsize=2*spf;
    for k=1:nframes
        if mod(k,10)==0;fprintf('%d ', k);end
        if mod(k,100)==0;fprintf('\n');end
        %if we dont have a half window below us, average over a half window above
        if k<round(winsize/2) 
            sv(:,:,k)=mean(M(:,:,1:(k+round(winsize/2))),3);
       
        %7/23/12 Vasha Dutell: changed "M(:,:,k-round(winsize)+1:k)"to "M(:,:,k-round(winsize)+1:nframes)"
        % we want our window to average all the way up to nframes not just below k
        elseif k>nframes-round(winsize/2)
             %if we dont have a half window above us, average over a half window below
            sv(:,:,k)=mean(M(:,:,k-round(winsize)+1:nframes),3); 
        else
        
            %else we can average over half window below and above
            sv(:,:,k)=mean(M(:,:,1+(k-round(winsize/2)):(k+round(winsize/2))),3);
        end
    end
    M=M-sv;
    
    
    %split and save
    fprintf('\nnow split and save in M x M x nframe chunks...')
    xidx=0;
    chunksize=256;
    nchunks=512/chunksize;
    for i=1:chunksize:512
        xidx=xidx+1;
        yidx=0;
        for j=1:chunksize:512
            yidx=yidx+1;
            kx=i:i+chunksize-1;
            ky=j:j+chunksize-1;
            fprintf('\n%d %d, %d-%d, %d-%d', i, j, kx(1), kx(end),ky(1), ky(end))
            M2=M(kx,ky,:);
            fn=sprintf('M2-%d-%d', xidx,yidx);
            save(fn, 'M2')
            %         figure
            %         imagesc(g(kx,ky))
            %         colormap(gray)
            %         set(gcf, 'pos', [400, 400, 128, 128])
        end
    end
    save analparams chunksize nchunks 
    %save params for easy later viewing by imview.m
    clear M M2
    
end

if(1) %load split data and do fft
    fprintf('\n\ndoing fft...')
    fftw('planner','patient'); %Added to speed up fft calculation - 8/10/12 Vasha Dutell 
    for xidx=1:nchunks
        for yidx=1:nchunks
            fn=sprintf('M2-%d-%d', xidx,yidx);
            fprintf('\n\nfile %s', fn)
            load(fn);
            M2=double(M2);
            sample=[1:size(M2,1)];
            NFFT = 2^nextpow2(nframes); % Next power of 2 from length of y
            %I'm only going to keep 512 freq points, there's no point
            %in keeping anything past that (it's >1 hz)
            NFFT2=1022; %if I change my mind and want to keep all frequency points, just change back to NFFT
            
            F=zeros(length(sample),length(sample),NFFT2/2+1);
            Phase=F;
            P=F;
            i=0;
            fprintf('\n')
            for m=sample
                i=i+1;
                fprintf('%d ', m)
                if mod(i,16)==0;fprintf('\n');end
                j=0;
                for n=sample
                    j=j+1; %here i indexes along image
                    
                    f=fft(squeeze(M2(m,n,:)), NFFT)/nframes;
                    F(i,j,:)=abs(f(1:NFFT2/2+1));
                    Phase(i,j,:)=unwrap(angle(f(1:NFFT2/2+1)), 2*pi);
                end
            end
            
            ff = fps/2*linspace(0,1,NFFT/2+1); %for Hz
            ff=ff(1:NFFT/2+1);
            %        ff = 1:NFFT2/2+1; %for frames
            
            %Plot Phase Map at stimulus periodicity
            %figure;
            
            %P=2*abs(Phase(:,:,1:NFFT2/2+1));
            %^Removed 2*abs(phase) because this reduces our resolution.8/8/12 Vasha Dutell 
            P=Phase(:,:,1:NFFT2/2+1);
            x=abs(ff-sp); %for Hz
            %x=abs(ff-spf/2+1);
            spidx=find(x==min((x))); %spidx is the fft index corresponding to stimulus periodicity
            spidx=spidx(1); %in case it's in between samples, pick one
            PM=P(:,:,spidx); %phase map at stim periodicity
            FM=F(:,:,spidx); %amplitude map at stim periodicity
            %imagesc(PM)
            %colorbar
            fprintf('\nsaving...')
            fn=sprintf('P-%d-%d', xidx,yidx);
            save(fn, 'P', '-v7.3')
            fn=sprintf('F-%d-%d', xidx,yidx);
            save(fn, 'F', '-v7.3')
            fn=sprintf('PM-%d-%d', xidx,yidx);
            save(fn, 'PM')
            fn=sprintf('FM-%d-%d', xidx,yidx);
            save(fn, 'FM')
        end
    end
end % %load and process raw video data


fprintf('\nassembling phase map at stim periodicity...')
%load small phase maps and assemble into one big map at sp
for xidx=1:nchunks
    for yidx=1:nchunks
        fn=sprintf('PM-%d-%d', xidx,yidx);
        fprintf('\n\nfile %s', fn)
        load(fn);
        kx=(xidx-1)*chunksize+(1:chunksize);
        ky=(yidx-1)*chunksize+(1:chunksize);
        fprintf('\n%d-%d, %d-%d', kx(1), kx(end),ky(1), ky(end))
        bigPM(kx,ky)=PM;
    end
end
figure
imagesc(bigPM)
colormap('HSV')%8/8/12 changed to HSV colormap - Vasha Dutell
title(sprintf('phase map at stimulus periodicity %s-%s', expdate, session))
colorbar



%load small phase maps and assemble into one big map
% check different periodicities
% fprintf('\nassembling phase maps, multiple periodicities...')
% for xidx=1:nchunks
%     for yidx=1:nchunks
%         fn=sprintf('P-%d-%d', xidx,yidx);
%         fprintf('\n\nfile %s', fn)
%         load(fn);
%         kx=(xidx-1)*chunksize+(1:chunksize);
%         ky=(yidx-1)*chunksize+(1:chunksize);
%         fprintf('\n%d-%d, %d-%d', kx(1), kx(end),ky(1), ky(end))
%         bigPM2(kx,ky,:)=P(:,:,spidx-10:spidx+10);
%     end
% end

%plot resulting big phase map
% for i=1:size(bigPM2,3)
%     figure
%     imagesc(squeeze(bigPM2(:,:,i)))
%     title(sprintf('phase map at relative periodicity %d frames', i-11))
%     colorbar
% end

fprintf('\nassembling amplitude map at stim periodicity...')
%load small amplitude maps and assemble into one big map at sp
for xidx=1:nchunks
    for yidx=1:nchunks
        fn=sprintf('FM-%d-%d', xidx,yidx);
        fprintf('\n\nfile %s', fn)
        load(fn);
        kx=(xidx-1)*chunksize+(1:chunksize);
        ky=(yidx-1)*chunksize+(1:chunksize);
        fprintf('\n%d-%d, %d-%d', kx(1), kx(end),ky(1), ky(end))
        bigFM(kx,ky)=FM;
    end
end
figure
imagesc(bigFM)
title(sprintf('amplitude map at stimulus periodicity %s-%s', expdate, session))
colorbar

%load small amplitude spectrum maps and assemble into one big map
% check different periodicities
% fprintf('\nassembling amplitude spectrum maps, multiple periodicities...')
% for xidx=1:nchunks
%     for yidx=1:nchunks
%         fn=sprintf('F-%d-%d', xidx,yidx);
%         fprintf('\n\nfile %s', fn)
%         load(fn);
%         kx=(xidx-1)*chunksize+(1:chunksize);
%         ky=(yidx-1)*chunksize+(1:chunksize);
%         fprintf('\n%d-%d, %d-%d', kx(1), kx(end),ky(1), ky(end))
%         bigFM2(kx,ky,:)=F(:,:,spidx-10:spidx+10);
%     end
% end

%plot resulting big amplitude spectrum map

% for i=1:size(bigFM2,3)
%     figure
%     imagesc(squeeze(bigFM2(:,:,i)))
%     title(sprintf('amplitude map at relative periodicity %d frames', i-11))
%     colorbar
% end


%save phase and amplitude maps at stimulus periodicity
save bigPM bigPM
save bigFM bigFM


%if you want to zoom in and autoscale the color do this
if(0)
    [x,y]=ginput(2); %on green surface image, or on amplitude image
    x=round(x);
    y=round(y);
    bigPM2=bigPM2(x(1):x(2), y(1):y(2), :);
    bigFM2=bigFM2(x(1):x(2), y(1):y(2), :);
end

if(0)
    samp=1:32:256;
    fprintf('\nplotting...')
    figure;hold on
    for i=samp
        for j=samp
            plot(squeeze(M2(i,j,:)))
            %         ylim([0 256])
            title([i j])
        end
    end
    set(gca, 'xtick', 1:spf:size(M2,3))
    grid on
end

if(0)
    figure;colormap gray
    for xidx=1:nchunks
        for yidx=1:nchunks
            fn=sprintf('M2-%d-%d', xidx,yidx);
            fprintf('\n\nfile %s', fn)
            load(fn);
            for i=1:nframes
                imagesc(squeeze(M2(:,:,i)));
                pause
            end
        end
    end
end

if(0)
    % Plot single-sided amplitude spectrum.
    figure;
    for i=1:32:size(F, 1)
        fprintf('\n%d',i)
        for j=1:8:size(F, 2)
            f=squeeze(F(i,j,:));%f=f./max(f);
            f=2*abs(f(1:NFFT2/2+1));
            semilogy(ff, f,'-o')
            xlabel('hz')
            title(sprintf('amplitude spectrum sp=%.4f', sp))
            xlim([sp-.1 sp+.1])
            hold on
        end
    end
    xt=get(gca, 'xtick');
    set(gca, 'xtick',sort([xt sp]));
    set(gca, 'xgrid', 'on')
end

if(0)
    % Plot phase spectrum.
    figure;
    for i=1:16:size(F, 1)
        for j=1:16:size(F, 2)
            p=squeeze(Phase(i,j,:));%p=p./max(p);
            p=2*abs(p(1:NFFT2/2+1));
            plot(ff, p, 'r')
            xlabel('hz')
            title(sprintf('phase spectrumsp=%.4f', sp))
            xlim([sp-.1 sp+.1])
            hold on
        end
    end
    xt=get(gca, 'xtick');
    set(gca, 'xtick',sort([xt sp]));
    set(gca, 'xgrid', 'on')
end

if(0)
    % Plot phase spectrum restricted to +-10 frames.
    figure;
    for i=1:16:size(bigPM2, 1)
        for j=1:16:size(bigPM2, 1)
            p=squeeze(bigPM2(i,j,:));%p=p./max(p);
            %p=2*abs(p(1:NFFT2/2+1));
            plot(p, 'r')
            xlabel('frames')
            title('phase')
            hold on
        end
    end
    
end

fprintf('\n');
toc(begin)

