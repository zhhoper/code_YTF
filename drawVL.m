function info = drawVL(labels, scores)
% info = drawVL(labels, scors)
%
% This function is used to compute the auc and eer using vl-feat 
run('~/CodeLib/vlfeat-0.9.19_2/toolbox/vl_setup.m');

[~, ~, info] = vl_roc(labels, scores);
disp(info.auc) ;
disp(info.eer) ;
end