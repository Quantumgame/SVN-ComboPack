function i=closest(array, value)
%find the index of array that is closest to value
%closest returns the lowest index, in the case of multiple answers (e.g. when value
%is exactly halfway between elements of array, or if array is
%non-monotonic)

%example:
%   x=20:20:200;
%   closest(x, 65)
%   ans = 3

i=find(abs(array-value)==min(abs(array-value)));
i=i(1);