%This code was written to compile and average the residuals of samples with
%high residuals when modeled with the C&M (2005) model.

Ex = 250:5:400;
Em = 350:2:550;

%Inputs for use with combineSampleFiles3.m (may need to be changed)
lastrow = 54; %Last sample row on excel spreadsheet
EEMdir = 'C:\Documents and Settings\Kaelin\My Documents\PARAFAC_model\PARAFAC Results\PB\C&M\'; %Insert the directory for the EEMs here
inputSS = 'C:\Documents and Settings\Kaelin\My Documents\PARAFAC_model\PARAFAC Results\PB\PB output.xls'; %Insert complete filename of input spreadsheet
sheetname = 'high C6 for residual'; %Insert name of the appropriate sheet of the above spreadsheet. Usually this will just be 'Sheet1'
% 
% %These wavelengths crop the EEMs to the same size as the EEMs used to validate the PB PARAFAC model if using combineSampleFiles3.m
first_emIdx = find(Em == 350); %The first emission wavelength to crop to in the model. Use 300 when beginning (no data will be cut). Must be an even number!
last_emIdx = find(Em == 550); %The last emission wavelength to crop to in the model. Use 600 when beginning (no data will be cut). Must be an even number!
first_exIdx = find(Ex == 250); %The first excitation wavelength to crop to in the model. Use 240 when beginning (no data will be cut). Must be a multiple of 5!
last_exIdx = find(Ex == 400); %The last excitation wavelength to crop to in the model. Use 450 when beginning (no data will be cut). Must be a multiple of 5!

bigMatrix = combineSampleFiles3PB(EEMdir, inputSS, sheetname, lastrow, first_emIdx, last_emIdx, first_exIdx, last_exIdx);

summ = zeros(101,31);
for j = 1:101
    for k = 1:31
        for i = 1:53
            summ(j,k) = summ(j,k) + bigMatrix (i,j,k);
        end
    end
end
Avg = summ/53;

figure;
contourf(Em,Ex,Avg, 10), axis tight, colorbar
xlabel('Emission (nm)')
ylabel('Excitation (nm)')


xlswrite(Avg,outfile)
