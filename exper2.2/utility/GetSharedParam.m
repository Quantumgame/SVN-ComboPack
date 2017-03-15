function out=GetSharedParam(param)
% GetSharedParam
%
% Retrieves 'param' values from the 'shared' structure.
% Returns [] (empty thing) if unsuccessful
%

global exper pref shared

if nargin<1 | ~isstr(param)
    param='default';
end

param = lower(param);

out=[];

sf = sprintf('out=shared.%s;',param);

try
    eval(sf);
catch
    out=[];
    return
end