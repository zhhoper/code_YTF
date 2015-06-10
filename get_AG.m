function [A, G] = get_AG(inter_s, intra_s)
% this function is used to get A and G in paper Joint Bayesian based on
% inter and intra class variance
[row, col] = size(inter_s);

tmp = [intra_s + inter_s, inter_s; inter_s, intra_s+inter_s];
inv_tmp = pinv(tmp);

G = inv_tmp(1:row, 1+col:end);
A = pinv(inter_s + intra_s) - inv_tmp(1:row, 1:col);
end