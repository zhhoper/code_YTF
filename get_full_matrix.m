function A = get_full_matrix(inv_cov)
% A = get_full_matrix(inv_cov)
%
% This function is used to get the full matrix based on the structured
% matrix we computed 

A = [];
numSize = inv_cov.size;
numOffDiag = length(inv_cov.offDiag);

for i = 1 : numSize
    F = inv_cov.diag(i).F;
    G = inv_cov.diag(i).G;
    num = inv_cov.diag(i).num;
    tmpG = repmat(G, num, num);
    
    count = 0;
    tmpF = [];
    while count < num
        tmpF = blkdiag(tmpF, F);
        count = count + 1;
    end
    tmp = tmpF + tmpG;
    ind = get_index(numOffDiag, i);
    tmpA = [];

    lastElem = i - 1;
    tmpInd = ind(end - lastElem + 1 : end);
    for k = 1 : length(tmpInd)
        data = inv_cov.offDiag(tmpInd(k)).data;
        tmpA = [tmpA, repmat(data, inv_cov.offDiag(tmpInd(k)).num2, inv_cov.offDiag(tmpInd(k)).num1)];
    end
    tmpA = [tmpA, tmp];
    for k = 1 : length(ind) - lastElem
        data = inv_cov.offDiag(ind(k)).data;
        tmpA = [tmpA, repmat(data, inv_cov.offDiag(ind(k)).num1, inv_cov.offDiag(ind(k)).num2)];
    end
    
    A = [A; tmpA];
end