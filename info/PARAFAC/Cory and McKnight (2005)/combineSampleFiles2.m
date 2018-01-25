function [X] = combineSampleFiles2(fpattern, ex, em)
% fpattern is the file pattern.  For example, to combine samples in xls 
% files in a given directory, fpattern should be '*.xls'
% 
% Usage: 
% At the console in the matlab command window, type: BigMatrix = combineSampleFiles2('*.xls');
% The data from all the EEM files in the set directory will be stored in BigMatrix 
%
% P.S. You don't have to really call it BigMatrix. 
%
% Written by Celeste Johanson on a cool summer evening in August 2006
% (64.5F on the roof tonight.)
% Edited by Kaelin Cawley for the 6/09 fluorescence workshop
fpattern = '*.xls';
filenames = dir(fpattern);

%creating a structure to hold the filenames.  It is really just an vector
%of filenames. Don't panic!
sortingMatrix = struct('name', {});   
i=1;
% sort the file names

for i=1:length(filenames)
    currname = filenames(i).name;               %name of the file for this loop iteration
    endindex = find(currname == '.') - 1;       %the index of the . in the file.  I assume there is only 1 .
    startindex = find(currname == '_') + 1;     %the index of the underscore in the file.  Again, assuming only 1
    
    filenumber = currname(startindex:endindex); %the file number found inbetween the _ and the . in the file name
    %this is how the filenames are sorted.  I put the filename in a matrix in 
    %the position corresponding the the filenumber.  It is OK to have
    %filenumbers that are non sequential, i.e. 1, 2, 4.  This will make a
    %vector of length 4 where the 3rd entry is blank.  Blank names are
    %ingored in the next loop.  
    sortingMatrix(str2num(filenumber)).name = char(currname);                
end

% OK!  Now loop through the sorted filenames
for i=1:length(sortingMatrix)
    currname = sortingMatrix(i).name;
    % check to make sure the filename isn't empty.  
    if(length(currname) > 3)  
        
        %load the file and put the contents into the big 3-D matrix.  
        currfile = load(currname); %change to load ?
        
        %Sets up the range to cut out for C&M 2005 or whichever model you
        %want ot apply
        
        exstart = find(ex == 250);
        exend = find(ex == 400);
        emstart = find(em == 350);
        emend = find(em == 550);
        
        MatrixPrelim=currfile(emstart:emend,exstart:exend); %ex240-450 every 10 and em 350-550 every 2
        
        %This loop interpolates for the ex every 5nm instead of every 10 nm
        loopend = length(350:2:550);
        for k = 1:loopend
            MatrixPrelimint(k,:)=Interp1(250:10:400,MatrixPrelim(k,:),250:5:400);
        end
        
        bigMatrix(i,:,:)=MatrixPrelimint;
        
        clear currfile; 
    end
end

X = bigMatrix; 