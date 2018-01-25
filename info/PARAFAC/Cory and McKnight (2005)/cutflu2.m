function Xnew = cutflu(X,EmAx,ExAx,Cut1,Cut2)
%function Xnew = cutflu(X,EmAx,ExAx,Cut1,Cut2)
% 
% Puts in NaN-values in a diagonalway.
% INPUT:
%    X      The X-array from the fluoressence spectra
%    EmAx   The Emitation Axis
%    ExAx   The Excitation Axis
%    Cut1   The extra cut at the beginning
%    Cut2   The extra cut at the end

%X = reshape(X,DimX);

for j = 1:length(ExAx)
   i = find(EmAx<(ExAx(j)+Cut1));
   X(:,i,j)=NaN;
end

Xnew=X;
%Xnew = reshape(X,DimX(1),prod(DimX(2:3)));
