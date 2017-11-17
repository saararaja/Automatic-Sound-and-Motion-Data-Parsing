%Will be used to play audio for all 20 phrases in lab setting. This sample
%version will only play first few phrases.

function PlayAllPhrases (object_handle, event) %will use the audiofile variable from main function
[y,Fs] = audioread('SampleAudioData.wav');  %will read the .wav audiofile to matlab
sampleleftbound = 1/Fs;
samplerightbound = 10;
samples = [sampleleftbound*Fs,samplerightbound*Fs]; 
[y,Fs] = audioread('SampleAudioData.wav', samples);
sound(y,Fs);  
end

