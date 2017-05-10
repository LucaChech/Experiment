% Adaptive staircase to find tone detection thresholds

%% Clear
close all
clear all
clear mex
clc

%% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ClockRandSeed;  %seed the random number generator using the computer clock

% display
screenRes = 1;                              % 1=640x480, 2=800x600, 3=1024x768, 4=1152x864, 5=1280x1024, 6=1600x1200
screenSize = [640 480];                     % sprite size required for full display
screenMode = 1;                             % 0 for window, 1 for full screen
screenCol = [0 0 0];                        % black screen background
screenFont = 'Arial Narrow';                % default font
screenFontSize = 24;                        % default font size

% audio
soundChannels = 1;                          % 1 = mono, 2 = stereo
soundBits = 16;                             % 8 or 16?
soundSampleFreq = 44100;                    % sampling frequency
soundBuffers = 1;                           % number of sound buffers

% times
stimDur = [500 100 100];
ISI = 500;
delay = 300;

% tones
toneFrequency = [1025 1025 1025 1025 1025]; % frequencies of tones for auditory task (demo, then 4 experimental frequencies)
toneRamp = 10;                             % ramp duration (ms)

% staircase
nTrials = [5 30 30];                        % # trials (demo, normal block, final block)
standard = 0;                               % value for standard
targetInitial = 0.05;                       % initial delta value for target (make larger to start at an easier point)
stepsize = [4 2];                           % step sizes for different phases of staircase (stage 1, stage 2)
absolute = false;                           % set to true for absolute stepsize, false for relative
nUp = [1 1];                                % number of incorrect answers required before adapting delta up (stage 1, stage 2)
nDown = [1 3];                              % number of correct answers required before adapting delta down (stage 1, stage 2)
reversals = [4 99];                         % max number of reversals before next phase  (stage 1, stage 2)
direction = -1;                             % lead in finishes when moving down or up
deltaMax = 0.3;                             % max delta value
deltaMin = 0.00002;                         % min delta value (best not to set to 0)
nRevEst = 2;                                % n reversals to use in threshold estimate - you can fit a psychometric function in the long run, but this gives an ok estimate fast)
output = 1;                                 % 0 for no output, 1 for text, 2 for text and graph

% responses
keys = [76 77];                             % response keys for numpad 1 and numpad 2

% blocks
blockType = [1 2 2 2 3];
blockLabel = {'Demo', 'Probe', 'Probe'};

% instruction text
instruction = cell(13,4);
instruction(:,1) = {'INSTRUCTIONS';...
    '';...
    'You will be played a beep during one of two time intervals.';...
    'Each interval (1 and 2) will be indicated on screen by the number';...
    'being highlighted.';...
    'You will then be asked whether the tone occurred during interval 1 or 2.';...
    '';...
    'Using your right hand, press the numpad key to respond.';...
    '';...
    'There is no rush to respond, take as much time as you need, although';...
    ['you won' char(39) 't remember it for long anyway!'];...
    '';...
    'Press the space bar to start a slowed down demo...'};
instruction(:,2) = {''; ''; '';...
    'GREAT!';...
    '';...
    'In the real thing the sounds will be faster, but your task is the same.';...
    '';...
    '';...
    '';...
    'Press the space bar to start.';...
    ''; ''; ''};
instruction(:,3) = {'WELL DONE!';...
    ''; ''; ''; ''; '';...
    '';...
    '';...
    '';...
    ['We' char(39) 'll now move on to a higher beep.'];...
    'Your task is still the same.';...
    '';...
    'Press the space bar to start.'};
instruction(:,4) = {'FINISHED!'; ''; ''; ...
    '';...
    '';...
    '';...
    '';...
    '';...
    '';...
    ''; ''; ''; 'Press the space bar to exit.'};

nInstruct = size(instruction);

%% Get Subject Info  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Subject Number:','Subject Initials:','Gender (f/m)','Age'}; %prompt
default = {'1-1-001','XX','fm','0'};
dlgname = 'Setup Info';
LineNo = 1;
answer = inputdlg(prompt,dlgname,LineNo,default);
[subNum, sub, sex, age] = deal(answer{:});

