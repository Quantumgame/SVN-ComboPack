function PlotGeGi_delay

%same as plot_ge_gi_all except ge, gi are normalized, and axis is zoomed in on rising phase
%
%mw - 07-15-2003


%plot ge & gi across freqs
t=1:p.datalength;t=t/samprate;  

g_toss_threshold=2; %ge and gi must be this tall to go on this ride 
delay_toss_threshold=20; %to get rid of off response outliers
fprintf('\nge_gi_delay: excluding sessions with max(ge) or max(gi) <%.1f', g_toss_threshold)
fprintf('\nge_gi_delay: excluding delays>%.1f', delay_toss_threshold)
save_to_file=1; %whether to save delay data to results file
pretty=1; %clean up plots for figure-making
LW=2;
if length(p.f2use)>1 
    n10=1;n50=1;delay50all=0;delay10all=0;
    figure(182)
    aindex=p.a2use(1);
    %    axlim=[ min(min(min([squeeze(p.GTOT(:,:,1,:)) squeeze(p.GE) squeeze(p.GI)]))) max(max(max([squeeze(p.GTOT(:,:,1,:)) squeeze(p.GE) squeeze(p.GI)])))]; 
    %axlim=[ min(min(min([squeeze(p.GTOT(:,:,1,:)) squeeze(p.GE) squeeze(p.GI)]))) max(max(max([squeeze(p.GTOT(:,:,1,:)) squeeze(p.GE) squeeze(p.GI)])))];  
    axlim2=[ min(min(min([p.GE p.GI]))) max(max(max([p.GE p.GI])))];
    for findex=p.f2use 
        ge=squeeze(p.GE(findex,aindex,:));
        gi=squeeze(p.GI(findex,aindex,:));
        %gtot=squeeze(p.GTOT(findex,aindex,1,:));
        gsyn=squeeze(p.GSYN(findex,aindex,1,:));
        %grest=mean(mean(p.GREST(p.f2use, p.a2use,1)));
        for spoo=182
            figure(spoo)        
            subplot(2,round((length(p.f2use)+1)/2), find(findex==p.f2use))
            hold on
            %plot(t, ge/max(ge), 'r', t, gi/max(gi), 'b');
            %plot ge, gi corrected for attenuation
            %plot(t, ge_c, 'r--', t, gi_c, 'b--', t, gtot_c, 'k--');
            titlestring=sprintf('%g kHz, %d dB',  p.freqs(findex)/1000, p.attens(aindex));
            if pretty
                %titlestring=sprintf('%g kHz',  p.freqs(findex)/1000);
                titlestring='';
            end
            title(titlestring)
            
            %zoom in axis to conductance rise only            
            tgmax=find(gsyn==max(gsyn));
            tgmaxpeak=tgmax+200; %mw 07-15-03
            if tgmaxpeak>p.datalength tgmaxpeak=p.datalength; end
            %tstart=min(find(gsyn(1:tgmax)/gsyn(tgmax)>.05));
            tstart=4*60;
            if tstart>tgmax %tgmax must be in a wierd place, this tone will get tossed anyway
                tstart=tgmax-1;
                if tstart==0
                    tstart=tstart+1;
                    tgmax=tgmax+1;
                end
            end
            %xlim([t(tstart)-10 t(tgmax)+10])
            fprintf('\nge_gi_delay: using time range %d-%d ms', t(tstart), t(tgmax))
            xlim([60 90])                        
            %ylim([0 1])
            
            %normalize ge and gi (rename to gen and gin)
            gen1=ge-min(ge(max(tstart-10, 1):tgmax));
            gin1=gi-min(gi(max(tstart-10, 1):tgmax));
            gen=gen1/max(gen1);
            gin=gin1/max(gin1);
            
            gen1peak=ge-min(ge(max(tstart-10, 1):tgmaxpeak));
            gin1peak=gi-min(gi(max(tstart-10, 1):tgmaxpeak));
            genpeak=gen1peak/max(gen1peak);
            ginpeak=gin1peak/max(gin1peak);
            
            plot(t, gen, 'g', t, gin, 'r', 'linewidth', LW); 
            if pretty axis off; end
            gen=gen(tstart:tgmax);
            gin=gin(tstart:tgmax);
            tn=t(tstart:tgmax);
            %cross out if g are too small
            if (max(gen1)<g_toss_threshold) | (max(gin1)<g_toss_threshold)%g_toss_threshold set at top
                line(xlim,ylim, 'color', 'r')
                line(fliplr(xlim),ylim, 'color', 'r')
            end
            %compute delay using median(delta t(v))
            if(0)
                dv=10^5;
                tempe=zeros(dv, 1);
                tempi=tempe;
                ve=round(gen*dv);
                vi=round(gin*dv);            
                tempe(ve(find(ve)))=1;
                tempi(vi(find(vi)))=1;
                te=cumsum(tempe)/4;
                ti=cumsum(tempi)/4;
                delay=sprintf('%.1f',median(ti-te));            
                text(t(tstart)-9,.65,delay)
            end
            %compute delay at g=10%gmax
            if(0)
                tge=find(abs(gen-.1)==min(abs(gen-.1)));
                tgi=find(abs(gin-.1)==min(abs(gin-.1)));
                hold on
                line([tn(tge), tn(tgi)], [gen(tge), gen(tge) ])
                delay10=(t(tgi)-t(tge));            
                delay10s=sprintf('%.1f',(t(tgi)-t(tge)));            
                text(tn(tgi)+3,.1,delay10s)
                if (max(gen1)>g_toss_threshold) & (max(gin1)>g_toss_threshold)%g_toss_threshold set at top
                    delay10all(n10, 1)=findex;
                    delay10all(n10, 2)=delay10;
                    n10=n10+1;
                end
            end
            
            %compute delay at g=50%gmax
            tge=find(abs(gen-.5)==min(abs(gen-.5)));
            tgi=find(abs(gin-.5)==min(abs(gin-.5)));
            %mw 07-15-03            
            %compute delay at g=gmax (peak)
            tgepeak=find(genpeak==max(genpeak));
            tgipeak=find(ginpeak==max(ginpeak));
            
            if length(tge)>1 tge=tge(1);end
            if length(tgi)>1 tgi=tgi(1);end
            if length(tgepeak)>1 tgepeak=tgepeak(1);end
            if length(tgipeak)>1 tgipeak=tgipeak(1);end
            hold on
            line([tn(tge), tn(tgi)], [gen(tge), gen(tge) ], 'linewidth', LW)
            delay50=(t(tgi)-t(tge));            
            delaypeak=(t(tgipeak)-t(tgepeak));            
            delay50s=sprintf('%.1f',(t(tgi)-t(tge)));   
            
                if pretty
                    text(tn(tgi)+3,.5,delay50s, 'fontsize', 18)
                else
                    text(tn(tgi)+3,.5,delay50s, 'fontsize', 10)
                end
            
            if 1%(max(gen1)>g_toss_threshold) & (max(gin1)>g_toss_threshold)%g_toss_threshold set at top
                if 1%abs(delay50)<delay_toss_threshold
                    delay50all(n50, 1)=findex;
                    %delay50all(n50, 2)=p.freqs(findex);
                    delay50all(n50, 2)=delay50;
                    delaypeakall(n50)=delaypeak;
                    n50=n50+1;
                end
            end
            %             %write delays and gsynmax to a file
            %             gsynmax=gsyn(tgmax);
            %             fid=fopen('c:\home\wehr\data\gdelay.txt', 'at');
            %             fprintf(fid, '\n%s\t%s\t%d\t%d\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f', p.expdate, p.filename, findex, aindex, gsynmax,gsynmax/grest, max(gen1), max(gin1), delay10, delay50)   ;
            %             fclose (fid);
            
            if (0)%find(findex==p.f2use)==1 %label first subplot
                xlabel('ms')
                ylabel('nS')
                set(gca, 'xtick', [])
            elseif find(findex==p.f2use)==length(p.f2use)
                xlabel([p.expdate, ' ',p.filename,  'Ee=',int2str(p.Ee), ' Ei=',int2str(p.Ei) , ' A=',num2str(p.A), ' created ',date   ]);
                l=line([80 90],[.1 .1]); %10 ms
                set(l, 'linewidth', 3, 'color', 'k')
                subplot(2,round((length(p.f2use)+1)/2), 1+length(p.f2use))
                plot(1, 1, 'g', 1, 1, 'r');
                axis off
                %legend('g_e', 'g_i',-1)
            end            
        end
    end %for findex=f2use 
    
    figure(185)
    if sum(delay50all)
        hold on
