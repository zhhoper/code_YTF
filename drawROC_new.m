function best_ori = drawROC_new(ori_intraPre, ori_extraPre)
% [best_ori, best_pro] = drawROC(ori_intraPre, ori_extraPre, proposed_intraPre, proposed_extrPre)
% 
% draw ROC curve and compute the best precision score

best_ori.mean = max((1+ori_intraPre.mean - ori_extraPre.mean)/2);
best_ori.min = max((1+ori_intraPre.min - ori_extraPre.min)/2);
best_ori.max = max((1+ori_intraPre.max - ori_extraPre.max)/2);
best_ori.median = max((1+ori_intraPre.median - ori_extraPre.median)/2);
best_ori.fmean = max((1+ori_intraPre.fmean - ori_extraPre.fmean)/2);
%best_ori.joint = max((1+ori_intraPre.selectJoint - ori_extraPre.selectJoint)/2);
%best_ori.withoutCross = max((1+ori_intraPre.withoutCross - ori_extraPre.withoutCross)/2);
best_ori.selectFeatureMean = max((1+ori_intraPre.selectFeatureMean - ori_extraPre.selectFeatureMean)/2);
best_ori.selectAdapt = max((1+ori_intraPre.selectAdapt - ori_extraPre.selectAdapt)/2);
best_ori.combine = max((1+ori_intraPre.combine - ori_extraPre.combine)/2);
best_ori.combine_adapt = max((1+ori_intraPre.combine_adapt - ori_extraPre.combine_adapt)/2);


line_width = 2;
figure;
plot(ori_extraPre.selectAdapt, ori_intraPre.selectAdapt, 'b-', 'LineWidth', line_width);
hold on;
plot(ori_extraPre.selectFeatureMean, ori_intraPre.selectFeatureMean, 'm-', 'LineWidth', line_width);
hold on;
plot(ori_extraPre.combine_adapt, ori_intraPre.combine_adapt, 'g-', 'LineWidth', line_width);
hold on;
plot(ori_extraPre.combine, ori_intraPre.combine, 'r-.', 'LineWidth', line_width);
hold on;
plot(ori_extraPre.max, ori_intraPre.max, 'k-', 'LineWidth', line_width);
hold on;
plot(ori_extraPre.fmean, ori_intraPre.fmean, 'r-', 'LineWidth', line_width);
hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot(proposed_extraPre1, proposed_intraPre1, 'r-', 'LineWidth', line_width);
% hold on;
% plot(proposed_extraPre2, proposed_intraPre2, 'k.-', 'LineWidth', line_width);

legend(sprintf('adapt: %f', best_ori.selectAdapt), sprintf('s-mean: %f', best_ori.selectFeatureMean), ...
    sprintf('com_adapt: %f', best_ori.combine_adapt), sprintf('combine:%f', best_ori.combine),...
    sprintf('max: %f', best_ori.max), sprintf('f-mean: %f', best_ori.fmean));

end