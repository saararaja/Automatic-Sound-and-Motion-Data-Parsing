%function to analzye the change in tongue range over time in ALS patients

function AnalyzeALSRange (Session1File, Session2File, Session3File, Session4File)

Session1Data = xlsread(Session1File);
Session2Data = xlsread(Session2File);
Session3Data = xlsread(Session3File);
Session4Data = xlsread(Session4File);

%Range for Phrase 1
RangeX = [Session1Data(2,4) Session2Data(2,4) Session3Data(2,4) Session4Data(2,4)];
RangeY = [Session1Data(2,5) Session2Data(2,5) Session3Data(2,5) Session4Data(2,5)];
RangeZ = [Session1Data(2,6) Session2Data(2,6) Session3Data(2,6) Session3Data(2,6)];


figure;
hold on
x = plot(RangeX, 'gd-', 'linewidth', 2, 'markersize', 10);
y = plot(RangeY,  'cd-', 'linewidth', 2, 'markersize', 10);
z = plot(RangeZ, 'md-', 'linewidth', 2, 'markersize', 10);
leg=legend([x y z], {'X' 'Y' 'Z'});
title ('Change in Tongue Range: Phrase 1', 'fontsize', 14);
ylabel ('Tongue Range (mm)', 'fontsize', 14);
xlabel ('Session Number', 'fontsize', 14);
set(gca, 'xtick', 1:1:4);
end