subInfo = [{'Subject Number'},{'Name'},{'Sex'},{'Age'};...
           {subNum},{sub},{sex},{age}];
       
mkdir(['.\data\' subNum '\thresholds\'])

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
cgfont(screenFont,screenFontSize+10);
cgtext('1',-100,0);

% interval 2
cgmakesprite(202, screenSize(1), screenSize(2), screenCol);
cgsetsprite(202);
cgpencol(1, 1, 1);
cgfont(screenFont,screenFontSize);
cgtext('1',-100,0);
cgpencol(1, 1, 0);
cgfont(screenFont,screenFontSize+10);
cgtext('2',100,0);

% probe
cgmakesprite(203, screenSize(1), screenSize(2), screenCol);
cgsetsprite(203);
cgpencol(1, 1, 1);
cgfont(screenFont,screenFontSize);
cgtext('Was the beep in interval 1 or 2?',0,100);

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
        cgtext(instruction{j,i},0,(nInstruct(1)/2-j)*25);
    end
end

% create sound array
tone = cell(1,length(blockType));

%% Experiment

% show initial instructions
cgsetsprite(0)
cgdrawsprite(210,0,0)
cgflip;
waitkeydown(inf,map.Space)

for b=1:length(blockType)
    
    % make array for data
    data = cell(nTrials(blockType(b))+ 3,6);
    data(1,:) = {blockLabel{blockType(b)}, [num2str(toneFrequency(b)) 'Hz'], '', '', '', ''};
    data(2,:) = {'Delta', 'LeadIn?', 'Reversal?', 'Target', 'Response', 'Correct?'};
    
    % create tone
    x = linspace(0, stimDur(blockType(b))/1000,soundSampleFreq*stimDur(blockType(b))/1000)';
    x = sin(2*pi*toneFrequency(b) * x);
    y = linspace(0, 1000/(toneRamp*soundSampleFreq), toneRamp*soundSampleFreq/1000);
    ramp  = ones(size(x));
    ramp(1:length(y)) = ((1+(cos(2*pi*(length(y)/2)*y + pi)))/2).^2;
    ramp((end-length(y)+1):end) = ((1+(cos(2*pi*(length(y)/2)*y )))/2).^2;
    tone{b} = x .* ramp;
    
    % create adaptive track
    s = adaptiveTrack(standard,targetInitial,absolute,nUp(1),nDown(1),stepsize(1),reversals(1),...
        direction,nUp(2),nDown(2),stepsize(2),reversals(2),nRevEst,nTrials,deltaMin,deltaMax,output);
    
    % randomise position of tone
    numbers = 0.5 + rand(1,nTrials(blockType(b)));
    targetInterval = (numbers > 1) +1;
    
    % trial loop
    for i = 1:nTrials(blockType(b))
        % prepare sound
        level(i) = s.getTargetValue;
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
            wait(stimDur(blockType(b)))
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
            wait(stimDur(blockType(b)))
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
        [key, time, n] = waitkeydown(inf,[map.Pad1 map.Pad2]);
        
        % update staircase and data
        data(i+2,4) = num2cell(targetInterval(i));
        data(i+2,5) = num2cell(key-75);
        if key == keys(targetInterval(i))       % correct
            data(i+2,6) = num2cell(1);
            s = s.Update(true);
        else                                    % incorrect
            s = s.Update(false);
            data(i+2,6) = num2cell(0);
        end
    end
    
    % save staircase data
    x = s.getHistory;
    data(3:end-1,1:3) = num2cell(x');
    
    thresholds(b) = s.getThresholdEstimate;
    data(end,1) = {'Threshold:'};
    data(end,2) = num2cell(thresholds(b));
    
    dlmcell(['.\data\' subNum '\thresholds\' subNum '_' num2str(b) '.csv'],data ,',');
    
    % show next instructions
    cgsetsprite(0)
    cgdrawsprite(210 + blockType(b),0,0)
    if blockType(b) ~= 1
        cgdrawsprite(202 + blockType(b),0,30)
    end
    cgflip;
    waitkeydown(inf,map.Space)
end
save(['.\data\' subNum '\thresholds\thresholds'], 'thresholds' )
stop_cogent
