% 
% lum_mod, March 2021, version 0.3
% (c) Rodrigo Dal Ben (dalbenwork@gmail.com)
%
% Fix bugs:
% - Matching function now works with average values (not provided by user);
% - Normalizing function now perform the correct operation for Lab CIE
% images.
%
% ------------------------------------------------------------------------
%
% lum_mod, February 2019, version 0.2
% (c) Rodrigo Dal Ben (dalbenwork@gmail.com)
%
% Function for modifying the luminance of RGB colored images. 
% The luminance calculations and modifications are performed in HSV 
% (Value channel) and CIE Lab (Luminance channel) color spaces and then
% transformed back to RGB color space.
% Luminance can be normalized or matched for a set of imaged. Mean 
% luminace values are used for normalization, whereas for matching mean 
% or user specified values can be used.
% Following modifications, luminace calculations are performed by
% re-transforming RGB to HSV or CIE Lab color spaces.
%
% ------------------------------------------------------------------------
% Permission to use, copy, or modify this software and its documentation
% for educational and research purposes only and without fee is hereby
% granted, provided that this copyright notice and the original authors'
% names appear on all copies and supporting documentation. This program
% shall not be used, rewritten, or adapted as the basis of a commercial
% software or hardware product without first obtaining permission of the
% authors. The authors make no representations about the suitability of
% this software for any purpose. It is provided "as is" without express
% or implied warranty.
%
% Please send suggestions or corrections to dalbenwork@gmail.com
% ------------------------------------------------------------------------

function lum_mod
% Clear command window
clc;

disp('lum_mod');

% Test if the Image Processing Toolbox is installed.
img_toolbox = license('test', 'image_toolbox');

if ~img_toolbox % Image Processing Toolbox is absent
  disp('Sorry, you need the Image Processing Toolbox to proceed.');
  return
end
    
% Set OS
sep1 = strcat(filesep,'*');
sep2 = filesep;
    
% Set image format
prompt = 'What image format are you using?\n';
img_f = input(prompt,'s');
if isempty(img_f)
    img_f = '.jpg';
    disp('.jpg as default');
end
    
% Set input and output folder
input('Press "Return" to select the image input directory');
input_folder = uigetdir;
while input_folder == 0
    input('Press "Return" to select the image input directory');
    input_folder = uigetdir;
end
input('Set!\nNow, press "Return" to select the image output directory');
output_folder = uigetdir;
while output_folder == 0
    input('Press "Return" to select the image output directory');
    output_folder = uigetdir;
end
disp('Set!');

% Set input source and name pattern
src = dir(fullfile(strcat(input_folder, sep1, img_f))); % pattern to match filenames.
numim = length(src);

% Set initial Mean and SD
M_hsv = 0;
M_lab = 0;
S_hsv = 0;
S_lab = 0;

% defining name prefix depending on normalization, match by avg or manual
pref_hsv = [];
pref_lab = [];

%% Checking if normalization or matching is intended and calculating basic statistics;
prompt = 'Do you want to Normalize or Match luminance? (N/M)\n';
n_or_m = input(prompt, 's');
while ~((n_or_m == 'N') ||  (n_or_m == 'M'))
    prompt = 'Please, type N for Normalize or M for Match\n';
    n_or_m = input(prompt, 's');
end

if n_or_m == 'M'
    prompt = 'Do you want to provide luminance values manually? (Y/N)\n';
    lum_src = input(prompt,'s');
    while ~((lum_src == 'Y') ||  (lum_src == 'N'))
    prompt = 'Please, type Y or N\n';
    lum_src = input(prompt, 's');
    end
end

if n_or_m == 'M' && lum_src == 'Y'
        prompt = 'Which will be the luminance for hsv images (0-1)?\n';
        manual_hsv = input(prompt, 's');
        manual_hsv = str2double(manual_hsv);
        while manual_hsv < 0 || manual_hsv > 1
            prompt = 'Please provide a value from 0 to 1\n';
            manual_hsv = input(prompt, 's');
            manual_hsv = str2double(manual_hsv);
        end
        prompt = 'Which will be luminance for lab images (0-100)?\n';
        manual_lab = input(prompt, 's');
        manual_lab = str2double(manual_lab);
            while manual_lab < 0 || manual_lab > 100
            prompt = 'Please provide a value from 0 to 100\n';
            manual_lab = input(prompt, 's');
            manual_lab = str2double(manual_lab);
            end
        disp('Set');
        disp('Please wait...');
