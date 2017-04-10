function RFMapper(varargin)
% draws a mouse-controlled flashing thing on the screen for mapping visual RFs
% usage (all arguments are optional):
% RFMapper([size], [sf], [angle], [period])
% inputs:
%     size:  size of the square in pixels
%     sf: spatial frequency of the grating in pixelsPerPeriod
%          (use 0 for a uniform grating)
%     angle: angle of the grating in degrees
%     period: how fast it flashes, in seconds
%example calls:
%RFMapper
%RFMapper(200, 0, [], .5)
%RFMapper(200, 150, [], .5)

% modified from MouseTraceDemo
%mw 090908
if nargin==0
    widthOfGrid = 300;
    pixelsPerPeriod = 150; % How many pixels will each period/cycle occupy?
    tiltInDegrees = 90; % The tilt of the grating in degrees.
    period=.25;
elseif nargin==1
    widthOfGrid = varargin{1};
    pixelsPerPeriod = 150; % How many pixels will each period/cycle occupy?
    tiltInDegrees = 90; % The tilt of the grating in degrees.
    period=.25;
elseif nargin==2
    widthOfGrid = varargin{1};
    pixelsPerPeriod  = varargin{2}; % How many pixels will each period/cycle occupy?
    tiltInDegrees = 90; % The tilt of the grating in degrees.
    period=.25;
elseif nargin==3
    widthOfGrid = varargin{1};
    pixelsPerPeriod  = varargin{2}; % How many pixels will each period/cycle occupy?
    tiltInDegrees = varargin{3}; % The tilt of the grating in degrees.
    period=.25;
elseif nargin==4
    widthOfGrid = varargin{1};
    pixelsPerPeriod  = varargin{2}; % How many pixels will each period/cycle occupy?
    tiltInDegrees = varargin{3}; % The tilt of the grating in degrees.
    period=varargin{4};
else error('RFMapper: wrong number of arguments')
end
if isempty(widthOfGrid)    widthOfGrid = 300;end
if isempty(pixelsPerPeriod) pixelsPerPeriod = 150; end% How many pixels will each period/cycle occupy?
if isempty(tiltInDegrees) tiltInDegrees = 90; end% The tilt of the grating in degrees.
if isempty(period) period=.25;end

% Screen('Preference', 'SkipSyncTests', 2 );
% ___________________________________________________________________
%
% Draw a curve with the mouse.
% _______________________________________________________________________
%
% See also: PsychDemos, MouseTraceDemo2, GetMouse.

% HISTORY
% 8/12/97  dhb, wtf  Wrote it.
% 8/13/97  dhb		 Small modifications.
% 8/15/97  dgp	     Drag mouse instead of clicking before and after.
% 8/07/01  awi       Added font conditional, changed "button" to "buttons"
%                    and indexed the mouse button result for Windows.
% 4/11/01  awi		 Cosmetic editing of comments.
% 4/13/02  dgp       Use Arial, no need for conditional.
% 11/18/04 awi       Modified to make it work on OS X and renamed to MouseTraceDemoOSX.
%                    Changed the open command to specify double
%                        buffers and 32 depth because we don't yet support
%                        8-bit depth on OS X.
%                    Double buffer the display;
%                        the path does not accumulate in the window so
%                        render the entire path on every frame, not just the
%                        path delta since the last segment was drawn.
%                    Added flip command because we are double
%                        buffered.
%                    Added try..catch to close onscreen window in
%                        event of failure.
%                    Open on the highest-numbered display and pass
%                        GetMouse the window pointer.  Not necessary for OS
%                        X, but often desirable to use secondary display if
%                        available.
% 11/19/06 dhb       Remove OSX from name.

