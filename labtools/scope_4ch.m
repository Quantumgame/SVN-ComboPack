function scope_4ch(varargin)
%oscilliscope-like data browser for 4-channel data
%usage: scope(expdate, session, filenum)

persistent t st1 st2 st3 st4 win w i p stim yl
if nargin==3 %init
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    godatadir(expdate, session, filenum)
    [datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
    D=load(datafile);
    st1=D.nativeScaling*double(D.trace)+D.nativeOffset;
    S=load(stimfile);
    stim=double(S.stim);
    stim=stim./max(abs(stim));
    stim=stim+1.1*min(st1);
    user=whoami;
    
    [datafile2, eventsfile, stimfile]=getfilenames(expdate, session, filenum, [user], '3');
    if exist(datafile2, 'file')
        D2=load(datafile2);
        st2=D2.nativeScaling*double(D2.trace)+ D2.nativeOffset;
    end
    
    [datafile3, eventsfile, stimfile]=getfilenames(expdate, session, filenum, [user], '4');
    if exist(datafile3, 'file')
        D2=load(datafile3);
        st3=D2.nativeScaling*double(D2.trace)+ D2.nativeOffset;
    end
    
    [datafile4, eventsfile, stimfile]=getfilenames(expdate, session, filenum, [user], '5');
    if exist(datafile4, 'file')
        D2=load(datafile4);
        st4=D2.nativeScaling*double(D2.trace)+ D2.nativeOffset;
    end
    
    
    figure
    set(gcf, 'pos', [21         568        1641         409])
    win=1e4; %in ms
    i=0;
    t=1:length(st1);t=t/10;
    region=(i*10*win+1):((i+1)*10*win);
    offset=range(st1(region));
    plot(t(region), st1(region),t(region), st2(region)+offset,t(region), st3(region)+2*offset,t(region), st4(region)+3*offset, t(region), stim(region), 'm')
    xlabel('ms')
    
    h1 = uicontrol('Style', 'pushbutton', 'String', '>',...
        'Position', [70 50 40 30], 'Callback', 'scope_4ch(''>'')');
    
    h2 = uicontrol('Style', 'pushbutton', 'String', '<',...
        'Position', [20 50 40 30], 'Callback', 'scope_4ch(''<'')');
    
    w = uicontrol('Style', 'edit', 'String', int2str(win),...
        'Position', [20 100 80 20], 'Callback', 'scope_4ch(''win'')');
    
    wt = uicontrol('Style', 'text', 'String', '(ms)',...
        'Position', [100 100 30 20]);
    p = uicontrol('Style', 'text', 'String', sprintf('%d %%', round(100*i*10*win/length(st1))),...
        'Position', [150 100 30 20]);
    yl = uicontrol('Style', 'checkbox', 'String', 'autoscale', 'value', 1, ...
        'Position', [50 200 100 20], 'Callback', 'scope_4ch(''yl'')');
    
    
    
elseif nargin==0
    fprintf('\nno input')
elseif nargin==1
    switch varargin{1}
        case 'yl'
            if ~get(yl, 'value')
                set(yl, 'userdata', ylim)
            end
        case 'win'
            win=str2num(get(w, 'string'));
            i=0;
            region=(i*10*win+1):((i+1)*10*win);
            if max(region)<length(st)
                offset=range(st1(region));
                plot(t(region), st1(region),t(region), st2(region)+offset,t(region), st3(region)+2*offset,t(region), st4(region)+3*offset, t(region), stim(region), 'm')
                if ~get(yl, 'value') ylim(get(yl, 'userdata'));end
                xlabel('ms')
                set(p, 'String', sprintf('%d %%', round(100*i*10*win/length(st))))
            end
        case '>'
            i=i+1;
            region=(i*10*win+1):((i+1)*10*win);
            if max(region)<length(st1)
                offset=range(st1(region));
                plot(t(region), st1(region),t(region), st2(region)+offset,t(region), st3(region)+2*offset,t(region), st4(region)+3*offset, t(region), stim(region), 'm')
                if ~get(yl, 'value') ylim(get(yl, 'userdata'));end
                xlabel('ms')
                set(p, 'String', sprintf('%d %%', round(100*i*10*win/length(st))))
            else i=i-1;beep
            end
        case '<'
            i=i-1;
            region=(i*10*win+1):((i+1)*10*win);
            if min(region)<0
                region=(1):(10*win);
                i=0;
                beep
            end
            offset=range(st1(region));
            plot(t(region), st1(region),t(region), st2(region)+offset,t(region), st3(region)+2*offset,t(region), st4(region)+3*offset, t(region), stim(region), 'm')
            if ~get(yl, 'value') ylim(get(yl, 'userdata'));end
            xlabel('ms')
            set(p, 'String', sprintf('%d %%', round(100*i*10*win/length(st))))
    end
    
end

