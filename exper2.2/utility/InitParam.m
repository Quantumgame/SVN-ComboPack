function out = InitParam(module,param,varargin)
% SETPARAM
% Set PARAM values of an exper module.
% 
% STRUCT = INITPARAM(MODULE,PARAM)
% 		Initialize param to default values
%
% STRUCT = INITPARAM(MODULE,PARAM,VARGIN)
%		Initialize and then call SETPARAM with the extra arguments 
%		(see SetParam)
%
% MODULE & PARAM, are strings
%
% The parameter will have default values as follows
%
% 	default.name = param;
%	default.type = 'double';
%	default.value = 1;
%  default.range = [];
%	default.ui = '';
%	default.h = [];
%	
% ZF MAINEN, CSHL, 8/00
%
global exper pref

param = lower(param);
module = lower(module);

if ~ExistParam(module,param)
	% parameter does not yet exist, so we need to init it
	default.name = param;
	default.type = 'param';
	default.value = 0;
	default.range = [];
	default.list = {};
	default.format = '';
	default.ui = '';
	default.h = -1;
	default.save = 0;
    default.pref = [];
	default.trial = [];
	sp = sprintf('exper.%s.param',module);
	SetP(sp,param,default);
end

user = '';

% look for a field 'ui' which tells us to create a ui
h = [];
uifields = {};
np = nargin-2;
for n=1:2:np
	field = varargin{n};
	val = varargin{n+1};
	switch field
	case 'ui'
      h = InitParamUI(module,param,val);
      if ishandle(h)
         fp = get(h);
	      uifields = lower(fieldnames(fp));
      end
	otherwise
	end
end

% next, set any ui properties or fields that might have been passed	
np = nargin-2;
for n=1:2:np
   field = varargin{n};
   val = varargin{n+1};
   switch lower(field)
       % foma 2004/05/18 changed field to lower(field) because Matlab
       % 'sometimes' does care about the difference between upper and
       % lowercase:-)
   case 'ui'
      % already dealt with that
   case {'value'}
	  SetParam(module,param,varargin{:});
   case 'pref'
       if ~val
            a=findobj('callback','editparam','tag',param);
            if ~isempty(a)
                set(a,'visible','off');
            end
       end
   case 'label'
       if ~val
           a=findobj('style','text','string',param);
           if ~isempty(a)
               delete(a);
           end
       end
 %   case {uifields, 'pos'}
 % changed: foma 2003/03/17
 % the 'uifields' stuff didn't work. Only god knows why
    case 'pos'
       if ishandle(h)
 		SetParamUI(module,param,field,val);
    end
% foma 2004/05/18: the 'uifields stuff' works now, see lower(field) above
   case uifields
      if ishandle(h)
		SetParamUI(module,param,field,val);
      end
      
  otherwise
	  SetParam(module,param,varargin{:});
   end
end


% deal with preferences that have been saved
if ExistParam('control','user')
    user = GetParam('control','user');
    prefstr = sprintf('%s_%s',module,param);
    if ispref(user,prefstr)
        a = getpref(user,prefstr);
        if isstruct(a)
            fields = fieldnames(a);
            n=1;
            for i=1:length(fields)
               switch fields{i}
                case {'name','type','ui','h','trial'}
                % don't restore these        
                otherwise
                    pairs{n} = fields{i};
                    pairs{n+1} = getfield(a,fields{i});
                    n=n+2;
                end
            end
            SetParam(module,param,pairs{:});
        else
            SetParam(module,param,a);
        end
    end
end



