function im3 = stitch(im1,im2)

if nargin<1
    im1 = single(rgb2gray(imread('boat/left.jpg')));
    im2 = single(rgb2gray(imread('boat/right.jpg')));
end

%find matching points
[f1,d1] = vl_sift(im1);
[f2,d2] = vl_sift(im2);
[matches, ~] = vl_ubcmatch(d1, d2) ;
f1match=f1(:,matches(1,:));
f2match=f2(:,matches(2,:));
p1 = f1match(1:2,:);
p2 = f2match(1:2,:);

%perform RANSAC to find transformation
[T, M] = RANSAC(1000,p1,p2);
%transform the 2cnd image

A = [M,T;0,0,1];
tA = maketform('affine',A');
tI = maketform('affine',eye(3));

[h,w] = size(im1);
[h2,w2] = size(im2);
newcorners = A*[1,w,1,w;1,1,h,h;1,1,1,1];
minXY = min([newcorners [w2;h2;1]],[],2);
maxXY = max([newcorners [w2;h2;1]],[],2);

Xdata = [minXY(1), maxXY(1)];
Ydata = [minXY(2), maxXY(2)];

imt1 = imtransform(im1,tA,'Xdata',Xdata,'Ydata',Ydata,'FillValues',NaN);
imt2 = imtransform(im2,tI,'Xdata',Xdata,'Ydata',Ydata,'FillValues',NaN);
[nh, nw] = size(imt1);
im3 = nanmean([imt1(:),imt2(:)],2);
im3 = reshape(im3,nh,nw);

end

