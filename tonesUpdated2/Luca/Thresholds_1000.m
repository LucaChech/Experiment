% Adaptive staircase to find tone detection thresholds

%% Clear
close all
clear all
clc

%% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rand('seed',fix(100*sum(clock))); %seed the random number generator using the computer clock

% display
screenRes = 3;                              % 1=640x480, 2=800x600, 3=1024x768, 4=1152x864, 5=1280x1024, 6=1600x1200
screenSize = [1024 768];                     % sprite size required for full display
screenMode = 1;                             % 0 for window, 1 for full screen
screenCol = [0.3 0.3 0.3];                  % grey screen background
screenFont = 'Arial Narrow';                % default font
screenFontSize = 38;                        % default font size

% audio
soundChannels = 1;                          % 1 = mono, 2 = stereo
soundBits = 16;                             % 8 or 16?
soundSampleFreq = 44100;                    % sampling frequency
soundBuffers = 2;                           % number of sound buffers

% times
stimDur = [500 100];
ISI = 500;
delay = 300;

% tones
toneFrequency = [1000 1000];                % frequencies of tones for auditory task
toneRamp = 0;                              % ramp duration (ms)

% staircase
nTrials = [2 30];                           % # trials
standard = 0;                               % value for standard
targetInitial = 0.05;                       % initial delta value for target
stepsize = [4 sqrt(2)];                           % step sizes for different phases
absolute = false;                           % set to true for absolute stepsize, false for relative
nUp = [1 1];                                % number of incorrect answers required before adapting delta up
nDown = [1 3];                              % number of correct answers required before adapting delta down
reversals = [2 99];                         % max number of reversals before next phase
direction = -1;                             % lead in finishes when moving down or up
deltaMax = 0.3;                             % max delta value
deltaMin = 0.00000002;                      % min delta value
nRevEst = 2;                                % n reversals to use in threshold estimate
output = 1;                                 % 0 for no output, 1 for text, 2 for text and graph

% responses
keys = [76 77];                             % response keys for numpad 1 and numpad 2

% blocks
blockType = [1 2];
blockLabel = {'Demo', 'Probe', 'Probe'};

% instruction text
instruction = cell(13,4);
instruction(:,1) = {'INSTRUCTIONS';...
    '';...
    'The numbers 1 and 2 will appear on the screen, and will be highlighted';...
    'one after the other. Along with one of the numbers you will hear a sound.';...
    '';...
    'Your task is to say whether the sound was with 1 or 2.';...
    '';...
    'Using your right hand, press NumPad1 for 1, and NumPad2 for 2.';...
    '';...
    ['Respond in your own time, there is no rush. If you can' char(39) 't hear'];...
    'the sound, just guess.';...
    '';...
    'Press space to start a slowed down demo...'};
instruction(:,2) = {''; ''; '';...
    'GREAT!';...
    '';...
    'In the real thing the sounds will be faster, but your task is the same.';...
    '';...
    '';...
    '';...
    'Press space to start.';...
    ''; ''; ''};
instruction(:,3) = {'FINISHED!'; ''; ''; ...
    '';...
    '';...
    '';...
    '';...
    '';...
    '';...
    ''; ''; ''; 'Press space to exit.'};

nInstruct = size(instruction);

%% Get Subject Info  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Subject Number:'}; %prompt
default = {'0'};
dlgname = 'Setup Info';
LineNo = 1;
answer = inputdlg(prompt,dlgname,LineNo,default);
[subNum] = deal(answer{:});
       
