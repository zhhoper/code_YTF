function det_x = spec_determin(A, k)
% det_x = spec_determin(A, k)
%
% This function is used to compute the log determinant of a special matrix
% [A, I, I...; I, A, I...]. 
% NOTE : A-I must be positive definite
% INPUT:
% A : matrix on the diagonal
% k : number of block on each row/column
% OUTPUT:
% x : the log determinant

[dim, ~] = size(A);
tmpA = A - eye(dim);
tmpB = A + (k-1)*eye(dim);

D1 = eig(tmpA);
D2 = eig(tmpB);

det_x = (k-1)*sum(log(abs(D1))) + sum(log(abs(D2)));