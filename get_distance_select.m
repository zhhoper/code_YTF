function distance = get_distance_select(pair, path, load_names, meanFeature, projection, A, G, id, video, noise, type)
% distane = get_distance_normal(pair, path, load_names, A, G)
%
% This function is used to compute the distance of two video faces under
% the assumption of Joint Bayesin, using mean, min, median, max

num = size(pair,1);
distance = struct;
distance.label = pair(:,3);
distance.mean = zeros(num,1);
distance.max = zeros(num,1);
distance.median = zeros(num,1);
distance.min = zeros(num,1);
distance.featureMean = zeros(num,1);

% select two or more samples and compute the distance based on that
distance.selectMean = zeros(num,1);
distance.selectMin = zeros(num,1);
distance.selectJoint = zeros(num,1);
distance.selectNum1 = zeros(num,1);
distance.selectNum2 = zeros(num,1);
distance.selectFeatureMean = zeros(num,1);
distance.selectAdapt = zeros(num,1);
distance.withoutCross = zeros(num, 1);
distance.cross = zeros(num,1);
distance.combine = zeros(num,1);
distance.combine_adapt = zeros(num,1);
numSelect = 30;

%% harding coding for determinant
tmpa = id.var + video.var + noise.var;
tmpb = id.var + video.var;
tmpc = id.var;

tmpX = [tmpa, tmpb, tmpc, tmpc; tmpb, tmpa, tmpc, tmpc; tmpc, tmpc, tmpa, tmpb; tmpc, tmpc, tmpb, tmpa];
eig1 = eig(tmpX); % 2*2
tmpX = [tmpa, tmpb, tmpc; tmpb, tmpa, tmpc; tmpc, tmpc, tmpa];
eig2 = eig(tmpX); % 2*1
tmpX = [tmpa, tmpc, tmpc; tmpc, tmpa, tmpb; tmpc, tmpb, tmpa];
eig3 = eig(tmpX); % 1*2

eig4 = eig(tmpa); % only1
tmpX = [tmpa, tmpb; tmpb,tmpa];
eig5 = eig(tmpX); % 2 samples

%%

