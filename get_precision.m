function [intra_pre, extra_pre] = get_precision(distance, label)
% [ori_intraPre, ori_extrPre] = get_precision(distance, label)
%
% This function is used to compute the intra and extra precision for
% drawing the curve
% INPUT:
% distance : the distance for each testing point
% label : label to indicate intra or extra testing
% OUTPUT:
% intra_pre : intra precision (true positive)
% extra_pre : extra precision (false positive);

minValue = min(distance);
maxValue = max(distance);
numStep = 10000;
step = (maxValue - minValue)/numStep;
threshold = minValue : step : maxValue;

num = length(threshold);
label = logical(label);
for i = 1 : num
    thr = threshold(i);
    ind = distance >= thr;
    tmp1 = ind(label);
    intra_pre(i) = sum(tmp1)/length(tmp1);
    tmp2 = ind(~label);
    extra_pre(i) = sum(tmp2)/length(tmp2);
end

end