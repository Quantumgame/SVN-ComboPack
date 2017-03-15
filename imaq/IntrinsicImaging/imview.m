function imview(varargin)
%same as imanal2 but doesn't process the data, only views previously
%processed data
%
%usage: imview([directory])
%usage: imview([expdate], [session])
% if you call without any arguments, default is to open a dialog box for you
% to select data
 set(0,'DefaultFigureWindowStyle','docked') 
% Use set(0,'DefaultFigureWindowStyle','normal') to revert
set(0,'DefaultFigureWindowStyle','normal')

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
figure
try
    fn='g.mat';
    load(fn)
    imagesc(g)
    colormap(gray)
    title('surface image (green)')
end
if exist('./imstimparams.mat', 'file')
    stimparams=load('imstimparams.mat');
    stimparams=stimparams.stimparams;
else
    stimparams=load('stimparams.mat');
    stimparams=stimparams.stimparams;
end
load('analparams.mat');
spf=stimparams.series_period_frames;

basefilename='M';

nfiles=size(ls(sprintf('%s-*.mat', basefilename)),1);
%nframes=nfiles*chunksize;
sp=stimparams.series_periodicity;
spf=stimparams.series_period_frames;
fps=stimparams.FPS;
NFFT = 2^nextpow2(nframes); % Next power of 2 from length of y

ff = fps/2*linspace(0,1,NFFT/2+1); %for Hz
ff=ff(1:NFFT/2+1);
x=abs(ff-sp); %for Hz
%x=abs(ff-spf/2+1);
spidx=find(x==min((x)));
spidx=spidx(1); %in case it's in between samples, pick one

% fprintf('\nassembling phase map at stim periodicity...')
% %load 16 small phase maps and assemble into one big map at sp
% for xidx=1:nchunks
%     for yidx=1:nchunks
%         fn=sprintf('PM-%d-%d', xidx,yidx);
%         fprintf('\n\nfile %s', fn)
%         load(fn);
%         kx=(xidx-1)*chunksize+(1:chunksize);
%         ky=(yidx-1)*chunksize+(1:chunksize);
%         fprintf('\n%d-%d, %d-%d', kx(1), kx(end),ky(1), ky(end))
%         bigPM(kx,ky)=PM;
%     end
% end
load bigFM
load bigPM

figure
imagesc(bigFM)
%colormap(gray) 
title(sprintf('amplitude map at stimulus periodicity %s-%s', expdate, session))
colorbar


figure
imagesc(bigPM)
colormap('HSV')%8/8/12 changed to HSV colormap - Vasha Dutell
%colormap(gray)
title(sprintf('phase map at stimulus periodicity %s-%s', expdate, session))
colorbar

%smoothed version
figure
imagesc(filter2(fspecial('gaussian', 10, 1), bigFM))
%colormap(gray)
title(sprintf('smoothed amplitude map at stimulus periodicity %s-%s', expdate, session))
colorbar

%smoothed version
figure
imagesc(filter2(fspecial('gaussian', 10, 1), bigPM))
colormap('HSV')%8/8/12 changed to HSV colormap - Vasha Dutell
%colormap(gray)
title(sprintf('smoothed phase map at stimulus periodicity %s-%s', expdate, session))
colorbar

% fprintf('\nassembling amplitude map at stim periodicity...')
% %load 16 small amplitude maps and assemble into one big map at sp
% for xidx=1:nchunks
%     for yidx=1:nchunks
%         fn=sprintf('F-%d-%d', xidx,yidx);
%         fprintf('\n\nfile %s', fn)
%         load(fn);
%         kx=(xidx-1)*chunksize+(1:chunksize);
%         ky=(yidx-1)*chunksize+(1:chunksize);
%         fprintf('\n%d-%d, %d-%d', kx(1), kx(end),ky(1), ky(end))
%         bigF(kx,ky)=F;
%     end
% end


