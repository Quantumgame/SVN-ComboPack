function p=get_correctedV_adapt(p) 
%%correct potentials for series error            
%usage: p=get_correctedV_adapt(p) 
%note:  potentials is the holding command
%       corrected_potentials has junction potential and out-of-cell Vm subtracted
%       correctedV is further corrected for series error
%       meantrials_orig does not have current divider correction applied since this is independent of series correction
for IPIindex=1:length(p.IPIs)
    for pindex=p.npotentials:-1:1
                mI(pindex, :)=squeeze(p.meantrials(pindex, IPIindex, :))';          
            %deltaI(pindex, :)=I(pindex, :)-mean(I(pindex, p.baseline));  %baseline is first 12.5 ms (50 samples at 4kHz)         
            
            %correct potentials for series error using session-wide median rs:
            p.correctedV(pindex,IPIindex, :)=p.corrected_potentials(pindex)-p.meanrs*mI(pindex,:)/1000;
            %correct potentials for series error using median rs for this sweep:
            %can't do because mI is averaged across sweeps
            %will have to do before generating meantrials
            %p.correctedV(pindex,findex,aindex, :)=p.corrected_potentials(pindex)-p.meanrs*mI(pindex,:)/1000;
            
        
    end 
end
