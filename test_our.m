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
ori = struct;
pre = struct;
ori_best = struct;
pre_best = struct;
for i = 1 : numValidation
    tic
    fprintf('Validation 1......\n');
    fprintf('Get training data label...\n')
    [faceLabel, videoLabel] = get_trainLabel(Splits, i, video_labels);
    fprintf('Done!\n');
    
    ind = 1;
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
        pcaResult.mean = meanFeature;
        pcaResult.projection = projection;
        save(strcat(matPath, 'pcaResult.mat'), 'pcaResult');
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
    
    [A, G] = get_AG(id.var, video.var + noise.var);
    fprintf('Computing the distance of two videos using original Joint Bayesian...\n');
    distanceOri = get_distance_select(Splits(:, :, i), path, load_names, meanFeature, projection, A, G, id, video, noise, type);
    %distanceOri = get_distance_normal(Splits(:, :, i), path, load_names, meanFeature, projection, A, G, type);
    fprintf('Done!\n');
    
    
    ori_intraPre = struct;
    ori_extraPre = struct;
    fprintf('Computing the precision for original Joint Bayesian...\n');
    [ori_intraPre.mean, ori_extraPre.mean] = get_precision(distanceOri.mean, distanceOri.label);
    [ori_intraPre.max, ori_extraPre.max] = get_precision(distanceOri.max, distanceOri.label);
    [ori_intraPre.min, ori_extraPre.min] = get_precision(distanceOri.min, distanceOri.label);
    [ori_intraPre.median, ori_extraPre.median] = get_precision(distanceOri.median, distanceOri.label);
    [ori_intraPre.fmean, ori_extraPre.fmean] = get_precision(distanceOri.featureMean, distanceOri.label);
    [ori_intraPre.selectMean, ori_extraPre.selectMean] = get_precision(distanceOri.selectMean, distanceOri.label);
    [ori_intraPre.selectMin, ori_extraPre.selectMin] = get_precision(distanceOri.selectMin, distanceOri.label);
    [ori_intraPre.selectJoint, ori_extraPre.selectJoint] = get_precision(distanceOri.selectJoint, distanceOri.label);
    fprintf('Done!\n');
    
    %     fprintf('Computing the distance of two videos using the model id + video + noise...\n');
    %     numFrames = 5;
    %     distance = get_distance_three(Splits(:, :, i), path, load_names, meanFeature, projection, id, video, noise, numFrames, type);
    %     fprintf('Done!\n');
    %
    %     fprintf('Computing the precision for our method...\n');
    %     [pre_intra1, pre_extra1] = get_precision(distance.data1, distance.label);
    %     fprintf('Done!\n');
    %
    %     fprintf('Computing the precision for our method...\n');
    %     [pre_intra2, pre_extra2] = get_precision(distance.data2, distance.label);
    %     fprintf('Done!\n');
    
    %     figure;
    %     plot(pre_extra1, pre_intra1, 'r-');
    %     hold on;
    %     plot(pre_extra2, pre_intra2, 'b-');
    fprintf('Computing the distance of two videos using the model id + video + noise...\n');
    distance = get_distance_video(Splits(:,:,i), path, load_names, meanFeature, projection, id, video, noise, type);
    fprintf('Done!\n');
    
    [pre_intra, pre_extra] = get_precision(distance.data, distance.label);
    

    
    fprintf('Draw ROC curve...\n');
    [best_ori, best_pro1, best_pro2] = drawROC_multiple(ori_intraPre, ori_extraPre,...
        pre_intra, pre_extra,...
        ori_intraPre.selectJoint, ori_extraPre.selectJoint);
    
    fprintf('Done!\n');
    cccc = 0;
    
    close all;
    ori(i).ori_intaPre = ori_intraPre;
    ori(i).ori_extraPre = ori_extraPre;
    pre(i).intra1 = pre_intra1;
    pre(i).intra2 = pre_intra2;
    pre(i).extra1 = pre_extra1;
    pre(i).extra2 = pre_extra2;
    ori_best(i).data = best_ori;
    pre_best(i).pro1 = best_pro1;
    pre_best(i).pro2 = best_pro2;
    toc
    ccc = 0;
end
    