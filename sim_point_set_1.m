function distance = sim_point_set_1(pair, path, load_names, meanFeature, projection, inter_s, intra_s)
% distance = sim_point_set_1(pair, data, label, A, G)
%
% This function is used to compute the point to set distance we defined. We
% require that the number of set is at most 20.
% INPUT:
% pair : N by 2 matrix, each row contains the index of the pair
% data : data matrix, each row presents a data, data should be preprocessed
% label : label for each data
% inter_s, intra_s : used to compute the distance
% OUTPUT:
% distance : the similarity score for every pair of data

num = size(pair,1);
distance.label = pair(:,3);
distance.data = zeros(num,1);

allF = struct;
allG = struct;
all_varData = struct;
all_pvarData = struct;
tvar = pinv(inter_s + intra_s);
tEig = eig(inter_s + intra_s);
tdet_var = sum(log(tEig));

DIM = size(inter_s, 1);

numFaces = 100;
for i = 1 : numFaces
    [allF(i).data, allG(i).data] = inv_covriance(inter_s, intra_s, i);
    all_varData(i).data = i*inter_s*(allF(i).data + i*allG(i).data)*inter_s;
    tEig = eig(all_varData(i).data);
    all_varData(i).det = sum(log(tEig));
    all_pvarData(i).data = pinv(all_varData(i).data);
end


for i = 1 : num
    I1 = pair(i,1);
    I2 = pair(i,2);
    f1 = load(strcat(path, load_names(I1)));
    f2 = load(strcat(path, load_names(I2)));
    f1 = f1';
    f2 = f2';
    num1 = size(f1,1);
    num2 = size(f2,1);
    % project using pca
    f1 = (f1 - repmat(meanFeature, num1, 1))*projection;
    f2 = (f2 - repmat(meanFeature, num2, 1))*projection;
    
    if num2 > numFaces
        [F2, G2] = inv_covriance(inter_s, intra_s, num2);
        varData2 = num2*inter_s*(F2 + num2*G2)*inter_s;
        pvarData2 = pinv(varData2);
    else
        F2 = allF(num2).data;
        G2 = allG(num2).data;
        varData2 = all_varData(num2).data;
        pvarData2 = all_pvarData(num2).data;
    end
    
    if num1 > numFaces
        [F1, G1] = inv_covriance(inter_s, intra_s, num1);
        varData1 = num1*inter_s*(F1 + num1*G1)*inter_s;
        pvarData1 = pinv(varData1);
    else
        F1 = allF(num2).data;
        G1 = allG(num2).data;
        varData1 = all_varData(num2).data;
        pvarData1 = all_pvarData(num2).data;
    end
      
    meanCondition = inter_s*(F2 + num2*G2)*sum(f2);
    tmpf1 = f1 - repmat(meanCondition, num1, 1);
    
    t_inter_s = inter_s - varData2;
    [tF2, tG2] = inv_covriance(t_inter_s, intra_s, num1);
    
    tmp1 = trace(tmpf1'*tmpf1*tF2) + sum(tmpf1)*tG2*sum(tmpf1)';
    tmp2 = trace(f1'*f1*F1) + sum(f1)*G1*sum(f1)';
    
    A1 = intra_s * t_inter_s + eye(DIM);
    A2 = intra_s * inter_s + eye(DIM);
    logDet1 = spec_determin(A1, num1);
    logDet2 = spec_determin(A2, num2);
    
    distance.data(i) = tmp2 - tmp1 + logDet2 - logDet1;    
end

end