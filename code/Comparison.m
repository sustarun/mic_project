% A = load('../data/assignmentSegmentBrain.mat');
% orig_img = A.imageData;

% rand('seed', 1);

orig_imgg = zeros(128,128,5);

lim=5;

orig_imgg(:,:,1) = phantom(128);
orig_imgg(:,:,2) = imnoise(phantom(128), 'gaussian', 0, 0.0001);
orig_imgg(:,:,3) = imnoise(phantom(128), 'gaussian', 0, 0.0005);
orig_imgg(:,:,4) = imnoise(phantom(128), 'gaussian', 0, 0.0025);
orig_imgg(:,:,5) = imnoise(phantom(128), 'gaussian', 0, 0.01);

% orig_img1 = imread('../data/fruit.png');
% orig_img2=rgb2gray(orig_img1);
% orig_img=double(orig_img2)./255;

    % orig_img = [0.25 0.45 0.75 0.9; 0.45 0.34 0.56 0.32; 0.23 0.95 0.13 0.56; 0.11 0.06 0.65 0.43];

for ii=1:lim
    orig_img = orig_imgg(:,:,ii);
    imshow(orig_img);
    title('Original Image');
    % figure;
    size1 = size(orig_img, 1);
    size2 = size(orig_img, 2);

    num_sgmnt = 5;

    % list_algo = ['k_means', 'fuzzy_C_means', 'EM', 'minCut'];
    
    num_algo = 4;
    
    list_algo = cell(num_algo,1);
    
    list_algo{1} = ['k-means'];
    list_algo{2} = ['FCM'];
    list_algo{3} = ['EM'];
    list_algo{4} = ['minCut'];
    

    labels = zeros(size1, size2, num_sgmnt, num_algo);

    display('Iamhere1');
    labels(:,:,:,1) = k_means(orig_img, num_sgmnt);
    display('Iamhere2');
    labels(:,:,:,2) = fuzzy_C_means(orig_img, num_sgmnt);
    display('Iamhere3');
    labels(:,:,:,3) = EM(orig_img, num_sgmnt);
    display('Iamhere4');
    labels(:,:,:,4) = minCut(orig_img, num_sgmnt);
    display('Iamhere5');
%     labels(:,:,:,1) = genetic(orig_img, num_sgmnt);

    for i=1:num_algo
        figure;
        for j=1:num_sgmnt
            subplot(1,num_sgmnt,j);
            imshow(labels(:,:,j,i));
            xlabel(['Segment ', num2str(j)]);
            title(['Algo:- ',list_algo{i}]);
            ax = gca;
            ax.FontSize = 7;
        end
    end

    silhouette_val = zeros(num_algo, 1);
    for i=1:num_algo
        silhouette_val(i)=silhouette(labels(:,:,:,i), orig_img);
    end
    
    figure;
    stem(silhouette_val);
    set(gca,'xtick',1:num_algo,'xticklabel',list_algo);
    xlabel('Different Algorithms');
    ylabel('Silhoutte values');
    axis([0 num_algo+1 0 1]);
    axis 'auto y';
    figure;
end