%        plot(p.freqs(delay50all(:,1))/1000, delay50all(:,2), 'bo-', p.freqs(delay10all(:,1))/1000, delay10all(:,2), 'mo-')
        plot(p.freqs(delay50all(:,1))/1000, delay50all(:,2), 'bo-')
        %legend('delay at 50%', 'delay at 10%')
        set(gca, 'xtick', [2 4 8 16 32], 'xscale', 'log', 'xlim', [1 40])
        yl=ylim;
        if yl(2)>20 yl(2)=20; end
        try
            ylim([0 1.1*yl(2)]);
        end
        xlabel('frequency, kHz')
        ylabel('delay, ms')

        global n DELAY50f DELAY50a 
        %set n=0 before running
        if ~isempty(n) %meaning it wasn't declared and initialized in base workspace
            n=n+1;
            DELAY50f(n).freqs=p.freqs(delay50all(:,1));
            DELAY50f(n).delay=delay50all(:,2);  
            DELAY50f(n).delaypeak=delaypeakall;              
            DELAY50f(n).expdate=p.expdate;
            DELAY50f(n).filename=p.filename;
            cd c:\home\wehr\results
            if save_to_file 
               save DELAY50b DELAY50f DELAY50a  
            end            
        end
    end
        
    end %if length(f2use)>1 %plot potentials versus freqs