elseif n_or_m == 'N'
    % Setting the mean luminance desired to normalized images
    prompt = 'Which will be the mean luminance for hsv images (0-1)?\n';
        manual_hsv = input(prompt, 's');
        manual_hsv = str2double(manual_hsv);
            while manual_hsv < 0 || manual_hsv > 1
            prompt = 'Please provide a value from 0 to 1\n';
            manual_hsv = input(prompt, 's');
            manual_hsv = str2double(manual_hsv);
            end
    prompt = 'Which will be the mean luminance for lab images (0-100)?\n';
        manual_lab = input(prompt, 's');
        manual_lab = str2double(manual_lab);
            while manual_lab < 0 || manual_lab > 100
            prompt = 'Please provide a value from 0 to 100\n';
            manual_lab = input(prompt, 's');
            manual_lab = str2double(manual_lab);
            end
       % Setting the luminance std deviation desired to normalized images     
    prompt = 'Which will be the luminance standard deviation for hsv images (0-1)?\n';
        manual_std_hsv = input(prompt, 's');
        manual_std_hsv = str2double(manual_std_hsv);
            while manual_std_hsv < 0 || manual_std_hsv > 1
            prompt = 'Please provide a value from 0 to 1\n';
            manual_std_hsv = input(prompt, 's');
            manual_std_hsv = str2double(manual_std_hsv);
            end
        prompt = 'Which will be the mean luminance standard deviation for lab images (0-100)?\n';
        manual_std_lab = input(prompt, 's');
        manual_std_lab = str2double(manual_std_lab);
            while manual_std_lab < 0 || manual_std_lab > 100
            prompt = 'Please provide a value from 0 to 100\n';
            manual_std_lab = input(prompt, 's');
            manual_std_lab = str2double(manual_std_lab);
            end         
        disp('Set');
        disp('Please wait...');
elseif n_or_m == 'M' && lum_src == 'N'
    % standard msg    
    disp('Set');
    disp('Please wait...');

end

for i = 1:numim
    % load images
    file_name = strcat(input_folder, sep2, src(i).name);
    I = imread(file_name);
    %figure,imshow(I); % Check if img were created correctly (delete %)
    
    % from rbg to hsv color space and set Value attribute
    hsv = rgb2hsv(I);
    v_hsv = hsv(:,:,3);
    %figure, imshow(v_hsv); %Checking the luminance channel
        
    % from rbg to lab color space and set Value attribute
    lab = rgb2lab(I);
    l_lab = lab(:,:,1);
    %figure, imshow(l_lab); %Checking the luminance channel
         
    % Redifining M an S, based on Intensity Values (sums each iteration)
    M_hsv = M_hsv + mean2(v_hsv(:));
    S_hsv = S_hsv + std2(v_hsv(:));
    M_lab = M_lab + mean2(l_lab(:));
    S_lab = S_lab + std2(l_lab(:));      
end

% Redifining Mean
M_hsv_t = M_hsv/numim;
S_hsv_t = S_hsv/numim;
M_lab_t = M_lab/numim;
S_lab_t = S_lab/numim;
    
% Redifining the prefix
if n_or_m == 'N'
    pref_hsv = 'hsv_n_';
    pref_lab = 'lab_n_';
elseif lum_src == 'Y'
    pref_hsv = 'hsv_m_man_';
    pref_lab = 'lab_m_man_';
elseif lum_src == 'N'
    pref_hsv = 'hsv_m_avg_';
    pref_lab = 'lab_m_avg_';
end
    

%%  Applying mean values (hsv and lab) to all images, calculating, and registering final statistics

