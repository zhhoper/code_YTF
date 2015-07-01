function inv_value = get_struct_inv(id_var, video_var, noise_var, numElem)
% inv_value = get_struct_inv(id_var, video_var, noise_var)
%
% This function is used to compute the inver of a matrix with a specific
% structure,
% INPUT:
% id_var :  covarinace matrix for id variable,
% video_var : covariance matrix for video variable
% noise_var : covariance matrix for noise variable
% numElem   : number of frames for each video
% OUTPUT:
% inv_value : a struct containing the elements to form the inverse of the
% matrix (specify it later)

inv_value = struct;
numVideo = length(numElem);

if numVideo == 1
    % we only have one video now
    [F, G] = inv_covariance(id_var + video_var, noise_var, numElem);
    inv_value.size = 1;
    inv_value.diag = struct;
    inv_value.diag(1).F= F;
    inv_value.diag(1).G = G;
    inv_value.diag(1).num = numElem;
    inv_value.offDiag = [];  % For the first level, there is no off diagonal.
else
    % We have multiple videos
    % Let's decompose the matrix in the following way:
    % [A, B; C, D], and D only contains one block of video
    
    % Get the inverse of D
    numD = numElem(numVideo);
    [F, G] = inv_covariance(id_var+video_var, noise_var, numD);
    
    % Get the inverse of A
    inv_A = get_struct_inv(id_var, video_var, noise_var, numElem(1:end-1));
    
    % compute the element for B*inv(D)*C
    tmpVar1 = get_cov_simple(F, G, id_var, numD);
    
    % compute inv(A - B*inv(D)*C) by calling the function again
    tmpValue = get_struct_inv(id_var - tmpVar1, video_var, noise_var, numElem(1:end-1));
    
    % compute the element for C*inv(A)*B
    tmpVar2 = get_cov_complicate(inv_A, id_var);
    
    % compute inv(D - C*inv(A)*B)
    [F, G] = inv_covariance(id_var + video_var - tmpVar2, noise_var, numD);
    
    % compute inv(A)*B*inv(D - C*inv(A)*B)
    tmpOffDiag = get_off_diag(inv_A, id_var, F, G, numD);
    
    % get the inv_value
    inv_value.size = inv_A.size + 1;
    inv_value.diag = inv_A.diag;
    inv_value.offDiag = inv_A.offDiag;
    
    numDiag = length(inv_value.diag);
    inv_value.diag(numDiag+1).F = F;
    inv_value.diag(numDiag+1).G = G;
    inv_value.diag(numDiag+1).num = numD;
    
    numOff = length(inv_value.offDiag);
    for j = 1 : length(tmpOffDiag)
        inv_value.offDiag(numOff + j).data = -tmpOffDiag(j).data;
        inv_value.offDiag(numOff + j).num1 = tmpOffDiag(j).num1;
        inv_value.offDiag(numOff + j).num2 = tmpOffDiag(j).num2;
    end
end

end