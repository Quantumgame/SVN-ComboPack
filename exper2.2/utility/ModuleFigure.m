function h = ModuleFigure(module,varargin)
% H = MODULEFIGURE(MODULE,VARARGIN)
% All modules make this as their base figure.

global exper pref

h = findobj('tag',module,'type','figure');
if ~isempty(h) 
%	set(h,'visible','on');
	delete(h);
end
h = figure;

% add a closerequest function that calls the 'close' function

clfcn = sprintf('ModuleClose(''%s'');',module);

set(h,'numbertitle','off','name',module,'tag',module,...
      'doublebuffer','on','menubar','none','closerequestfcn',clfcn,...
		varargin{:})
	