% Project: MFORB 

% Function: standardize stimuli (luminance) with SHINE
% toolbox and export mask stimuli with matched luminance 

% Citation:
% Willenbockel, V., Sadr, J., Fiset, D., Horne, G. O., Gosselin, F., &
% Tanaka, J. W. (2010). Controlling low-level image properties: The SHINE
% toolbox. Behavior Research Methods, 42(3), 671–684.
% http://doi.org/10.3758/BRM.42.3.671 

% Pre-requisite: SHINE toolbox, Image Processing Toolbox

% Author: Chen Danni, dnchen@connect.hku.hk
% Update date: May-23-2021

%% define folder
clear;clc;

shinetoolbox_path = "C:\toolbox\SHINEtoolbox";
addpath (shinetoolbox_path);

parentFolder = "C:\Users\Psychology\Desktop\MFORB\exp3\stim";
cd ( parentFolder );

rawstimFolder = fullfile( parentFolder, "original_stim");
greyscaledFolder = fullfile( parentFolder, "processed_stim", "stim_greyscaled");
normedFolder = fullfile( parentFolder, "processed_stim", "stim_norm");

%% read figures and greyscaled figures within rawstim Folder
% 
% cd (rawstimFolder);
% 
% oneback_task_folder1 = "oneback_60\24old";
% oneback_task_folder2 = "oneback_60\36new";
% pv_task_folder1 = "PV_120\A";
% pv_task_folder2 = "PV_120\C";
% SCT_AMP_task_folder = "SCT_AMP";
% folder_list = {oneback_task_folder1, oneback_task_folder2, pv_task_folder1, pv_task_folder2, SCT_AMP_task_folder};
% 
% for j = 1:numel(folder_list)
%     
%     thisfolder = string(folder_list(j));
%     thisfigureNames = dir (strcat (rawstimFolder, '\', thisfolder, "\*.png"));
%     
%     output_path = fullfile (parentFolder, "processed_stim", "step1_greyscaled", thisfolder);
%     if ~exist(output_path)
%         mkdir(output_path)
%     end
%     cd(output_path);
%    
%     for i = 1: length(thisfigureNames)
%         
%         thisFigName = thisfigureNames(i).name;
%         thisFigDir  = thisfigureNames(i).folder;
%         [thisFig,~,thisAlpha] = imread ( strcat(thisFigDir, '\', thisFigName));
%         fprintf(['Size of ', thisFigName, '  :  ', num2str(size(thisFig)) '\n']);
%         newFig  = rgb2gray(thisFig);
%         imwrite(newFig, strcat(output_path, '\greyscaled_', thisFigName), 'Alpha', thisAlpha);
% 
%     end
% 
% end

%% normalize stimuli within each task

greyscaled_folder = fullfile (parentFolder, "processed_stim", "step1_greyscaled");
cd ( greyscaled_folder );

oneback_task_folder1 = "oneback_60\24old";
oneback_task_folder2 = "oneback_60\36new";
pv_task_folder1 = "PV_120\A";
pv_task_folder2 = "PV_120\C";
SCT_AMP_task_folder = "SCT_AMP";
folder_list = {oneback_task_folder1, oneback_task_folder2, pv_task_folder1, pv_task_folder2, SCT_AMP_task_folder};

%% one-back task
thisfolder_list = {oneback_task_folder1, oneback_task_folder2};
thisfiglist = {};
thisalphalist = {};
thisfignamelist = {};
thisfolderlist = {};
cnt = 1;

% 1. Read images 
for j = 1:numel(thisfolder_list)
    
    thisfolder = string(thisfolder_list(j));
    thisfigureNames = dir (strcat (greyscaled_folder, '\', thisfolder, "\*.png"));
   
    for i = 1: length(thisfigureNames)
        
        thisFigName = thisfigureNames(i).name;
        thisFigDir  = thisfigureNames(i).folder;
        thisFig = imread ( strcat(thisFigDir, '\', thisFigName));
        [~,~,thisAlpha] = imread ( strcat(thisFigDir, '\', thisFigName));
        fprintf(['Size of ', thisFigName, '  :  ', num2str(size(thisFig)) '\n']);
        thisfiglist{cnt} = thisFig;
        thisalphalist{cnt} = thisAlpha;
        thisfignamelist{cnt} = thisFigName;
        thisfolderlist{cnt} = thisfolder;
        
        cnt = cnt + 1;
        
    end

end

% 2. Normalize current figure list
newimageslist = SHINE(thisfiglist);
% History:
% SHINE options    [1=default, 2=custom]: 2
% Matching mode    [1=luminance, 2=spatial frequency, 3=both]: 1
% Luminance option [1=lumMatch, 2=histMatch]: 2
% Optimize SSIM    [1=no, 2=yes]: 2
% Matching region  [1=whole image, 2=foreground/background]: 2
% Segmentation of: [1=source images, 2=template(s)]: 1
% Image background [1=specify lum, 2=find automatically (most frequent lum in the image)]: 2
%  
% Number of images: 60
%  
% Option:   histMatch separately for the foregrounds and backgrounds (background = all regions of lum 0)
% Progress: histMatch successful
%  
% RMSE:     4.489262e+00
% SSIM:     9.702769e-01

% 3. Save normalize images
for j = 1:numel(thisfolder_list)
    
    thisfolder = string(thisfolder_list{j});
    output_path = fullfile (parentFolder, "processed_stim", "step2_normalized", thisfolder);
    if ~exist(output_path)
        mkdir(output_path)
    end
    
end
% create folders

cd( fullfile(parentFolder, "processed_stim", "step2_normalized"));

for i = 1: length(newimageslist)
    
    newFigure = newimageslist{i};
    thisFigName = string(thisfignamelist(i));
    thisFigDir  = string(thisfolderlist(i));
    thisFigAlpha = cell2mat(thisalphalist(i));
    
    fprintf(strcat('Size of ', thisFigName, ' Folder', thisFigDir, '  :  ', num2str(size(thisFig)), '\n'));
    cd (fullfile (parentFolder, "processed_stim", "step2_normalized", thisFigDir));
    imwrite(newFigure, strcat('normed_', thisFigName), 'Alpha', thisFigAlpha);

end

%% passive-viewing task
thisfolder_list = {pv_task_folder1, pv_task_folder2};
thisfiglist = {};
thisalphalist = {};
thisfignamelist = {};
thisfolderlist = {};
cnt = 1;

% 1. Read images 
for j = 1:numel(thisfolder_list)
    
    thisfolder = string(thisfolder_list(j));
    thisfigureNames = dir (strcat (greyscaled_folder, '\', thisfolder, "\*.png"));
   
    for i = 1: length(thisfigureNames)
        
        thisFigName = thisfigureNames(i).name;
        thisFigDir  = thisfigureNames(i).folder;
        thisFig = imread ( strcat(thisFigDir, '\', thisFigName));
        [~,~,thisAlpha] = imread ( strcat(thisFigDir, '\', thisFigName));
        fprintf(['Size of ', thisFigName, '  :  ', num2str(size(thisFig)) '\n']);
        thisfiglist{cnt} = thisFig;
        thisalphalist{cnt} = thisAlpha;
        thisfignamelist{cnt} = thisFigName;
        thisfolderlist{cnt} = thisfolder;
        
        cnt = cnt + 1;
        
    end

end

% 2. Normalize current figure list
newimageslist = SHINE(thisfiglist);
% % History:
% SHINE options    [1=default, 2=custom]: 2
% Matching mode    [1=luminance, 2=spatial frequency, 3=both]: 1
% Luminance option [1=lumMatch, 2=histMatch]: 2
% Optimize SSIM    [1=no, 2=yes]: 2
% Matching region  [1=whole image, 2=foreground/background]: 2
% Segmentation of: [1=source images, 2=template(s)]: 1
% Image background [1=specify lum, 2=find automatically (most frequent lum in the image)]: 2
%  
% Number of images: 120
%  
% Option:   histMatch separately for the foregrounds and backgrounds (background = all regions of lum 0)
% Progress: histMatch successful
%  
% RMSE:     3.680834e+00
% SSIM:     9.729198e-01

% 3. Save normalize images
for j = 1:numel(thisfolder_list)
    
    thisfolder = string(thisfolder_list{j});
    output_path = fullfile (parentFolder, "processed_stim", "step2_normalized", thisfolder);
    if ~exist(output_path)
        mkdir(output_path)
    end
    
end
% create folders

cd( fullfile(parentFolder, "processed_stim", "step2_normalized"));

for i = 1: length(newimageslist)
    
    newFigure = newimageslist{i};
    thisFigName = string(thisfignamelist(i));
    thisFigDir  = string(thisfolderlist(i));
    thisFigAlpha = cell2mat(thisalphalist(i));
    
    fprintf(strcat('Size of ', thisFigName, ' Folder', thisFigDir, '  :  ', num2str(size(thisFig)), '\n'));
    cd (fullfile (parentFolder, "processed_stim", "step2_normalized", thisFigDir));
    imwrite(newFigure, strcat('normed_', thisFigName), 'Alpha', thisFigAlpha);

end

%% SCT & AMP Task
thisfolder_list = {SCT_AMP_task_folder};
thisfiglist = {};
thisalphalist = {};
thisfignamelist = {};
thisfolderlist = {};
cnt = 1;

% 1. Read images 
for j = 1:numel(thisfolder_list)
    
    thisfolder = string(thisfolder_list(j));
    thisfigureNames = dir (strcat (greyscaled_folder, '\', thisfolder, "\*.png"));
   
    for i = 1: length(thisfigureNames)
        
        thisFigName = thisfigureNames(i).name;
        thisFigDir  = thisfigureNames(i).folder;
        thisFig = imread ( strcat(thisFigDir, '\', thisFigName));
        [~,~,thisAlpha] = imread ( strcat(thisFigDir, '\', thisFigName));
        
        fprintf(['Size of ', thisFigName, '  :  ', num2str(size(thisFig)) '\n']);
        
        if (size(thisFig) ~= [250 200])
            thisAlpha = thisAlpha(1:250, 1:200);
            thisFig   = thisFig(1:250, 1:200);
        end % resize figures
        
        thisfiglist{cnt} = thisFig;
        thisalphalist{cnt} = thisAlpha;
        thisfignamelist{cnt} = thisFigName;
        thisfolderlist{cnt} = thisfolder;
        
        cnt = cnt + 1;
        
    end

end

% 2. Normalize current figure list
newimageslist = SHINE(thisfiglist);
% History:
% SHINE options    [1=default, 2=custom]: 2
% Matching mode    [1=luminance, 2=spatial frequency, 3=both]: 1
% Luminance option [1=lumMatch, 2=histMatch]: 2
% Optimize SSIM    [1=no, 2=yes]: 2
% Matching region  [1=whole image, 2=foreground/background]: 2
% Segmentation of: [1=source images, 2=template(s)]: 1
% Image background [1=specify lum, 2=find automatically (most frequent lum in the image)]: 2
%  
% Number of images: 48
%  
% Option:   histMatch separately for the foregrounds and backgrounds (background = all regions of lum 0)
% Progress: histMatch successful
%  
% RMSE:     7.088848e+00
% SSIM:     9.325291e-01

% 3. Save normalize images
for j = 1:numel(thisfolder_list)
    
    thisfolder = string(thisfolder_list{j});
    output_path = fullfile (parentFolder, "processed_stim", "step2_normalized", thisfolder);
    if ~exist(output_path)
        mkdir(output_path)
    end
    
end
% create folders

cd( fullfile(parentFolder, "processed_stim", "step2_normalized"));

for i = 1: length(newimageslist)
    
    newFigure = newimageslist{i};
    thisFigName = string(thisfignamelist(i));
    thisFigDir  = string(thisfolderlist(i));
    thisFigAlpha = cell2mat(thisalphalist(i));
    
    fprintf(strcat('Size of ', thisFigName, ' Folder', thisFigDir, '  :  ', num2str(size(thisFig)), '\n'));
    cd (fullfile (parentFolder, "processed_stim", "step2_normalized", thisFigDir));
    imwrite(newFigure, strcat('normed_', thisFigName), 'Alpha', thisFigAlpha);

end
