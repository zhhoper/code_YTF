function [data, lab_video, lab_face] = get_data_label(path, load_names, labels, type)
% [data, lab_video, lab_face] = get_data_label(path, load_names, video_labels)
%
% This function is used to load feature and perpare label for training and
% testing
% INPUT : 
% path : path that containing the feature
% load_names : name of the feature
% labels : label for each video based on face
% type : which type of data we want to use, 1: LBP, 2 : FPLBP, 3 : CSLBP
% OUTPUT:
% data : a mat containing all the face features
% lab_video : video level label
% lab_face  : face level label

numVideos = length(load_names);

tmpData = cell(numVideos,1);
tmpVideo = cell(numVideos,1);
tmpFace = cell(numVideos,1);
totalCount = 0;

% loading data to cell
for i = 1 : numVideos
    tmp = load(strcat(path, load_names{i}));
    if type == 1
        tmpData{i} = tmp.VID_DESCS_LBP';
    elseif type == 2
        tmpData{i} = tmp.VID_DESCS_FPLBP';
    elseif type == 3
        tmpData{i} = tmp.VID_DESCS_CSLBP';
    end
    count = size(tmpData{i},1);
    totalCount = totalCount + count;
    tmpFace{i} = ones(count,1)*labels;
    tmpVideo{i} = ones(count,1)*i;
end

% converting data to mat type
data = cell2mat(tmpData);
lab_video = cell2mat(tmpVideo);
lab_face = cell2mat(tmpFace);

end