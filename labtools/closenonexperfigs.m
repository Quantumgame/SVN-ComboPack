%simple function to close all non-exper figures
f=findobj('type', 'figure', 'tag', '');
close(f)
