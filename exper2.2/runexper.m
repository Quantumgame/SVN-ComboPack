% EXPER
% This is where it all begins.

clear all hidden;

global exper pref

pref.username=[];
options.WindowStyle='modal';
while isempty(pref.username)
    logInput = inputdlg({'Please enter your username','Load user prefs? (y/n)'},'username',1,{'lab','n'}, options);
    pref.username=logInput(1);
    pref.username=pref.username{:};
    pref.loadpref = logInput(2);
end

if strcmp(pref.loadpref,'y')
    RestorePrefs(pref.username); %Loads prefs from native Matlab 'prefs' and converts to exper-friendly pref structure
    pref.loadpref = 'y'; %keeps loadpref positive if was previously neg
elseif strcmp(pref.loadpref,'n')
    %Prefs; %Sets default preferences
    pref.loadpref = 'n';
end

daqreset;   % reset the data acquisition system

ModuleInit('control');  % initialize the control module and start Exper2

CallModule('Control', 'restore_layout')

ao('samplerate'); %mw 02.01.06 
if isfield(pref, 'aisamplerate')
    ai('samplerate', 32e3)
end


if strcmp(pref.username,'apw') && strcmp(pref.rigconfig,'axopatch')
    % These don't open in tetrode mode.
    %(you can change the startup modules in Prefs) -mw 06.17.2014
%    close sealtest 
%    close onliner
elseif strcmp(pref.username,'mak')
%     close holdcmd
%     close onliner
end
