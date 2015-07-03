function distance = get_distance_video(pair, path, load_names, meanFeature, projection, id, video, noise, type)
% distance = get_distance_three(pair, path, load_names, meanFeature, projection, id, video, noise, type)
%
% This function is used to compute the distance of two videos using our
% proposed three variable model of joint bayesian
% INPUT:
% pair : indicating which two videos to compute
% load_names : loading name of videos
% meanFeature : mean feature for PCA
% projection : projection matrix for PCA
% id : variable id
% video : variable video
% noise : variable noise
% type : type of feature we want to use
% OUTPUT:
% distance : distance.label indicate whether two videos are the same or not
%            distance.data contains the distance

num = size(pair,1);
distance = struct;

% initialize the distance to zero
distance.label = pair(:,3);
distance.data = zeros(num,1);

[A, G] = get_AG(id.var, video.var);

for i = 1 : num
    I1 = pair(i,1);
    I2 = pair(i,2);
    f1 = load(strcat(path, load_names{I1}));
    f2 = load(strcat(path, load_names{I2}));
    
    % loading features based on type
    if type == 1
        f1 = f1.VID_DESCS_LBP';
        f2 = f2.VID_DESCS_LBP';
    elseif type == 2
        f1 = f1.VID_DESCS_FPLBP';
        f2 = f2.VID_DESCS_FPLBP';
    elseif type == 3
        f1 = f1.VID_DESCS_CSLBP';
        f2 = f2.VID_DESCS_CSLBP';
    end
    
    
    num1 = size(f1,1);
    num2 = size(f2,1);
    
    % project using pca
    f1 = (f1 - repmat(meanFeature, num1, 1))*projection;
    f2 = (f2 - repmat(meanFeature, num2, 1))*projection;
    
    
    % decorrelate features between frames
    [mu1, ~] = decompose_video(f1, id, video, noise);
    [mu2, ~] = decompose_video(f2, id, video, noise);
    
    distance.data(i) = mu1*A*mu1' + mu2*A*mu2' - 2*mu1*G*mu2';
    
end

end