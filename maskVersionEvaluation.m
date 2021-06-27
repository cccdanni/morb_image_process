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

normedFolder = fullfile( parentFolder, "Masked_stim", "stim");
normedInfoFolder = fullfile( parentFolder, "Masked_stim", "normalizedInfo");
processedMaskFolder = fullfile( parentFolder, "processed_stim", "step4_processedMask");

%% process normalized stimuli
if ~exist(normedInfoFolder)
    mkdir(normedInfoFolder);
end
cd (normedInfoFolder);

oneback_task_folder1 = "masked_one_back\24old";
oneback_task_folder2 = "masked_one_back\36new";
SCT_AMP_task_folder = "masked_SCT_AMP";
folder_list = {oneback_task_folder1, oneback_task_folder2, SCT_AMP_task_folder};

for j = 1:numel(folder_list)
    
    thisfolder = string(folder_list(j));
    thisfigureNames = dir (strcat (normedFolder, '\', thisfolder, "\*.png"));
    thisFigDir = strcat (normedFolder, '\', thisfolder);
    thisfigureInfo = struct;
    
    thisLumInfoFolder = strcat (normedInfoFolder, '\', thisfolder);
    if ~exist(thisLumInfoFolder)
        mkdir(thisLumInfoFolder);
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
        
        [h w] = size ( thisFig);
        thisFigLowerHalf = thisFig(h/2:h, 1:w);
        thisAlphaLowerHalf = thisAlpha(h/2:h, 1:w);
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
        
    end
    
    %% save figure info for each folder
    cd (thisLumInfoFolder);
    T = struct2table ( thisfigureInfo) ;
    writetable (T, strcat(strrep (thisfolder, '\', '_'), "_stiminfo.csv"))
    
end


