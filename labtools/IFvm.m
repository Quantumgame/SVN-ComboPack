function [Vout, spiketimes] = IFvm(Vm, dt, Th, rf)
% membrane-potential-based integrate-and-fire model
% modified from IFg
% the idea is to pass in a Vm trace and predict spikes
% since the data is recorded in IClamp, there is no need to incorporate
% Gleak, I, C, Ge or Gi
%for this reason it isn't really even an integrate-and-fire model (yet...)
%
% usage: [spiketimes] = IFvm(Vm, dt, Th, rf)
% integrate-and-fire, with time varying Vm
% INPUT:
%   Vm      Vm trace
%   dt     time step (in msec)
%   Th     threshold (in mV relative to Vrest)
%   rf     refractory period (in msec)
% OUTPUT
%   spiketimes - spikes given by threshold crossings 

C=1;
% El = 0; % leak conductance
% Gl=.001;

t=dt:dt:10*rf;
refract=-exp(-t/rf)'; %exponentially decaying refractory function starting at t=0, tau=rf;
% figure
% plot(t, refract)

      
N = length(Vm);
Vrest=mean(Vm(1:100));
Vm=Vm-Vrest;
Vin=Vm;
spiketimes=[];
for i = 2: (N-1)
	if Vm(i-1)>Th      
		spiketimes=[spiketimes i*dt];
        if i+length(refract)<length(Vm)
        Vm(i:i+length(refract)-1)=Vm(i:i+length(refract)-1)+Vm(i)*refract;
        else
                    Vm(i:end)=Vm(i:end)+Vm(i)*refract(1:length(Vm)-i+1);
        end
    end

end
Vout=Vm;
 
% fig=gcf;
% if length(spiketimes)>0
%     figure(2)
%  plot(Vm, 'r')
% hold on
% plot(Vmin)
% figure(fig)
% end

%%suggested starting parameters
%  N=2000; 
%  Ge=.001*poissrnd(2,N,1);
%  Gi=.001*poissrnd(2,N,1); 
%  Gl=1/50; 
%  C=1;
%  dt=.1;
%  Th=.4;
