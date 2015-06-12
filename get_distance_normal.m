function distance = get_distance_normal(pair, path, load_names, meanFeature, projection, A, G, type)
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

for i = 1 : num
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
    
    tmpF1 = diag(f1*A*f1');
    tmpF2 = diag(f2*A*f2');
    tmpF12 = f1*G*f2';
    
    tmpF1 = repmat(tmpF1, 1, num2);
    tmpF2 = repmat(tmpF2', num1, 1);
    
    tmp1 = tmpF1 + tmpF2 - 2*tmpF12;
    tmp2 = triu(tmp1);
    ind = tmp1 == tmp2;
    t_distance = tmp1(ind);
    t_distance = t_distance(:);
    distance.mean(i) = mean(t_distance);
    distance.max(i) = max(t_distance);
    distance.min(i) = min(t_distance);
    distance.median(i) = median(t_distance);
end

end
