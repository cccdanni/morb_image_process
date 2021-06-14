%% Basic Info
% Project: MFORB
% Function: standardize stimuli with SHINE toolbox
% Author: Chen Danni
% Update date: May-04-2021

shinetoolbox_path = "C:\toolbox\SHINEtoolbox";
addpath (shinetoolbox_path);

parentFolder = "C:\Users\Psychology\Desktop\MFORB\exp3\stim";
cd ( parentFolder );

rawstimFolder = fullfile( parentFolder, "stim_raw");
greyscaledFolder = fullfile( parentFolder, "stim_greyscaled");
normedFolder = fullfile( parentFolder, "stim_norm");
if ~exist(normedFolder)
    mkdir(normedFolder);
end

cd ( rawstimFolder );
figureNames = dir ("*.png");

%% grey scale image
for i = 1: length(figureNames)
    thisFigName = figureNames(i).name;
    thisFig = imread ( thisFigName);
    fprintf(['Size of ', thisFigName, '  :  ', num2str(size(thisFig)) '\n']);
    newFig  = rgb2gray(thisFig);
    imwrite(newFig, strcat(greyscaledFolder, '\nomask_gs_', thisFigName));
    % Not consistent size: morph_ca07_ch08_n_g (251,201);
end

%% normalize image with SHINE toolbox
cd (greyscaledFolder);
images = {};
badIMNames = 'gs_morph_ca07_ch08_n_f.png';
figureNames = dir ("*.png");
for i = 1:length(figureNames)
    thisFigName = figureNames(i).name;
    if (~strcmp (thisFigName, badIMNames))
        images{i} = imread( thisFigName);
    end
end
newimages = SHINE(images);

% Condition 1: 
% SHINE options    [1=default, 2=custom]: 2
% Matching mode    [1=luminance, 2=spatial frequency, 3=both]: 1
% Luminance option [1=lumMatch, 2=histMatch]: 1
% Matching region  [1=whole image, 2=foreground/background]: 2
% Segmentation of: [1=source images, 2=template(s)]: 1
% Image background [1=specify lum, 2=find automatically (most frequent lum in the image)]: 1
% Enter lum value  [integer between 0 and 255]: 255

% **** Condition 2 ****:
% SHINE options    [1=default, 2=custom]: 2
% Matching mode    [1=luminance, 2=spatial frequency, 3=both]: 1
% Luminance option [1=lumMatch, 2=histMatch]: 2
% Optimize SSIM    [1=no, 2=yes]: 2
% Matching region  [1=whole image, 2=foreground/background]: 2
% Segmentation of: [1=source images, 2=template(s)]: 1
% Image background [1=specify lum, 2=find automatically (most frequent lum in the image)]: 1
% Enter lum value  [integer between 0 and 255]: 255

% Condition 3:
% SHINE options    [1=default, 2=custom]: 2
% Matching mode    [1=luminance, 2=spatial frequency, 3=both]: 3
% Matching of both [1=hist&sf, 2=hist&spec, 3=sf&hist, 4=spec&hist]: 1
% Optimize SSIM    [1=no, 2=yes]: 2
% # of iterations? 1
% Matching region  [1=whole image, 2=foreground/background]: 2
% Segmentation of: [1=source images, 2=template(s)]: 1
% Image background [1=specify lum, 2=find automatically (most frequent lum in the image)]: 2
%  
% Number of images: 2
%  
% Option:   histMatch & sfMatch with 1 iteration(s)
% Option:   histMatch separately for the foregrounds and backgrounds (background = all regions of lum 0)
% Progress: histMatch successful
% Progress: sfMatch successful

% Condition 4
% SHINE options    [1=default, 2=custom]: 2
% Matching mode    [1=luminance, 2=spatial frequency, 3=both]: 1
% Luminance option [1=lumMatch, 2=histMatch]: 2
% Optimize SSIM    [1=no, 2=yes]: 1
% Matching region  [1=whole image, 2=foreground/background]: 2
% Segmentation of: [1=source images, 2=template(s)]: 1
% Image background [1=specify lum, 2=find automatically (most frequent lum in the image)]: 2
%  
% Number of images: 2

for i = 1:length(figureNames)
    thisFigName = figureNames(i).name;
    thisFig = newimages{i};
    fprintf(['Size of ', thisFigName, '  :  ', num2str(size(thisFig)) '\n']);
    imwrite(thisFig, strcat(normedFolder, '\norm_condition2_', thisFigName));
end

% Hist Match Mask Figure
mask_images = {};
mask_images{1} = imread('C:\Users\Psychology\Desktop\MFORB\exp3\stim\stim_raw\WhiteMask.png');
template_images = imread('C:\Users\Psychology\Desktop\MFORB\exp3\stim\stim_norm\Method2_Norms_withoutMask_addMaskAfterWards\norm_condition2_nomask_gs_CH_N_M_02.png');
maskMatrix = zeros(size(mask_images{1},1), size(mask_images{1},2));
tmp = mask_images{1};
tmp = tmp (:,:,1);
maskMatrix(tmp~=0)=1;
matchedMaskImages = histMatch(mask_images, 1, imhist(template_images), maskMatrix);
figure;
imshow(matchedMaskImages{1});
saveas(gcf,strcat(normedFolder, '\histmatch_mask.png'))
LumMaskImages = lumMatch(mask_images, maskMatrix, [124.4479, 73.9630]);
figure;
imshow(LumMaskImages{1});
saveas(gcf,strcat(normedFolder, '\lummatch_mask.png'))


%% check luminance distribution
cd(normedFolder);
figureNames = dir ("*.png");
for i = 1:length(figureNames)
    thisFigName = figureNames(i).name;
    thisFig = imread ( thisFigName);
    figure;
    imhist(thisFig);
    saveas(gcf,strcat(normedFolder, '\hist_', thisFigName, '.png'))
end