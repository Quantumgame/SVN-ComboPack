function setupMice_Template
%Because we can't have local mousekontrol with versioned software, just
%take this, put it on the desktop or w/e, and use that one.
[pathstr, name, ext] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(fileparts(pathstr)),'bootstrap'));
setupEnvironment

names = {''}
lab = 'wehrCNM'

switch lab
    case 'wehr'
        ratrixPath = 'C:\Users\nlab\Desktop\wehrData';
        p = 'setProtocolWehr';
    case 'wehrCNM'
        ratrixPath = 'C:\Users\nlab\Desktop\laserData';
        p = 'setProtocolTones';
    case 'niell'
        ratrixPath = 'C:\Users\nlab\Desktop\mouseData0512';
        p = 'setProtocolAbstOrient';
    otherwise
        error('huh?')
end

for i=1:length(names)
    standAloneRun(ratrixPath,p,names{i},[],[],true)
end

end