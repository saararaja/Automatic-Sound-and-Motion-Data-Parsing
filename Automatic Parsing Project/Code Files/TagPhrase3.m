function TagPhrase3 (object_handle, event) %inputs for this function include all the same variables
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


%% Phrase 3 boundaries

for row = new_start:length(TimeMatrix); %loop starts from first row of audio data
   
    if TimeMatrix(row,2) > 0.03; %when absolute value of audio is greater than 0.03 amplitude, the sound is most likely the patient's voice and not static noise
        
        t1 = TimeMatrix(row,1);  %time corresponding to the beginning of the patient vocals 
        new_start = row+1;  %next loop will begin where this loop ended
        break %this loop will be broken when a beginning boundary is set and the next loop will begin to set an ending boundary
    end
    
end

    T1 = t1 - 0.4; %if there is 0.4 seconds then this will be the window of observation

t1; %reveal t1
T1;%reveal T1


%Now we will look for the end boundary and end viewing window for the third phrase
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

Minimum = LL_Matrix(tag_bound_1, 2); %The phrase begins when TB is at a maximum. Place the initial maximum position
for i = tag_bound_1 + 1: tag_bound_2
    if Minimum > LL_Matrix(i,2); %if any y position between the two bounds is lower than the initial minimum, then it will be the new minimum
        Minimum = LL_Matrix(i,2);
    end
end

[I, J] = find (LL_Matrix == Minimum); %find the row number for the minimum y value
Tag_1_time = LL_Matrix(I,1); %Note down the time for this minimum y value. This will be the position of the first tag.

%Tag 2 loops:
for i = 1:length(TT_Matrix) 

    if TT_Matrix(i, 1) >= t2; %find the Timing that is closest to t2
        tag_bound_3 = i; %mark this row number
        break
    end
end

for i = 1:length(TT_Matrix)
    
    if TT_Matrix (i,1) >= T2; %find the Timing that is closest to T2
        tag_bound_4 = i; %mark this row number
        break
    end
end

Maximum = TT_Matrix(tag_bound_3, 2); %The phrase ends when the tongue tip is at a maximum. Place the initial maximum
for i = tag_bound_3 + 1: tag_bound_4
    if Maximum < TT_Matrix(i,2); %if any y position between the two bounds is higher than the initial maximum, then it will be the new maximum
        Maximum = TT_Matrix(i,2);
    end
end

[I, J] = find (TT_Matrix == Maximum); %find the row number for the maximum y value
Tag_2_time = TT_Matrix(I,1); %Note down the time for this maximum y value. This will be the position of the second tag.

%% Build the User Interface
   
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
    
    
    %% User Interface Controls
    
    accept = uicontrol ('Style', 'pushbutton', 'String', 'Accept Tags', 'units',...
        'normalized', 'Position', [.665 .35 .2 .06], 'callback', {@AcceptPhrase3Tags}); %button that will allow the user to accept the tag positions, save the tag positions and the range of motion
    
    next = uicontrol ('Style', 'pushbutton', 'String', 'Finish', 'units',...
        'normalized', 'Position', [.78 .18 .2 .06], 'callback', {@Finish}); %button that will allow the user to accept the tag positions, save the tag positions and the range of motion
    
end



%% Callback Function to Accept Tag Positions and Save Relevant Information
function AcceptPhrase3Tags (object_handle, event)
global Tag_1_time
global Tag_2_time
global Timings
global SensorData
global sensor_number_TT
global column
global AnalysisMatrix
global TagFilename
  
%Create a text file that will save all of the relevate information
fprintf('Saving Tag information to file: %s\n', TagFilename); %show filename in the command line

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
fprintf(fileID, '3\t %10.3f\t %10.3f\t %10.3f\t %10.3f\t %10.3f\t \r\n', Tag_1_time, Tag_2_time, RangeX, RangeY, RangeZ);
fclose(fileID);

end

function Finish (object_handle, event)
close all
end

