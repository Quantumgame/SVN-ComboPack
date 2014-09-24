% how to copy a subplot into its own new figure

%first, plot some data
PlotTC_psth_PrePost('092907','001','001','092907','001','005', 5, 15)

%I want to extract the subplot from 15kHz, 80 dB
%counting from the top left, this is subplot number 13 
%(the numbering wraps around, such that 15kHz, 67dB is number 30)

% click on the PlotTC_psth_PrePost figure to make sure it's current
subplot1(13)
h=get(gca, 'children');
figure
axes
copyobj(h, gca)

% you can then add any desired axis labels, title, etc.