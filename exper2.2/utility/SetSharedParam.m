function out = SetSharedParam(param,value)
% SetSharedParam
% Sets the field 'param' of the shared data structure 'shared' to 'value'
%
% Returns 1 for success and 0 for failure.
%
% param is string, value can be anything 
%
global exper pref shared

if nargin<1 | ~isstr(param)
    param='default';
end

if nargin<2
    value=0;
end

param = lower(param);

out=0;

sf=sprintf('shared.%s=value;',param);

try
    eval(sf);
    out=1;
catch
    return
end