for i = 1:numim
   % load images
   file_name = strcat(input_folder, sep2, src(i).name);
   I = imread(file_name);
        %figure,imshow(I); % To check if imgs have been loaded properly delete the "%" mark
    
   % from rbg to hsv and lab color space
   hsv = rgb2hsv(I);
   lab = rgb2lab(I);
   
   % defining channels
   h = hsv(:,:,1);
   s = hsv(:,:,2);
   v_hsv = hsv(:,:,3);
        %figure, imshow(v_hsv); %Checking the luminance channel
   
   l_lab = lab(:,:,1);
   a = lab(:,:,2);
   b = lab(:,:,3);
        %figure, imshow(l_lab); %Checking the luminance channel
   
   % Setting matched luminance
   % Empty dimension
   empty_hsv = zeros(size(v_hsv));
   empty_lab = zeros(size(l_lab));
   
   % Applying mannual or average luminance values to normalized or match luminance
   if n_or_m == 'N'
       z_hsv = (v_hsv - M_hsv_t) / S_hsv_t;
       v_hsv = (z_hsv * manual_std_hsv) + manual_hsv;
       z_lab = (l_lab - M_lab_t) / S_lab_t;
       l_lab = (z_lab * manual_std_lab) + manual_lab;
   elseif lum_src == 'N' && n_or_m == 'M'
       v_hsv = empty_hsv + M_hsv_t;
       l_lab = empty_lab + M_lab_t;
   elseif lum_src == 'Y'
       v_hsv = empty_hsv + manual_hsv;
       l_lab = empty_lab + manual_lab;
   end
         
   % new image with manipulated luminance
   new_v = cat(3, h, s, v_hsv);
   new_hsv = hsv2rgb(new_v);
        %figure, imshow(new_hsv); % Check if img were created correctly (delete %)
      
   new_l = cat(3, l_lab, a, b);
   new_lab = lab2rgb(new_l);
        %figure, imshow(new_lab); % Check if img were created correctly (delete %)

   % saving rgb imgs with new luminance
   save_hsv = strcat(output_folder, sep2, pref_hsv, src(i).name);
   save_lab = strcat(output_folder, sep2, pref_lab, src(i).name);
         
   % Writing rgb imgs with new luminance
   imwrite(new_hsv, save_hsv);
   imwrite(new_lab, save_lab);
              
end

%% Final calculations
% Opening the output .txt
statistics_hsv = fopen([output_folder sep2 pref_hsv 'statistics.txt'], 'wt'); % hsv
statistics_lab = fopen([output_folder sep2 pref_lab 'statistics.txt'], 'wt'); % lab

% Setting data structure
fprintf(statistics_hsv, 'Img\tMean\tSD\n'); % hsv
fprintf(statistics_lab, 'Img\tMean\tSD\n'); % lab

% Setting initial Img
img = [];

% Setting initital number of hsv and lab imgs
n_hsv = 0;
n_lab = 0;

% Setting initial mean and standard deviation
M_v = 0;
Sd_v = 0;
M_l = 0;
Sd_l = 0;

% New images src folder for hsv
src_n = dir(fullfile(strcat(output_folder, sep1, img_f))); % pattern to match filenames.
numim = length(src_n);

for i = 1:numim
   % load images
   file_name = strcat(output_folder, sep2, src_n(i).name);
   I = imread(file_name);
       %figure,imshow(I); % To check if imgs have been loaded properly delete the "%" mark
    
   % from rbg to hsv and lab color space
   hsv = rgb2hsv(I);
   lab = rgb2lab(I);
   
   % defining channels
   v_hsv = hsv(:,:,3);  
   l_lab = lab(:,:,1);
  
   % Recording indiviudal means and sds
   m_hsv = mean2(v_hsv);
   m_lab = mean2(l_lab);
   sd_hsv = std2(v_hsv);
   sd_lab = std2(l_lab);
   
   % Updating img name
   img = src_n(i).name;
   
   % Separating info from hsv and lab files
        if strfind(file_name, pref_hsv)
           fprintf(statistics_hsv, '%s\t%.6f\t%.6f\n', img, m_hsv, sd_hsv); % rec individual mean and sd
           n_hsv = n_hsv + 1; % updates the number of hsv files
           M_v = M_v + m_hsv; % sum of the mean of each iteration of hsv files
           Sd_v = Sd_v + sd_hsv; % sum of the sd of each iteration of hsv files
        elseif strfind(file_name, pref_lab)
           fprintf(statistics_lab, '%s\t%.6f\t%.6f\n', img, m_lab, sd_lab); %same logic, but lab files
           n_lab = n_lab + 1;
           M_l = M_l + m_lab;
           Sd_l = Sd_l + sd_lab;
        end
      
end

% Redifining Mean
M_v = M_v/n_hsv; 
Sd_v = Sd_v/n_hsv;

M_l = M_l/n_lab;
Sd_l = Sd_l/n_lab;

% Redifining img
img = 'Pooled';

% Recording the overall mean and sd for hsv and lab files 
fprintf(statistics_hsv, '%s\t%.6f\t%.6f\n', img, M_v, Sd_v); 
fprintf(statistics_lab, '%s\t%.6f\t%.6f\n', img, M_l, Sd_l); 
fclose('all'); % close all open .txt

disp('All done! Check imgs!');
disp('Please send suggestions or corrections to dalbenwork@gmail.com');

end