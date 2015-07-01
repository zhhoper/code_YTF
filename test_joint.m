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
        thr = 0.8;
        [meanFeature, projection] = train_pca(path, videoLabel, load_names, thr, type);
        fprintf('Done!\n');
    end
    
    if exist('inter_s.mat', 'file') && exist('intra_s.mat', 'file') && ind
        fprintf('Loading inter and intra variane...\n');
        load('inter_s.mat');
        load('intra_s.mat');
        fprintf('Done!\n');
    else
        fprintf('Get inter and intra variance...\n');
        [inter_s, intra_s] = get_var_video_step(path, faceLabel, videoLabel, load_names, type, meanFeature, projection);
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
    distancePropose5 = sim_point_set_2(Splits(:, :, i), path, load_names, meanFeature, projection, inter_s, intra_s, type);
    fprintf('Done!\n');
    
    ori_intraPre = struct;
    ori_extraPre = struct;
    fprintf('Computing the precision for original Joint Bayesian...\n');
    [ori_intraPre.mean, ori_extraPre.mean] = get_precision(distanceOri.mean, distanceOri.label);
    [ori_intraPre.max, ori_extraPre.max] = get_precision(distanceOri.max, distanceOri.label);
    [ori_intraPre.min, ori_extraPre.min] = get_precision(distanceOri.min, distanceOri.label);
    [ori_intraPre.median, ori_extraPre.median] = get_precision(distanceOri.median, distanceOri.label);
    [ori_intraPre.fmean, ori_extraPre.fmean] = get_precision(distanceOri.featureMean, distanceOri.label);
    fprintf('Done!\n');
    save('ori_intraPre.mat', 'ori_intraPre');
    save('ori_extraPre.mat', 'ori_extraPre');
    
    fprintf('Computing the precision for proposed Joint Bayesian...\n');
    [proposed_intraPre1, proposed_extraPre1] = get_precision(distancePropose1.data, distancePropose1.label);
    save('proposed_intraPre1.mat', 'proposed_intraPre1');
    save('proposed_extraPre1.mat', 'proposed_extraPre1');
    [proposed_intraPre2, proposed_extraPre2] = get_precision(distancePropose2.data, distancePropose2.label);
    save('proposed_intraPre2.mat', 'proposed_intraPre2');
    save('proposed_extraPre2.mat', 'proposed_extraPre2');
    [proposed_intraPre3, proposed_extraPre3] = get_precision(distancePropose3.data, distancePropose3.label);
    save('proposed_intraPre3.mat', 'proposed_intraPre3');
    save('proposed_extraPre3.mat', 'proposed_extraPre3');
    [proposed_intraPre4, proposed_extraPre4] = get_precision(distancePropose4.data, distancePropose4.label);
    save('proposed_intraPre4.mat', 'proposed_intraPre4');
    save('proposed_extraPre4.mat', 'proposed_extraPre4');
    [proposed_intraPre5, proposed_extraPre5] = get_precision(distancePropose5.data, distancePropose5.label);
    save('proposed_intraPre5.mat', 'proposed_intraPre5');
    save('proposed_extraPre5.mat', 'proposed_extraPre5');
    fprintf('Done!\n');
    
    
    fprintf('Draw the curve...\n');
    [ori_pre1, proposed_pre1] = drawROC(ori_intraPre, ori_extraPre, proposed_intraPre1, proposed_extraPre1);
    [ori_pre2, proposed_pre2] = drawROC(ori_intraPre, ori_extraPre, proposed_intraPre2, proposed_extraPre2);
    [ori_pre3, proposed_pre3] = drawROC(ori_intraPre, ori_extraPre, proposed_intraPre3, proposed_extraPre3);
    [ori_pre4, proposed_pre4] = drawROC(ori_intraPre, ori_extraPre, proposed_intraPre4, proposed_extraPre4);
    [ori_pre5, proposed_pre5] = drawROC(ori_intraPre, ori_extraPre, proposed_intraPre5, proposed_extraPre5);
    fprintf('Done!\n');
    
    fprintf('End of Validation 1!\n');
    ccc = 1;
end


