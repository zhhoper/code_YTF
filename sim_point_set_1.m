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

numFaces = 60;
for i = 1 : numFaces
    [allF(i).data, allG(i).data] = inv_covriance(inter_s, intra_s, i);
    all_varData(i).data = (inter_s + intra_s) - i*inter_s*(allF(i).data + i*allG(i).data)*inter_s;
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
        [F, G] = inv_covriance(inter_s, intra_s, i);
        varData = (inter_s + intra_s) - num2*inter_s*(F + num2*G)*inter_s;
        pvarData = pinv(varData);
        tEig = eig(varData);
        detData = sum(log(tEig));
        
    else
        F = allF(m).data;
        G = allG(m).data;
        varData = all_varData(m).data;
        pvarData = all_pvarData(m).data;
        detData = all_varData(m).det;
    end
    
    tmp = sum(f2,1);
    meanData = (inter_s*(F + m*G)*tmp')';
    
    % wrongly computed
    distance(i) = 0.5*f1*tvar*f1' - 0.5*(f1 - meanData)*pvarData*(f1 - meanData)'...
        + tdet_var - detData;

    % correctly computed
%     distance(i) = f1*tvar*f1' - (f1 - meanData)*pvarData*(f1 - meanData)'...
%         + tdet_var - detData;
    
end

end