function dist = com_distance_adapted_2(x1, x2, id, video, noise, W1, W2)
% dist = com_distance_adapted(x1, x2, id, video, noise, num1, num2)
% 
% this function is used to compute the adapted distance 
% Don't forget the determinant part

inter_s = id.var;
intra_s1 = video.var + sum(W1.^2)*noise.var;
intra_s2 = video.var + sum(W2.^2)*noise.var;

tmp1 = inter_s + intra_s1;
tmpV1 = pinv(tmp1); % also inv(A11)
tmp2 = inter_s + intra_s2;
tmpV2 = pinv(tmp2); % also inv(A22)

tA11 = pinv(tmp1 - inter_s*tmpV2*inter_s);
tA22 = pinv(tmp2 - inter_s*tmpV1*inter_s);
tA12 = -tmpV1*inter_s*tA22;

dist = x1*(tmpV1 - tA11)*x1' + x2*(tmpV2 - tA22)*x2' - 2*x1*tA12*x2';

eigValue1 = eig([inter_s + intra_s1, inter_s; inter_s, inter_s+intra_s2]);
eigValue2 = eig(inter_s + intra_s1);
eigValue3 = eig(inter_s + intra_s2);
dist = dist + sum(log(abs(eigValue2))) + sum(log(abs(eigValue3))) - sum(log(abs(eigValue1)));
end