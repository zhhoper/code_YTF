function distance = get_distance_three(pair, path, load_names, meanFeature, projection, id, video, noise, type)
% distance = get_distance_three(pair, path, load_names, meanFeature, projection, id, video, noise, type)
%
% This function is used to compute the distance of two videos using our
% proposed three variable model of joint bayesian
% INPUT:
% pair : indicating which two videos to compute
% load_names : loading name of videos
% meanFeature : mean feature for PCA
% projection : projection matrix for PCA
% id : variable id
% video : variable video
% noise : variable noise
% type : type of feature we want to use
% OUTPUT:
% distance : distance.label indicate whether two videos are the same or not
%            distance.data contains the distance

num = size(pair,1);
distance = struct;

% initialize the distance to zero
distance.label = pair(:,3);
distance.data = zeros(num,1);

for i = 1 : num
    I1 = pair(i,1);
    I2 = pair(i,2);
    f1 = load(strcat(path, load_names{I1}));
    f2 = load(strcat(path, load_names{I2}));
    
    % loading features based on type
    if type == 1
        f1 = f1.VID_DESCS_LBP';
        f2 = f2.VID_DESCS_LBP';
    elseif type == 2
        f1 = f1.VID_DESCS_FPLBP';
        f2 = f2.VID_DESCS_FPLBP';
    elseif type == 3
        f1 = f1.VID_DESCS_CSLBP';
        f2 = f2.VID_DESCS_CSLBP';
    end
    
    num1 = size(f1,1);
    num2 = size(f2,1);
    % project using pca
    f1 = (f1 - repmat(meanFeature, num1, 1))*projection;
    f2 = (f2 - repmat(meanFeature, num2, 1))*projection;
    
    
    % decorrelate features between frames
    numFrames = 5; % number of previous frames used to decorrelate
    [~, epson1] = decompose_video(f1, id, video, noise);
    [~, epson2] = decompose_video(f1, id, video, noise);
    f1 = decorre_feature(f1, epson1, numFrames);
    f2 = decorre_feature(f2, epson2, numFrames);
    
    % compute distance
    num1 = size(f1,1);
    num2 = size(f2,1);
    [F, G] = inv_covariance(id.var + video.var, noise.var, num2);
    tmpMean = id.mean + video.mean + noise.mean;
    tmpF2 = f2 - repmat(tmpMean, num2, 1);
    sumF2 = sum(tmpF2, 1);
    adapt_mean = tmpMean + (id.var*(F + num2*G)*sumF2')';
    
    tmpVar = id.var*(num2*F + num2^2*G)*id.var;
    
    tmpInter = id.var + video.var - tmpVar;
    tmpIntra = noise.var;
    tmpF1 = f1 - repmat(adapt_mean, num1, 1);
    [F1, G1] = inv_covariance(tmpInter, tmpIntra, num1);
    tmp1 = trace(tmpF1*F1*tmpF1') + sum(tmpF1,1)*G1*sum(tmpF1, 1)';
    
    tmpInter2 = id.var + video.var;
    tmpIntra2 = noise.var;
    
    [F2, G2] = inv_covariance(tmpInter2, tmpIntra2, num1);
    tmpF1 = f1 - repmat(tmpMean, num1, 1);
    tmp2 = trace(tmpF1*F2*tmpF1') + sum(tmpF1, 1)*G2*sum(tmpF1,1)';
    
    % compute the determinant
    eig1 = eig(tmpInter);
    eig2 = eig(tmpInter2);
    
    A1 = pinv(tmpInter)*tmpIntra + eye(DIM);
    A2 = pinv(tmpInter2)*tmpIntra2 + eye(DIM);
    logDet1 = spec_determin(A1, num1) + num1*sum(log(abs(eig1)));
    logDet2 = spec_determin(A2, num1) + num2*sum(log(abs(eig2)));
    
    distance.data(i) = tmp2 - tmp1 + logDet2 - logDet1;
    
end

end