function cov_matrix = get_cov_simple(F, G, intra_s, num)
% cov_matrix = get_cov_simple(F, G, intra_s, num)
%
% This function is a help function to compute the invers of a structured
% matrix [A, B; C, D]
% This function is used to compute B*inv(D)*C.
% INPUT:
% B is a num1*num block matrix with each block being intra_s.
% C is a num*num1 block matrix with each block being intra_s.
% inv(D) is a num2*num2 block matrix, with diagonal block being F + G and
% off-diagonal elements being G
% we ignore num1 because it is not useful here.
% OUTPUT:
% the result is a block matrix with all elements being intra_s
% *sum(sum(inv(D))*intra_s, here, we only return the elements 

cov_matrix = intra_s*(num*F + num^2*G)*intra_s;

end