%plot ge & gi across attens
if length(p.a2use)>1 
    n10=1;n50=1;delay50all=0;delay10all=0;
    figure(182)
    findex=p.f2use(end); %if there are multiple freqs, enter BF here manually
    %    axlim=[ min(min(min([squeeze(p.GTOT(:,:,1,:)) squeeze(p.GE) squeeze(p.GI)]))) max(max(max([squeeze(p.GTOT(:,:,1,:)) squeeze(p.GE) squeeze(p.GI)])))];  
    axlim2=[ min(min(min([p.GE p.GI]))) max(max(max([p.GE p.GI])))];
    for aindex=p.a2use 
        ge=squeeze(p.GE(findex,aindex,:));
        gi=squeeze(p.GI(findex,aindex,:));
        %       gtot=squeeze(p.GTOT(findex,aindex,1,:));
        gsyn=squeeze(p.GSYN(findex,aindex,1,:));
        %grest=mean(mean(p.GREST(p.f2use, p.a2use,1)));
        for spoo=182            
            figure(spoo)
            subplot(2,round((length(p.a2use)+1)/2), find(aindex==p.a2use))
            hold on
            %plot(t, ge/max(ge), 'r', t, gi/max(gi), 'b');
            titlestring=sprintf('%g kHz, %d dB, %s',  p.freqs(findex)/1000, p.attens(aindex), p.stimdir);
            if ~pretty
                title(titlestring)
            end
            %zoom in axis to conductance rise only            
            tgmax=find(gsyn==max(gsyn));
            tgmaxpeak=tgmax+200; %mw 07-15-03
            if tgmaxpeak>p.datalength tgmaxpeak=p.datalength; end

            tstart=min(find(gsyn(1:tgmax)/gsyn(tgmax)>.05));
            xlim([t(tstart)-10 t(tgmax)+10])
            fprintf('\nge_gi_delay: using time range %d-%d ms', t(tstart), t(tgmax))
            
            %normalize ge and gi (rename to gen and gin)
            %use ge_c and gi_c
            ge_c=ge;  
            gi_c=gi;
            gen1=ge-min(ge(max(tstart-10, 1):tgmax));
            gin1=gi-min(gi(max(tstart-10, 1):tgmax));
            gen=gen1/max(gen1);
            gin=gin1/max(gin1);
           
            gen1peak=ge-min(ge(max(tstart-10, 1):tgmaxpeak));
            gin1peak=gi-min(gi(max(tstart-10, 1):tgmaxpeak));
            genpeak=gen1peak/max(gen1peak);
            ginpeak=gin1peak/max(gin1peak);
           
            
            plot(t, gen, 'g', t, gin, 'r', 'linewidth', LW); 
            if pretty axis off; end
            gen=gen(tstart:tgmax);
            gin=gin(tstart:tgmax);
            tn=t(tstart:tgmax);
            
            %cross out if g are too small
            if (max(gen1)<g_toss_threshold) | (max(gin1)<g_toss_threshold)%g_toss_threshold set at top
                line(xlim,ylim, 'color', 'r')
                line(fliplr(xlim),ylim, 'color', 'r')
            end
            
            %compute delay using median(delta t(v))
            if(0)
                dv=10^5;
                tempe=zeros(dv, 1);
                tempi=tempe;
                ve=round(gen*dv);
                vi=round(gin*dv);            
                tempe(ve(find(ve)))=1;
                tempi(vi(find(vi)))=1;
                te=cumsum(tempe)/4;
                ti=cumsum(tempi)/4;
                delay=sprintf('%.1f',median(ti-te));            
                text(t(tstart)-9,.65,delay)
            end
            
            %compute delay at g=10%gmax
            if(0)
                tge=find(abs(gen-.1)==min(abs(gen-.1)));
                tgi=find(abs(gin-.1)==min(abs(gin-.1)));
                hold on
                line([tn(tge), tn(tgi)], [gen(tge), gen(tge) ])
                delay10=(t(tgi)-t(tge));            
                delay10s=sprintf('%.1f',(t(tgi)-t(tge)));            
                text(tn(tgi)+3,.1,delay10s)
                if (max(gen1)>g_toss_threshold) & (max(gin1)>g_toss_threshold)%g_toss_threshold set at top
                    delay10all(n10, 1)=aindex;
                    delay10all(n10, 2)=delay10;
                    n10=n10+1;
                end
            end
            %compute delay at g=50%gmax
            tge=find(abs(gen-.5)==min(abs(gen-.5)));
            tgi=find(abs(gin-.5)==min(abs(gin-.5)));

            %mw 07-15-03            
            %compute delay at g=gmax (peak)
            tgepeak=find(genpeak==max(genpeak));
            tgipeak=find(ginpeak==max(ginpeak));
            
            if length(tge)>1 tge=tge(1);end
            if length(tgi)>1 tgi=tgi(1);end
            if length(tgepeak)>1 tgepeak=tgepeak(1);end
            if length(tgipeak)>1 tgipeak=tgipeak(1);end

            hold on
            if length(tgi)>1 tgi=tgi(1);end
            line([tn(tge), tn(tgi)], [gen(tge), gen(tge) ], 'linewidth', LW)
            delay50=(t(tgi)-t(tge));            
            delay50s=sprintf('%.1f',(t(tgi)-t(tge)));            
            delaypeak=(t(tgipeak)-t(tgepeak));            
            text(tn(tgi)+3,.5,delay50s)
            if 1%(max(gen1)>g_toss_threshold) & (max(gin1)>g_toss_threshold)%g_toss_threshold set at top
                if 1%abs(delay50)<delay_toss_threshold
                    delay50all(n50, 1)=aindex;
                    %delay50all(n50, 2)=p.attens(aindex);
                    delaypeakall(n50)=delaypeak;
                    delay50all(n50, 2)=delay50;
                    n50=n50+1;
                end
            end
            
            %             %write delays and gsynmax to a file
            %             gsynmax=gsyn(tgmax);
            %             fid=fopen('c:\home\wehr\data\gdelay.txt', 'at');
            %             fprintf(fid, '\n%s\t%s\t%d\t%d\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f', p.expdate, p.filename, findex, aindex, gsynmax,gsynmax/grest, max(gen1), max(gin1), delay10, delay50)   ;
            %             fclose (fid);
            
            if find(aindex==p.a2use)==1
                xlabel('ms')
                ylabel('nS')
                set(gca, 'xtick', [])
            elseif find(aindex==p.a2use)==length(p.a2use)
                xlabel([p.expdate, ' ',p.filename,  'Ee=',int2str(p.Ee), ' Ei=',int2str(p.Ei) ,' A=',num2str(p.A) ]);
                subplot(2,round((length(p.a2use)+1)/2), 1+length(p.a2use))
                plot(1, 1, 'g', 1, 1, 'r');
                axis off
                %legend('g_e', 'g_i', -1)
            end
        end
    end %for aindex=a2use 
    figure(185) 
    if sum(delay50all)
        hold on
        plot(p.attens(delay50all(:,1)), delay50all(:,2), 'bo-')
        %legend('delay at 50%', 'delay at 10%')
        yl=ylim;
        ylim([0 1.1*yl(2)]);
        xlim([-5 65])
        set(gca, 'xtick', [0 20 40 60])
        
        global n DELAY50f DELAY50a 
        %set n=0 in base workspace, as a global, before running
        if ~isempty(n) %meaning it wasn't declared and initialized in base workspace
            n=n+1;
            DELAY50a(n).attens=p.attens(delay50all(:,1));
            DELAY50a(n).delay=delay50all(:,2);        
            DELAY50a(n).delaypeak=delaypeakall;              
            DELAY50a(n).expdate=p.expdate;
            DELAY50a(n).filename=p.filename;
            cd c:\home\wehr\results
            if save_to_file 
               save DELAY50 DELAY50f DELAY50a  
            end            
        end 
    end
end %if length(f2use)>1 %plot potentials versus freqs
p.delay50all=delay50all;
p.delaypeakall=delaypeakall;


if(0)%this is never to be executed, just a convenient place to evaluate from before running
    %don't forget to set save_to_file at top
    clear global n DELAY50f DELAY50a 
    global n DELAY50f DELAY50a
    DELAY50f=[];DELAY50a=[];n=0;
end