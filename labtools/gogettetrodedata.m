function [T1 T2 T3 T4 AO E S]=GoGetTetrodeData(expdate,session,filenum)

% This is a script that looks for processed data on this cpu and if it's
% not found, it will process the raw data. If the raw data isn't found on
% this computer it'll look on the backup server, blister with
% a prompt to load the server if needed.
% usage:
%   [T1 T2 T3 T4 AO E S]=GoGetTetrodeData(expdate,session,filenum);
%
%outputs:
% T1 T2 T3 T4: the four tetrode data channels
% AO: AOPulse channel if it was recorded, otherwise AO is empty.
% E: events
% S: stimulus channel
%
%mw 043012 wrote for new tetrode channel naming scheme

[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
T1file=strrep(datafile, 'AxopatchData1', 'TetrodeData1');
T2file=strrep(datafile, 'AxopatchData1', 'TetrodeData2');
T3file=strrep(datafile, 'AxopatchData1', 'TetrodeData3');
T4file=strrep(datafile, 'AxopatchData1', 'TetrodeData4');
AOfile=strrep(datafile, 'AxopatchData1', 'AOPulse');
eventsfile=strrep(T1file, 'trace', 'events');

username=whoami;
fprintf('\nGoGetTetrodeData: Looking on this machine for processed data:\n   %s ...',datafile);
try godatadir(expdate, session, filenum)
    [T1 T2 T3 T4 AO E S]=goload;
    fprintf(' ...done.\n');
catch
    fprintf('... not found');
    try fprintf('\nGoGetTetrodeData: Looking on backup server processed data:\n   %s ',datafile);
        godatadirbak(expdate, session, filenum)
        [T1 T2 T3 T4 AO E S]=goload;
        fprintf(' ...done.\n');
    catch
        fprintf('... not found. \nWill now look for raw data to process.');
        try ProcessData_single(expdate, session, filenum)
            [T1 T2 T3 T4 AO E S]=goload;
        catch
            fprintf('\nGoGetTetrodeData: Failed: I think you are logged in as "%s", is that correct?',username);
            fprintf('\nDid you enter the correct filename? \nDid you use the correct plotting function?\n');
            return
        end
    end
end

    function [T1 T2 T3 T4 AO E S]=goload %nested function
        T1=load(T1file);
        T2=load(T2file);
        T3=load(T3file);
        T4=load(T4file);
        AO=[];
        try        AO=load(AOfile);
        catch fprintf('\nNo AO channel found.')
        end
        E=load(eventsfile);
        S=load(stimfile);
    end
end