function varargout=Plot_many_GPIASs(varargin)
%usage Plot_many_GPIASs(expdate1, session1, filenum1, expdate2, session2, filenum2, ...)
%assumes you have already run PlotGPIAS
%
%optional outputs:
%[P, percentGPIAS, time]=Plot_many_GPIASs(expdate1, session1, filenum1, ...
%P=p-values
%time=timevecs of each file
%09.17.10 mw: added support for multiple expdates

if nargin==0 fprintf('\nno input');return;
elseif mod(nargin, 3) 
    help Plot_many_GPIASs
    error('wrong number of input arguments.');
end
    
global pref
if isempty(pref) Prefs; end
username=pref.username;

for i=1:(nargin)/3
    expdate=varargin{3*i-2};
    session=varargin{3*i-1};
    filenum=varargin{3*i};
    outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);

    fprintf('\ntrying to load %s...', outfilename)
    try
        godatadir(expdate,session, filenum)
        load(outfilename)
    catch
        fprintf('failed to load outfile')
        return
    end

    fprintf('done\n');

    P(i,:)=out.P;
    percentGPIAS(i,:)=out.percentGPIAS;
    time(i,:)=getexpertime(expdate,session, filenum);

end
for i=1:size(time, 1)
t(i)=etime(time(i,:), time(1,:));
end
t=t/60;%->minutes

figure
plot(t, P, '-o')
xlabel('file number')
ylabel('p-value of gap detection')
%set(gca, 'xtick', [1:(nargin)/3])
%xlim( [0 1+(nargin)/3])
xlabel('time, min.')
title(sprintf('P(GPIAS) %s-%s-%s', varargin{1}, varargin{2}, varargin{3}))
ylim([0 1])

figure
plot(percentGPIAS, '-o')
xlabel('file number')
ylabel('percent gap inhibition')
set(gca, 'xtick', [1:(nargin)/3])
xlim( [0 1+(nargin)/3])
title(sprintf('Percent Gap Inhibition %s-%s-%s', varargin{1}, varargin{2}, varargin{3}))
%title(sprintf('P(GPIAS) %s-%s', expdate, sprintf('%s-%s, ',varargin{:})))
ylim([0 100])
pos=get(gcf, 'pos');
pos(1)=pos(1)+pos(3);
set(gcf, 'pos', pos);

if nargout==1
    varargout{1}=P;
elseif nargout==2
    varargout{1}=P;
    varargout{2}=percentGPIAS;
elseif nargout==3
    varargout{1}=P;
    varargout{2}=percentGPIAS;
    varargout{3}=time;
end    
