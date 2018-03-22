function [FI, maxEm, HIX, FrI] = F4CorrectFunIISPF(Afile, ifile, bfile, rfile, dilution_factor, correctedpath, uvlenth)

%Make sure you hit save any time you make changes or else it won't yet be
%integrated into the code. 
%USER INPUT
%This is where you input the scan parameters that you used
eminc = 2; %the increment of the emission spectra you collected
exinc = 10; %the increment of the excitation spectra you collected
em = 300:eminc:600; %Emission start wavelength:eminc:emission ending wavelength
ex = 240:exinc:450; %Excitation start wavelength:exinc:excitation ending wavelength
%RamanEnd = 450; %This is the end of your Raman scan, or where you want the 
                %raman scan to end the integration area
%RamanBegin = 365; %Where you want the Raman scan to start integration
                   %Usually 370 but make sure its after your scan starts
                   % This should match the range for the mcRaman correction file input as "RC" in
                   % the RunCorrectionsII code
%RamanInc = 0.5; %The increment on your raman scan                     
            

ExTop=[0,ex]; %Recreates the row of excitation wavelengths cut off when inputting the .dat files

%CODE
emlen = length(em);
exlen = length(ex);

%Read in Raman file, instrument correct, Calculate Area under curve%
%R = dlmread(char(rfile), '\t',2,2); %Reads in Raman file not integrated
%R = dlmread(char(rfile), '\t', 3, 2); %Reads in Raman file integrated

%Trims the old raman files if it's needed from 370 to scan end
%Rfind = find(R == RamanBegin); 
%Rfindend = find(R == RamanEnd);
%Rlen = length(R);
%Raman = R(Rfind:Rfindend,2);


%The section below calculates the area under the raman curve.
%y = Raman;
%x = R(Rfind:Rfindend,1);
%xlen = length(x) - 1;
%summation = 0; 
%iteration=1;

%for i=1:xlen %This integrates from RamanBegin to RamanEnd.
%    y0 = y(i); 
%    y1 = y(i + 1); 
%    dx = x(i+1) - x(i); 
%    summation = summation + dx * (y0 + y1)/2;
%    iteration = iteration+1;
%end
%BaseRect = (y(1)+y(xlen))/2*(x(xlen)-x(1));
%RamanArea = summation - BaseRect

%Read in blank file, instrument correct, Raman normalize
B = dlmread(char(bfile), '', 2, 0); %Reads in Blank EEM file

B=[ExTop ; B]; %Adds the excitation wavelengths back into the Blank file

Bsize = size(B);

emfind = B(:,1);
emstart = find(emfind == em(1));
emend = Bsize(1);

exfind = B(emstart-1,:);
exstart = find(exfind == ex(1));
exend = Bsize(2);

B = B(emstart:emend,exstart:exend);%Removes wavelengths from matrix

%Br=B/RamanArea; %This raman normalizes the corrected blank file.

%Read in sample file, instrument correct, IFE, Raman normalize, Blank subtract

A = dlmread(char(Afile), '\t', 2, 0);  % Reads in raw EEM file in .xls format.

A=[ExTop ; A]; %Adds the excitation wavelengths back into the EEM file

Asize = size(A);

emfind = A(:,1);
emstart = find(emfind == em(1));
emend = Asize(1);

exfind = A(emstart-1,:);
exstart = find(exfind == ex(1));
exend = Asize(2);

A = A(emstart:emend,exstart:exend);

%Ar = A/RamanArea; %This raman normalizes the EEM file.

Asub = minus(A,B); %This blank subtracts the corrected EEM file.

Adil = Asub*dilution_factor; %This applies the dilution factor normalization.

% Save the Raman normalized and correceted EEM matrix (inner filter too).
pathname = correctedpath;

for i=1:length(ifile)

    pathname(length(pathname) + 1) = ifile(i);

end

pathnamelength = length(pathname);

pathname(pathnamelength + 1: pathnamelength + 4) = '.xls';

save(pathname, 'Adil', '-ascii', '-double', '-tabs');

% This next part calculates the fluorescence index

