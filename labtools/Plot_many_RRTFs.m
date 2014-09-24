function Plot_many_RRTFs(expdate, session, varargin)
%usage Plot_many_RRTFs(expdate, session, filneum1, filenum2, ...)
%assumes you have already run ProcessWNTrain2 and PlotWN2_RRTF

global pref
if isempty(pref) Prefs; end
username=pref.username;

for i=1:nargin-2
    filenum=varargin{i};
    processed_data_dir=sprintf('D:\\%s\\Data-processed\\%s-%s', username, expdate, username);
    processed_data_session_dir=sprintf('%s-%s-%s', expdate, username, session);
    outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);

    fprintf('\ntrying to load %s...', outfilename)
    try
        cd(processed_data_dir)
        cd(processed_data_session_dir)
        load(outfilename)
    catch
        fprintf('failed to load outfile')
        return
    end

    fprintf('done\n');

    RRTF(i,:)=out.RRTF;
end


figure
plot(RRTF', '-o')
legend(varargin)
set(gca, 'xtick', 1:out.numisis, 'xticklabel', out.isis)
xlabel('isi, ms')
ylabel('last/first click ratio')

title(sprintf('RRTFs for %s-%s: %s', expdate, session, sprintf('%s  ',varargin{:})))
set(gca, 'xdir', 'reverse')


