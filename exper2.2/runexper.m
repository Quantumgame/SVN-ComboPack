% EXPER
% This is where it all begins.

clear all hidden;

global exper pref

pref.username=[];
options.WindowStyle='modal';
while isempty(pref.username)
    pref.username=inputdlg('Please enter your username','username',1,{'lab'}, options);
    pref.username=pref.username{:};
end

Prefs;      %set the preferences

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
