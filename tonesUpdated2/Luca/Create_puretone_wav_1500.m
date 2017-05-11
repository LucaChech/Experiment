% Creates pure tone of custom frequency and duration and saves as a .wav file

close all
clear
clc

% Enter parameters
toneFrequency = 1500;               % Frequency (Hz) 
toneDuration = 50;                 % Duration (ms)
useThreshold = 1;                   % Whether or not to use the threshold calculated by the other script - 0=No, 1=Yes
subNum = 555.3;                         % (if applicable) Subject Number used in threshold script 
levelIncrease = 12;                 % (if applicable) number of dB to add to threshold for experiment tone level

% Fixed parameters
soundBits = 16;                     % 8 or 16?
soundSampleFreq = 44100;            % Sampling frequency
toneRamp = 0;                      % Duration of volume ramp for tone (ms) - to avoid harsh on and offsets (clicks)

% Create tone data
x = linspace(0, toneDuration/1000,soundSampleFreq*toneDuration/1000)';
x = sin(2*pi*toneFrequency*x);
y = linspace(0, 1000/(toneRamp*soundSampleFreq), toneRamp*soundSampleFreq/1000);
ramp  = ones(size(x));
ramp(1:length(y)) = ((1+(cos(2*pi*(length(y)/2)*y + pi)))/2).^2;
ramp((end-length(y)+1):end) = ((1+(cos(2*pi*(length(y)/2)*y )))/2).^2;
tone = x .* ramp;

if useThreshold==0
    audiowrite(['PureTone_F' num2str(toneFrequency) '_t' num2str(toneDuration) '.wav'], tone, soundSampleFreq, 'BitsPerSample', soundBits)
else
    load(['data\' num2str(subNum) '\thresholds'])
    thresh = thresholds(3,1);
    scaleFactor = 2^(levelIncrease/6);
    level = scaleFactor*thresh;
    tone = level*tone;
    mkdir(['tones\Subject ' num2str(subNum)])
    audiowrite(['tones\Subject ' num2str(subNum) '\PureTone_F' num2str(toneFrequency) '_t' num2str(toneDuration) '.wav'], tone, soundSampleFreq, 'BitsPerSample', soundBits)
end

% play sound (copy this and paste in command window to repeat the sound,
% check you or pp can hear it etc.
sound(tone, soundSampleFreq)