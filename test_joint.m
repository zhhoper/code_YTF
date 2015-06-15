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
    
    ind = 0;
    if exist('pcaResult.mat', 'file') && ind
        fprintf('Loading PCA results...\n');
        load('pcaResult.mat');
        meanFeature = pcaResult.mean;
        projection = pcaResult.projection;
        fprintf('Done!\n');
    else
        fprintf('PCA to reduce dimension...\n');
        [meanFeature, projection] = train_pca(path, videoLabel, load_names, type);
        fprintf('Done!\n');
    end
    
    if exist('inter_s.mat', 'file') && exist('intra_s.mat', 'file') && ind
        fprintf('Loading inter and intra variane...\n');
        load('inter_s.mat');
        load('intra_s.mat');
        fprintf('Done!\n');
    else
        fprintf('Get inter and intra variance...\n');
        [inter_s, intra_s] = get_var_video(path, faceLabel, videoLabel, load_names, type, meanFeature, projection);
        fprintf('Done!\n');
    end
    
    [A, G] = get_AG(inter_s, intra_s);
    fprintf('Computing the distance of two videos using original Joint Bayesian...\n');
    distanceOri = get_distance_normal(Splits(:, :, i), path, load_names, meanFeature, projection, A, G, type);
    fprintf('Done!\n');
    
    fprintf('Computing the distance of two videos using proposed Joint Bayesian...\n');
    distancePropose1 = sim_point_set_1(Splits(:, :, i), path, load_names, meanFeature, projection, inter_s, intra_s, type);
    distancePropose2 = sim_set_set_1(Splits(:, :, i), path, load_names, meanFeature, projection, inter_s, intra_s, type);
    distancePropose3 = sim_set_set_2(Splits(:, :, i), path, load_names, meanFeature, projection, inter_s, intra_s, type);
    distancePropose4 = sim_set_set_3(Splits(:, :, i), path, load_names, meanFeature, projection, inter_s, intra_s, type);
    fprintf('Done!\n');
    
    ori_intraPre = struct;
    ori_extraPre = struct;
    fprintf('Computing the precision for original Joint Bayesian...\n');
    [ori_intraPre.mean, ori_extraPre.mean] = get_precision(distanceOri.mean, distanceOri.label);
    [ori_intraPre.max, ori_extraPre.max] = get_precision(distanceOri.max, distanceOri.label);
    [ori_intraPre.min, ori_extraPre.min] = get_precision(distanceOri.min, distanceOri.label);
    [ori_intraPre.median, ori_extraPre.median] = get_precision(distanceOri.median, distanceOri.label);
    fprintf('Done!\n');
    save('ori_intraPre.mat', 'ori_intraPre');
    save('ori_extraPre.mat', 'ori_extraPre');
    
    fprintf('Computing the precision for proposed Joint Bayesian...\n');
    [proposed_intraPre1, proposed_extraPre1] = get_precision(distancePropose1.data, distancePropose1.label);
    [proposed_intraPre2, proposed_extraPre2] = get_precision(distancePropose2.data, distancePropose2.label);
    [proposed_intraPre3, proposed_extraPre3] = get_precision(distancePropose3.data, distancePropose3.label);
    [proposed_intraPre4, proposed_extraPre4] = get_precision(distancePropose4.data, distancePropose4.label);
    fprintf('Done!\n');
    
    save('proposed_intraPre.mat', 'proposed_intraPre');
    save('proposed_extraPre.mat', 'proposed_extraPre');
    
    fprintf('Draw the curve...\n');
    [ori_pre, proposed_pre] = drawROC(ori_intraPre, ori_extraPre, proposed_intraPre, proposed_extraPre);
    fprintf('Done!\n');
    
    fprintf('End of Validation 1!\n');
    ccc = 1;
end


