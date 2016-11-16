function out = GetParam(module,param,field)
% GETPARAM
% Retrieve PARAM values from an exper MODULE.
% 
% OUT = GETPARAM(MODULE,PARAM)
% 		Return the 'value' field (the default)
% 		(except for lists, where the default is the string of the current
% 		list selection.
%
% OUT = GETPARAM(MODULE,PARAM,FIELD)
%		Return the FIELD field.
%
% MODULE and PARAM are strings.
% FIELD can be a cell array of field names, FIELD = {'f1','f2'},
% in which case the output is a corresponding cell array VAL = {'v1','v2'}
%
% ZF MAINEN, CSHL, 8/00
%
global exper pref

param = lower(param);
module = lower(module);

sf = sprintf('exper.%s.param.%s',module,param);

if nargin < 3
	out = GetP(sf,'value');
	list = GetP(sf,'list');
	if iscell(list) & ~isempty(list)
		out = list{out};
	end
else
	out = GetP(sf,field);
end
