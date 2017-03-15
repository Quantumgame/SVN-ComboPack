function Plot_tone_timecourse(expdate, session, freqs, amps, varargin)
%usage Plot_tone_timecourse(expdate, session, freqs, amps, [colors], [timeaxis])
%   for a single tone (indicated by freqs and amps), plots spiking response to
%   that tone for every tuning curve in a time series
%   (for example, at multiple time points after trauma)
%-specify freqs in kHz and amps in dB, the closest match will be used
%-use multiple values for freqs and amps to plot multiple tones
%-use optional colors argument to specify colors for each tone
%-use optional timeaxis argument to specify whether time axis is in minutes
%   ('time') (default) or sequential ('seq') i.e. just the file sequence
%
%
%assumes you have already generated an outfile using PlotTC_spikes
%PlotTC_spikes_entire_session may be useful for this purpose
%assumes you have a cell list and if using 'time' assumes there is a cell
%   array description field containing 'pre' or 'post n min'
%
%example calls:
%Plot_tone_timecourse('040209', '001', 20, 80)
%Plot_tone_timecourse('040209', '001', [20 24 28], [80 80 80])
%Plot_tone_timecourse('040209', '001', [20 24 28 20 24 28], [80 80 80 60 60 60], 'rrrggg')
%Plot_tone_timecourse('040209', '001', [20 24], [80 80 ], 'rg', 'time' )
%Plot_tone_timecourse('040209', '001', [20 24], [80 80 ], [], 'time' )

figure
fs=18;
colormap('default')

numfreqs=length(freqs);
numamps=length(amps);
if numfreqs~=numamps error('number of freqs and amps must match'); end

timeaxis='time';
if nargin==0; fprintf('\nno input'); return; end
if nargin>=5
    c=varargin{1};
    c=c(~isspace(c));
    if isempty(c)
        c=colormap;
        c=flipud(c);
        cstep=round(64/(numfreqs));
    end
    while length(c)<numfreqs
        c=strcat(c, 'k');
    end
else
    c=colormap;
    c=flipud(c);
    cstep=round(64/(numfreqs));
end
if nargin==6
    timeaxis=varargin{2};
    if ~(strcmp(timeaxis, 'seq') | strcmp(timeaxis, 'time'))
        timeaxis='time'; %default
    end
end

cells=cell_list_NIHL_xiang;
for i=1:length(cells)
    if strcmp(cells(i).expdate, expdate) & strcmp(cells(i).session,session)
        cellnum=i;
    end
end %assumes only one match exists in the cell list


%find findex and aindex
filenum=cells(cellnum).filenum(1, :);
outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);
fprintf('\ntrying to load %s...', outfilename)
try
    godatadir(expdate, session, filenum)
    load(outfilename)
catch
    fprintf('failed to load outfile')
    return
end
for i=1:numfreqs
    findices(i)=find(abs(out.freqs-1000*freqs(i))==min(abs(out.freqs-1000*freqs(i))));
    aindices(i)=find(abs(out.amps-amps(i))==min(abs(out.amps-amps(i))));
end

numfiles=size(cells(cellnum).filenum, 1);
if ~isfield(cells(cellnum), 'description') error('no description field in cell list');end
description=cells(cellnum).description;
if length(description)~=numfiles error('not all files in cell list have a description'); end

for i=1:numfiles
    filenum=cells(cellnum).filenum(i, :);
    outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);

    fprintf('\ntrying to load %s...', outfilename)
    try
        godatadir(expdate, session, filenum)
        load(outfilename)
    catch
        fprintf('failed to load outfile')
        return
    end

    fprintf('done\n');
    for j=1:numfreqs
        findex=findices(j);
        aindex=aindices(j);
        R(i,j)=out.mM1(findex, aindex);
        SD(i,j)=out.sM1(findex, aindex)./sqrt(out.nreps(findex, aindex));
    end

    switch timeaxis
        case 'seq'
            t(i)=i;
            xlab='file number';
        case 'time'
            xlab='time after trauma, in minutes';
            %extract time in minutes from description field
            if strfind(description{i}, 'pre')
                for j=1:i
                    t(j)=-5*(i+1-j);
                end
            elseif strfind(description{i}, 'post')
                [tok1, r]=strtok(description{i}); %should be 'post'
                [tok2, r]=strtok(r); %should be a number
                [tok3, r]=strtok(r); %should start with 'min'
                if strcmp(tok1, 'post') & strcmp(tok3(1:3), 'min')
                    t(i)=str2num(tok2);
                    t(i)=t(i)+5; %adding 5 minutes (half of typical TC duration) so that timepoint is centered
                else
                    fprintf('\n%s-%s', cells(cellnum).expdate, cells(cellnum).session)
                    fprintf('\nfile %s', cells(cellnum).filenum(i,:))
                    fprintf('\ndescription: %s\n', cells(cellnum).description{i})
                    error('can''t extract time from description')

                end
            else %neither pre nor post??
                error(sprintf('file %s is neither pre nor post??', cells(cellnum).filenum(i,:)))
            end
    end