try


    % Open up a window on the screen and clear it.
    whichScreen = max(Screen('Screens'));
    [theWindow,theRect] = Screen(whichScreen,'OpenWindow',0,[],[],2);

    % Move the cursor to the center of the screen
    theX = theRect(RectRight)/2;
    theY = theRect(RectBottom)/2;
    SetMouse(theX,theY);
    ShowCursor(0);

    %%%%%%%%%%%%%%%%%
    %     %from GratingDemo
    %%%%%%%%%%%%%%%%%
    % Retrieves color codes for black and white and gray.
    black = BlackIndex(theWindow);  % Retrieves the CLUT color code for black.
    white = WhiteIndex(theWindow);  % Retrieves the CLUT color code for white.
    gray = (black + white) / 2;  % Computes the CLUT color code for gray.
    if round(gray)==white
        gray=black;
    end

    % Taking the absolute value of the difference between white and gray will
    % help keep the grating consistent regardless of whether the CLUT color
    % code for white is less or greater than the CLUT color code for black.
    absoluteDifferenceBetweenWhiteAndGray = abs(white - gray);

    % *** To rotate the grating, set tiltInDegrees to a new value.
    %     tiltInDegrees = 7; % The tilt of the grating in degrees.
    tiltInRadians = tiltInDegrees * pi / 180; % The tilt of the grating in radians.

    % *** To lengthen the period of the grating, increase pixelsPerPeriod.
    %     pixelsPerPeriod = 33; % How many pixels will each period/cycle occupy?
    spatialFrequency = 1 / pixelsPerPeriod; % How many periods/cycles are there in a pixel?
    radiansPerPixel = spatialFrequency * (2 * pi); % = (periods per pixel) * (2 pi radians per period)

    % *** To enlarge the gaussian mask, increase periodsCoveredByOneStandardDeviation.
    % The parameter "periodsCoveredByOneStandardDeviation" is approximately
    % equal to
    % the number of periods/cycles covered by one standard deviation of the radius of
    % the gaussian mask.
    periodsCoveredByOneStandardDeviation = 1;
    % The parameter "gaussianSpaceConstant" is approximately equal to the
    % number of pixels covered by one standard deviation of the radius of
    % the gaussian mask.
    gaussianSpaceConstant = periodsCoveredByOneStandardDeviation  * pixelsPerPeriod;

    if gaussianSpaceConstant==0 %if we requested a uniform guassian
        gaussianSpaceConstant=widthOfGrid;
    end
    % *** If the grating is clipped on the sides, increase widthOfGrid.
    %     widthOfGrid = 400;
    halfWidthOfGrid = widthOfGrid / 2;
    widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  % widthArray is used in creating the meshgrid.

    % ---------- Image Setup ----------
    % Stores the image in a two dimensional matrix.

    % Creates a two-dimensional square grid.  For each element i = i(x0, y0) of
    % the grid, x = x(x0, y0) corresponds to the x-coordinate of element "i"
    % and y = y(x0, y0) corresponds to the y-coordinate of element "i"
    [x y] = meshgrid(widthArray, widthArray);

    % Replaced original method of changing the orientation of the grating
    % (gradient = y - tan(tiltInRadians) .* x) with sine and cosine (adapted from DriftDemo).
    % Use of tangent was breakable because it is undefined for theta near pi/2 and the period
    % of the grating changed with change in theta.

    a=cos(tiltInRadians)*radiansPerPixel;
    b=sin(tiltInRadians)*radiansPerPixel;

    % Converts meshgrid into a sinusoidal grating, where elements
    % along a line with angle theta have the same value and where the
    % period of the sinusoid is equal to "pixelsPerPeriod" pixels.
    % Note that each entry of gratingMatrix varies between minus one and
    % one; -1 <= gratingMatrix(x0, y0)  <= 1
    gratingMatrix = sin(a*x+b*y);

    if pixelsPerPeriod==0
        gratingMatrix=ones(size(gratingMatrix)); %overwrite grating with white
    end
    % Creates a circular Gaussian mask centered at the origin, where the number
    % of pixels covered by one standard deviation of the radius is
    % approximately equal to "gaussianSpaceConstant."
    % For more information on circular and elliptical Gaussian distributions, please see
    % http://mathworld.wolfram.com/GaussianFunction.html
    % Note that since each entry of circularGaussianMaskMatrix is "e"
    % raised to a negative exponent, each entry of
    % circularGaussianMaskMatrix is one over "e" raised to a positive
    % exponent, which is always between zero and one;
    % 0 < circularGaussianMaskMatrix(x0, y0) <= 1
    circularGaussianMaskMatrix = exp(-((x .^ 2) + (y .^ 2)) / (gaussianSpaceConstant ^ 2));

    % Since each entry of gratingMatrix varies between minus one and one and each entry of
    % circularGaussianMaskMatrix vary between zero and one, each entry of
    % imageMatrix varies between minus one and one.
    % -1 <= imageMatrix(x0, y0) <= 1
    imageMatrix = gratingMatrix .* circularGaussianMaskMatrix;

    % Since each entry of imageMatrix is a fraction between minus one and
    % one, multiplying imageMatrix by absoluteDifferenceBetweenWhiteAndGray
    % and adding the gray CLUT color code baseline
    % converts each entry of imageMatrix into a shade of gray:
    % if an entry of "m" is minus one, then the corresponding pixel is black;
    % if an entry of "m" is zero, then the corresponding pixel is gray;
    % if an entry of "m" is one, then the corresponding pixel is white.
    grayscaleImageMatrix1 = gray + absoluteDifferenceBetweenWhiteAndGray * imageMatrix;
    grayscaleImageMatrix2 = gray + absoluteDifferenceBetweenWhiteAndGray * -1 *imageMatrix;

    %%%%%%%%%%%%%%%%%
    %     end of block from GratingDemo
    %%%%%%%%%%%%%%%%%
    %     use DrawTexture from DriftDemo
    tex1=Screen('MakeTexture', theWindow, grayscaleImageMatrix1);
    tex2=Screen('MakeTexture', theWindow, grayscaleImageMatrix2);



    %
    %  Wait for a click and hide the cursor
    Screen(theWindow,'FillRect',gray); %mw
    %     Screen(theWindow,'FillRect',0); %


    %Screen(theWindow,'TextFont','Arial');
    %Screen(theWindow,'TextSize',18);
    %     Screen(theWindow,'DrawText','click to start',50,50,255);
    %     Screen('Flip', theWindow);
    %     while (1)
    %         [x,y,buttons] = GetMouse(whichScreen);
    %         %        if   KbCheck
    %         if buttons(1) | KbCheck %mw
    %             break;
    %         end
    %     end
    Screen(theWindow,'DrawText','press any key to quit',10,10,0);
    %Screen(theWindow,'DrawText','Release button to finish',50,50,255);

    % Loop and track the mouse, drawing the contour
    %     [theX,theY] = GetMouse(whichScreen);
    %     thePoints = [theX theY];
    %     Screen(theWindow,'DrawLine',255  ,theX,theY,theX,theY);

    % Writes the image to the window.
    %	Screen('PutImage', theWindow, grayscaleImageMatrix);
    %     Screen('PutImage', theWindow, grayscaleImageMatrix, [theX theY  size(grayscaleImageMatrix)]);
    %       Screen('DrawTexture', theWindow, tex); %works
    HideCursor

