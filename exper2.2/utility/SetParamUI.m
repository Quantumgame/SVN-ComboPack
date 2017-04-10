function h = SetParamUI(module,param,varargin)
% SETPARAMUI
% Change properties of a ui associated with a PARAM.
% PARAM is a string with the param name; MODULE can be
% a string or a cell array of strings. Returns a handle
% to the ui.
% 
% H = SETPARAMUI(MODULE,PARAM,VARAGIN)
%	
% ZF MAINEN, CSHL, 8/00
%
global exper pref

sf = sprintf('exper.%s.param.%s',lower(module),lower(param));
h = GetP(sf,'h');             
if ~ishandle(h) return; end

% make extra adjustments 
np = nargin-2;
for n=1:2:np
	field = varargin{n};
	val = varargin{n+1};
	switch field
	case 'pos'
		% getpos can handle various kinds of requests
		if isstr(val)
			set(h,'pos',getpos(h,val));
		else
			set(h,field,val);
		end
		% we have to move the label and pref buttons
		hlabel = findobj('user',h,'style','text');
		hbutt = findobj('user',h,'style','pushbutton');
		pos = get(h,'pos');
        if ~strcmpi(get(h,'units'),'normalized')
		    bpos = [pos(1)+pos(3) pos(2) 6 pos(4)];
		    lpos = [pos(1)+pos(3)+10 pos(2) pos(3) pos(4)];
        else
		    bpos = [pos(1)+pos(3)             pos(2) 0.1*pos(3) pos(4)];
		    lpos = [pos(1)+pos(3)+0.12*pos(3) pos(2)      pos(3) pos(4)];
            set(hlabel,'units','normalized');
            set(hbutt,'units','normalized');
        end             
		set(hlabel,'pos',lpos);
		set(hbutt,'pos',bpos);
		
	case 'string'
if 0		style = get(h,'style');
		hlabel = findobj('user',h,'style','text');
		switch style
		case {'edit','disp','checkbox'}
			set(hlabel,'string',val);
		otherwise
			set(h,field,val);
		end
else
			set(h,field,val);
end        
    
		
	case 'label'
		hlabel = findobj('user',h,'style','text');
		set(hlabel,'string',val);
		
	case 'pref'
		hpref = findobj('user',h,'style','pushbutton');
		if val
			set(hpref,'visible','on');
		else
			set(hpref,'visible','off');
		end
    % foma 2004/02/07 added the following case statement, because the
    % visibility was handled only for the main ui component and not for the
    % push button and text 
    case 'visible'
        allh=findobj('user',h);
        set(h,field,val);
        set(allh,field,val);
	otherwise
		set(h,field,val);
	end
end


