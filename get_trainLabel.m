function [faceLabel, videoLabel] = get_trainLabel(Splits, index, video_labels)
% [faceLabel, videoLabel] = get_trainName(Splits, index, video_names, path)
%
% this function is used to get the training samples' label 
% INPUT:
% Splits : contains the spliting for training and testign
% index : the set used for testing
% video_names : name of the video
% path : the path where we can load the feature
% OUTPUT:
% faceLabel : the face label used for training
% videoLabel : the video label used for training

numVal = size(Splits, 3);

% get all the video index that will be used for training
videoLabel = [];
for i = 1 : numVal
    if i ~= index
        tmp = Splits(:,:,i);
        videoLabel = [videoLabel; tmp(:,1); tmp(:,2)];
        videoLabel = unique(videoLabel);
    end
end

% get their corresponding face label
numVideos = size(videoLabel,1);
faceLabel = zeros(numVideos, 1);
for i = 1 : numVideos
    faceLabel(i) = video_labels(videoLabel(i));
end
end