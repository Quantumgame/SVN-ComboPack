function d=display(s)
    type='';
    d=['stereoDiscrim (n target, m distractor fields, ' type ' type)\n'...
        '\t\t\tfreq:\t[' num2str(s.freq) ... 
        ']\n\t\t\tamplitudes:\t[' num2str(s.amplitudes)];
    d=sprintf(d);