function [id, video, noise] = get_var_video_simple(path, faceLabel, videoLabel, load_names, type, meanFeature, projection)
% [id, video, noise] = get_var_video_simple(path, faceLabel, videoLabel, load_names, type, meanFeature, projection)
%
% Get the statistics for id, video and noise variable use the most simple
% method, i.e. no EM, no decorrelation
% INPUT:
% path : path whichh contains all data
% faceLabel : faceLabel for training
% videoLabel : video label for training
% load_names : names for the mat file
% type : 1 LBP, 2 FPLBP, 3 CSLbp
% meanFeature : meanFeature when doing PCA
% projection  : projection direction for PCA
% OUTPUT:
% id: id.mean is the mean for id, id.var is the variance for id
% video : video.mean is the mean for video, video.var is the variance
% noise : noise.mean is the mean for noise, noise.var is the variance

id = struct;
video = struct;
noise = struct;

faceIndex = unique(faceLabel);
numFaces = length(faceIndex);

% get the dimension of the data
DIM = size(projection, 2);

countFrames = 0;
countVideos = 0;
meanEachFace = zeros(numFaces, DIM);

for i = 1 : numFaces
    tmpFace = faceIndex(i);
    tIndex = faceLabel == tmpFace;
    vIndex = videoLabel(tIndex);
    
    % number of videos for this face
    tmpNum = length(vIndex);
    
    for j = 1 : tmpNum
        countVideos = countVideos + 1;
        tmp = load(strcat(path, load_names{vIndex(j)}));
        if type == 1
            tmpFeature = tmp.VID_DESCS_LBP';
        elseif type == 2
            tmpFeature = tmp.VID_DESCS_FPLBP';
        elseif type == 3
            tmpFeature = tmp.VID_DESCS_CSLBP';
        end
        
        % number of frames for each video
        tmpNum1 = size(tmpFeature,1);
        countFrames = countFrames + tmpNum1;
        
        tmpFeature = (tmpFeature - repmat(meanFeature, tmpNum1, 1))*projection; 
        meanEachFace(i,:) = meanEachFace(i,:) + mean(tmpFeature,1);
    end
    meanEachFace(i,:) = meanEachFace(i,:)/tmpNum;
end
%% I have some doubts about this part. Should we suppose all the variables being 0 mean?
% Let' now suppose all the three variables are zeros mean (When using EM,
% we may ignore this assumption)
% get the mean and variance for id
id.mean = zeros(1, DIM);
id.var = (meanEachFace - repmat(id.mean, numFaces, 1))'*(meanEachFace - repmat(id.mean, numFaces, 1))/numFaces;


varVideo = zeros(DIM, DIM);
varNoise = zeros(DIM, DIM);

for i = 1 : numFaces
    tmpFace = faceIndex(i);
    tIndex = faceLabel == tmpFace;
    vIndex = videoLabel(tIndex);
    
    % number of videos for this face
    tmpNum = length(vIndex);
    
    for j = 1 : tmpNum
        tmp = load(strcat(path, load_names{vIndex(j)}));
        if type == 1
            tmpFeature = tmp.VID_DESCS_LBP';
        elseif type == 2
            tmpFeature = tmp.VID_DESCS_FPLBP';
        elseif type == 3
            tmpFeature = tmp.VID_DESCS_CSLBP';
        end
        
        % number of frames for each video
        tmpNum1 = size(tmpFeature,1);
        
        tmpFeature = (tmpFeature - repmat(meanFeature, tmpNum1, 1))*projection; 
        tmpMean = mean(tmpFeature, 1);
        varVideo = varVideo + (tmpMean - meanEachFace(i,:))'*(tmpMean - meanEachFace(i,:));
        varNoise = varNoise + (tmpFeature - repmat(tmpMean, tmpNum1, 1))'*(tmpFeature - repmat(tmpMean, tmpNum1, 1));
    end
end

video.mean = zeros(1, DIM);
video.var = varVideo/countVideos;

noise.mean = zeros(1, DIM);
noise.var = varNoise/countFrames;
end