function [dist1, dist2] = com_distance_withoutCross(x1, x2, id, video, noise)
% dist = com_distance_withoutCross(x1, x2, id, video, noise)
%
% This function is used to compute the distance of two videos without
% considering the cross term between each frame in the same video


num1 = size(x1,1);
num2 = size(x2,1);
numElem = [num1; num2];

inv_value = get_struct_inv(id, video, noise, numElem);

[F1, G1] = inv_covariance(id + video, noise, num1);
[F2, G2] = inv_covariance(id + video, noise, num2);

aF1 = inv_value.diag(1).F;
aG1 = inv_value.diag(1).G;
aF2 = inv_value.diag(2).F;
aG2 = inv_value.diag(2).G;

A1 = F1 + G1 - aF1 - aG1;  % quadratic term for the first video
A2 = F2 + G2 - aF2 - aG2;  % quadratic term for the second video
B = inv_value.offDiag.data; % corss term for frames in first and second video
C1 = G1 - aG1;  % cross term for frames in the first video
C2 = G2 - aG2;  % cross term for frames in the second video

dist1 = sum(diag(x1*A1*x1')) + sum(diag(x2*A2*x2')) - 2*sum(sum(x1*B*x2'));
dist2 = dist1 + (sum(sum(x1*C1*x1')) - sum(diag(x1*C1*x1'))) + (sum(sum(x2*C2*x2')) - sum(diag(x2*C2*x2')));

% dist1 = dist1 + detValue;
% dist2 = dist2 + detValue;
ccc = 0;
end