% Starter code prepared by James Hays for CS 143, Brown University
% This function should return negative training examples (non-faces) from
% any images in 'non_face_scn_path'. Images should be converted to
% grayscale, because the positive training data is only available in
% grayscale. For best performance, you should sample random negative
% examples at multiple scales.

function features_neg = get_random_negative_features(non_face_scn_path, feature_params, num_samples)
% 'non_face_scn_path' is a string. This directory contains many images
%   which have no faces in them.
% 'feature_params' is a struct, with fields
%   feature_params.template_size (probably 36), the number of pixels
%      spanned by each train / test template and
%   feature_params.hog_cell_size (default 6), the number of pixels in each
%      HoG cell. template size should be evenly divisible by hog_cell_size.
%      Smaller HoG cell sizes tend to work better, but they make things
%      slower because the feature dimensionality increases and more
%      importantly the step size of the classifier decreases at test time.
% 'num_samples' is the number of random negatives to be mined, it's not
%   important for the function to find exactly 'num_samples' non-face
%   features, e.g. you might try to sample some number from each image, but
%   some images might be too small to find enough.

% 'features_neg' is N by D matrix where N is the number of non-faces and D
% is the template dimensionality, which would be
%   (feature_params.template_size / feature_params.hog_cell_size)^2 * 31
% if you're using the default vl_hog parameters

% Useful functions:
% vl_hog, HOG = VL_HOG(IM, CELLSIZE)
%  http://www.vlfeat.org/matlab/vl_hog.html  (API)
%  http://www.vlfeat.org/overview/hog.html   (Tutorial)
% rgb2gray

image_files = dir( fullfile( non_face_scn_path, '*.jpg' ));
num_images = length(image_files);

%todo
count = 0;
D = (feature_params.template_size / feature_params.hog_cell_size)^2 * 36;
features_neg = [];
for i= 1:num_images
    
    FullFile = fullfile( non_face_scn_path, image_files(i).name);
    img = imread(FullFile);
    if size(img,3) >= 2 
        img = rgb2gray(img); 
    end
    img_hog = vl_hog(single(img),feature_params.hog_cell_size,'variant','dalaltriggs');
    [hog_height,hog_width,hog_chn] = size(img_hog);
    ratio = feature_params.template_size/feature_params.hog_cell_size;
    [img_height,img_width,img_chn] = size(img);
    temp_height = floor(img_height/feature_params.template_size);
    temp_width = floor(img_width/feature_params.template_size);
    max_index = max(temp_height,temp_width);
    
    max_height = hog_height-ratio+1;
    max_width = hog_width-ratio+1;
    
    for j = 1:max_index
        %sample
        randi_height = randi(max_height);
        randi_width = randi(max_width);
        %retrieve the hog in corresponding template
        start_h = randi_height;
        start_w = randi_width;
        end_h = randi_height+ratio-1;
        end_w = randi_width+ratio-1;
        
        %disp(size((img_hog(start_h:end_h,start_w:end_w,1:31))));
        %disp(size(img_hog));
        this_neg = reshape((img_hog(start_h:end_h,start_w:end_w,1:36)),[1,D]);
        features_neg = [features_neg;this_neg];
        count = count+1;
        if(count>num_samples)
            return;
        end;
    end
        

end

% placeholder to be deleted
%features_neg = rand(100, (feature_params.template_size / feature_params.hog_cell_size)^2 * 31);