function [pViewMat,coorMat]=buildPVmat(Load)
type='b';

close all
if nargin<1
    Load = 1;
    type='b';
end

% load the descriptors of the images house
if type=='h'
    display('loading house pictures')
    am=19;
    dataLoc = cell(1,am);
    hesLoc = cell(1,am);
    featInd1H = cell(1,am);
    featInd2H = cell(1,am);
    featCoor1H = cell(1,am);
    featCoor2H = cell(1,am);
    for i = 1:am
        dataLoc{i} = ['house/8ADT',num2str(8585+i),'.png.haraff.sift'];
        hesLoc{i} = ['house/8ADT',num2str(8585+i),'.png.hesaff.sift'];
    end
end



% load the descriptors of the images BEAR
if type=='b'
    display('loading bear pictures')
    am=16;
    dataLoc = cell(1,am);
    hesLoc = cell(1,am);
    featInd1 = cell(1,am);
    featInd2 = cell(1,am);
    featCoor1 = cell(1,am);
    featCoor2 = cell(1,am);
    for i = 1:am
        dataLoc{i} = ['Teddy/HarSift/obj02_',num2str(i,'%03d'),'.png.haraff.sift'];
        hesLoc{i} = ['Teddy/HesSift/obj02_',num2str(i,'%03d'),'.png.hesaff.sift'];
    end
end
N = 200; %run RANSAC N times

% calculate the matches between the two images
if Load
    if type=='b'
    load('featInd1','featInd1');
    load('featInd2','featInd2');
    load('featCoor1','featCoor1');
    load('featCoor2','featCoor2');
    end
    if type=='h'
	load('featInd1H','featInd1H');
    load('featInd2H','featInd2H');
    load('featCoor1H','featCoor1H');
    load('featCoor2H','featCoor2H');
    end
else
    %if you get an error here please load the feat toolbox
    for i = 1:16 % later tot 16
        [~,featInd1{i},featInd2{i},featCoor1{i},featCoor2{i}]= ...
            estFunMatrix(dataLoc{i},dataLoc{mod(i,16)+1},hesLoc{i},hesLoc{mod(i,16)+1},N);
    end
 end
save('help/featInd1','featInd1');
save('help/featInd2','featInd2');
save('help/featCoor1','featCoor1');
save('help/featCoor2','featCoor2');
% the Point-view matrix, every row represents an image and every column a
% point. On the rows the images are from 1 to 16
% also filling it for the first time
if type=='h'
    featCoor1=featCoor1H;
    featCoor2=featCoor2H;
    featInd1=featInd1H;
    featInd2=featInd2H;
end

pViewMat = zeros(am,size(featInd1{1},2));
pViewMat(1:2,:) = 1;
coorMat = zeros(am,2*size(featInd1{1},2));
coorMat(1,1:2:end) = featCoor1{1}(:,1);
coorMat(1,2:2:end) = featCoor1{1}(:,2);
coorMat(2,1:2:end) = featCoor2{1}(:,1);
coorMat(2,2:2:end) = featCoor2{1}(:,2);

% pViewMat = sparse(pViewMat);
% coorMat = sparse(coorMat);

newInd = 1:size(featInd1{1},2);
%zeros(size(featInd1{2},2),1);
for m = 2:am-1
    oldInd = newInd;
    newInd = zeros(size(featInd1{m},2),1);
    for i = 1:size(featInd1{m},2)
        ind = find(featInd2{m-1}==featInd1{m}(i),1,'first');
        if isempty(ind)
            newColumn = zeros(am,1);
            newColumn(m:m+1) = 1;
            newCoor = zeros(am,2);
            newCoor(m:m+1,:) = [featCoor1{m}(i,1:2);featCoor2{m}(i,1:2)];
            
            pViewMat = [pViewMat,newColumn];
            coorMat = [coorMat,newCoor];
            newInd(i) = size(pViewMat,2);
        else
            pViewMat(m+1,oldInd(ind)) = 1;
            try 
                coorMat(m+1,oldInd(ind)*2-1:oldInd(ind)*2) = featCoor2{m}(i,1:2);
            catch exception
                throw(exception);
            end
            newInd(i) = oldInd(ind);
        end
    end
end

%Load images
im = cell(1,am);
if type=='b'
for i = 1:am
im{i} = imread(['Teddy/obj02_',num2str(i,'%03d'),'.png']);
end
end

if type=='h'
for i = 1:am
    im{i} = imread(['house\8ADT',num2str(8585+i),'.png']);
end 
end

%show some of the images with matched point connected in images
n=13;
ind=find(sum(pViewMat,1)>2);
P=pViewMat(:,ind);
coX=coorMat(:,1:2:end);
coX=coX(:,ind);
coY=coorMat(:,2:2:end);
coY=coY(:,ind);
for i = 1:3
    figure(i)
    imshow(im{i})
    hold on;
    plot(coX(i,400),coY(i,400),'ro');
end

for i=1:size(pViewMat,1)
    sum(P(i,:))
end

end
