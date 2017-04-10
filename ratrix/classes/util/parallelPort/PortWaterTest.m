function PortWaterTest
%Does 1000 presses of the requested port at 60ms per press
%Fill water reservoir to specific volume and measure difference, divide by
%1000 to get water use per press

%Lifted from portTest
addr='0378';
valves=[6 7 8];
sensors=[4 2 3];
states = '01';

flipParity = true;
if flipParity
    c=2;
else
    c=1;
end

c=states(c);

closed=char(states(1)*ones(1,8));
lastBlockedSensors=sensors;

while true
    'Will do 1000 water rewards at 50ms a reward on all ports'
    'Press space when ready'
    [~, ~, codes]=KbCheck;
    if codes(KbName('space'))
        break
    end
end

% Do this in a janky way - for each valve, get into a for loop that opens
% and closes it.
pause on
t=closed;
for i = 1:1000
    t(valves(1))='1';
    lptwrite(hex2dec(addr),bin2dec(t));
    pause(.060);
    t=closed;
    lptwrite(hex2dec(addr),bin2dec(t));
    pause(.060);
    clc
    'On click #:'
    i
end

for i = 1:1000
    t(valves(2))='1';
    lptwrite(hex2dec(addr),bin2dec(t));
    pause(.060);
    t=closed;
    lptwrite(hex2dec(addr),bin2dec(t));
    pause(.060);
    clc
    'On click #:'
    i
end

for i = 1:1000
    t(valves(3))='1';
    lptwrite(hex2dec(addr),bin2dec(t));
    pause(.060);
    t=closed;
    lptwrite(hex2dec(addr),bin2dec(t));
    pause(.060);
    clc
    'On click #:'
    i
end

%lptwrite(hex2dec(addr),bin2dec(closed));



