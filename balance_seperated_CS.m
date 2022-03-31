clc, clear
close all;

addpath('pregen_wavelets');
addpath(genpath('reconstruction'));
addpath('C:\Users\Dvir\Desktop\DMD Settings and Control\DMD Full Control\Usfull stuff')


%%%%%%%%%%%%%% PTB %%%%%%%%%%%%%%%%%
    
    PsychDefaultSetup(2);
    
    %Debug flag controls verbosity level
    %Screen('Preference', 'Verbosity',  handles.debugFlag);
    
    % Get the screen numbers
    screens = Screen('Screens');
    
    % Draw to the external screen
    screenNumber = max(screens);
    if screenNumber ~= 2
        error('External screen not found/not in use!')
    end
    
     % Define black and white
    whiteColor = WhiteIndex(screenNumber);
    blackColor = BlackIndex(screenNumber);
    
    %Skip the sync tests because they fail screens with framerate > 250 Hz
    %anyway.
    Screen('Preference', 'SkipSyncTests', 1);
    [window, ~] = PsychImaging('OpenWindow', screenNumber, whiteColor);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    imageSize = 64;
%     numMeasurements = 8 * imageSize;
    numMeasurements = (imageSize^2)/8;
        % Generates measurement matrices if they don't already exist. 
    oposite = 1;
    same_mask = 2; 
    
    switch same_mask
        
        case 1
         [Movie_mat, permutations] = ...
            GenerateMovieMat(imageSize, numMeasurements, 'dragon', 1, oposite);
            first_measurement_matrix = [Movie_mat; Movie_mat];

        case 2
        oposite = 1;
        [Movie_mat1, permutations1] = ...
            GenerateMovieMat(imageSize, numMeasurements, 'dragon', 1, oposite);
         
        [Movie_mat0, permutations0] = ...
            GenerateMovieMat(imageSize, numMeasurements, 'dragon', 1, oposite);
        
        first_measurement_matrix = [Movie_mat1; Movie_mat0];
        second_measurement_matrix = [Movie_mat0; Movie_mat1];

            disp('created CS measurement set')
            
    end 

inverse_cells = balance_LL_inverse(imageSize); 

% Open an on screen window if not open
if isempty(window)
    Screen('Preference', 'SkipSyncTests', 1);
    [window, ~] = PsychImaging('OpenWindow', screenNumber, whiteColor);
else
    Screen('FillRect', window, whiteColor);
    Screen('Flip', window);% set screen to white
end

topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel); % PTB priority

% Get the size of the on screen window
[screenSizeX, screenSizeY] = Screen('WindowSize', window);

if screenSizeX ~= 608 || screenSizeY ~= 684
    warning('External screen resolution was not the expected 1140x912')
end


%load black frame and do noise estimation
Screen('FillRect', window, blackColor);
% Flip from buffer to screen
Screen('Flip', window);
KbStrokeWait;


for k = 1: 2 % numMeasurements + 1
    if k == numMeasurements + 1
        Screen('FillRect', window, blackColor);
        Screen('Flip', window);
        
        disp('Finished first measurements press any key to start the switched measurement.');
        KbStrokeWait;
%         k = 0;
        break;
    end


%     waitbar(k/numMeasurements);

    % Draw mask
    Screen('FillRect', window, whiteColor, inverse_cells(:, (first_measurement_matrix(:, k) > 0))); 
    Screen('Flip', window);
    
    % %load black frame and do noise estimation
    Screen('FillRect', window, blackColor);
    % % Flip from buffer to screen
    Screen('Flip', window);
    % Flip from buffer to screen`ff
   
end

if same_mask ~= 1

    for k = 1: 2 % numMeasurements + 1
        if k == numMeasurements + 1
            Screen('FillRect', window, blackColor);
            Screen('Flip', window);

            disp('Finished measurments! Press any key to save the data.');
            KbStrokeWait;

            break;
        end


    %     waitbar(k/numMeasurements);

        % Draw mask
        Screen('FillRect', window, whiteColor, inverse_cells(:, (second_measurement_matrix(:, k) > 0))); 
        Screen('Flip', window);

        % %load black frame and do noise estimation
        Screen('FillRect', window, blackColor);
        % % Flip from buffer to screen
        Screen('Flip', window);
        % Flip from buffer to screen`ff

    end
end

Screen('FillRect', window, blackColor);
Screen('Flip', window);
KbStrokeWait;
Screen('CloseAll');




% Flip from buffer to screen


    
    
    