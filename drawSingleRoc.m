function bestResult = drawSingleRoc(pre_intra, pre_extra)
% bestResult = drawSingleRoc(pre_intra, pre_extra)
%
% This function is used to draw ROC curve
% INPUT:
% pre_intra : intra precision
% pre_extra : extra precision
% OUTPUT:
% bestResult : show the best results

bestResult = max((1 + pre_intra - pre_extra)/2);

line_width = 2;
figure;
plot(pre_intra, pre_extra, 'b-', 'LineWidth', line_width);
hold on;

end