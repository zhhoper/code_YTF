function [best_ori, best_pro] = drawROC(ori_intraPre, ori_extraPre, proposed_intraPre, proposed_extrPre)
% [best_ori, best_pro] = drawROC(ori_intraPre, ori_extraPre, proposed_intraPre, proposed_extrPre)
% 
% draw ROC curve and compute the best precision score

best_ori.mean = max((1+ori_intraPre.mean - ori_extraPre.mean)/2);
best_ori.min = max((1+ori_intraPre.min - ori_extraPre.min)/2);
best_ori.max = max(1+ori_intraPre.max - ori_extraPre.max)/2;
best_ori.median = max(1+ori_intraPre.median - ori_extraPre.median)/2;
best_ori.fmean = max(1+ori_intraPre.fmean - ori_extraPre.fmean)/2;
best_pro = max(1 + proposed_intraPre - proposed_extrPre)/2;

line_width = 2;
figure;
plot(ori_extraPre.mean, ori_intraPre.mean, 'b-', 'LineWidth', line_width);
hold on;
plot(ori_extraPre.min, ori_intraPre.min, 'g-', 'LineWidth', line_width);
hold on;
plot(ori_extraPre.max, ori_intraPre.max, 'k-', 'LineWidth', line_width);
hold on;
plot(ori_extraPre.median, ori_intraPre.median, 'm-', 'LineWidth', line_width);
hold on;
plot(ori_extraPre.fmean, ori_intraPre.fmean, 'b-.', 'LineWidth', line_width);
hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot(proposed_extrPre, proposed_intraPre, 'r-', 'LineWidth', line_width);

legend(sprintf('mean: %f', best_ori.mean), sprintf('min: %f', best_ori.min), ...
    sprintf('max: %f', best_ori.max), sprintf('median: %f', best_ori.median),...
    sprintf('fmean: %f', best_ori.fmean), sprintf('proposed: %f', best_pro));

end