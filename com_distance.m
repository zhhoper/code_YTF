function dist = com_distance(f1, f2, id, video, noise)

num1 = size(f1,1);
num2 = size(f2,1);
DIM = size(f1, 2);

[F, G] = inv_covariance(id.var + video.var, noise.var, num2);
tmpMean = id.mean + video.mean + noise.mean;
tmpF2 = f2 - repmat(tmpMean, num2, 1);
sumF2 = sum(tmpF2, 1);
adapt_mean = tmpMean + (id.var*(F + num2*G)*sumF2')';

tmpVar = id.var*(num2*F + num2^2*G)*id.var;

tmpInter = id.var + video.var - tmpVar;
tmpIntra = noise.var;
tmpF1 = f1 - repmat(adapt_mean, num1, 1);
[F1, G1] = inv_covariance(tmpInter, tmpIntra, num1);
tmp1 = trace(tmpF1*F1*tmpF1') + sum(tmpF1,1)*G1*sum(tmpF1, 1)';

tmpInter2 = id.var + video.var;
tmpIntra2 = noise.var;

[F2, G2] = inv_covariance(tmpInter2, tmpIntra2, num1);
tmpF1 = f1 - repmat(tmpMean, num1, 1);
tmp2 = trace(tmpF1*F2*tmpF1') + sum(tmpF1, 1)*G2*sum(tmpF1,1)';

% compute the determinant
eig1 = eig(tmpInter);
eig2 = eig(tmpInter2);

A1 = pinv(tmpInter)*tmpIntra + eye(DIM);
A2 = pinv(tmpInter2)*tmpIntra2 + eye(DIM);
logDet1 = spec_determin(A1, num1) + num1*sum(log(abs(eig1)));
logDet2 = spec_determin(A2, num1) + num1*sum(log(abs(eig2)));

dist = tmp2 - tmp1 + logDet2 - logDet1;
end