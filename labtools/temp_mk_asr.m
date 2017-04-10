

eee=[];
for ii=1:length(event)
    eee=[eee event(ii).soundcardtriggerPos];
end

eee_diff=diff(floor(eee));
eee_mean=mean(eee_diff)/10
eee_std=std(eee_diff)/10
keyboard


% soa 100ms, stim 25ms, isi 100ms, actual isi 311 +/- 5 ms
% soa 100ms, stim 25ms, isi 200ms, actual isi 406 +/- 5 ms
% soa 100ms, stim 25ms, isi 300ms, actual isi 507 +/- 1 ms
% soa 100ms, stim 25ms, isi 400ms, actual isi 608 +/- 2 ms
% soa 100ms, stim 25ms, isi 500ms, actual isi 706 +/- 8 ms
% soa 100ms, stim 25ms, isi 1000ms, actual isi 1215 +/- 6 ms
% soa 100ms, stim 25ms, isi 10000ms, actual isi 10219 +/- 6 ms

% soa 0ms, stim 25ms, isi 500ms, actual isi 609 +/- 2 ms