% for i=1:size(bigFM2,3)
%     figure
%     imagesc(squeeze(bigFM2(:,:,i)))
%     title(sprintf('amplitude map at relative periodicity %d frames', i-11))
%     colorbar
% end

% overlay of vessels on intrinsic image
smoothPM=filter2(fspecial('gaussian', 10, 1), bigPM);

%mask=mat2gray(g);
if exist('g')
mask=(im2bw(mat2gray(g),  .9*graythresh(mat2gray(g))));

%imshow(mask);shg

 %imshow(mat2gray(bigPM));shg
 
 I =(mat2gray(smoothPM));
X = grayslice(I,256);
maskedX=mask.*X;
cmap=jet(256);
cmap(1,:)=[0 0 0];
figure, imshow(maskedX,cmap)
%figure, imshow(X,cmap)
end

%figure, imshow(X,jet(256))
% 
% out_red   = I;
% out_green = I;
% out_blue  = I;
% out = cat(3, out_red, out_green, out_blue);
% imshow(out, jet(256))
% shg
% 
% E=bigPM;
% BW=ones(size(E));
% M=g;
% 
% figure
% source_color = im2uint8([.5 .5 1]);
% E = im2uint8(mat2gray(E));
% red = E;
% green = E;
% blue = E;
% red(BW) = source_color(1);
% green(BW) = source_color(2);
% blue(BW) = source_color(3);
% rgb_bottom = cat(3, red, green, blue);
% imshow(rgb_bottom, 'InitialMag', 'fit')

% Make a second RGB image that is a constant green.
% rgb_top = zeros(size(M,1), size(M,2), 3, 'uint8');
% rgb_top(:,:,2) = 255;
% 
% % Turn the influence or dependence map into an AlphaData channel to be used
% % to display with the green image.
% M(BW) = 0;
% M = imadjust(mat2gray(M), [0 1], [0 .6], 0.5);
% 
% image('CData', rgb_top, 'AlphaData', M);
% hold off

% keyboard
return

%load 16 small phase maps and assemble into one big map
% check different periodicities
fprintf('\nassembling phase maps, multiple periodicities...')
for xidx=1:nchunks
    for yidx=1:nchunks
        fn=sprintf('P-%d-%d', xidx,yidx);
        fprintf('\n\nfile %s', fn)
        load(fn);
        kx=(xidx-1)*chunksize+(1:chunksize);
        ky=(yidx-1)*chunksize+(1:chunksize);
        fprintf('\n%d-%d, %d-%d', kx(1), kx(end),ky(1), ky(end))
        bigPM2(kx,ky,:)=P(:,:,spidx-10:spidx+10);
    end
end

%plot resulting big phase map
for i=1:size(bigPM2,3)
    figure
    imagesc(squeeze(bigPM2(:,:,i)))
    colormap('HSV')%8/8/12 changed to HSV colormap - Vasha Dutell
    title(sprintf('phase map at relative periodicity %d frames', i-11))
    colorbar
end

%load 16 small amplitude spectrum maps and assemble into one big map
% check different periodicities
fprintf('\nassembling amplitude spectrum maps, multiple periodicities...')
for xidx=1:nchunks
    for yidx=1:nchunks
        fn=sprintf('F-%d-%d', xidx,yidx);
        fprintf('\n\nfile %s', fn)
        load(fn);
        kx=(xidx-1)*chunksize+(1:chunksize);
        ky=(yidx-1)*chunksize+(1:chunksize);
        fprintf('\n%d-%d, %d-%d', kx(1), kx(end),ky(1), ky(end))
        bigFM2(kx,ky,:)=F(:,:,spidx-10:spidx+10);
    end
end

%plot resulting big amplitude spectrum map

for i=1:size(bigFM2,3)
    figure
    imagesc(squeeze(bigFM2(:,:,i)))
    title(sprintf('amplitude map at relative periodicity %d frames', i-11))
    colorbar
end


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


