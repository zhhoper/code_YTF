function drawGaussian(path, faceLabel, videoLabel, load_names, type, meanFeature, projection)
% [inter_s, intra_s] = get_var_video(path, faceLabel, videoLabel, load_names, type)
%
% INPUT:
% path : path whichh contains all data
% faceLabel : faceLabel for training
% videoLabel : video label for training
% load_names : names for the mat file
% type : 1 LBP, 2 FPLBP, 3 CSLbp
% OUTPUT:
% inter_s : inter class variation
% intra_s : intra class variation

faceIndex = unique(faceLabel);
numFaces = length(faceIndex);

% get the dimension of the data
DIM = size(projection, 2);

countFrames = 0;
countVideos = 0;
meanEachFace = zeros(numFaces, DIM);

numStep = 1;  % Select samples every 20 frames

% get the mean of the feature
for i = 1 : numFaces
    tmpFace = faceIndex(i);
    tIndex = faceLabel == tmpFace;
    vIndex = videoLabel(tIndex);
    tmpNum = length(vIndex);
    numFrameEachFace = 0;
    for j = 1 : tmpNum
        countVideos = countVideos + 1;
        tmp = load(strcat(path, load_names{vIndex(j)}));
        if type == 1
            tmpFeature = tmp.VID_DESCS_LBP';
        elseif type == 2
            tmpFeature = tmp.VID_DESCS_FPLBP';
        elseif type == 3
            tmpFeature = tmp.VID_DESCS_CSLBP';
        end
        
        tmpNum1 = size(tmpFeature,1);
        maxInd = tmpNum1/numStep;
        ind = 1:numStep:maxInd;
        tmpFeature = tmpFeature(ind, :);
        tmpNum1 = size(tmpFeature,1);
        
        countFrames = countFrames + tmpNum1;
        numFrameEachFace = numFrameEachFace + tmpNum1;
        tmpFeature = (tmpFeature - repmat(meanFeature, tmpNum1, 1))*projection; 
        meanEachFace(i,:) = meanEachFace(i,:) + sum(tmpFeature,1);
    end
    meanEachFace(i,:) = meanEachFace(i,:)/numFrameEachFace;
end

inter_s = meanEachFace'*meanEachFace/numFaces;
[V, D] = eig(inter_s);
D = diag(D);
[y, I] = sort(D(:), 'descend');
tmpInd = I(1:2);
projection1 = V(:, tmpInd);
fprintf('Energe 1 %f\n', sum(y(1:2))/sum(y));
meanVideos = zeros(countVideos, DIM);
indVideo = 0;
% get intra_s
intra_s = zeros(DIM, DIM);
for i = 1 : numFaces
    tmpFace = faceIndex(i);
    tIndex = faceLabel == tmpFace;
    vIndex = videoLabel(tIndex);
    tmpNum = length(vIndex);
    for j = 1 : tmpNum
        indVideo = indVideo + 1;
        tmp = load(strcat(path, load_names{vIndex(j)}));
        if type == 1
            tmpFeature = tmp.VID_DESCS_LBP';
        elseif type == 2
            tmpFeature = tmp.VID_DESCS_FPLBP';
        elseif type == 3
            tmpFeature = tmp.VID_DESCS_CSLBP';
        end
        
        tmpNum1 = size(tmpFeature,1);
        maxInd = tmpNum1/numStep;
        ind = 1:numStep:maxInd;
        tmpFeature = tmpFeature(ind, :);
        
        numFrames = size(tmpFeature, 1);
        tmpFeature = (tmpFeature - repmat(meanFeature, numFrames, 1))*projection;
        tmpFeature = tmpFeature - repmat(meanEachFace(i,:), numFrames, 1);
        
        meanVideos(indVideo,:) = mean(tmpFeature,1);
        intra_s = intra_s + (tmpFeature - repmat(meanVideos(indVideo,:), numFrames, 1))'*...
            (tmpFeature - repmat(meanVideos(indVideo,:), numFrames, 1));
    end
end

tmpVar = meanVideos'*meanVideos/numFaces;
[V, D] = eig(tmpVar);
D = diag(D);
[y, I] = sort(D(:), 'descend');
tmpInd = I(1:2);
projection2 = V(:, tmpInd);
fprintf('Energe 2 %f\n', sum(y(1:2))/sum(y));

intra_s = intra_s / countFrames;
[V, D] = eig(intra_s);
D = diag(D);
[y, I] = sort(D(:), 'descend');
tmpInd = I(1:2);
projection3 = V(:, tmpInd);
fprintf('Energe 3 %f\n', sum(y(1:2))/sum(y));

