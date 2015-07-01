function [mu, epson] = decompose_video(f, id, video, noise)
% [mu, epson] = decompose_video(f, id, video, noise)
%
% This function is used to comptue the mu and epson given the feature of
% the video
% INPUT:
% f : feature matrix, each row represents a feature of a frame
% id : prior distribution of id variable
% video : prior distribution of video variable
% noise : prior distribution of noise variable
% OUTPUT:
% mu : the u + v for the video
% epson : noise term

inter_s = id.var + video.var;
intra_s = noise.var;

mean1 = id.mean + video.mean + noise.mean;
mean2 = noise.mean;

num = size(f, 1);
[F, G] = inv_covariance(inter_s, intra_s, num);

tmpSum = sum(f, 1);
mu = mean1 + (inter_s*(F*tmpSum' + num*G*tmpSum'))';

epson = repmat(mean2', 1, num) + intra_s*(F*f' + repmat(num*G*tmpSum', 1, num));
epson = epson';

end