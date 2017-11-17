%This function will put tags on the beginning and end of each phrase.
%
% The function will zoom in on each phrase individually and automatically
% put two end tags.
%
% The user has the option of listening to the audio for the phrase and
% then has to accept or reject the position of the automatically generated tags.
%
% If the user accepts the tags, the program will move to the next phrase
% and the process will be repeated. If the user rejects the tag positions,
% he/she has the option to change the viewing window and manually adding
% tags.



function Tagging (object_handle, event) %inputs for this function include all the same variables

%% global variables
global t1
global T1
global t2
global T2
global Tag_1_time
global Tag_2_time
global Tag_1_line
global Tag_2_line
global y
global Fs
global time
global y_abs
global TimeMatrix
global new_start
global MotionData
global SensorData
global Timings
global LL_Matrix
global TT_Matrix
global TB_Matrix
global sensor_number_TT

%% Finding absolute value of the audio
%The absolute value helps with finding thresholds for the audio data;
%without absolute values, all of the audio below zero interferes with
%finding a threshold. 

[y,Fs] = audioread('SampleAudioData.wav'); %read audio file to matlab
time = [1:size(y)]/Fs;  %generate time values for audio data
y_abs = abs(y);  %find absolute values for audio data
TimeMatrix = [time' y_abs]; %matrix with time data and absolute value of y positions


%% Phrase 1 boundaries
%since Phrase 1 is at the very beginning of the sound bite, the loops for
%this phrase will be slightly different from the others. All the other
%phrases will have the same procedure.

for row = 1:length(TimeMatrix); %loop starts from first row of audio data
   
    
    if TimeMatrix(row,2) > 0.03; %when absolute value of audio is greater than 0.03 amplitude, the sound is most likely the patient's voice and not static noise
        
        t1 = TimeMatrix(row,1);  %time corresponding to the beginning of the patient vocals 
        new_start = row+1;  %next loop will begin where this loop ended
        break %this loop will be broken when a beginning boundary is set and the next loop will begin to set an ending boundary
    end
    
end

if t1 - 0.4 > 0;  %for the first phrase, there may not be 0.4 seconds at the beginning of the recording
    T1 = t1 - 0.4; %if there is 0.4 seconds then this will be the window of observation
else
    T1 = 0; %if there is less than 0.4 seconds, then the window of observation will just begin at the start of the recording
end

t1; %reveal t1
T1; %reveal T1

% Now we have two data points recorded: t1 which marks the beginning of the
% patient speech and T1 that marks the beginning of the viewing window
% The beginning tag will be placed between t1 and T1, based on the curves
% of the motion data.


%Now we will look for the end boundary and end viewing window for the first phrase
for row = new_start:length(TimeMatrix); % this loop begins where the previous loop broke 
    
    if TimeMatrix(row,2) < 0.03; %when absolute value of audio is less than the 0.03 amplitude threshold, it is most likely the end of the phrase
        
        % However, this must be verified because there are pauses within each phrase (between each word) that dip below 0.03. 
        % Algorithm to verify if it is indeed the end of the phrase is to test whether the below 0.03 amplitude persists for 0.3 seconds
        
        test_time = TimeMatrix(row,1); %the time at the point where the amplitude is below 0.03. Needs to be tested.
        test_row = row; %we will call this test_row to test if it is a pause or actually the end of the phrase
        
        
        %before we test whether it is a pause, we need to find the row # where the time will be 0.3 seconds from the test_time
        for row = test_row: length(TimeMatrix); %loop begins at test_row to find the i value where the time is 0.3 seconds later
            if TimeMatrix(row,1) >= test_time + 0.3; %this is the first time value that is 0.3 seconds later
                verify_row = row; %the row value here will be noted as verify_row
                break %this loop will be broken because the needed information (verify_row) has been found
            end
        end
        
        if TimeMatrix(test_row:verify_row, 2) < 0.03; %if the amplitude is entirely below 0.03 between these two times, then it is the end of the phrase
            t2 = TimeMatrix(test_row,1); %the time will be noted as t2
            new_start = test_row + 1; %the new_start will be noted to start over for the next phrase
            break %the loop will be broken
            
        end
        
        
    else
        continue %if the amplitude is not less than 0.02 at this point, then it was just a minor pause within the phrase and the loop will
        %continue to find the next instance of a dip below 0.02 amplitude
        
    end
end
t2;  %reveal t2
T2 = t2 + 0.4; %T2, which shows the window of observation, will be the previously noted t2 + 0.4 seconds. The end tag will be placed
%between t2 and T2

%% Find Position of Automatic Tags
    
    %Tags are based on the motion data, and each phrase depends on a different sensor. 
    %The first phrase "I love you" is most clearly shown by the Lower Lip sensor
    %The sensor placement was inputted by the user into the function, and now a loop needs to be written to find the numerical value of the correct sensor
    
    
    %Assign sensor numbers for the sensors that are most useful in
    %indicating tongue motion
   sensor_number_TT = 1;
   sensor_number_TB = 2;
   sensor_number_LL = 4;   
    % The Y dimension shows the mouth opening and closing for each sensor.
    % According to the data, the second column from the data set for each sensor is the Y dimension, therefore to find the line of interest:
    
    sensor_column_LL = (sensor_number_LL - 1)*3 +2; %equation to find line corresponding to Y dimension of Lower Lip
    sensor_column_TT = (sensor_number_TT - 1)*3 +2; %equation to find line corresponding to Y dimension of Tongue Tip
    sensor_column_TB = (sensor_number_TB - 1)*3 +2; %equation to find line corresponding to Y dimension of Tongue Back
    
% The following lines are repeated from the main function
    MotionData = csvread('SampleMotionData.csv', 1, 0); %will open up all of the data for the patient you want
    SensorData = []; %make a matrix with only the important data from the huge data file; i.e, want the x,y,and z positions of each sensor over time

    for sensor = 2:7; %sensor refers to the number of sensor you want; options are 2-7
        column = 3 + (sensor-1) * 9+ 2; %this equation pulls only the data of interest into the new matrix
        SensorData  = [SensorData MotionData(:,column+1) MotionData(:,column+2) MotionData(:,column+3)];
    end
    Timings = [MotionData(:,1)]; %this matrix will have time data; the first column is always time
    %end of repeated lines

LL_Matrix = [Timings SensorData(:, sensor_column_LL)]; %matrix of Time Data and y dimension data for the Lower Lip sensor
TT_Matrix = [Timings SensorData(:, sensor_column_TT)]; %matrix of Time Data and y dimension data for the Tongue Tip sensor
TB_Matrix = [Timings SensorData(:, sensor_column_TB)]; %matrix of Time Data and y dimension data for the Tongue Back sensor


% Tag 1 loops:    
for i = 1:length(LL_Matrix) 

    if LL_Matrix(i, 1) >= T1; %find the Timing that is closest to T1
        tag_bound_1 = i; %mark this row number
        break
    end
end

for i = 1:length(LL_Matrix)
    
    if LL_Matrix (i,1) >= t1; %find the Timing that is closest to t1
        tag_bound_2 = i; %mark this row number
        break
    end
end

Minimum = LL_Matrix(tag_bound_1, 2); %The mouth opens when the LL is at a minimum. Place the initial minimum position
for i = tag_bound_1 + 1: tag_bound_2
    if Minimum > LL_Matrix(i,2); %if any y position between the two bounds is lower than the initial minimum, then it will be the new minimum
        Minimum = LL_Matrix(i,2);
    end
end

[I, J] = find (LL_Matrix == Minimum); %find the row number for the minimum y value
Tag_1_time = LL_Matrix(I,1); %Note down the time for this minimum y value. This will be the position of the first tag.

%Tag 2 loops:
    
for i = 1:length(LL_Matrix) 

    if LL_Matrix(i, 1) >= t2; %find the Timing that is closest to t2
        tag_bound_3 = i; %mark this row number
        break
    end
end

for i = 1:length(LL_Matrix)
    
    if LL_Matrix (i,1) >= T2; %find the Timing that is closest to T2
        tag_bound_4 = i; %mark this row number
        break
    end
end

Maximum = LL_Matrix(tag_bound_3, 2); %The mouth closes when the LL is at a maximum. Place the initial maximum position
for i = tag_bound_3 + 1: tag_bound_4
    if Maximum < LL_Matrix(i,2); %if any y position between the two bounds is higher than the initial maximum, then it will be the new maximum
        Maximum = LL_Matrix(i,2);
    end
end

[I, J] = find (LL_Matrix == Maximum); %find the row number for the maximum y value
Tag_2_time = LL_Matrix(I,1); %Note down the time for this maximum y value. This will be the position of the second tag.

%% Build the User Interface
   
figure('Position', [200, 100, 900, 600]); %will recreate the main figure, but zoom in only on the phrase of interest
subplot(19,1,1, 'position', [0.07,0.89, 0.5, 0.1]); %This first plot will be audio data, will be bigger than the other subplots
[y,Fs] = audioread('SampleAudioData.wav'); %read the audiofile to matlab
time = [1:size(y)]/Fs; %find the time values for the audio data
plot(time,y); %plot the audio against time
xlim([T1 T2]); %Now zoom in on the phrase of interest. T1 and T2 represent the bounds of the viewing window
hold on
%graph the tags
x1=[Tag_1_time,Tag_1_time]; %x position for Tag1
x2=[Tag_2_time,Tag_2_time]; %x position for Tag2
y_limits=[-0.5,0.5]; %min and max y 
Tag_1_line = plot(x1,y_limits, 'color', 'm'); %plot tag1
Tag_2_line = plot(x2, y_limits, 'color', 'm'); %plot tag2


%now motion data will be plotted
for newcolumn = 1:18; %newcolumn is the column number from the matrix SensorData; each of these columns has motion data and will be plotted individually vs time
    bottom = 0.89 - 0.04*(newcolumn); %equation for the bottoms of each subplot to be alligned
    subplot(19,1,newcolumn+1, 'position', [0.07, bottom, 0.5, 0.04]); %position of each subplot
    if newcolumn==1 | newcolumn==4 | newcolumn==7 | newcolumn==10 | newcolumn==13 | newcolumn==16; %color code x dimension as blue
        p1=plot(Timings, SensorData(:,newcolumn),'color', [0 0 .6]); %plot the lines
    end
    if newcolumn==2 | newcolumn==5 | newcolumn==8 | newcolumn==11 | newcolumn==14 | newcolumn==17; % color code y dimension as green
        p2=plot(Timings, SensorData(:,newcolumn),'color',[0 .6 0]); %plot the lines
    end
    if newcolumn==3 | newcolumn==6 | newcolumn==9 | newcolumn==12 | newcolumn==15 | newcolumn==18; %color code z dimension as red
        p3=plot(Timings, SensorData(:,newcolumn),'color',[.6 0 0]); %plot the lines
    end
    axis tight; % make the graph fit the figures
    xlim([T1 T2]); %zoom in on the viewing window between T1 and T2
    set(gca,'yticklabel', ''); %remove y tick labels because too congested
    if newcolumn == 9; %add labels in the 9th line for symmetrical look
        ylabel ('Tongue motion (mm)', 'fontsize', 14); %label the y axis
        leg=legend([p1 p2 p3], {'X' 'Y' 'Z'}); % add a legend
        set(leg, 'position', [0.55 0.0482 0.0606 0.0714]); %place legend in bottom corner
    end
    if newcolumn ==18;
    xlabel ('Time (seconds)', 'fontsize', 14); %label the x axis
    end
end
    
   %sensor labels 
    annotation('textbox',...
        [0.565 0.76 0.0530783430466095 0.0381309750143657],...
        'Color',[0.2 0.2 0.2],'String','TT','LineStyle','none','FontWeight','bold'); %label first sensor based on user input to function
    annotation('textbox',...
        [0.565 0.64 0.0530783430466095 0.0381309750143657],...
        'Color',[0.2 0.2 0.2],'String','TB','LineStyle','none','FontWeight','bold'); %label second sensor based on user input to function
    annotation('textbox',...
        [0.565 0.52 0.0530783430466095 0.0381309750143657],...
        'Color',[0.2 0.2 0.2],'String','UL','LineStyle','none','FontWeight','bold'); %label third sensor based on user input to function
    annotation('textbox',...
        [0.565 0.4 0.0530783430466095 0.0381309750143657],...
        'Color',[0.2 0.2 0.2],'String','LL','LineStyle','none','FontWeight','bold'); %label fourth sensor based on user input to function
    annotation('textbox',...
        [0.565 0.28 0.0530783430466095 0.0381309750143657],...
        'Color',[0.2 0.2 0.2],'String','JL','LineStyle','none','FontWeight','bold'); %label fifth sensor based on user input to function
    annotation('textbox',...
        [0.565 0.16 0.0530783430466095 0.0381309750143657],...
        'Color',[0.2 0.2 0.2],'String','JR','LineStyle','none','FontWeight','bold'); %label sixth sensor based on user input to function
    
    %thicken the axis line for each sensor
    annotation('line',[0.07 0.57],...
        [0.769 0.769],'LineWidth',1.5, 'color', [0.2 0.2 0.2]);
    annotation('line',[0.07 0.57],...
        [0.65 0.65],'LineWidth',1.5, 'color', [0.2 0.2 0.2]);
    annotation('line',[0.07 0.5],...
        [0.529 0.529],'LineWidth',1.5, 'color', [0.2 0.2 0.2]);
    annotation('line',[0.07 0.57],...
        [0.41 0.41],'LineWidth',1.5, 'color', [0.2 0.2 0.2]);
    annotation('line',[0.07 0.57],...
        [0.289 0.289],'LineWidth',1.5, 'color', [0.2 0.2 0.2]);  
    
    %% User Interface Controls
    
    play_phrase = uicontrol ('Style', 'pushbutton', 'String', 'Play Audio', 'units',...
        'normalized', 'Position', [.6 .9 .15 .05], 'callback', {@PlayOnePhrase}); %button that will play only the zoomed in phrase
    
    info_button = uicontrol ('Style', 'pushbutton', 'String', 'Help', 'units',...
        'normalized', 'Position', [.78 .9 .15 .05], 'callback', {@Information}); %button that will give instructions on how to use the tagging features
    
    annotation ('textbox', [.6 .78 .40 .05], 'String', 'Adjust Viewing Window', 'fontsize', 14, ...
        'fontweight', 'bold', 'linestyle', 'none'); %Title for the options that the user can use to adjust viewing window
    
    annotation ('textbox', [.6 .7 .15 .05], 'String', 'T1', 'fontsize', 13, ...
        'linestyle', 'none'); %option to adjust T1 position
    
    editT1 = uicontrol ('style', 'edit', 'units', 'normalized', 'position', [.64 .71 .08 .04]); %user can change T1 position
    
    annotation ('textbox', [.715 .69 .15 .05], 'String', 's', 'fontsize', 11, ...
        'linestyle', 'none'); %indicates that input should be in seconds
    
    annotation ('textbox', [.76 .7 .15 .05], 'String', 'T2', 'fontsize', 12, ...
        'linestyle', 'none'); %option to adjust T2 position
    
    editT2 = uicontrol ('style', 'edit', 'units', 'normalized', 'position', [.80 .71 .08 .04]); %user can change T2 position
    
    annotation ('textbox', [.875 .69 .15 .05], 'String', 's', 'fontsize', 11, ...
        'linestyle', 'none'); %indicates that input should be in seconds
    
    change_window = uicontrol ('Style', 'pushbutton', 'String', 'Adjust', 'units',...
        'normalized', 'Position', [.69 .63 .15 .05], 'callback', {@ChangeWindow, editT1, editT2}); %button that allows the user to edit the viewing window
    
    annotation ('textbox', [.6 .53 .40 .05], 'String', 'Manually Change Tags', 'fontsize', 14, ...
        'fontweight', 'bold', 'linestyle', 'none'); %Title for the options that the user can use to adjust viewing window
    
    tag1 = uicontrol ('Style', 'pushbutton', 'String', 'Tag 1', 'units',...
        'normalized', 'Position', [.6 .47 .15 .05], 'callback', {@ChangeTag1}); %button that will allow the user to change the position of the start tag
    
    tag2 = uicontrol ('Style', 'pushbutton', 'String', 'Tag 2', 'units',...
        'normalized', 'Position', [.78 .47 .15 .05], 'callback', {@ChangeTag2}); %button that allows the user to change the position of the end tag
    
   accept = uicontrol ('Style', 'pushbutton', 'String', 'Accept Tags', 'units',...
       'normalized', 'Position', [.665 .35 .2 .06], 'callback', {@AcceptPhrase1Tags}); %button that will allow the user to accept the tag positions, save the tag positions and the range of motion
    
    next = uicontrol ('Style', 'pushbutton', 'String', 'Tag Phrase 2', 'units',...
        'normalized', 'Position', [.78 .18 .2 .06], 'callback', {@TagPhrase2}); %button that will allow the user to accept the tag positions, save the tag positions and the range of motion
    
    
end

%% Callback function to play one phrase
function PlayOnePhrase (object_handle, event) %uses audiofile
global T1
global T2
[y,Fs]   = audioread('SampleAudioData.wav'); %load the audiofile into matlab
if T1 == 0; %if the T1 viewing window is 0 (for the first phrase only)
    audioleft = 1/Fs; %then the left bound for playing audio will be set at 1
else
    audioleft = round(T1); %otherwise, the left bound will be the T1 position rounded to the nearest integer
end

audioright = round(T2); %the right bound for playing audio will be the T2 position rounded to the nearest integer
 samples  = [audioleft*Fs,audioright*Fs]; %shows the start and end point of the audio that needs to be played; only integer values work
 [y,Fs]   = audioread('SampleAudioData.wav', samples); %reads only the selected samples from the audio
 sound(y, Fs); %plays the selected audio
end

%% callback function that allows the user to change the size of the viewing window
function ChangeWindow (object_handle, event, editT1, editT2)
    %global variables
    global T1
    global T2
    global Tag_1_time
    global Tag_2_time
    global Tag_1_line
    global Tag_2_line
    
    string1 = get(editT1, 'string'); %get the string that the user typed for T1 boundary
    NewT1 = str2num (string1); %convert user inputted string into a number
    string2 = get(editT2, 'string'); %get the string that the user typed for T2 boundary
    NewT2 = str2num (string2); %convert user inputted string into a number
    T1 = NewT1 %use user inputted number as the new value for T1
    T2 = NewT2  %use user inputted number as new value for T2 


    subplot(19,1,1, 'position', [0.07,0.89, 0.5, 0.1]); %edit the audio subplot
    [y,Fs] = audioread('SampleAudioData.wav'); %read audiofile to matlab
    time = [1:size(y)]/Fs; %find the time values for the audio data
    plot(time,y); %plot the audio against time
    xlim([T1 T2]); %Change the viewing window to the new user inputted values for T1 and T2
    hold on
    %graph the tags
    x1=[Tag_1_time,Tag_1_time]; %x position for Tag1
    x2=[Tag_2_time,Tag_2_time]; %x position for Tag2
    y_limits=[-0.5,0.5]; %min and max y 
    Tag_1_line = plot(x1,y_limits, 'color', 'm'); %replot tag1
    Tag_2_line = plot(x2, y_limits, 'color', 'm'); %replot tag2
end

%% Callback Function to manually change Tag1
function ChangeTag1 (object_handle, event)
    %global variables
    global Tag_1_time
    global Tag_1_line
    
delete (Tag_1_line); %delete the current Tag1
[New_Tag_1_time,Y] = ginput(1); %allow the user to click where they want the new Tag1 to be
Tag_1_time = New_Tag_1_time; %note down the time value
x1=[Tag_1_time,Tag_1_time]; %x position for Tag1
y_limits=[-0.5,0.5]; %min and max y 
Tag_1_line = plot(x1,y_limits, 'color', 'm'); %plot a new tag1 where desired by the user 
end

%% Callback Function to manually change Tag2
function ChangeTag2 (object_handle, event)
    %global variables
    global Tag_2_time
    global Tag_2_line
    
delete (Tag_2_line); %delete the current Tag2
[New_Tag_2_time,Y] = ginput(1); %allow the user to click where they want the new Tag1 to be
 Tag_2_time = New_Tag_2_time; %note down the time value
 x1=[Tag_2_time,Tag_2_time]; %x position for Tag2
y_limits=[-0.5,0.5]; %min and max y 
Tag_2_line = plot(x1,y_limits, 'color', 'm'); %plot a new tag2 where desired by the user 
end

%% Callback Function to Accept Tag Positions and Save Relevant Information
function AcceptPhrase1Tags (object_handle, event)
global Tag_1_time
global Tag_2_time
global Timings
global SensorData
global sensor_number_TT
global column
global AnalysisMatrix
global TagFilename

  
%Create a text file that will save all of the relevate information
TagFilename = [ 'SampleMotionData-tags.xls']; %name the file based on the inputted motionfile name
fprintf('Saving Tag information to file: %s\n', TagFilename); %show filename in the command line

fileID = fopen(TagFilename, 'w'); 
fprintf(fileID, 'Phrase \t\tTag1\t\t Tag2\t\t RangeX\t\t RangeY\t\t RangeZ\t  \r\n'); %label the column names

%Will be analyzing tongue range for the tongue tip sensor
column = (sensor_number_TT - 1) *3;  %determine column numbers
AnalysisMatrix = [Timings SensorData(:, column+1) SensorData(:, column+2) SensorData(:, column+3)];

%find the row numbers corresponding to the Tag times
for i = 1:length(AnalysisMatrix) 
    if AnalysisMatrix(i, 1) >= Tag_1_time; %find the Timing that is closest to Tag1 time
        time1 = i; %mark this row number
        break
    end
end

for i = 1:length(AnalysisMatrix) 
    if AnalysisMatrix(i, 1) >= Tag_2_time; %find the Timing that is closest to Tag2 time
        time2 = i; %mark this row number
        break
    end
end

%find the range in the x dimension
Maximum = AnalysisMatrix(time1, 2); %Initial max position for x dimension
for i = time1 + 1: time2
    if Maximum < AnalysisMatrix(i,2); %if any x position between the two bounds is higher than the initial maximum, then it will be the new maximum
        Maximum = AnalysisMatrix(i,2);
    end
end
Minimum = AnalysisMatrix(time1, 2); %Initial min position for x dimension
for i = time1 + 1: time2
    if Minimum > AnalysisMatrix(i,2); %if any x position between the two bounds is lower than the initial minimum, then it will be the new minimum
        Minimum = AnalysisMatrix(i,2);
    end
end
RangeX = Maximum - Minimum;

%find the range in the y dimension
Maximum = AnalysisMatrix(time1, 3); %Initial max position for y dimension
for i = time1 + 1: time2
    if Maximum < AnalysisMatrix(i,3); %if any y position between the two bounds is higher than the initial maximum, then it will be the new maximum
        Maximum = AnalysisMatrix(i,3);
    end
end
Minimum = AnalysisMatrix(time1, 3); %Initial min position for y dimension
for i = time1 + 1: time2
    if Minimum > AnalysisMatrix(i,3); %if any y position between the two bounds is lower than the initial minimum, then it will be the new minimum
        Minimum = AnalysisMatrix(i,3);
    end
end
RangeY = Maximum - Minimum;

%find the range in the z dimension
Maximum = AnalysisMatrix(time1, 4); %Initial max position for z dimension
for i = time1 + 1: time2
    if Maximum < AnalysisMatrix(i,4); %if any z position between the two bounds is higher than the initial maximum, then it will be the new maximum
        Maximum = AnalysisMatrix(i,4);
    end
end
Minimum = AnalysisMatrix(time1, 4); %Initial min position for z dimension
for i = time1 + 1: time2
    if Minimum > AnalysisMatrix(i,4); %if any z position between the two bounds is lower than the initial minimum, then it will be the new minimum
        Minimum = AnalysisMatrix(i,4);
    end
end
RangeZ = Maximum - Minimum;

fileID = fopen(TagFilename, 'a');
fprintf(fileID, '1\t %10.3f\t %10.3f\t %10.3f\t %10.3f\t %10.3f\t \r\n', Tag_1_time, Tag_2_time, RangeX, RangeY, RangeZ);
fclose(fileID);
    
end
