% projection intra
coord1 = [];
coord2 = [];
for i = 1 : numFaces
    tmpFace = faceIndex(i);
    tIndex = faceLabel == tmpFace;
    vIndex = videoLabel(tIndex);
    tmpNum = length(vIndex);
    for j = 1 : tmpNum
        tmp = load(strcat(path, load_names{vIndex(j)}));
        if type == 1
            tmpFeature = tmp.VID_DESCS_LBP';
        elseif type == 2
            tmpFeature = tmp.VID_DESCS_FPLBP';
        elseif type == 3
            tmpFeature = tmp.VID_DESCS_CSLBP';
        end
        
        tmpNum1 = size(tmpFeature,1);
        maxInd = tmpNum1/numStep;
        ind = 1:numStep:maxInd;
        tmpFeature = tmpFeature(ind, :);
        
        numFrames = size(tmpFeature, 1);
        tmpFeature = (tmpFeature - repmat(meanFeature, numFrames, 1))*projection;
        tmpFeature = tmpFeature - repmat(meanEachFace(i,:), numFrames, 1);
        
        tmpMeanFeature = mean(tmpFeature,1);
        meanCoord = tmpMeanFeature*projection2;
        coord1 = [coord1; meanCoord];
%         figure(f1);
%         plot(meanCoord(:,1), meanCoord(:,2));
%         hold on;
        
        tmpFeature = tmpFeature - repmat(tmpMeanFeature, numFrames, 1);
        coord = tmpFeature*projection3;
        coord2 = [coord2; coord];
        ccc = 0;
%         figure(f2);
%         plot(coord(:,1), coord(:, 2), '.', 'MarkerSize');
%         hold on;
    end
end
figure;
plot(coord1(:,1),coord1(:,2), '.', 'MarkerSize', 1);
figure;
plot(coord2(:,1),coord2(:,2), '.', 'MarkerSize', 1);
ccc = 0;
for i = 1 : 4
    tmpFace = faceIndex(i);
    tIndex = faceLabel == tmpFace;
    vIndex = videoLabel(tIndex);
    tmpNum = length(vIndex);
    for j = 1 : tmpNum
        tmp = load(strcat(path, load_names{vIndex(j)}));
        if type == 1
            tmpFeature = tmp.VID_DESCS_LBP';
        elseif type == 2
            tmpFeature = tmp.VID_DESCS_FPLBP';
        elseif type == 3
            tmpFeature = tmp.VID_DESCS_CSLBP';
        end
        
        tmpNum1 = size(tmpFeature,1);
        maxInd = tmpNum1/numStep;
        ind = 1:numStep:floor(maxInd*numStep);
        tmpFeature = tmpFeature(ind, :);
        
        numFrames = size(tmpFeature, 1);
        tmpFeature = (tmpFeature - repmat(meanFeature, numFrames, 1))*projection;
        tmpFeature = tmpFeature - repmat(meanEachFace(i,:), numFrames, 1);
        tmpMean = mean(tmpFeature,1);
        
        tmpFeature = tmpFeature - repmat(tmpMean, numFrames, 1);
        coord = tmpFeature*projection3;
        %tmpFeature = tmpFeature*proj;
        
        figure;
        plot(coord(:,1), coord(:,2), 'r.');
        ccc = 0;
%         if i == 1
%            
%             if j == 1
%                 plot(coord(:,1), coord(:, 2), 'g.');
%                 hold on;
%             elseif j == 2
%                 plot(coord(:,1), coord(:, 2), 'r.');
%                 hold on;
%             elseif j == 3
%                 plot(coord(:,1), coord(:, 2), 'b.');
%             end
%         elseif i == 2
%            
%             if j == 1
%                 plot(coord(:,1), coord(:, 2), 'g.');
%                 hold on;
%             elseif j == 2
%                 plot(coord(:,1), coord(:, 2), 'r.');
%                 hold on;
%             elseif j == 3
%                 plot(coord(:,1), coord(:, 2), 'b.');
%             end
%         elseif i == 3
%            
%             if j == 1
%                 plot(coord(:,1), coord(:, 2), 'g.');
%                 hold on;
%             elseif j == 2
%                 plot(coord(:,1), coord(:, 2), 'r.');
%                 hold on;
%             elseif j == 3
%                 plot(coord(:,1), coord(:, 2), 'b.');
%             end
%         elseif i == 4
%             
%             if j == 1
%                 plot(coord(:,1), coord(:, 2), 'g.');
%                 hold on;
%             elseif j == 2
%                 plot(coord(:,1), coord(:, 2), 'r.');
%                 hold on;
%             elseif j == 3
%                 plot(coord(:,1), coord(:, 2), 'b.');
%             end
%         end
    end
end


figure;
for i = 1 : numFaces
    tmp = meanEachFace(i,:)*projection1;
    plot(tmp(:,1), tmp(:,2), '.');
    hold on;
end


end




