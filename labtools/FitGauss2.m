function [muindex, Sigma, A, Ymin, max_upslope, max_downslope]=FitGauss(expdate, session, filename, showplot)

% usage:
%     [muindex, sigma, A, max_upslope, max_downslope]=FitGauss(expdate, session, filename, showplot)
%
% note that the output arguments are each arrays of length numamps
%
% if gaussfit can't get a fit (r^2<.9) it returns NaNs for that amp
%
% this function does a gaussian fit of spike count vs. frequency at each sound level
% and returns the gaussian fit parameters (mu, sigma, A) plus points of maximum slope
% usage
%
% the actual fitting is done by the utility subfunction gaussfit (below)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% here is the help for gaussfit
% [sigma,mu,A]=gaussfit(x,y)
% [sigma,mu,A]=gaussfit(x,y,h)
%
% this function is doing fit to the function
% y=A * exp( -(x-mu)^2 / (2*sigma^2) )
%
% the fitting is been done by a polyfit
% the lan of the data.
%
% h is the threshold which is the fraction
% from the maximum y height that the data
% is been taken from.
% h should be a number between 0-1.
% if h have not been taken it is set to be 0.2
% as default.

%% outfile info
if nargin==0 fprintf('\nno input\n');
    return;
end



outfile=sprintf('out%s-%s-%s', expdate, session, filename);
%fprintf('\nloading... ')
godatadir(expdate, session, filename);
load(outfile);
numfreqs=length(out.freqs);
numamps=length(out.amps);
freqs1=out.freqs;
amps=out.amps;
M1=out.M1;
mM1=out.mM1;
sM1=out.sM1;
% fprintf('done\n')
     muindex=nan;
     max_downslope=nan;
     max_upslope=nan;

% global freqs1 muindex
%% strip top 3 freqs due to harmonic distortion in Tannoy
if round(freqs1(end))==80000
    numfreqs=numfreqs-3;
    freqs1=freqs1(1:numfreqs);
    M1=M1(1:numfreqs,:,:,:);
    mM1=mM1(1:numfreqs,:);
    sM1=sM1(1:numfreqs,:);
end

%% plot
if (showplot==1)
    figure
end
for aindex=1:numamps; %choose  a single amplitude
% 
    a=nan;
    sigma=nan;
    ymin=nan;

    Ma=squeeze(mM1(:,aindex,:,:));
    ymin=prctile(Ma, 25);

    if (showplot==1)
        subplot(numamps,1,1+numamps-aindex);
        plot(1:length(freqs1),Ma, '.');
    end
    %    [sigma,mu,A,s]=gaussfit(freqs1,Ma-ymin,.2);
    [sigma,muidx,a,s]=gaussfit(1:length(freqs1),Ma-ymin,.1); %h=.2

    %calculate sse and sst and use them to calculate r-square
    sse = s.normr^2;
    sst = norm(Ma-mean(Ma))^2;
    rsquare = (1-(sse/sst));

    if (muidx > length(freqs1) || muidx < 1 || isreal(sigma)==0 || rsquare<=.9)
        muindex(aindex)=nan;
        max_downslope(aindex)=nan;
        max_upslope(aindex)=nan;
    else
        y=a*exp(-((1:length(freqs1))-muidx).^2/(2*sigma^2))+ymin;
        dy=diff(y);

        %muidx=find(abs(freqs1-mu)==min(abs(freqs1-mu)));
        if muidx>length(dy) muidx=length(dy);
        elseif muidx<1 muidx=1;

        end

        muidx=round(muidx);

        %find peak on up-slope
        dy1=dy(1:muidx);
        max_upslope_index=find(dy1==max(abs(dy1)));
        if muidx<3 %B.F. too close to edge, upslope poorly defined
            max_upslope_index=nan;
        end
        %find peak on down-slope
        dy2=dy(muidx:end);
        max_downslope_index=find(abs(dy2)==max(abs(dy2)))+muidx-1;

        if muidx>numfreqs-3 %B.F. too close to edge, upslope poorly defined
            max_downslope_index=nan;
        end

        muindex(aindex)=muidx;
        Sigma(aindex)=sigma;
        A(aindex)=a;
        Ymin(aindex)=ymin;
        max_downslope(aindex)=max_downslope_index;
        max_upslope(aindex)=max_upslope_index;

        if (showplot==1)
            hold on; plot(1:length(freqs1),y);
            plot(max_downslope_index, y(max_downslope_index), 'mo');
            plot(max_upslope_index, y(max_upslope_index), 'mo');
            title(sprintf('%d', round(amps(aindex))));
            suptitle(sprintf('%s-%s-%s', expdate,session, filename));
        end
    end
end
if (showplot==1)
    set(gcf,'pos',[360    93   345   829]);
end


function [sigma,mu,A,s]=gaussfit(x,y,h)
%% threshold
if nargin==2, h=0.2; end

%% cutting
ymax=max(y);
xnew=[];
ynew=[];
for n=1:length(x)
    if y(n)>ymax*h;
        xnew=[xnew,x(n)];
        ynew=[ynew,y(n)];
    end
end

%% fitting
ylog=log(ynew);
xlog=xnew;

%perform fitting using matlab polyfit
%p are the coefficients, s contains stats
[p,s]=polyfit(xlog,ylog,2);

A2=p(1);
A1=p(2);
A0=p(3);
sigma=sqrt(-1/(2*A2));
mu=A1*sigma^2;
A=exp(A0+mu^2/(2*sigma^2));