%timer for flashing
% fliptimer=timer('TimerFcn',@flipme,'Period',period,'ExecutionMode','FixedRate');
% start(fliptimer)
% pause(5)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is the redraw loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    state=1;
    Screen('Flip', theWindow);
    startTime = GetSecs;
    %LastTime=GetSecs;
    fprintf('\npress any key to quit...')
    while (1)
        [x,y,buttons] = GetMouse(whichScreen);
        %         if ~buttons(1)
        if KbCheck %mw
            break;
        end

        %         if (x ~= theX | y ~= theY)
        %             [numPoints, two]=size(thePoints);
        %             for i= 1:numPoints-1
        %                 Screen(theWindow,'DrawLine',255,thePoints(i,1),thePoints(i,2),thePoints(i+1,1),thePoints(i+1,2));
        %             end

        %             Screen('Flip', theWindow);
        %             theX = x; theY = y;
        %         end
         ThisTime=GetSecs;
          state= mod(ThisTime-startTime, period) == mod(ThisTime-startTime, 2*period);
  
%             fprintf('\n%.4f %.4f', mod(ThisTime-startTime, period) , mod(LastTime-startTime, period))
%             if mod(ThisTime-startTime, period) < mod(LastTime-startTime, period)
%             %flip
%             fprintf('\nflip')
%             state=~state;
%         end
        if state
            Screen('DrawTexture', theWindow, tex1, [], [x-halfWidthOfGrid y-halfWidthOfGrid x+halfWidthOfGrid y+halfWidthOfGrid]); %
        else
            Screen('DrawTexture', theWindow, tex2, [], [x-halfWidthOfGrid y-halfWidthOfGrid x+halfWidthOfGrid y+halfWidthOfGrid]); %
        end
        Screen('Flip', theWindow);
        LastTime=GetSecs;
        Screen(theWindow,'DrawText','press any key to quit',10,10,0);
    end

    % Close up
    Screen(theWindow,'DrawText','Click mouse to finish',50,50,255);
    ShowCursor;
    Screen(theWindow,'Close');

    %spit out last coordinates in [x y size size] format
    fprintf('\nlast coordinates:')
    fprintf('\n%d %d %d %d \n', x, y, widthOfGrid, widthOfGrid)


catch
    Screen('CloseAll');
    Screen('ShowCursor');
    psychrethrow(psychlasterror);


end %try..catch..

% function flipme
% global state
% state=~state;
% fprintf('\nflip')

% % Return the name of this file/module.
% function out = me
% out = lower(mfilename);
% 
% % me

