% Project: MFORB
% Function: export processed mask and export figure information (luminance distribution, luminance mean and std.)
% mask stimuli with matched luminance
% Author: Chen Danni, dnchen@connect.hku.hk
% Update date: May-23-2021

%% define folder
clear;clc;

shinetoolbox_path = "C:\toolbox\SHINEtoolbox";
addpath (shinetoolbox_path);

parentFolder = "C:\Users\Psychology\Desktop\MFORB\exp3\stim";
cd ( parentFolder );

rawstimFolder = fullfile( parentFolder, "original_stim");
greyscaledFolder = fullfile( parentFolder, "processed_stim", "step1_greyscaled");
normedFolder = fullfile( parentFolder, "processed_stim", "step2_normalized");
normedInfoFolder = fullfile( parentFolder, "processed_stim", "step3_normalizedInfo");
processedMaskFolder = fullfile( parentFolder, "processed_stim", "step4_processedMask");

original_mask_figure = imread (strcat(rawstimFolder, '\WhiteMask.png'));
[~, ~, original_mask_alpha] = imread (strcat(rawstimFolder, '\WhiteMask.png'));
greyscaled_mask_figure = rgb2gray(original_mask_figure);

%% process normalized stimuli
if ~exist(normedInfoFolder)
    mkdir(normedInfoFolder);
end
cd (normedInfoFolder);

oneback_task_folder1 = "oneback_60\24old";
oneback_task_folder2 = "oneback_60\36new";
pv_task_folder1 = "PV_120\A";
pv_task_folder2 = "PV_120\C";
SCT_AMP_task_folder = "SCT_AMP";
folder_list = {oneback_task_folder1, oneback_task_folder2, pv_task_folder1, pv_task_folder2, SCT_AMP_task_folder};

for j = 1:numel(folder_list)
    
    thisfolder = string(folder_list(j));
    thisfigureNames = dir (strcat (normedFolder, '\', thisfolder, "\*.png"));
    thisFigDir = strcat (normedFolder, '\', thisfolder);
    thisfigureInfo = struct;
    
    thisLumInfoFolder = strcat (normedInfoFolder, '\', thisfolder);
    if ~exist(thisLumInfoFolder)
        mkdir(thisLumInfoFolder);
    end
    
    thisMaskFolder = strcat(processedMaskFolder, '\', thisfolder);
    if ~exist(thisMaskFolder)
        mkdir(thisMaskFolder);
    end
    
    for i = 1:numel(thisfigureNames)
        
        thisFigName = thisfigureNames(i).name;
        thisFig = imread ( strcat(thisFigDir, '\', thisFigName));
        [~,~,thisAlpha] = imread ( strcat(thisFigDir, '\', thisFigName));
        thislummean = mean2(thisFig(thisAlpha~=0));
        thislumstd  = std2(thisFig(thisAlpha~=0));
        
        %% Basic Info
        thisfigureInfo(i).ID = i;
        thisfigureInfo(i).figureName = thisfigureNames(i).name;
        thisfigureInfo(i).figureFolder = thisfigureNames(i).folder;
        thisfigureInfo(i).luminance_Mean_All = thislummean;
        thisfigureInfo(i).luminance_Std_All = thislumstd;
        
        %% luminance distribution        
        figure;
        imhist(thisFig(thisAlpha~=0));
        title(strcat("luminance distribution: ", thisfigureNames(i).name));
        saveas(gcf,strcat(thisLumInfoFolder, '\hist_', thisFigName, '.png'));
        close all;
        
        %% Match Mask Figure
        [h w] = size ( thisFig);
        thisFigLowerHalf = thisFig(h/2:h, 1:w); % 5/25 Update: lower half
        thisAlphaLowerHalf = thisAlpha(h/2:h, 1:w); % 5/25 Update: lower half
        thisMeanLowerHalf = mean2 (thisFigLowerHalf(thisAlphaLowerHalf~=0));
        thisStdLowerHalf = std2 (thisFigLowerHalf(thisAlphaLowerHalf~=0));
        thisfigureInfo(i).luminance_Mean_LowerHalf = thisMeanLowerHalf;
        thisfigureInfo(i).luminance_Std_LowerHalf  = thisStdLowerHalf;
        
        thisFigUpperHalf = thisFig(1:h/2, 1:w);
        thisAlphaUpperHalf = thisAlpha(1:h/2, 1:w);
        thisMeanUpperHalf = mean2 (thisFigUpperHalf(thisAlphaUpperHalf~=0));
        thisStdUpperHalf = std2 (thisFigUpperHalf(thisAlphaUpperHalf~=0));
        thisfigureInfo(i).luminance_Mean_UpperHalf = thisMeanUpperHalf;
        thisfigureInfo(i).luminance_Std_UpperHalf  = thisStdUpperHalf;
        % 5/25 Update: Add info about upper half
        
        mask_images = {};
        mask_images{1} = greyscaled_mask_figure;
        maskMatrix = original_mask_alpha;
        maskMatrix(maskMatrix~=0) = 1;
        matchedMaskImages = lumMatch(mask_images, maskMatrix, [thisMeanLowerHalf thisStdLowerHalf]);
        newMask = cell2mat (matchedMaskImages(1));
        imwrite(newMask, strcat(thisMaskFolder, '\mask_', thisFigName), 'Alpha', original_mask_alpha);
        thisfigureInfo(i).luminance_Mean_Mask = mean2(newMask(original_mask_alpha~=0));
        thisfigureInfo(i).luminance_Std_Mask  = std2(newMask(original_mask_alpha~=0));
        
    end
    
    %% save figure info for each folder
    cd (thisLumInfoFolder);
    T = struct2table ( thisfigureInfo) ;
    writetable (T, strcat(strrep (thisfolder, '\', '_'), "_stiminfo.csv"))
    
end


