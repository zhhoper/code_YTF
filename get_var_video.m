function [inter_s, intra_s] = get_var_video(path, faceLabel, videoLabel, load_names, type, meanFeature, projection)
% [inter_s, intra_s] = get_var_video(path, faceLabel, videoLabel, load_names, type)
%
% INPUT:
% path : path whichh contains all data
% faceLabel : faceLabel for training
% videoLabel : video label for training
% load_names : names for the mat file
% type : 1 LBP, 2 FPLBP, 3 CSLbp
% OUTPUT:
% inter_s : inter class variation
% intra_s : intra class variation

faceIndex = unique(faceLabel);
numFaces = length(faceIndex);

% get the dimension of the data
DIM = size(projection, 2);

countFrames = 0;
meanEachFace = zeros(numFaces, DIM);

% get the mean of the feature
for i = 1 : numFaces
    tmpFace = faceIndex(i);
    tIndex = faceLabel == tmpFace;
    vIndex = videoLabel(tIndex);
    tmpNum = length(vIndex);
    numFrameEachFace = 0;
    for j = 1 : tmpNum
        tmp = load(strcat(path, load_names{vIndex(j)}));
        if type == 1
            tmpFeature = tmp.VID_DESCS_LBP';
        elseif type == 2
            tmpFeature = tmp.VID_DESCS_FPLBP';
        elseif type == 3
            tmpFeature = tmp.VID_DESCS_CSLBP';
        end
        tmpNum1 = size(tmpFeature,1);
        countFrames = countFrames + tmpNum1;
        numFrameEachFace = numFrameEachFace + tmpNum1;
        tmpFeature = (tmpFeature - repmat(meanFeature, tmpNum1, 1))*projection; 
        meanEachFace(i,:) = meanEachFace(i,:) + sum(tmpFeature,1);
    end
    meanEachFace(i,:) = meanEachFace(i,:)/numFrameEachFace;
end

inter_s = meanEachFace'*meanEachFace/numFaces;

% get intra_s
intra_s = zeros(DIM, DIM);
for i = 1 : numFaces
    tmpFace = faceIndex(i);
    tIndex = faceLabel == tmpFace;
    vIndex = videoLabel(tIndex);
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
        numFrames = size(tmpFeature, 1);
        tmpFeature = (tmpFeature - repmat(meanFeature, numFrames, 1))*projection;
        intra_s = intra_s + (tmpFeature - repmat(meanEachFace(i,:), numFrames, 1))'*...
            (tmpFeature - repmat(meanEachFace(i,:), numFrames, 1));
    end
end
intra_s = intra_s / countFrames;

end