end



hold on
for i=1:numfreqs
    %     e=errorbar(t, R(:,i), SD(:,i)); %non-normalized spike count
    e=errorbar(t, R(:,i)./R(1,i), SD(:,i)./R(1,i)); %normalized to first pre

    if size(c, 1)==64
        if (1+(i-1)*cstep)>length(c)
            set(e, 'marker', 'o', 'color', c(end,:))
        else
            set(e, 'marker', 'o', 'color', c(1+(i-1)*cstep,:))
        end
    else
        set(e, 'marker', 'o', 'color', c(i))
    end
    legstring{i}=sprintf('%.1f, %d', out.freqs(findices(i))/1000, round(out.amps(aindices(i))));
end

legend(legstring)
set(gca, 'fontsize', fs)
xlabel(xlab)
line([0 0], ylim, 'linestyle', '--', 'color', 'k')
line(xlim,[1 1],  'linestyle', '--', 'color', 'k')



% ylabel('spike count +- S.E.M.')
ylabel('normalized spike count +- S.E.M.')
title(sprintf('time course for %s-%s: %.1f kHz (%d), %d db (%d)', expdate, session, out.freqs(findex)/1000, findex, round(out.amps(aindex)), aindex))


% % write out description fields on figure
% a=get(gca, 'pos');
% a(4)=a(4)*.5;a(2)=.5;
% set(gcf, 'pos', [   560   125   580   825])
% set(gca, 'pos', a)
%
% ypos=-diff(ylim)/10;
% if strcmp(timeaxis, 'seq')
%     T1=text(0, ypos, sprintf('%d:\n', 1:numfiles));
%     set(T1, 'VerticalAlignment', 'top')
%
%     T2=text(1, ypos, cells(cellnum).filenum);
%     set(T2, 'VerticalAlignment', 'top')
% end
% T3=text(2, ypos, cells(cellnum).description);
% set(T3, 'VerticalAlignment', 'top')

%orient tall

%tuning curve key
filenum=cells(cellnum).filenum(1, :);
outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);

fprintf('\ntrying to load %s...', outfilename)
try
    godatadir(expdate, session, filenum)
    load(outfilename)
catch
    fprintf('failed to load outfile')
    return
end

figure
mM1=out.mM1;
imagesc(mM1')
set(gca, 'ydir', 'normal', 'fontsize', 18)
colormap(gray)

xtick=1:3:length(out.freqs);
set(gca, 'xtick', xtick)
set(gca, 'xticklabel',  round(out.freqs(xtick)/100)/10)
set(gca, 'ytick', 1:length(out.amps))
set(gca, 'yticklabel', round(out.amps))

% ch=colorbar;
% clab=get(ch, 'ylabel');
% set(clab, 'string','spike count')


hold on
for j=1:numfreqs
    findex=findices(j);
    aindex=aindices(j);
    p=plot(findex, aindex, '.');
    if size(c, 1)==64
           if (1+(j-1)*cstep)>length(c)
               set(p, 'markersize', 20, 'color',c(end,:))
        else
        set(p, 'markersize', 20, 'color', c(1+(j-1)*cstep,:))
           end
    else
        set(p, 'markersize', 20, 'color', c(j))

    end
end
%set(gca, 'ytick', out.amps, 'xtick', out.freqs)
xlabel('frequency (kHz)')
ylabel('level (dB)')
a=get(gcf, 'pos');
a(1)=a(1)-a(3);
set(gcf, 'pos', a)

title(sprintf('time course for %s-%s', expdate, session))
















