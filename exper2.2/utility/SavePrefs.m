function SavePrefs(user,module,param)
% SAVEPREFS(USER[,MODULE,PARAM])
% Using builtin Matlab pref functions, restore saved preferences
% for the specified user. MODULE and PARAM are optional.
% Note that the default is to save prefs for parameters with 
% edit, checkbox, and popupmenu UIs and otherwise NOT save prefs.
% This behavior can be changed for a given parameter by setting
% the 'pref' field to 0 or 1 ([] is the default value).
% See RESTOREPREFS(USER), CLEARPREFS(USER)

% ZF MAINEN, CSHL, 1/01

global exper pref

% go through all the modules
if nargin > 1
    modules{1} = module;
else
    modules = GetParam('control','sequence','list');
    modules{end+1} = 'control';
end
    
for n=1:length(modules)
    module = modules{n};
    sf = sprintf('exper.%s.param',module);
    s = evalin('caller',sf);
   
    if nargin > 2
        params{1} = param;
    else
        params = fieldnames(s);
    end
    
    % go through all the parameters
    for i=1:length(params)
        sfs = sprintf('%s.%s',sf,params{i});
        % save only the ones that need to be saved
        ui = getp(sfs,'ui');
        pref = getp(sfs,'pref');
        switch ui
        case {'edit','checkbox','popupmenu'}
            savepref = isequal(0,pref);
        otherwise
            savepref = isequal(1,pref);            
        end
        
        if savepref
       		sfsf = sprintf('exper.%s.param.%s',module,params{i});
    		%  get the actual structure
    		s = evalin('caller',sfsf);
            pref_str = sprintf('%s_%s',module,params{i});
            setpref(user,pref_str,s);
        end
    end
    setpref(user,default_modules,modules);
    
end
            
            
        
