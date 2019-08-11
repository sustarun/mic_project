% A = load('../data/assignmentSegmentBrain.mat');
% orig_img = A.imageData;
orig_img1 = imread('../data/objects.jpg');
orig_img2=rgb2gray(orig_img1);
orig_img=double(orig_img2)./255;
% orig_img=phantom(256);
imshow(orig_img);
figure;

% Edge = edge(orig_img, 'sobel');
% imshow(Edge);
% title('Matlab sobel');
% figure;

B=orig_img;
C=orig_img;

maskx_3by3 = [-1,0,1; -2,0,2; -1,0,1];
masky_3by3 = [1,2,1; 0,0,0; -1,-2,-1];

for i=1:size(C,1)-2
    for j=1:size(C,2)-2
        %Sobel mask for x-direction:
%         Gx=((2*C(i+2,j+1)+C(i+2,j)+C(i+2,j+2))-(2*C(i,j+1)+C(i,j)+C(i,j+2)));
        small_grid = C(i:i+2, j:j+2);
        gradx = small_grid.*maskx_3by3;
        Gx = sum(sum(gradx));
        %Sobel mask for y-direction:
%         Gy=((2*C(i+1,j+2)+C(i,j+2)+C(i+2,j+2))-(2*C(i+1,j)+C(i,j)+C(i+2,j)));
        grady = small_grid.*masky_3by3;
        Gy = sum(sum(grady));
        %The gradient of the image
%         B(i,j)=abs(Gx)+abs(Gy);
        B(i,j)=sqrt(Gx.^2+Gy.^2);
    end
end

max_b = max(max(B));
temp = B./max_b;
% temp = B;

D = temp > 0.2;

% D1 = circshift(D, 1, 1);
% D2 = D==D1;
% D(D2) = 0;
% D1 = circshift(D, 1, 2);
% D2 = D==D1;
% D(D2) = 0;

% D = temp;
imshow(D);
title('Sobel gradient 3X3 mask');
figure;

maskx_5by5 = [-5,-4,0,4,5; -8,-10,0,10,8; -10,-20,0,20,10; -8,-10,0,10,8; -5,-4,0,4,5];
masky_5by5 = [5,8,10,8,5; 4,10,20,10,4; 0,0,0,0,0; -4,-10,-20,-10,-4; -5,-8,-10,-8,-5];

for i=1:size(C,1)-4
    for j=1:size(C,2)-4
        %Sobel mask for x-direction:
%         Gx=((2*C(i+2,j+1)+C(i+2,j)+C(i+2,j+2))-(2*C(i,j+1)+C(i,j)+C(i,j+2)));
        small_grid = C(i:i+4, j:j+4);
        gradx = small_grid.*maskx_5by5;
        Gx = sum(sum(gradx));
        %Sobel mask for y-direction:
%         Gy=((2*C(i+1,j+2)+C(i,j+2)+C(i+2,j+2))-(2*C(i+1,j)+C(i,j)+C(i+2,j)));
        grady = small_grid.*masky_5by5;
        Gy = sum(sum(grady));
        %The gradient of the image
%         B(i,j)=abs(Gx)+abs(Gy);
        B(i,j)=sqrt(Gx.^2+Gy.^2);
%         B(i,j) = Gx;
%         B(i,j) = Gy;
    end
end

max_b = max(max(B));
temp = B./max_b;
% temp = B;

D = temp > 0.2;

imshow(D);
title('Sobel gradient 5X5 mask');
figure;