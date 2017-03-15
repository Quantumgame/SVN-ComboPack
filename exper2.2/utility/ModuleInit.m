function ModuleInit(name,init)
% MODULEINIT(NAME,INIT)
% INIT parameter is optional name of initialization case

global exper pref
	
%	p.param = 1;	
    p.param = []; %mw 01.11.06
	if ~isfield(exper,name)
		exper = setfield(exper,name,p);
	end
	InitParam(name,'priority','value',5);
	InitParam(name,'dependents','list',{});
	InitParam(name,'open','value',1);
		
	% call the module's initialization
    if nargin < 2
        CallModule(name, 'init');
    else 
%         CallModule(name, 'init'); mw073106
                CallModule(name, init);
    end
 
   
	% Set the checkbox in control
	set(findobj('tag','modload','user',name),'checked','on');

	% Put me in the control sequence
	if ExistParam('control','sequence')
        CallModule('control','sequence');
    end
    
	
	
	