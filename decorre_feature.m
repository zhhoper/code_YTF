function def = decorre_feature(f, epson, numFrames)
% f = decorre_feature(f, num)
%
% This function is used to decorrelate frames within one video using
% auto-regression model
% INPUT:
% f : original feature
% epson : the noise part which is used to decorrelation
% numFrames : number of previouse frames used to decorrelate
% OUTPUT:
% f : decorrelated feature (we remove the first few frames)

num = size(f,1);
dim = size(f,2);

% helper is used to fast compute the matrix we needed
helper = epson*epson;

startInd = numFrames + 1;
A = zeros(numFrames, numFrames);
b = zeros(numFrames, numFrames);

for i = startInd : num
    A = A + helper(i-numFrames : i-1, i - numFrames, i-1);
    b = b + helper(i-numFrames : i-1, i); 
end
% Aw = b
W = A\b;

def = zeros(num-numFrames, dim);
for i = 1 : num - numFrames
    def(i,:) = (f(i : i+numFrames-1, :)'*w)';
end

end