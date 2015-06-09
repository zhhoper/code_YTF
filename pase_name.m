function name = pase_name(file_name, aligned)
% name = pase_name(file_name) 
%
% This function is used to pase the file name so we can load the feature
% for each frame
% INPUt:
% file_name : a string containing all the file names
% aligned : indicate whether to load aligned or non-aligned files
% OUTPUT:
% name : name of a file for loading features

num = length(file_name);
name = cell(num,1);
for i = 1 : num
    tmpString = file_name{i};
    split_pos = strfind(tmpString, '/');
    if aligned == 1
        name{i} = strcat(tmpString(1:split_pos), 'aligned_video_', tmpString(split_pos+1:end), '.mat');
    else
        name(i) = strcat(tmpString(1:split_pos), 'video_', tmpString(split_pos+1:end), '.mat');
    end
end

end