mkdir(['.\data\' subNum ])

%% Initialise Cogent

config_display(screenMode, screenRes, screenCol);
config_sound(soundChannels, soundBits, soundSampleFreq, soundBuffers)
config_keyboard;
start_cogent
map = getkeymap;

%% Make sprites

% basic
cgmakesprite(200, screenSize(1), screenSize(2), screenCol);
cgsetsprite(200);
cgpencol(1, 1, 1);
cgfont(screenFont,screenFontSize);
cgtext('1',-100,0);
cgtext('2',100,0);

% interval 1
cgmakesprite(201, screenSize(1), screenSize(2), screenCol);
cgsetsprite(201);
cgpencol(1, 1, 1);
cgfont(screenFont,screenFontSize);
cgtext('2',100,0);
cgpencol(1, 1, 0);
cgfont(screenFont,screenFontSize+15);
cgtext('1',-100,0);

% interval 2
cgmakesprite(202, screenSize(1), screenSize(2), screenCol);
cgsetsprite(202);
cgpencol(1, 1, 1);
cgfont(screenFont,screenFontSize);
cgtext('1',-100,0);
cgpencol(1, 1, 0);
cgfont(screenFont,screenFontSize+15);
cgtext('2',100,0);

% probe
cgmakesprite(203, screenSize(1), screenSize(2), screenCol);
cgsetsprite(203);
cgpencol(1, 1, 1);
cgfont(screenFont,screenFontSize);
cgtext('Was the beep with 1 or 2?',0,100);

% prepare face sprites
cgmakesprite(204, 150, 150, screenCol);
cgsetsprite(204);
cgloadbmp(204, 'Happy.bmp', 150, 150)

cgmakesprite(205, 150, 150, screenCol);
cgsetsprite(205);
cgloadbmp(205, 'Awesome.bmp', 150, 150)

% prepare instruction sprites
for i=1:nInstruct(2)
    cgmakesprite(209+i, screenSize(1), screenSize(2), screenCol);
    cgsetsprite(209+i);
    cgpencol(1, 1, 1);
    cgfont(screenFont,screenFontSize);
    for j=1:nInstruct(1)
        cgtext(instruction{j,i},0,(nInstruct(1)/2-j)*40);
    end
end

% create sound array
tone = cell(1,length(blockType));

%% Experiment

% show initial instructions
cgsetsprite(0)
cgdrawsprite(210,0,0)
cgflip;
[k, time, n] = waitkeydown(inf,[71 52]);
if any(k == 52)      % Escape key
    stop_cogent
    return
end

for b=1:length(blockType)
    
    % make arrays for data
    data1 = cell(nTrials(blockType(b))+ 3,6);
    data1(1,:) = {blockLabel{blockType(b)}, [num2str(toneFrequency(b)) 'Hz'], 'Staircase 1', '', '', ''};
    data1(2,:) = {'Delta', 'LeadIn?', 'Reversal?', 'Target', 'Response', 'Correct?'};
    data2 = cell(nTrials(blockType(b))+ 3,6);
    data2(1,:) = {blockLabel{blockType(b)}, [num2str(toneFrequency(b)) 'Hz'], 'Staircase 2', '', '', ''};
    data2(2,:) = {'Delta', 'LeadIn?', 'Reversal?', 'Target', 'Response', 'Correct?'};
    
    % create tone & dummy
    x = linspace(0, stimDur(blockType(b))/1000,soundSampleFreq*stimDur(blockType(b))/1000)';
    x = sin(2*pi*toneFrequency(b) * x);
    y = linspace(0, 1000/(toneRamp*soundSampleFreq), toneRamp*soundSampleFreq/1000);
    ramp  = ones(size(x));
    ramp(1:length(y)) = ((1+(cos(2*pi*(length(y)/2)*y + pi)))/2).^2;
    ramp((end-length(y)+1):end) = ((1+(cos(2*pi*(length(y)/2)*y )))/2).^2;
    tone{b} = x .* ramp;
    dummy = 0*x;
    preparesound(dummy,2);
    
    % create adaptive tracks
    s1 = adaptiveTrack(standard,targetInitial,absolute,nUp(1),nDown(1),stepsize(1),reversals(1),...
        direction,nUp(2),nDown(2),stepsize(2),reversals(2),nRevEst,nTrials(blockType(b)),deltaMin,deltaMax,output);
    s2 = adaptiveTrack(standard,targetInitial,absolute,nUp(1),nDown(1),stepsize(1),reversals(1),...
        direction,nUp(2),nDown(2),stepsize(2),reversals(2),nRevEst,nTrials(blockType(b)),deltaMin,deltaMax,output);
    
    % randomise position of tone
    numbers = 0.5 + rand(1,nTrials(blockType(b))*2);
    targetInterval = (numbers > 1) +1;
    
    % randomise which staircase to take from
    staircase = [ones(1,nTrials(blockType(b))) 2*ones(1,nTrials(blockType(b)))];
    staircase = staircase(randperm(length(staircase)));
    
    % trial loop
    for i = 1:nTrials(blockType(b))*2
        % prepare sound
        switch staircase(i)
            case 1
                level(i) = s1.getTargetValue;
            case 2
                level(i) = s2.getTargetValue;
        end
        target = level(i)*tone{b};
        preparesound(target,1);
        
        % show base screen
        cgsetsprite(0);
        cgdrawsprite(200,0,0);
        cgflip;
        wait(delay)
        
        % interval 1
        cgsetsprite(0);
        cgdrawsprite(201,0,0);
        cgflip;
        if targetInterval(i)==1
            playsound(1)
            waitsound(1)
        else
            playsound(2)
            waitsound(2)
        end
        
        % show base screen
        cgsetsprite(0);
        cgdrawsprite(200,0,0);
        cgflip;
        wait(ISI)
        
        % interval 2
        cgsetsprite(0);
        cgdrawsprite(202,0,0);
        cgflip;
        if targetInterval(i)==2
            playsound(1)
            waitsound(1)
        else
            playsound(2)
            waitsound(2)
        end
        
        % show base screen
        cgsetsprite(0);
        cgdrawsprite(200,0,0);
        cgflip;
        wait(delay)
        
        % show question screen
        cgsetsprite(0);
        cgdrawsprite(203,0,0);
        cgflip;
        [k, time, n] = waitkeydown(inf,[76 77 52]);
        if k == 52      % Escape key
            stop_cogent
            return
        end
        
        % update staircase and data
        switch staircase(i)
            case 1
                data1(sum(staircase(1:i)==1)+2,4) = num2cell(targetInterval(i));
                data1(sum(staircase(1:i)==1)+2,5) = num2cell(k-75);
                if k == keys(targetInterval(i))       % correct
                    data1(sum(staircase(1:i)==1)+2,6) = num2cell(1);
                    s1 = s1.Update(true);
                else                                    % incorrect
                    data1(sum(staircase(1:i)==1)+2,6) = num2cell(0);
                    s1 = s1.Update(false);                    
                end
            case 2
                data2(sum(staircase(1:i)==1)+2,4) = num2cell(targetInterval(i));
                data2(sum(staircase(1:i)==1)+2,5) = num2cell(k-75);
                if k == keys(targetInterval(i))       % correct
                    data2(sum(staircase(1:i)==1)+2,6) = num2cell(1);
                    s2 = s2.Update(true);
                else                                    % incorrect
                    data2(sum(staircase(1:i)==1)+2,6) = num2cell(0);
                    s2 = s2.Update(false);                    
                end
        end
    end
    
    % save staircase data
    x1 = s1.getHistory;
    data1(3:end-1,1:3) = num2cell(x1');
    x2 = s2.getHistory;
    data2(3:end-1,1:3) = num2cell(x2');
    
    if b>1
        thresholds(1,b-1) = s1.getThresholdEstimate;
        thresholds(2,b-1) = s2.getThresholdEstimate;
        if isnan(thresholds(1,b-1)) && isnan(thresholds(2,b-1))
            thresholds(3,b-1) = NaN;
        elseif isnan(thresholds(1,b-1))
            thresholds(3,b-1) = thresholds(2,b-1);
        elseif isnan(thresholds(2,b-1))
            thresholds(3,b-1) = thresholds(1,b-1);
        else
            thresholds(3,b-1) = (thresholds(1,b-1) + thresholds(2,b-1))/2;
        end
        
    data1(end,1) = {'Threshold:'};
    data1(end,2) = num2cell(thresholds(1,b-1));
    data2(end,1) = {'Threshold:'};
    data2(end,2) = num2cell(thresholds(2,b-1));
    
    dlmcell(['data\' subNum '\' subNum '_' num2str(toneFrequency(b)) 'Hz_1.csv'],data1 ,',');
    dlmcell(['data\' subNum '\' subNum '_' num2str(toneFrequency(b)) 'Hz_2.csv'],data2 ,',');
    end

    
    % show next instructions
    cgsetsprite(0)
    cgdrawsprite(210 + blockType(b),0,0)
    if blockType(b) ~= 1
        cgdrawsprite(203 + blockType(b),0,30)
    end
    cgflip;
    waitkeydown(inf,71)
end
save(['data\' subNum '\thresholds'], 'thresholds' )
stop_cogent
