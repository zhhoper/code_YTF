function [meanFeature, projection] = train_pca(path, videoLabel, load_names, type)
% [meanFeatuer, projection] = train_pca(path, videoLabel, load_names, type)
%
% This function is used to do pca on the feature

numVideos = length(videoLabel);

% get the dimension of the data
tmp = load(strcat(path, load_names{1}));
if type == 1
    DIM = size(tmp.VID_DESCS_LBP, 1);
elseif type == 2
    DIM = size(tmp.VID_DESCS_FPLBP, 1);
elseif type == 3
    DIM = size(tmp.VID_DESCS_CSLBP,1);
else
    error('Type of descriptor should be 1:LBP, 2:FPLBP, 3:CSLBP');
end

meanFeature = zeros(1, DIM);
countFrames = 0;

% get the mean of the feature
for i = 1 : numVideos
    tmp = load(strcat(path, load_names{videoLabel(i)}));
    if type == 1
        tmpFeature = tmp.VID_DESCS_LBP';
    elseif type == 2
        tmpFeature = tmp.VID_DESCS_FPLBP';
    elseif type == 3
        tmpFeature = tmp.VID_DESCS_CSLBP';
    end
    countFrames = countFrames + size(tmpFeature,1);
    meanFeature = meanFeature + sum(tmpFeature,1);
end
meanFeature = meanFeature / countFrames;

covMatrix = zeros(DIM, DIM);
% get covariance matrix
for i = 1 : numVideos
    tmp = load(strcat(path, load_names{videoLabel(i)}));
    if type == 1
        tmpFeature = tmp.VID_DESCS_LBP';
    elseif type == 2
        tmpFeature = tmp.VID_DESCS_FPLBP';
    elseif type == 3
        tmpFeature = tmp.VID_DESCS_CSLBP';
    end
    numFrames = size(tmpFeature,1);
    covMatrix = covMatrix + (tmpFeature - repmat(meanFeature, numFrames, 1))'*...
        (tmpFeature - repmat(meanFeature, numFrames, 1));
end

[V, D] = eig(covMatrix);
tmpD = diag(D);
indicator = 0;
thr = 0.80;
total = sum(tmpD);
i = 1;

while indicator ~= 1
    tmp = sum(tmpD(1:i));
    if tmp/total > thr
        indicator = 1;
    else 
        i = i + 1;
    end
end

projection = V(:,1: i);
ccc = 0;
