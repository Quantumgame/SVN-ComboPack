function [D E S varargout]=gogetdata(expdate,session,filenum)

% This is a script that looks for processed data on this cpu and if it's
% not found, it will process the raw data. If the raw data isn't found on
% this computer it'll look on the backup server, blister (or pustule) with
% a prompt to load the server if needed.
% usage: 
%   [D E S]=gogetdata(expdate,session,filenum);
%   [D E S D2]=gogetdata(expdate,session,filenum); returns second data
%   channel D2 if it exists
% Created by mak 8nov2010

D=[];
E=[];
S=[];

[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
username=whoami;
% fprintf('\nload file 1: ')
fprintf('\ngogetdata: Looking on this machine for processed data:\n   %s ...',datafile);
try godatadir(expdate, session, filenum)
    D=load(datafile);
    E=load(eventsfile);
    S=load(stimfile);
    fprintf(' ...done.\n');
catch
    fprintf('... not found');
    try fprintf('\ngogetdata: Looking on backup server processed data:\n   %s ',datafile);
        try
            godatadirbak(expdate, session, filenum)
            if ~isempty(dir(datafile)); fprintf('\nfound %s, loading ...', datafile); end
            D=load(datafile);
            E=load(eventsfile);
            S=load(stimfile);
            fprintf(' ...done.\n');
        catch
            % Add old rigs...
            if strcmp(rig,'rig4');
                
                cd('\\blister\backup\oldRig3\')
                cd(sprintf('Data-%s-processed', username))
                cd(sprintf('%s-%s',expdate, username))
                cd(sprintf('%s-%s-%s',expdate, username, session))
                
                if ~isempty(dir(datafile)); fprintf('\nfound %s, loading ...', datafile); end
                D=load(datafile);
                E=load(eventsfile);
                S=load(stimfile);
                fprintf(' ...done.\n');
                
            end
        end
        
    catch
        fprintf('... not found. \nWill now look for raw data to process.');
        try ProcessData_single(expdate, session, filenum)
            D=load(datafile);
            E=load(eventsfile);
            S=load(stimfile);
        catch
            fprintf('\ngogetdata: Failed: I think you are logged in as "%s", is that correct?',username);
            fprintf('\nDid you enter the correct filename? \nDid you use the correct plotting function?\n');
            return
        end
    end
end


datafile2=strrep(datafile, 'AxopatchData1', 'AxopatchData2');
if exist(datafile2, 'file')
    D2=load(datafile2);
    if nargout==4
        varargout{1}=D2;
    end
else
    varargout{1}=[];
end
end
