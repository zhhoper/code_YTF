function [F, G] = inv_covariance(inter_s, intra_s, m)
% this function is used to compute the inverse of the covariance matrix
% which is composed by F and G. This implementation is based on
% supplementary materials of joint bayesian paper
% m is the number of training samples 

F = pinv(intra_s);
G = -pinv(m*inter_s + intra_s)*inter_s*F; 
F = (F + F')/2;
G = (G + G')/2;
end


