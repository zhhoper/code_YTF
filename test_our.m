% test for video face recognition with our u + v + epson method

% loading data
fprintf('Loading mete_data...\n');
load('../YTF/meta_data/meta_and_splits.mat');
fprintf('Done!\n');

% for each testing
path = '../YTF/descriptors_DB/';
load_names = pase_name(video_names, 1);
[numPair, ~, numValidation] = size(Splits);
type = 1;

matPath = 'keep_mat/';
for i = 1 : numValidation
    fprintf('Validation 1......\n');
    fprintf('Get training data label...\n')
    [faceLabel, videoLabel] = get_trainLabel(Splits, i, video_labels);
    fprintf('Done!\n');
    
    ind = 0;
    if exist(strcat(matPath,'pcaResult.mat'), 'file') && ind
        fprintf('Loading PCA results...\n');
        load(strcat(matPath,'pcaResult.mat'));
        meanFeature = pcaResult.mean;
        projection = pcaResult.projection;
        fprintf('Done!\n');
    else
        fprintf('PCA to reduce dimension...\n');
        % keep 80% of the energy when doing PCA
        thr = 0.8; 
        [meanFeature, projection] = train_pca(path, videoLabel, load_names, thr, type);
        fprintf('Done!\n');
    end
    
    if exist(strcat(matPath, 'id.mat'), 'file') ...
            && exist(strcat(matPath, 'video.mat'), 'file')...
            && exist(strcat(matPath, 'noise.mat'), 'file') && ind
        fprintf('Loading inter and intra variane...\n');
        load(strcat(matPath, 'id.mat'));
        load(strcat(matPath, 'video.mat'));
        load(strcat(matPath, 'noise.mat'));
        fprintf('Done!\n');
    else
        fprintf('Get inter and intra variance...\n');
        % use the most simple case when training, no EM, no decorrelation
        [id, video, noise] = get_var_video_simple(path, faceLabel, videoLabel, load_names, type, meanFeature, projection);
%         % use EM for training but with no decorrelation
%         [id, video, noise] = get_var_video_EM(path, faceLabel, videoLabel, load_names, type, meanFeature, projection);
%         % Decorrelate frames but with no EM
%         [id, video, noise] = get_var_video_corr(path, faceLabel, videoLabel, load_names, type, meanFeature, projection);
%         % use both EM and decorrelation
%         [id, video, noise] = get_var_video_EM_corr(path, faceLabel, videoLabel, load_names, type, meanFeature, projection);
        fprintf('Done!\n');
    end
    
    
    fprintf('Compute the distance of two videos using the model id + video + noise...\n');
    distance = get_distance_three(Splits(:, :, i), path, load_names, meanFeature, projection, id, video, noise, type);
    fprintf('Done!\n');
end
    