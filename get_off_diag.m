function cov_matrix = get_off_diag(inv_A, id_var, F, G, numD)
% cov_matrix = get_off_diag(inv_A, id_var, F, G, numD)
%
% This function is a help function to compute the invers of a structured
% matrix [A, B; C, D]
% This function is used to compute inv(A)*B*inv(D - C*inv(A)*B)
% INPUT:
% inv_A : a struct to indicate the inverse of A
% id_var : elements in B and C 
% inv(D-C*inv(A)*B) is a structed matrix with diagonal elements being F + G
% and off-diagonal elements being G
% OUTPUT:
% a struct indicating the cov_matrix (it is a blog matrix which has the
% form [x1;x2;x3...]

% Suppose inv_A is a numSize * numSize block matrix, the cov_matrix has
% numSize distict elements
numSize = inv_A.size;
numOffSize = length(inv_A.offDiag);
% the Element for B*inv(D - C*inv(A)*B)
tmpMatrix = id_var*(F + numD*G);
cov_matrix = struct;
for i = 1 : numSize
    % dealing with diagnal
    numDiag = inv_A.diag(i).num;
    tmp = inv_A.diag(i).F + numDiag*inv_A.diag(i).G;
    
    if numOffSize ~= 0
        ind = get_index(numOffSize, i);
        for j = 1 : length(ind)
            numOff = inv_A.offDiag(ind(j)).num2;
            tmp = tmp + numOff*inv_A.offDiag(ind(j)).data;
        end
    end
    
    cov_matrix(i).num1 = numDiag;
    cov_matrix(i).num2 = numD;
    cov_matrix(i).data = tmp*tmpMatrix;
end

end