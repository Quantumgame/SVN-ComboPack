function gettitle
% returns titles in current figure (in case they're hard to read)
t=get(get(gcf, 'children'), 'title');

if iscell(t)
    for i=1:length(t)
        s=get(t{i}, 'string');
        if ~isempty(s); fprintf('\n%s', s); end
    end
else
    s=get(t, 'string');
    if ~isempty(s); fprintf('\n%s', s); end
end
