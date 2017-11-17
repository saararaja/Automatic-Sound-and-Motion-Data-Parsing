% ALS Phrase Parsing Function:
%
%PURPOSE:
%
% This function will be used to automatically parse ALS audio and motion 
% data into individual phrases.
%
%DISCLAIMER: The following version of this program loads sample data only.
%Actual data is confidential and owned by the University of Texas at
%Dallas.
%
%INSTRUCTIONS:
%Step One:
%Type ALSPhraseParsing in the interactive MATLAB Workspace to activate the
%program.
%Step Two:
% You can play the audio by clicking the 'Play Audio' button. You can begin
% the parsing process by clicking 'Begin Tagging'. Each pair of tags will 
%have to be accepted by you before proceeding to the next pair. After all
%tagging is finished, the data will be extracted.


function [] = ALSPhraseParsing ()

%% Getting the data from a text file into Matlab
% This step extracts the relevant data from the Sample Data File and
% formats it appropriately for MATLAB to read.

MotionData = csvread('SampleMotionData.csv', 1, 0);      
SensorData = [];   %The data of interest is the x,y,and z positions of each sensor over time
                                                                                                                  
for sensor = 2:7;                            %sensor refers to the number of sensor you want; There are 6 sensors, numbered 2-7
    column = 3 + (sensor-1) * 9+ 2;          %this equation pulls only the data of interest into the new matrix
    SensorData  = [SensorData MotionData(:,column+1) MotionData(:,column+2) MotionData(:,column+3)]; %Matrix now contains all motion data for each sensor
end

Timings = [MotionData(:,1)]; %this matrix will have time data; time data is alwasy located in the first column in the 'MotionData' spreadsheet 

%% Plotting the audio and motion data into one large figure

%audio data
figure ('Position', [300, 100, 900, 600]);    %create a figure for audio and motion data
subplot(19,1,1, 'position', [0.07,0.89, 0.9, 0.1] );    %This first plot will be audio data
[y,Fs] = audioread('SampleAudioData.wav');     %read the sample audio file to matlab
time = [1:size(y)]/Fs;   %makes a matrix for time related to audio
plot (time, y);   %plot audio against time
axis tight;   

%motion data
%plotting motion data and color coding to distinguish x, y, and z motion
for newcolumn = 1:18;     %6 sensors times 3 dimensions (x,y,z)= 18
    bottom = 0.89 - 0.04*(newcolumn);   %the bottom position of each subplot will be directly below the previous subplot
    subplot(19,1,newcolumn+1, 'position', [0.07, bottom, 0.9, 0.04]);   
    if newcolumn==1 | newcolumn==4 | newcolumn==7 | newcolumn==10 | newcolumn==13 | newcolumn==16;   %select all of the x dimension columns
        p1=plot(Timings, SensorData(:,newcolumn),'color', [0 0 .6]);   %plot the x dimension and color code it blue
    end
    if newcolumn==2 | newcolumn==5 | newcolumn==8 | newcolumn==11 | newcolumn==14 | newcolumn==17;   %select all of the y dimension columns
        p2=plot(Timings, SensorData(:,newcolumn),'color',[0 .6 0]);   %plot the y dimension and color code it green
    end
    if newcolumn==3 | newcolumn==6 | newcolumn==9 | newcolumn==12 | newcolumn==15 | newcolumn==18;   %select all of the z dimension columns
        p3=plot(Timings, SensorData(:,newcolumn),'color',[.6 0 0]);   %plot the z dimension and color code it red
    end
 
%Making figure neat
    axis tight; 
    set(gca,'yticklabel', '');   
    set(gca, 'xticklabel', ''); 
    if newcolumn == 9;     
        ylabel ('Tongue motion (mm)', 'fontsize', 14);   
        leg=legend([p1 p2 p3], {'X' 'Y' 'Z'});     
        set(leg, 'position', [0.8971 0.0482 0.0606 0.0714]);    
    end
    
    if newcolumn == 18; 
        set(gca, 'xticklabel', 5:5:45)
    end    
end
%% More making the figure pretty and labeling the sensors
xlabel ('Time (seconds)', 'fontsize', 14); 

annotation('textbox',...
    [0.966 0.763 0.031 0.038],...
    'Color',[0.2 0.2 0.2],'String','TT','FontSize', 14, 'LineStyle','none','FontWeight','bold'); 
annotation('textbox',...
    [0.966 0.650 0.031 0.038],...
    'Color',[0.2 0.2 0.2],'String','TB','FontSize', 14,'LineStyle','none','FontWeight','bold'); 
annotation('textbox',...
    [0.966 0.527 0.031 0.038],...
    'Color',[0.2 0.2 0.2],'String','UL','FontSize', 14,'LineStyle','none','FontWeight','bold'); 
annotation('textbox',...
    [0.966 0.402 0.031 0.038],...
    'Color',[0.2 0.2 0.2],'String','LL','FontSize', 14,'LineStyle','none','FontWeight','bold'); 
annotation('textbox',...
    [0.966 0.283 0.031 0.038],...
    'Color',[0.2 0.2 0.2],'String','JL','FontSize', 14,'LineStyle','none','FontWeight','bold'); 
annotation('textbox',...
    [0.966 0.165 0.031 0.038],...
    'Color',[0.2 0.2 0.2],'String','JR','FontSize', 14,'LineStyle','none','FontWeight','bold'); 
annotation('line',[0.07 0.97],[0.769 0.769],...
    'color', [0.2 0.2 0.2], 'LineWidth',1.5);
annotation('line',[0.07 0.97],[0.65 0.65],...
    'LineWidth',1.5, 'color', [0.2 0.2 0.2]);
annotation('line',[0.07 0.97],[0.53 0.53],...
    'LineWidth',1.5, 'color', [0.2 0.2 0.2]);
annotation('line',[0.07 0.97],[0.41 0.41],...
    'LineWidth',1.5, 'color', [0.2 0.2 0.2]);
annotation('line',[0.07 0.97],[0.29 0.29],...
    'LineWidth',1.5, 'color', [0.2 0.2 0.2]);

%% Adding buttons that lead to the main functions

audiobutton = uicontrol ('Style', 'pushbutton', 'String', 'Play Audio', 'units',...
    'normalized', 'Position', [.057 .0582 .1 .035], 'callback', {@PlayAllPhrases}); %button that allows users to hear the audio for all of the phrases

taggingbutton = uicontrol ('Style', 'pushbutton', 'String', 'Start Tagging',...
    'units', 'normalized', 'Position', [.18 .0582 .15 .035], 'callback', {@Tagging}); %button that begins the tagging process


end

