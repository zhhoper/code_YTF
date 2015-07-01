function cov_matrix = get_cov_complicate(inv_A, intra_s)
% get_cov_complicate(inv_A, id_var, sum(numElem(1:end-1)))
%
% This function is a help function to compute the invers of a structured
% matrix [A, B; C, D]
% This function is used to compute C*inv(A)*B.
% INPUT:
% B is a num1*num block matrix with each block being intra_s.
% C is a num*num block matrix with each block being intra_s.
% inv(A) is a num*num matrix, whose elemensts are indicated by inv_A
% we ignore num1 and num because they are not usefull here
% OUTPUT:
% the result is a block matrix with all elements being intra_s
% *sum(sum(inv(A))*intra_s, here, we only return the elements 

numDiag = length(inv_A.diag);
numOffDiag = length(inv_A.offDiag);

DIM = size(inv_A.diag(1).F, 1);
inv_matrix = zeros(DIM, DIM);

for i = 1 : numDiag
    tmp1 = inv_A.diag(i).num*(inv_A.diag(i).F + inv_A.diag(i).num*inv_A.diag(i).G);
    inv_matrix = inv_matrix + tmp1;
end

for i = 1 : numOffDiag
    tmp1 = 2*inv_A.offDiag(i).num1* inv_A.offDiag(i).num2*data;
    inv_matrix = inv_matrix + tmp1;
end

cov_matrix = intra_s * inv_matrix * intra_s;
end