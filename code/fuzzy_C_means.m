function all_labels = fuzzy_C_means(orig_img, num_sgmnt)
    % A = load('data/assignmentSegmentBrain');
    rand('seed', 1);
    % original_image = A.imageData;
    % imshow(original_image);
    % title('Original Corrupted Image');
    % figure;
    % img_mask =A.imageMask;
    original_image = orig_img;
%     num_sgmnt=4;
    K=num_sgmnt;
    lim = 50;
    % %% Calculating Weight
    mask_size = 21;
    sigma = 2;
    weight = fspecial('gaussian', mask_size, sigma);
    sum_weight = sum(sum(weight));
    weight = weight/sum_weight;
    % imagesc(weight);
    % title('Weight');
    % figure;
    % [row,col]=find(img_mask);
    q = 1.6;
    % original_image = orig_img;
    size1 = size(original_image,1);
    size2 = size(original_image,2);
    y = original_image;
    % temp=original_image;
    % %% Initializing Memberships
    initial_label= kmeans(y(:),K);
    initial_label=reshape(initial_label,size1,size2);
    % initial_label=initial_label.*img_mask;
    % initial_label(initial_label==3)=2;
    % initial_label(initial_label==4)=3;
    init_mem = zeros(size1,size2,K);
    for i=1:K
       init_mem(:,:,i) = initial_label == i;
    end
    curr_mem = init_mem;
    % %% Initial Membership Images
    % for i=1:K
    %    imshow(reshape(init_mem(:,:,i), N, N));
    %    title(['Initial Membership Image for Class ' num2str(i)]);
    %    figure;
    % end
    % %% Initializing Means
    init_means=zeros(K,1);
    for i=1:K
    check = initial_label==i;
    change=original_image.*check;
    counting=length(find(check));
    init_means(i)= sum(sum(change))/counting;
    end
    curr_means = init_means;
    % %% Intialising Bias
    init_bias = ones(size1);
    curr_bias = init_bias;
    d = zeros(size1,size2, K);
    % J = zeros(lim,1);
    % %% Updating
    for i=1:lim
        temp1 = conv2(curr_bias, weight,'same');
        temp2 = conv2(curr_bias.^2, weight,'same');
        maskSum = sum(sum(weight));
    % %% Updating Memberships
        for k = 1:K
            d(:,:,k) = (y.^2).*maskSum + (curr_means(k).^2).*temp2 - (2.*curr_means(k).*y).*temp1;
        end
    %     d(d<0) = 0;
        u = d.^(-1/q-1);
        sum_d = nansum(u, 3);
    %     sum_d = sum(u,3);
        for k=1:K
            temp_u = u(:,:,k);
            temp_u = temp_u./sum_d;
    %         temp_u(~logical(img_mask))=0;
    %         curr_mem = u./repmat(sum_d, 1,1,K);
    %         nan_mat1 = isnan(curr_mem);
    %         curr_mem(nan_mat1) = 0;
            u(:,:,k)= temp_u;
        end
        nan_mat1 = isnan(u);
        u(nan_mat1) = 0;
        curr_mem = u;
    % %% Updating Means
        c_numer = sum(sum((curr_mem.^q).*repmat(y.*temp1, 1,1,K)));
        c_denom = sum(sum((curr_mem.^q).*repmat(temp2, 1,1,K)));
        curr_means = c_numer./c_denom;
    % %% Updating Bias
        b_sum_numer = sum((curr_mem.^q).*repmat(curr_means,size1,size2,1), 3);
        b_sum_denom = sum((curr_mem.^q).*repmat(curr_means.^2,size1,size2,1), 3);
        b_numer = conv2(b_sum_numer.*y, weight, 'same');
        b_denom = conv2(b_sum_denom, weight, 'same');
        curr_bias = b_numer./b_denom;
        nan_mat2 = isnan(curr_bias);
        curr_bias(nan_mat2) = 0;
    %     curr_bias = curr_bias.*img_mask;
    % %% Updating Objective function
    %     temp3 = conv2(curr_bias, weight,'same');
    %     temp4 = conv2(curr_bias.^2, weight,'same');
    %     maskSum = sum(sum(weight));
    %     for k = 1:K
    %         d(:,:,k) = y.^2.*maskSum + (curr_means(k)^2).*temp4 - (2.*curr_means(k).*y).*temp3;
    %     end
    %     d(d<0) = 0;
    %     J(i) = sum(sum(sum((curr_mem.^q).*d)));
    end
    
    all_labels = zeros(size1, size2, K);
    for i=1:size1
        for j=1:size2
            [~, J] = max(curr_mem(i,j,:));
            all_labels(i,j,J) = 1;
        end
    end
    
    % %% Plotting Objective function
    % plot(J);
    % title('Objective Function vs Iteration');
    % figure;
    % %% Optimal Membership Images
%     for i=1:K
%         figure;
%         imshow(reshape(curr_mem(:,:,i), size1, size2));
%         title(['Optimal Membership Image for Class ' num2str(i)]);
%     end
    % %% Optimal Bias-Field Image
    % imshow(curr_bias);
    % title('Optimal Bias-Field Image');
    % figure;
    % %% Bias-Removed Image
    % A = sum(curr_mem.*repmat(curr_means, N, N, 1), 3);
    % imshow(A);
    % title('Bias-Removed Image');
    % figure;
    % %% Residual Image
    % R = y - A.*curr_bias;
    % imshow(R,[]);
    % title('Residual Image');
    % close all;
    
end