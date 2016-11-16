%use http://graphpad.com/quickcalcs/contingency1/

% it doesn't really matter whether you use Fisher's exact, Chi-square, etc
% as they all give about the same value. Remember that the entries should
% be number right and number wrong. Don't use total number of trials by
% accident. For example (Zar p.490), converting to mouse behavior,
% control=6 trials correct, 12 trials incorrect (18 total, 6/18=30%
% correct), laser ON=28 trials correct, 24 incorrect, total 52 (53.85%
% correct). chi-square with Yates correction, 2-tailes, gives p=.22, which
% matches Zar. Fisher's exact 2-tailed gives p=.1748 (which matches Zar
% p.550)

%I still haven't figure out how to do this in matlab (The various fisher's
%exact test m-files I downloaded either don't take contingency tables, or
%break with large N), but the online calculator works great so just use
%that.

