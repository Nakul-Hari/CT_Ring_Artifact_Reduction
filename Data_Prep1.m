% Matlab file for preparing the dataset
close all
clear
%% Creating the dataset
% Find the file and filepaths
base_dir = './Medical Imaging Datasets/';
f = dir(base_dir);
folders = {f.name};
sum = 10;
A = {};
num_files = 0;
for i = 1:length(f)-2
    added_dir = "/";
    while sum > 0
        f = dir(base_dir+string(folders(i+2))+added_dir);
        idirValues = [f.isdir];
        folder = {f(idirValues).name};
        sum = length(folder)-2;
        if sum>0
            added_dir = added_dir+string(folder(3))+"/";
        end
    end
    num_files = num_files+length(f)-2;
    A{i} = base_dir+string(folders(i+2))+added_dir;
    sum = 10;
end
clearvars -except A num_files base_dir
%%
outputDir = './Dataset_Random';
if ~exist(outputDir, 'dir')
    mkdir(outputDir); % Create the directory if it doesn't exist
end

%% Creation of data set
outputDirImagesx = string(outputDir)+'/Images/xtrain/';
outputDirImagesy = string(outputDir)+'/Images/ytrain/';
outputDirSinogramsx = string(outputDir)+'/Sinograms/xtrain/';
outputDirSinogramsy = string(outputDir)+'/Sinograms/ytrain/';
if ~exist(outputDirImagesx, 'dir')
    mkdir(outputDirImagesx);
end
if ~exist(outputDirImagesy, 'dir')
    mkdir(outputDirImagesy);
end
if ~exist(outputDirSinogramsx, 'dir')
    mkdir(outputDirSinogramsx);
end
if ~exist(outputDirSinogramsy, 'dir')
    mkdir(outputDirSinogramsy);
end

% Setting up the one times
ig_big = image_geom('nx', 512, 'fov', 35, 'down', 1); % Creates image profile
sg = sino_geom('ge1', 'units', 'cm', 'strip_width', 'd', 'down', 1); % Creates sinogram profile
Abig = Gtomo_nufft_new(sg, ig_big); % Creates the kernel based on the requirement above
geom = fbp2(sg, ig_big); % initialising the filter back projection using the profiles
index = 0;
for fileindex = 1:length(A)
    f = dir(A{fileindex});
    fileNames = {f.name};
    p = fileNames(3:end);
    plen = length(p);
    for imgindex = 1:plen
        index = index+1
        fprintf('\nSegment=%d\tImage=%d\n', fileindex, imgindex);
        impath = A{fileindex}+"/"+ p(imgindex);
        [true_image,true_sino,noisy_image,noisy_sino] = process_image(impath,Abig,geom);
        imwrite(uint16(true_image), fullfile(outputDirImagesy, sprintf('%04d.png', index)), 'BitDepth', 16);
        imwrite(uint16(noisy_image), fullfile(outputDirImagesx, sprintf('%04d.png', index)), 'BitDepth', 16);
        imwrite(uint16(true_sino), fullfile(outputDirSinogramsy, sprintf('%04d.png', index)), 'BitDepth', 16);
        imwrite(uint16(noisy_sino), fullfile(outputDirSinogramsx, sprintf('%04d.png', index)), 'BitDepth', 16);
    end
    disp(fileindex);
    disp("done");
end
% %% Visualiation
% index = 1;  % Example index to visualize
% 
% % Create a new figure
% figure;
% 
% % Plot noisy image from imageStackx1
% subplot(2, 2, 1);
% imagesc(imageStackx1(:,:,index));
% colormap(gray);
% axis image;
% title('Noisy Image 1');
% 
% % Plot true image from imageStacky1
% subplot(2, 2, 2);
% imagesc(imageStacky1(:,:,index));
% colormap(gray);
% axis image;
% title('True Image 1');
% 
% % Plot noisy sino image from imageStackx2
% subplot(2, 2, 3);
% imagesc(imageStackx2(:,:,index));
% colormap(gray);
% axis image;
% title('Noisy Sino Image');
% 
% % Plot true sino image from imageStacky2
% subplot(2, 2, 4);
% imagesc(imageStacky2(:,:,index));
% colormap(gray);
% axis image;
% title('True Sino Image');
% 
% % Adjust the layout
% sgtitle('Image Stacks Visualization');

%% Functions

function [true_image,true_sino,noisy_image,noisy_sino] = process_image(path,Abig,geom)
    xtrue512 = dicomread(path);
    xtrue512 = double(xtrue512);
    maxi = 4096;
    xtrue512_norm = xtrue512/maxi;
    true_sino = Abig * xtrue512_norm; % Creates the sinogram
    noisy_sino = true_sino.*(1+0.005*repmat(rand(888,1),1,984));
    noisy_image = abs(fbp2(noisy_sino, geom))*maxi;
    true_sino = (true_sino +0.1)*maxi;
    noisy_sino = (noisy_sino+0.1)*maxi;
    true_image = xtrue512;
end

