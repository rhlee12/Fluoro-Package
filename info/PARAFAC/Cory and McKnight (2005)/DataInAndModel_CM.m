%function [X] = DataInAndModel_CM(mm)

%This code builds a matrix of corrected EEMs and then applied the Penobscot
%Bay PARAFAC model.  The code graphs two samples with the corrected EEM on
%the left, Modeled EEM on the right, and the residual (difference between the
%two) on the bottom of the figure.  All graphs are saved to the folder
%designated in line 150.  The code also outputs a text file containing
%the loadings for A, B, and C.  The code also outputs a text file
%containing the fmax values (= fmax factors * PARAFAC loadings).


ex = 240:10:450; %Type in the ex and em ranges and increments that you collected your samples at
em = 300:2:550;
%
% e cut). Must be a multiple of 5!

%This code creates the bigMatrix for modeling
%if (mm == 1)
    bigMatrix = combineSampleFiles2('*.xls', ex, em);
%else bigMatrix = combineSampleFiles3PB(EEMdir, inputSS, sheetname, lastrow, first_emIdx, last_emIdx, first_exIdx, last_exIdx);
%end

%pause

nsamples = size(bigMatrix,1); %Determines the number of samples in the bigMatrix

load 'PARAFAC5.mat'; %STEP 1 for use with EEMs collected ex every 5 nm

% load 'em.txt'; %Step 2
% load 'ex.txt'; %Step 2
% Em=em; %Step 2
% Ex=ex; %Step 2

T = bigMatrix;  %Step 3

%Use code below to trim EEMs combined using another method
%T = bigMatrix(:,26:126,3:43);%trimming the matrix to the dimensions of the model(sample,em,ex)
%T = bigMatrix(:,26:126,3:23); %Use this for Ex every 10 nm
%re organising the data matrix
%X=(reshape(X',43,151,20));
%X=permute(X,[3 2 1]);

%T=T(:,:,3:33);  %Step 4
%Ex=250:5:450; %Step 4
% Em=350:2:550; %Step 4


%%%%%%%%%%%%%%%%%%%%%%
% This code plots the corrected EEMs 9 to a page
% for i=(1:9:nsamples) %Upper limit should be the number of samples here.
% figure;  %Step 5
% for j = 1:9
%     try
% subplot(3,3,j),
% contourf(data.Ex,data.Em,(reshape(T((i+j-1),:),101,41))), colorbar
% xlabel('Ex. (nm)')
% ylabel('Em. (nm)')
% title(i+j-1)
%     catch
%     end
% end
% end

data.Ex = Ex;
data.Em = Em;

%remove first and second order rayleigh scatter
T = EEMCutPB(T, data, 20, 20, 20, 120, '');

%making ALL dataset
all=[T.X(1:nsamples,:,:)]; %Step 9

%%%%%THINK BE CAREFUL%%%%%%
% save 'C:\PARAFAC_code\parafac_1_Fit.mat';
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load 'C:\PARAFAC_code\PARAFAC5.mat';   %STEP 1

[A,B,C]=fac2let(Fac_val_e6_13);  %Step 10
A=rand(nsamples,13);
Oldload={A;B;C};
Oldload=Oldload';
clear A B C;

[Fac_all_13]=PARAFAC(all,13,[1e-6 1 1],[2 2 2],Oldload,[0 1 1]);  %Step 11

M = cutflu2(nmodel(Fac_all_13),data.Em,data.Ex,0,0);  %Step 12
E=all-M;
M=all-E;
RP=E./all*100;

fall=permute(all,[1,3,2]);  %Step 13
Egraph=permute(E,[1,3,2]);
M=permute(M,[1,3,2]);
RP=permute(RP,[1,3,2]);

%This is the text file for graphing with names below.
fid = fopen('Location of Graph Headings files', 'r+'); %must end with .txt
text = textscan(fid, '%s');
names = text{1,1};

for i=(1:nsamples), figure;
subplot(2,2,1),
contourf(data.Em,data.Ex,(reshape(fall(i,:),31,101)), 10), axis tight, colorbar
xlabel('Emission (nm)')
ylabel('Excitation (nm)')

subplot(2,2,2),
contourf(data.Em,data.Ex,(reshape(M(i,:),31,101)), 10), axis tight, colorbar
xlabel('Emission (nm)')
ylabel('Excitation (nm)')

subplot(2,2,4),
contourf(data.Em,data.Ex,(reshape(RP(i,:),31,101)), 10), axis tight, colorbar
xlabel('Emission (nm)')
ylabel('Excitation (nm)')

subplot(2,2,3),
contourf(data.Em,data.Ex,(reshape(Egraph(i,:),31,101)), 10), axis tight, colorbar
xlabel('Emission (nm)')
ylabel('Excitation (nm)')

pathnamegraph = 'Location to save PARAFAC Results';%Must end with / or \ depending on your OS
ifile = sprintf('%s%s', char(names(i,1)));
    for j=1:length(ifile)
        pathnamegraph(length(pathnamegraph) + 1) = ifile(j);
    end
    res = '_residual';
    pathnameres = pathnamegraph;
    for j=1:length(res)
        pathnameres(length(pathnameres) + 1) = res(j);
    end
    xlswrite(pathnameres, squeeze(E(i,:,:)));
    saveas(gcf,pathnamegraph,'jpg');
    close

end

clear M E Oldload; %Step 15


[A,B,C]=fac2let(Fac_all_13);  %Step 16

%The following code gives fmax values from the loadings in A.

%Fmax = [0.058487607	0.039157667	0.041923643	0.053320303	0.111283143	0.071241378	0.055665316];

% for i = 1:7 %Columns
%     for j = 1:length(A) %Rows
%         Fmaxout(j,i) = A(j,i)*Fmax(i);
%     end
% end

%save 'Fmax.txt' Fmaxout -ascii -double -tabs;
save 'A.txt' A -ascii -double -tabs;  %Step 17
save 'B.txt' B -ascii -double -tabs;  %Step 17
save 'C.txt' C -ascii -double -tabs;  %Step 17
clear A B C Fmax;


