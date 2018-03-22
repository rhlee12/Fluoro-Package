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
%uvpath = 'C:\Users\maggi_000\Documents\PARAFAC\Data\UV Scans\'; %Enter the path for location of your UV files in csv format
correctedpath = 'C:\Users\maggi_000\Documents\PARAFAC\Data\Corrected EEMs\'; %Enter the path where the corrected EEMs will be saved
blankpath = 'C:\Users\maggi_000\Documents\PARAFAC\Data\Blanks\'; %Enter the path where the blank files from the fluorometer are
ramanpath = 'C:\Users\maggi_000\Documents\PARAFAC\Data\Raman Scans\'; %Enter the path where the raman files from the fluorometer are
% All path locations should end with either "/" or "\" depending on your
% computer operating system

   

    %Read input file
    % for the input file, make an excel file (use the CorrectionInputsIINFO.xls
    % to figure out what goes in what column, then save it as a text file and 
    % input the path below.)
fid = fopen('C:\Users\maggi_000\Documents\PARAFAC\Data\CorrectionsInputIISPF.txt'); %path for correction inputs spreadsheet
text = textscan(fid, '%s%s%s%s%n%n');
textlen = length(text{1,1}); %This should be the number of samples you have
n = 1;
%END USER INPUT


%CODE
%RUN CORRECTION CODE ON EACH FILE
for n = 1:textlen

    Afile = sprintf('%s%s', char(text{1,1}(n)), '.dat'); %Name of exported raw EEM

    ifile = sprintf('%s%s', char(text{1,2}(n))); %Name of corrected file to save
    
    bfile = sprintf('%s%s%s', blankpath, char(text{1,3}(n)), '.dat'); %Name of blank file
    
    rfile = sprintf('%s%s%s', ramanpath, char(text{1,4}(n)), '.dat'); %Name of raman file
    
    dilution_factor = text{1,5}(n); %Input dilution factor
    
    uvlength = text{1,6}(n);
     
    [FI(n), maxEm(n), HIX(n), FrI(n)] = F4CorrectFunIISPF(Afile, ifile, bfile, rfile, dilution_factor, correctedpath, uvlength); 
    %Save out corrected EEM and fluorescence index as well as abs254
    fprintf('Progress: File number ')
    n
end

%SAVE FLUORESCENCE INDEX TABLE
FI = FI'; %Transpose of FI
maxEm = maxEm';
HIX=HIX';
FrI=FrI';
data = [FI maxEm HIX FrI];
path = correctedpath
FIfile = 'FI.txt';

for i=1:length(FIfile)
    path(length(path) + 1) = FIfile(i);
end

save (path, 'data', '-ASCII', '-tabs');  %Saves column of fluorescence index values to FI.txt in the corrected EEM directory. The second column is the wavelength (nm)
% of max emission at an exciation of 370nm.  The third column is the
% absorbance at 254 nm.n
