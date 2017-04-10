function out = ExistParam(module,param)

global exper pref

param = lower(param);
module = lower(module);

sf = sprintf('isfield(exper,''%s'')',module);
out = evalin('caller',sf);
if out
	sf = sprintf('isfield(exper.%s.param,''%s'')',module,param);
	out = evalin('caller',sf);
end