for i = 1 : num
    tic
    I1 = pair(i,1);
    I2 = pair(i,2);
    f1 = load(strcat(path, load_names{I1}));
    f2 = load(strcat(path, load_names{I2}));
    
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
    
    %%
    %     W1 = ones(num1, 1)/num1;
    %     W2 = ones(num2, 1)/num2;
    %     tmpOnes1 = ones(1, num1);
    %     tmpOnes2 = ones(1, num2);
    %     thr = 1;
    %     max_count = 50;
    %     diff = inf;
    %     count = 0;
    %     while diff > thr && count < max_count
    %         count = count + 1;
    %         oldW1 = W1;
    %         oldW2 = W2;
    %
    %         tvA1 = pinv(f1*A*f1');
    %         tB1 = f1*G*f2'*W2;
    %         W1 = tvA1*tB1 - (tmpOnes1*tvA1*tB1 -1)/(tmpOnes1*tvA1*tmpOnes1')*tvA1*tmpOnes1';
    %
    %         tvA2 = pinv(f2*A*f2');
    %         tB2 = f2*G*f1'*W1;
    %         W2 = tvA2*tB2 - (tmpOnes2*tvA2*tB2 -1)/(tmpOnes2*tvA2*tmpOnes2')*tvA2*tmpOnes2';
    %
    %         diff = norm(W1 - oldW1, 'fro') + norm(W2 - oldW2, 'fro');
    %     end
    %
    %     combine1 = (f1'*W1)';
    %     combine2 = (f2'*W2)';
    %     distance.combine(i) = combine1*A*combine1' + combine2*A*combine2' - 2*combine1*G*combine2';
    
    %%
    tmpF1 = diag(f1*A*f1');
    tmpF2 = diag(f2*A*f2');
    tmpF12 = f1*G*f2';
    
    tmpF1 = repmat(tmpF1, 1, num2);
    tmpF2 = repmat(tmpF2', num1, 1);
    
    tmp1 = tmpF1 + tmpF2 - 2*tmpF12;
    
    t_distance = tmp1(:);
    
    % try to use mean feature
    meanF1 = mean(f1, 1);
    meanF2 = mean(f2, 1);
    
    distance.featureMean(i) = meanF1*A*meanF1' + meanF2*A*meanF2' - 2*meanF1*G*meanF2';
    distance.mean(i) = mean(t_distance);
    distance.max(i) = max(t_distance);
    distance.min(i) = min(t_distance);
    distance.median(i) = median(t_distance);
    
    %% Select some features to compute the distance
    %     [tmpDist, index] = sort(t_distance, 'descend');
    %     tmpDist = tmpDist(1:numSelect);
    %     distance.selectMean(i) = mean(tmpDist);
    %     distance.selectMin(i) = min(tmpDist);
    %
    %     % Using joint method
    %     index = index(1:numSelect);
    %     ti = zeros(numSelect,1);
    %     tj = zeros(numSelect,1);
    %     for t = 1 : numSelect
    %         [ti(t), tj(t)] = ind2sub([num1, num2], index(t));
    %     end
    %     ti = unique(ti);
    %     tj = unique(tj);
    %     f1 = f1(ti,:);
    %     f2 = f2(tj,:);
    [tmpDist, index] = sort(t_distance, 'descend');
    numTotal = length(index);
    ti = zeros(numTotal, 1);
    tj = zeros(numTotal, 1);
    for t = 1 : length(index)
        [ti(t), tj(t)] = ind2sub([num1, num2], index(t));
    end
    ti = unique(ti);
    tj = unique(tj);
    ti = ti(1:numSelect);
    tj = tj(1:numSelect);
    f1 = f1(ti,:);
    f2 = f2(tj,:);
    
    tmpF1 = diag(f1*A*f1');
    tmpF2 = diag(f2*A*f2');
    tmpF12 = f1*G*f2';
    
    tmpF1 = repmat(tmpF1, 1, numSelect);
    tmpF2 = repmat(tmpF2', numSelect, 1);
    
    tmp1 = tmpF1 + tmpF2 - 2*tmpF12;
    
    t_distance = tmp1(:);
    distance.selectMean(i) = mean(t_distance);
    
    
%     tmpDist = tmpDist(1:numSelect);
%     distance.selectMean(i) = mean(tmpDist);
%     distance.selectMin(i) = min(tmpDist);
%     
%     % Using joint method
%     index = index(1:numSelect);
%     ti = zeros(numSelect,1);
%     tj = zeros(numSelect,1);
%     for t = 1 : numSelect
%         [ti(t), tj(t)] = ind2sub([num1, num2], index(t));
%     end
%     ti = unique(ti);
%     tj = unique(tj);
%     f1 = f1(ti,:);
%     f2 = f2(tj,:);
    
    tNum1 = size(f1, 1);
    tNum2 = size(f2, 1);
    distance.selectNum1(i) = tNum1;
    distance.selectNum2(i) = tNum2;
    %distance.selectJoint(i) = com_distance(f1, f2, id, video, noise);
    %%
    
    
    selectMean1 = mean(f1, 1);
    selectMean2 = mean(f2, 1);
    distance.selectFeatureMean(i) = selectMean1*A*selectMean1' + selectMean2*A*selectMean2' - 2*selectMean1*G*selectMean2';
    distance.selectAdapt(i) = com_distance_adapted(selectMean1, selectMean2, id, video, noise, tNum1, tNum2);
    
    
    
%     if tNum1 == 2 && tNum2 == 2
%         detValue = 2*sum(log(abs(eig5))) - sum(log(abs(eig1)));
%     elseif tNum1 ==2 && tNum2 == 1
%         detValue = sum(log(abs(eig4))) + sum(log(abs(eig5))) - sum(log(abs(eig2)));
%     elseif tNum1 == 1 && tNum2 == 2
%         detValue = sum(log(abs(eig4))) + sum(log(abs(eig5))) - sum(log(abs(eig3)));
%     end
    
    %[distance.withoutCross(i), distance.cross(i)] = com_distance_withoutCross(f1, f2, id.var, video.var, noise.var);
    
    
    %% linear combination
    W1 = ones(tNum1, 1)/tNum1;
    W2 = ones(tNum2, 1)/tNum2;
    tmpOnes1 = ones(1, tNum1);
    tmpOnes2 = ones(1, tNum2);
    lb1 = zeros(tNum1, 1);
    lb2 = zeros(tNum2, 1);
    ub1 = ones(tNum1, 1);
    ub2 = ones(tNum2, 1);
    thr = 1;
    max_count = 50;
    diff = inf;
    count = 0;
    while diff > thr && count < max_count
        count = count + 1;
        oldW1 = W1;
        oldW2 = W2;
        
        A1 = -f1*A*f1';
        B1 = f1*G*f2'*W2;
        %W1 = tvA1*tB1 - (tmpOnes1*tvA1*tB1 -1)/(tmpOnes1*tvA1*tmpOnes1')*tvA1*tmpOnes1';
        W1 = quadprog(A1, B1, [], [], tmpOnes1, 1, lb1, ub1, W1);
        
        A2 = -f2*A*f2';
        B2 = f2*G*f1'*W1;
        %W2 = tvA2*tB2 - (tmpOnes2*tvA2*tB2 -1)/(tmpOnes2*tvA2*tmpOnes2')*tvA2*tmpOnes2';
        W2 = quadprog(A2, B2, [], [], tmpOnes2, 1, lb2, ub2, W2);
        diff = norm(W1 - oldW1, 'fro') + norm(W2 - oldW2, 'fro');
    end
    
    combine1 = (f1'*W1)';
    combine2 = (f2'*W2)';
    distance.combine(i) = combine1*A*combine1' + combine2*A*combine2' - 2*combine1*G*combine2';
    distance.combine_adapt(i) = com_distance_adapted_2(combine1, combine2, id, video, noise, W1, W2);
    toc
    ccc = 0;
    
end

end
