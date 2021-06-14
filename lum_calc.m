%
% lum_calc, January 2019
% (c) Rodrigo Dal Ben (dalbenwork@gmail.com)
%
% Function for calculating the luminance mean and standard deviation from
% RGB colored images. The calculations are performed in HSV (Value channel)
% and CIE Lab (Luminance channel) color spaces.
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


function lum_calc
%% Initial setup
% Clear command window
clc;
disp('lum_calc');

% Test if the Image Processing Toolbox is installed.
img_toolbox = license('test', 'image_toolbox');

if ~img_toolbox % Image Processing Toolbox is absent
  disp('Sorry, you need the Image Processing Toolbox to proceed.');
  return
end

% Set OS
if ispc ==1
    sep1 = '\*';
    sep2 = '\';
else
    sep1 = '/*';
    sep2 = '/';
end

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
disp('Set! Calculations will be saved in the same directory under the name "img_statistics.txt".');
disp('Please wait...');

% Set input source and name pattern
src = dir(fullfile(strcat(input_folder, sep1, img_f))); % pattern to match filenames.
numim = length(src);

% Opening the output .txt
statistics = fopen([input_folder sep2 'img_statistics.txt'], 'wt'); % generic (both hsv nor lab)

% Setting data structure
fprintf(statistics, 'Img\tMean_hsv\tSD_hsv\tMean_lab\tSD_lab\n'); % generic

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
src_n = dir(fullfile(strcat(input_folder, sep1, img_f))); % pattern to match filenames.
numim = length(src_n);

for i = 1:numim
   % load images
   file_name = strcat(input_folder, sep2, src_n(i).name);
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
   
   % Registering hsv and lab values
   fprintf(statistics, '%s\t%.4f\t%.4f\t%.4f\t%.4f\n', img, m_hsv, sd_hsv, m_lab, sd_lab); % rec individual mean and sd
   n_hsv = n_hsv + 1; % updates the number of hsv files
   M_v = M_v + m_hsv; % sum of the mean of each iteration of hsv files
   Sd_v = Sd_v + sd_hsv; % sum of the sd of each iteration of hsv files
   n_lab = n_lab + 1;
   M_l = M_l + m_lab;
   Sd_l = Sd_l + sd_lab;
end
      
% Calculating pooled mean and sd
M_v = M_v/numim; 
Sd_v = Sd_v/numim;

M_l = M_l/numim;
Sd_l = Sd_l/numim;

% Redifining img
img = 'Pooled';

% Recording the overall mean and sd for hsv and lab files 
fprintf(statistics, '%s\t%.4f\t%.4f\t%.4f\t%.4f', img, M_v, Sd_v, M_l, Sd_l); 
fclose('all'); % close all open .txt

disp('All done! Have Fun!');
disp('Please send suggestions or corrections to dalbenwork@gmail.com');

end