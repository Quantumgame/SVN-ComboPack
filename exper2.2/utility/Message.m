
function Message(module,text,type)

h = findobj(findobj('tag',module),'tag','message');
if isempty(h)
    % if none exists, try to find a message box for the general experiment
    h = findobj(findobj('tag','exper'),'tag','message');
end

if nargin < 3 type = ''; end
if nargin < 2 text = ''; end

switch type
    case 'clear'
        if ~isempty(h)
            set(h,'string','','backgroundcolor',get(findobj('tag',module),'color'));
        end
    case 'error'
        if ~isempty(h)
            set(h,'string',text,'backgroundcolor',[1 0 0]);
        else
            disp(['Error (' module '): ' text]);
        end
    case 'blue'
        if ~isempty(h)
            set(h,'string',text,'backgroundcolor',[0 0 1], 'foregroundcolor', [1 1 1]);
        else
            disp('Error: no message box available');
        end
    case 'green'
        if ~isempty(h)
            set(h,'string',text,'backgroundcolor',[0 1 0], 'foregroundcolor', [0 0 0]);
        else
            disp('Error: no message box available');
        end
    case 'normal'
        if ~isempty(h)
            set(h,'string',text,'backgroundcolor',get(findobj('tag',module),'color'), 'foregroundcolor', [0 0 0]);
        else
            disp('Error: no message box available');
        end
    case 'append' %mw 06.26.06
        if ~isempty(h)
            prev_text=get(h, 'string');
    
            if size(prev_text,1)>=6
                new_text=sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s',prev_text(end-5,:),prev_text(end-4,:),prev_text(end-3,:),prev_text(end-2,:),prev_text(end-1,:),prev_text(end,:), text);
            elseif size(prev_text,1)==5
                new_text=sprintf('%s\n%s\n%s\n%s\n%s\n%s',prev_text(end-4,:),prev_text(end-3,:),prev_text(end-2,:),prev_text(end-1,:),prev_text(end,:), text);
            elseif size(prev_text,1)==4
                new_text=sprintf('%s\n%s\n%s\n%s\n%s',prev_text(end-3,:),prev_text(end-2,:),prev_text(end-1,:),prev_text(end,:), text);
            elseif size(prev_text,1)==3
                new_text=sprintf('%s\n%s\n%s\n%s',prev_text(end-2,:),prev_text(end-1,:),prev_text(end,:), text);
            elseif size(prev_text,1)==2
                new_text=sprintf('%s\n%s\n%s',prev_text(end-1,:),prev_text(end,:), text);
            elseif size(prev_text,1)==1
                new_text=sprintf('%s\n%s',prev_text, text);
            elseif isempty(prev_text)
               new_text= text;
            else
                error('??????')
            end%             if length(new_text)>100
            %                 new_text=new_text(end-100:end);
            %             end
            try
                set(h,'string',new_text,'backgroundcolor',get(findobj('tag',module),'color'), 'foregroundcolor', [0 0 0]);
            catch
                set(h,'string',text,'backgroundcolor',get(findobj('tag',module),'color'), 'foregroundcolor', [0 0 0]);
            end
        else
            disp('Error: no message box available');
        end
            case 'appendred' %mw 06.26.06
        if ~isempty(h)
            prev_text=get(h, 'string');
            if size(prev_text,1)>=2
                new_text=sprintf('%s\n%s\n%s',prev_text(end-1,:),prev_text(end,:), text);
            elseif size(prev_text,1)==1
                new_text=sprintf('%s\n%s',prev_text, text);
            else
                error('??????')
            end%             if length(new_text)>100
            %                 new_text=new_text(end-100:end);
            %             end
            try
                set(h,'string',new_text,'backgroundcolor','r', 'foregroundcolor', [0 0 0]);
            catch
                set(h,'string',text,'backgroundcolor','r', 'foregroundcolor', [0 0 0]);
            end
        else
            disp('Error: no message box available');
        end


    otherwise
        if ~isempty(h)
            set(h,'string',text,'backgroundcolor',get(gcf,'color'));
        else
            disp([text ': ' module]);
        end
end

drawnow