ex370 = find(ex == 370); %Index where excitation is 370
em470 = find(em == 470); %Index where emission is 470
em520 = find(em == 520); %Index where emission is 520

A=Adil'; %Transposes corrected matrix for plotting and FI.

FI = A(ex370, em470)./A(ex370, em520); %Calculates the fluorescence index.

%This part calculates the humification index

%Specifies size of matrix of your EEM
Asize = size(A);
ylen = Asize(1);
xlen = Asize(2);
y = ex;
x = em;
xend = x(xlen);
yend = y(ylen);

%Creates a grid of the EEM pairs you need to interpolate for
[xi yi] = meshgrid(x(1):1:xend,y(1):1:yend);

zi = interp2(x, y, A, xi, yi, 'spline');

%Finds the row with excitation of 254 nm and extracts that data
ex254 = find(yi(:,1) == 254);
line254=zi(ex254,:);


% %Find boundaries for red humic peaks
em435 = find(xi(1,:) == 435);
em480 = find(xi(1,:) == 480);
RedHum = line254(1,em435:em480);

% %find boundaries for blue humic peaks
em300 = find(xi(1,:) == 300);
em345 = find(xi(1,:) == 345);
BlueHum = line254(1,em300:em345);

% %Finds the area under the peaks
RedA = trapz(RedHum);
BlueA = trapz(BlueHum);

%This first code calculates HIX with the updated formula from Ohno(2002)
% HIX = RedA/(RedA+BlueA);

%This calculates HIX using the original formula from Zsolnay(1999).  Ensure
%you have low concentrations of DOC to not have inner filter or
%concentration affects

HIX = RedA/BlueA;

%This part calculates the freshness index

ex310 = find(ex == 310); %index where excitation is 310 nm
em380 = find(em == 380); %index where emission is 380 nm
em420 = find(em == 420); %index where emission is 420 nm
em436 = find(em == 436); %index where emission is 436 nm


%Calculates the Freshness Index
FrI = A(ex310,em380)/max(A(ex310,em420:em436));

% Graph ...

figure(1), clf; %, subplot(2,1,1); This subplot puts the 370ex emission curve on the bottom half of the EEM tiff file.

% set colormap

% set min and max intensity values (to be mapped to min and max colors in

% colormap)

% prevent auto-setting of caxis by changing caxis to manual control

% now draw the graph

contourf(em,ex,A,30); % with 30 contour lines

maxEm = em(find(A(ex370, :) == max(A(ex370, :))));

handle = gca;

set(handle,'fontsize', 14);

colormap(jet);

% caxis sets range for plotting. Change as necessary.

caxis([0, max(max(A))]);

caxis('manual');

H = colorbar('vert');

set(H,'fontsize',14);

xlabel('Emission Wavelength, nm','fontsize',12)

ylabel('Excitation Wavelength, nm','fontsize',12)

title (ifile, 'fontsize', 12); 

% Saves current object, this won't work if you close the figure first.
% This command saves the current object only.
% Enter the path name for the corrected EEM figure to be placed.

pathname = correctedpath;

for i=1:length(ifile)

    pathname(length(pathname) + 1) = ifile(i);

end

pathnamelength = length(pathname);

pathname(pathnamelength + 1: pathnamelength + 4) = '.tif';

saveas(gcf, pathname, 'tif');

close;

figure, plot(em, A(ex370, :), 'k-', 'LineWidth', 2.0), xlabel('Emission Wavelength, nm'), title('Emission at Excitation 370nm');

% % Saves current object, this won't work if you close the figure first.
% % This command saves the current object only.
% % Enter the path name for the corrected EEM figure to be placed.
% 
% pathname = correctedpath;
% 
% for i=1:length(ifile)
% 
%     pathname(length(pathname) + 1) = ifile(i);
% 
% end
% 
% pathnamelength = length(pathname);
% 
% pathname(pathnamelength + 1: pathnamelength + 4) = '.tif';
% 
% saveas(gcf, pathname, 'tif');
% 
% close;
% 
% figure, plot(em, A(ex370, :), 'k-', 'LineWidth', 2.0), xlabel('Emission Wavelength, nm'), title('Emission at Excitation 370nm')