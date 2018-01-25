%RunCorrections.m
%Originally written by Laurel Larsen, 5/25/07
%Update for the 6/09 fluorescence workshop by Kaelin Cawley, 6/18/09
%Update for the 4/2010 fluorescence workshop by Rachel Gabor, Bailey Simone,
%and Mike SanClements

%Make sure you hit save any time you make changes or else it won't yet be
%integrated into the code. 
%Run this code 1st and have CorrectFunII also open, as it will call the code.
%Set the current directory to the folder with your raw eems. Also have this
%code and CorrectfunII in that same folder. Also must create an input text 
%file that the code reads in (see CorrectionInputsIINFO.xls for a guide of what
%info needs to be included). 
%It saves the corrected EEMs.  The code also calculates and saves FI.
%Users should pay attention to the USER INPUT section in this code and in 
%CorrectFunII code!


%Notes on directories: Put this code, CorrectFun.m, and the instrument 
%correction files in the directory with the raw EEM files prior to running the code. 

clear
clc
close all

%USER INPUT
uvpath = 'UV path location'; %Enter the path for location of your UV files in csv format
correctedpath = 'Path location to save corrected EEMs'; %Enter the path where the corrected EEMs will be saved
blankpath = 'FL blank location'; %Enter the path where the blank files from the fluorometer are
ramanpath = 'FL Raman location'; %Enter the path where the raman files from the fluorometer are
% All path locations should end with either "/" or "\" depending on your
% computer operating system

    % Read in correction files (mcorrect & xcorrect) 
    % These are instrument specific so make sure you have them for the right
    % instrument
    % Ensure xcorrect is in the correct format [see Rose Cory, et al.
    % Effect of Instrument-specific response on the analysis of fulvic acid
    % fluorescence spectra.  Limnology and Oceanography: Methods. 8, 2010,
    % 67-78 -- both article and supporting information]
    % Ensure the ranges and increments for the correction files match those
    % of your scans

MC = xlsread('location of emission correction file');  %Emission Correction
XC = xlsread('location of excitation correction file'); %Excitation Correction
RC = xlsread('location of raman correction file'); %Raman Correction
%Correction files should all end in .xls


X=diag(XC);
Y=diag(MC);

    %Read input file
    % for the input file, make an excel file (use the CorrectionInputsIINFO.xls
    % to figure out what goes in what column, then save it as a text file and 
    % input the path below.)
fid = fopen('Location of input file'); %path for correction inputs spreadsheet
%input file should end in .txt
text = textscan(fid, '%s%s%s%s%s%n%n');
textlen = length(text{1,1}) %This should be the number of samples you have
n = 1;
%END USER INPUT


%CODE
%RUN CORRECTION CODE ON EACH FILE
for n = 1:textlen

    Afile = sprintf('%s%s', char(text{1,1}(n)), '.xls'); %Name of exported raw EEM

    ifile = sprintf('%s%s', char(text{1,3}(n))); %Name of corrected file to save
    
    bfile = sprintf('%s%s%s', blankpath, char(text{1,5}(n)), '.xls'); %Name of blank file
    
    rfile = sprintf('%s%s%s', ramanpath, char(text{1,4}(n)), '.xls'); %Name of raman file

    uvfile = sprintf('%s%s%s', uvpath, char(text{1,2}(n)), '.CSV'); %Name of UV file

    dilution_factor = text{1,6}(n); %Input dilution factor
    
    uvlength = text{1,7}(n); %Input uv pathlength (in cm)
    
    [FI(n), maxEm(n), abs254(n), HIX(n), FrI(n)] = CorrectFunII(X, Y, RC, Afile, ifile, uvfile, bfile, rfile, dilution_factor, correctedpath, uvlength); %Save out corrected EEM and fluorescence index as well as abs254
    name{n} = ifile; 
    fprintf('Progress: File number ')
    n
end

%SAVE FLUORESCENCE INDEX TABLE
FI = FI'; %Transpose of FI
maxEm = maxEm';
abs254 = abs254';
HIX = HIX';
FrI = FrI';
name = name';
data = [FI  maxEm abs254 HIX FrI];
path = correctedpath;
FIfile = 'Index.txt'

for i=1:length(FIfile)
    path(length(path) + 1) = FIfile(i);
end

save (path, 'data', '-ASCII', '-tabs');  %Saves column of fluorescence index values to FI.txt in the corrected EEM directory. The second column is the wavelength (nm)
% of max emission at an exciation of 370nm.  The third column is the
% absorbance at 254 nm.