function h = InitParamUI(module,param,style,fig)
% INITPARAMUI
% Create a ui associated with a PARAM and MODULE.
%
% H = INITPARAMUI(MODULE,PARAM,STYLE,[FIG])
%
% Can handle most of the uicontrole types and
% also uimenus (both single items and lists).
% PARAM and MODULE are strings
% STYLE is a string that corresponds to one of the
% uicontrol types:
% pushbutton | togglebutton | radiobutton | checkbox 
% edit | slider | listbox | popupmenu
% or 
% disp (which is like edit, but inactive, for display)
% or
% menu (which is another way of handling a LIST type param)
%
%
% ZF MAINEN, CSHL, 8/00
%
global exper pref

if nargin < 4
    figs = findobj('tag',module,'type','figure');
    if isempty(figs)
    	fig = ModuleFigure(module);	
    else
    	fig = figs(1); % only work on the first figure found
    end
end
bc = get(fig,'color');
p = getp(sprintf('exper.%s.param.%s',module,param));
if strcmp(style,'menu')
	% we have a uimenu rather than a uicontrol
	% a list sets the entire menu list
	h = uimenu(fig,'label',p.name);
	sf = sprintf('exper.%s.param.%s',module,param);
	SetP(sf,'h',h);
	for x=1:length(p.list)
		uimenu(h,'tag',p.name,'label',p.list{x},'callback','FigHandler;','parent',h);
	end 
else
	switch style
	case 'edit'
		h = uicontrol('style','edit','horizontal','right','backgroundcolor',[1 1 1]);
	case 'disp'
		h = uicontrol('style','edit','enable','inactive','horizontal','right','background',bc);
	case {'toggle', 'togglebutton'}
		h = uicontrol('style','togglebutton','string',param);		
	case 'checkbox'
		h = uicontrol('style','checkbox','background',bc);
	case 'listbox'
%		h = uicontrol('style','listbox','string',p.list);			
		h = uicontrol('style','listbox');			
	case 'popupmenu'
%		h = uicontrol('style','popupmenu','string',p.list{1},'background',[1 1 1]);
		h = uicontrol('style','popupmenu','background',[1 1 1]);
	case 'slider'
		h = uicontrol('style','slider','max',p.range(2),'min',p.range(1));
	otherwise;
		message(sprintf('Style %s not implemented for paramui''s',style),'error');
	end
	set(h,'parent',fig,'tag',param,'callback','FigHandler;');

% add a preference editor
    hp=uicontrol('parent',fig,'style','pushbutton','tag',param,...
		'callback','editparam','user',h,'background',bc);
	
% add a label 
switch param
case 'sequence'
	ht=uicontrol('parent',fig,'string',param,'style','text',...
		'horiz','left','user',h,'background',bc);
otherwise
	ht=uicontrol('parent',fig,'string',param,'style','text',...
		'horiz','left','user',h,'background',bc);
end
	
end
sf = sprintf('exper.%s.param.%s',module,param);
SetP(sf,'h',h);

