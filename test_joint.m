% test for video face recognition

% loading data
fprintf('Loading mete_data...\n');
load('../YTF/meta_data/meta_and_splits.mat');
fprintf('Done!\n');

% for each testing
path = '../YTF/descriptors_DB/';
load_names = pase_name(video_names, 1);
[numPair, ~, numValidation] = size(Splits);
type = 1;
for i = 1 : numValidation
    fprintf('Validation 1......\n');
    fprintf('Get training data label...\n')
    [faceLabel, videoLabel] = get_trainLabel(Splits, i, video_labels);
    fprintf('Done!\n');
    
    ind = 1;
    if exist('pcaResult.mat', 'file') && ind
        fprintf('Loading PCA results...\n');
        load('pcaResult.mat');
        meanFeature = pcaResult.mean;
        projection = pcaResult.projection;
        fprintf('Done!\n');
    else
        fprintf('PCA to reduce dimension...\n');
        [meanFeatuer, projection] = train_pca(path, videoLabel, load_names, type);
        fprintf('Done!\n');
    end
    
    if exit('inter_s.mat', 'file') && exit('intra_s.mat', 'file') && ind
        fprintf('Loading inter and intra variane...\n');
        load('inter_s.mat');
        load('inter_s.mat');
        fprintf('Done!\n');
    else
        fprintf('Get inter and intra variance...\n');
        [inter_s, intra_s] = get_var_video(path, faceLabel, videoLabel, load_names, type, meanFeature, projection);
        fprintf('Done!\n');
    end
    
    [A, G] = get_AG(inter_s, intra_s);
    
    
end


