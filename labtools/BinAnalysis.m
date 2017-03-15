clear
close all
begin=tic;
dbstop if error
animals=cell_list_Binaural;
savefiledir='c:\lab\Michael';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Skeleton code to load all relevant cell information
% for i=length(animals):-1:1
%     expdate=animals(i).experimentID;
%     age=animals(i).age; % in post-natal days
%     mass=animals(i).mass; % in grams
%     earpiececheck_notes=animals(i).earpiececheck_notes; % Both sealed, unobstructed, patent, & disease free
%     a1=animals(i).a1; % y=yes, n=no, m=maybe: as established by tonotopy
%     for j=1:length(animals(i).ephys.site)
%         username=animals(i).ephys.site(j).user;
%         depth=animals(i).ephys.site(j).depth; % um
%         CF=animals(i).ephys.site(j).CF; % kHz; 0 for unknown
%         notes=animals(i).ephys.site(j).notes;
%         if strcmp(animals(i).ephys.site(j).user,'mak')
%             lostat1performed=animals(i).ephys.site(j).lostat1performed; % 'yes' or '' for no
%             vout=animals(i).ephys.site(j).vout; % mV
%             for k=1:length(animals(i).ephys.site(j).file)
%                 session=animals(i).ephys.site(j).file(k).session;
%                 filename=animals(i).ephys.site(j).file(k).filenum;
%                 mode=animals(i).ephys.site(j).file(k).mode;
%                 if strcmp(mode,'inorm')
%                     inorm=animals(i).ephys.site(j).file(k).inorm; % in pA
%                 end
%             end
%         end
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Make a pdf of all Binaural spiking data
% % Added commented code for Vm data
% cd(savefiledir)
% % if exist('Vm_psth.ps','file');delete('Vm_psth.ps');end
% if exist('Vm.ps','file');delete('Vm.ps');end
% cd(savefiledir)
% % if exist('Bin_psthErrorList.txt','file');delete('Bin_psthErrorList.txt');end
% if exist('Bin_VmErrorList.txt','file');delete('Bin_VmErrorList.txt');end
% % Bin_psthEL=fopen('Bin_psthErrorList.txt','w+t');
% Bin_VmEL=fopen('Bin_VmErrorList.txt','w+t');
% close all
% counter=0;
% for i=length(animals):-1:1
%     expdate=animals(i).experimentID;
%     age=animals(i).age; % in post-natal days
%     mass=animals(i).mass; % in grams
%     earpiececheck_notes=animals(i).earpiececheck_notes; % Both sealed, unobstructed, patent, & disease free
%     a1=animals(i).a1; % y=yes, n=no, m=maybe: as established by tonotopy
%     for j=1:length(animals(i).ephys.site)
%         username=animals(i).ephys.site(j).user;
%         depth=animals(i).ephys.site(j).depth; % um
%         CF=animals(i).ephys.site(j).CF; % kHz; 0 for unknown
%         notes=animals(i).ephys.site(j).notes;
%         if strcmp(animals(i).ephys.site(j).user,'mak')
%             lostat1performed=animals(i).ephys.site(j).lostat1performed; % 'yes' or '' for no
%             vout=animals(i).ephys.site(j).vout; % mV
%             counter=counter+1;
%             fprintf('\nCell %d/86',counter)
%             for k=1:length(animals(i).ephys.site(j).file)
%                 session=animals(i).ephys.site(j).file(k).session;
%                 filename=animals(i).ephys.site(j).file(k).filenum;
%                 mode=animals(i).ephys.site(j).file(k).mode;
%                 try stimtypes=stimtype(expdate,session,filename);
%                 catch
%                     ProcessData_single(expdate,session,filename);
%                     stimtypes=stimtype(expdate,session,filename);
%                 end
%                 if (sum(strcmp(stimtypes,'binwhitenoise'))==1 ||sum(strcmp(stimtypes,'bintone'))==1) && ~strcmp(mode,'vc')
%                     try
% %                         PlotBinTC_psth(expdate,session,filename,10,[0 300],[-1 20],5)
% %                         figure
%                         if strcmp(mode,'inorm')
%                             inorm=animals(i).ephys.site(j).file(k).inorm; % in pA
%                             PlotBinTC_mak(expdate,session,filename,[0 300],[],mode,inorm)
%                         else
%                             PlotBinTC_mak(expdate,session,filename,[0 300],[],mode)
%                         end
%                         cd(savefiledir)
% %                         for m=[4 1:3]
% %                             figure(m)
% %                             print('-dpsc2','Vm_psth','-append');
% %                             close(figure(m))
% %                         end
%                         print('-dpsc2','Vm','-append');
%                         close(figure(1))
%                     catch
%                         close(figure(1))
%                         cd(savefiledir)
% %                         fprintf(Bin_psthEL,'\n%s-%s-%s didn''t plot due to no spikes!',expdate, session, filename);
%                         fprintf(Bin_VmEL,'\n%s-%s-%s didn''t plot, that''s weird!!!',expdate, session, filename);
%                     end
%                 end
%             end
%         end
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Make a pdf of all BinGeGi plots
cd(savefiledir)
% if exist('lostatplots.ps','file');delete('lostatplots.ps');end
if exist('GeGiplots.ps','file');delete('GeGiplots.ps');end
cd(savefiledir)
if exist('BinGeGiErrorList.txt','file');delete('BinGeGiErrorList.txt');end
BinGeGiEL=fopen('BinGeGiErrorList.txt','w+t');
close all
counter=0;
for i=length(animals):-1:1
    expdate=animals(i).experimentID;
    age=animals(i).age; % in post-natal days
    mass=animals(i).mass; % in grams
    earpiececheck_notes=animals(i).earpiececheck_notes; % Both sealed, unobstructed, patent, & disease free
    a1=animals(i).a1; % y=yes, n=no, m=maybe: as established by tonotopy
    for j=1:length(animals(i).ephys.site)
        username=animals(i).ephys.site(j).user;
        depth=animals(i).ephys.site(j).depth; % um
        CF=animals(i).ephys.site(j).CF; % kHz; 0 for unknown
        notes=animals(i).ephys.site(j).notes;
        if strcmp(animals(i).ephys.site(j).user,'mak')
            lostat1performed=animals(i).ephys.site(j).lostat1performed; % 'yes' or '' for no
            vout=animals(i).ephys.site(j).vout; % mV
            counter=counter+1;
            fprintf('\nCell %d/86',counter)
            for k=1:length(animals(i).ephys.site(j).file)
                session=animals(i).ephys.site(j).file(k).session;
                filename=animals(i).ephys.site(j).file(k).filenum;
                mode=animals(i).ephys.site(j).file(k).mode;
                if strcmp(mode,'vc')
                    try PlotBinGeGi(expdate, session, filename, [0 300])
                        cd(savefiledir)
                        print('-dpsc2','GeGiplots','-append');
                        close all
                    catch
                        try ProcessBinGeGi(expdate, session, filename, vout, [0 300])
                            close all
                            PlotBinGeGi(expdate, session, filename, [0 300])
                            cd(savefiledir)
                            print('-dpsc2','GeGiplots','-append');
                            close all
                        catch
                            try ProcessBinVCData(expdate, session, filename, vout, [0 300])
                                ProcessBinGeGi(expdate, session, filename, vout, [0 300])
                                close all
                                PlotBinGeGi(expdate, session, filename, [0 300])
                                cd(savefiledir)
                                print('-dpsc2','GeGiplots','-append');
                                close all
                            catch
                                cd(savefiledir)
                                fprintf(BinGeGiEL,'\n%s-%s-%s didn''t plot or process!',expdate, session, filename);
                            end
                        end
                    end
                end
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Make a cell list of all relevant cell information
% savefiledir='c:\lab\Michael';
% cd(savefiledir)
% bincelllist=fopen('BinCellList.txt','w+t');
% counter=0;
% for i=length(animals):-1:1
%     expdate=animals(i).experimentID;
% %     if strcmp(expdate,'060910')
%         age=animals(i).age; % in post-natal days
%         mass=animals(i).mass; % in grams
%         earpiececheck_notes=animals(i).earpiececheck_notes; % Both sealed, unobstructed, patent, & disease free
%         a1=animals(i).a1; % y=yes, n=no, m=maybe: as established by tonotopy
%         for j=1:length(animals(i).ephys.site)
%             username=animals(i).ephys.site(j).user;
%             depth=animals(i).ephys.site(j).depth; % um
%             CF=animals(i).ephys.site(j).CF; % kHz; 0 for unknown
%             notes=animals(i).ephys.site(j).notes;
%             if strcmp(animals(i).ephys.site(j).user,'mak')
%                 counter=counter+1;
%                 lostat1performed=animals(i).ephys.site(j).lostat1performed; % 'yes' or '' for no
%                 vout=animals(i).ephys.site(j).vout; % mV
%                 fprintf(bincelllist,'\n\nCell %d, Vout=%.1fmV, lostat=%s',counter,vout,lostat1performed);
%                 for k=1:length(animals(i).ephys.site(j).file)
%                     session=animals(i).ephys.site(j).file(k).session;
%                     filename=animals(i).ephys.site(j).file(k).filenum;
%                     mode=animals(i).ephys.site(j).file(k).mode;
%                     if strcmp(mode,'inorm')
%                         inorm=animals(i).ephys.site(j).file(k).inorm; % in pA
%                     end
%                     try stimtypes=stimtype(expdate,session,filename);
%                     catch
%                         ProcessData_single(expdate,session,filename);
%                         stimtypes=stimtype(expdate,session,filename);
%                     end
%                     if isempty(stimtypes)
%                         ProcessData_single(expdate,session,filename);
%                         stimtypes=stimtype(expdate,session,filename);
%                         if isempty(stimtypes)
%                             warning(sprintf('\n\n%s-%s-%s STIMTYPES NOT FOUND!!!\n',expdate, session, filename));
%                         end
%                         %                     Now make a list of all cells.
%                     elseif length(stimtypes)==2
%                         stimtypes=char(stimtypes); stimtypes1=stimtypes(1,:); stimtypes2=stimtypes(2,:);
%                         currdir=sprintf('%s',pwd);
%                         cd(savefiledir);
%                         fprintf(bincelllist,'\n%s-%s-%s: %s, %s & %s',expdate,session,filename,mode,stimtypes1,stimtypes2);
%                         cd(currdir)
%                     elseif length(stimtypes)==1
%                         stimtypes=char(stimtypes);
%                         currdir=sprintf('%s',pwd);
%                         cd(savefiledir);
%                         fprintf(bincelllist,'\n%s-%s-%s: %s, %s',expdate,session,filename,mode,stimtypes);
%                         cd(currdir)
%                     elseif length(stimtypes)>2
%                         warning(sprintf('\n\n%s-%s-%s More than 2 stimtypes, need to fix code!!!\n',expdate, session, filename));
%                     end
%                 end
%             end
%         end
% %     end
% end
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dbclear all
labtools
toc(begin)