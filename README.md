# Automatic-Sound-and-Motion-Data-Parsing

PURPOSE:
- This is a software program that is used to automatically parse audio and motion data obtained from ALS patients by the University of Texas at Dallas. It was developed for use of the Speech Disorders and Technology lab run by Dr. Jun Wang.
- ALS Speech Data is collected in approximately 45 second soundbites composed of 20 commonly used phrases. These phrases need to be separated for data analysis by adding tags at the beginning and end of each phrase; the audio and motion data (of the patient's tongue movement) will be parsed and extracted between each pair of tags.
- This program separates the phrases by an algorithm that detects speech from noise using a baseline auditory threshold
- The process of manual data parsing for this type of data with a high level of precision takes approximately 2 hours per patient dataset. This software program enables the same task to be completed under 5 minutes.

HOW TO RUN THE SOFTWARE:
- Download the entire folder (including MATLAB code and sample data)
- Set the MATLAB path to the downloaded folder
- Type ALSPhraseParsing in the MATLAB interactive workspace to initiate the program
- Click through the GUI to observe how the program works.You can start by playing all of the audio and beginning the parsing process by clicking 'Begin Tagging'. 
- There is an information button on the GUI that will provide more instructions

DISCLAIMER:
- The following version of this Automatic Parsing program is abridged and loads sample data only
- The full version of this software along with patient data is owned by the University of Texas at Dallas
