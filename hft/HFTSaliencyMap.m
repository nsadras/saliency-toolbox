%%%%%%%%%%%%%%%%%%%%%%%%%%%%  HFT Saliency Computing  %%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% This computes the HFT saliency map for the input image                  %
% The hypercomplex FFT functions are provided by T. Ell[40]               %
%                                                                         %
% Jian Li. March,2011.                                                    %
%                                                                         %
% Email: lijian.nudt@gmail.com; lijian@cim.mcgill.ca                      %
% --You can use and distribute the code freely. If you use the HFT code   %
% --and the corresponding ROC code, please cite our PAMI paper:           %
% --Visual Saliency Based on Scale-Space Analysis in the Frequency Domain %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SalMap] = HFTSaliencyMap(img)

%% Initializtion 
param=callHFTParams;

%% Load image
if ischar(img)
    inImg1= double(imread (img));
else
    inImg1 = img; % assume that the user is not a psychopath
end

if size(inImg1, 3) == 1
    inImg1 = cat(3, inImg1, inImg1, inImg1);
end
    
[p1,p2,~]=size(inImg1);

%% Resize image so that its smallest dimension is 128px %You are encouraged to try other resolutions, or even learn a optimal image scale by training.
rescaleFactor = min(1, 128 / min(p1, p2));
inImg1 = imresize(inImg1, round(rescaleFactor*[p1 p2]), 'bilinear');

%% Compute input feature maps
r = inImg1(:,:,1);
g = inImg1(:,:,2);
b = inImg1(:,:,3); 

I = mean(inImg1,3);
%I=max(max(r,g),b); % Results by "mean" are slightly different from that by "max"; Please try both of them for better results. We use "mean" for quantitative evaluation.

R = r-(g+b)/2;
G = g-(r+b)/2;
B = b-(r+g)/2;
Y = (r+g)/2-abs(r-g)/2-b;
Y(Y<0) = 0;
RG = double(R - G);
BY = double(B - Y);

%% Compute the Hypercomplex representation
f = quaternion(0.25*RG, 0.25*BY, 0.5*I);  % the default weights for each feature map are 0.25 0.25 0.5

%% Compute the Scale space in frequency domain
[M,N]=size(r);
S=MSQF(f,M,N);

%% Find the optimal scale
[~,W,~]=size(inImg1);
for k=1:8 
      entro(k)=entropy1((S(:,:,k)));     %if run HFT, please use this line;
%     entro(k)=entropy2((S(:,:,k)));     %if run HFT(e), please use this line
end
entro_seq=sort(entro); 
c=find(entro==entro_seq(1));
c=c(1);
SalMap=mat2gray(S(:,:,c));

%% Postprocessing
%-------------
%incorperate a border cut. A border cut could be employ to alleviate the
%problem caused by the border effect. However the unfairness will be
%introduced when make comparison. In our paper, the border cut is not used.
if param.openBorderCut == 1
    SalMap=bordercut(SalMap,param.BorderCutValue);
end
%-------------
sgm=W*param.SmoothingValue;
SalMap = imfilter(SalMap, fspecial('gaussian',[round(4*sgm) round(4*sgm)],sgm));
SalMap = imresize(SalMap, [p1,p2], 'bilinear');
%-------------
%incorperate a global center bias
%However, we think that center bias has little significace, but only inrease
%ROC score. In our paper, the center bias is not incorperated.
if param.setCenterBias == 1
SalMap=CenterBias(SalMap,param.CenterBiasValue);
end
%-------------
SalMap=mat2gray(SalMap);

end

