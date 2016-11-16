function lostat=getlostat1(expdate, session, filenum, varargin)
% usage:
% lostat=getlostat(expdate, session, filenum) returns the position in samples after which we lost the cell
% lostat=getlostat(expdate, session, filenum, 'plot') plots the entire trace and allows you to click and
% define the lost at point, which is then returned
% returns [] if cell not found in database or database not found
% This works on the wehrrig computers as of 31Mar2010, by mak and mw
global pref
if isempty(pref) Prefs; end
username=pref.username;

try
    if nargin==4
        if strcmp(varargin{1}, 'plot')
            try
                godatadir(expdate, session, filenum)
                D=load(sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate,username, session, filenum));
                S=load(sprintf('%s-%s-%s-%s-stim.mat', expdate,username, session, filenum));
            catch
                try ProcessData_single(expdate, session, filenum)
                    godatadirbak(expdate, session, filenum)
                    D=load(sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate,username, session, filenum));
                    S=load(sprintf('%s-%s-%s-%s-stim.mat', expdate,username, session, filenum));
                catch
                    godatadirbak(expdate, session, filenum)
                    D=load(sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate,username, session, filenum));
                    S=load(sprintf('%s-%s-%s-%s-stim.mat', expdate,username, session, filenum));
                end
            end
            figure
            plot(1000*double(S.stim)/max(abs(double(S.stim))), 'm')
            hold on
            plot(D.nativeOffset+D.nativeScaling*double(D.trace))
            title('press return to abort')
            [x,y]=ginput(1);
            lostat=x;
            if isempty(x) %empty = aborted
                fprintf('\naborted');
            else
                cd c:\\lab\\lostat
                lostatfilename=sprintf('lostat-%s-%s-%s.txt',expdate, session, filenum);
                fid=fopen(lostatfilename, 'wt');
                fprintf(fid, '%s%s%s\t%d\n', expdate, session, filenum, lostat);
                fclose(fid);
            end
        end
    else

        cd d:\\lab\\lostat
        string=sprintf('%s%s%s', expdate, session, filenum);
        [id, la]=textread('lostat.txt', '%s%f');
        lostat=la(find(strcmp(id, string)));

    end

catch
    lostat=[];
end
labtools;
fprintf('\nedit ProcessBinVCData');