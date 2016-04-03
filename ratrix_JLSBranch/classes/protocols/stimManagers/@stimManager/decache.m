function s=decache(s)
if strmatch('correctStim',fieldnames(s))
    s.correctStim=[];
end
