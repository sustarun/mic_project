% A = load('data/assignmentSegmentBrain.mat');
% orig_img = A.imageData;
% diary
% 
% 
% orig_img = phantom(256);
% 
% % orig_img1 = imread('data/elephant.jpg');
% % orig_img2=rgb2gray(orig_img1);
% % orig_img=double(orig_img2)./255;
% 
% % orig_img = [0.25 0.45 0.75 0.9; 0.45 0.34 0.56 0.32; 0.23 0.95 0.13 0.56; 0.11 0.06 0.65 0.43];
% 
% imshow(orig_img);
function final_labels = minCut(orig_img, num_sgmnt)
    rand('seed', 1);
    img_arr = orig_img(:);
    size1 = size(orig_img, 1);
    size2 = size(orig_img, 2);
    size_arr = size(img_arr, 1);
    beta_list = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
%     beta_list = [0.1];
    K=2;
%     num_sgmnt = 4;
    [indx, Means] = kmeans(img_arr, num_sgmnt);
    C = sort(Means);

    lim = 50;

    lambda_arr = zeros(size_arr, 1);

    epsilon1 = 1e-4;
    epsilon2 = 1e-5;

    V1 = zeros(3*size_arr - size1 - size2, 1);
    V2 = zeros(3*size_arr - size1 - size2, 1);
    Weights = zeros(3*size_arr - size1 - size2, 1);
    temp_arr = img_arr;
    
    
    max_sil = 0;
    for beta = beta_list
        all_labels = zeros(size_arr, num_sgmnt);
        display('--------------------------------------------------');
        display(beta);
    for J=1:num_sgmnt-1
        labels = zeros(size_arr+2, 1);
    %     labels(1:size_arr) = indx - J;
        J1 = find(Means == C(J));
    %     [min_val2, J2] = min(C);
        labels(1:size_arr) = not(indx == J1);
        s = size_arr + 1;
        t = size_arr + 2;
        labels(s) = 0;
        labels(t) = 1;
        for d = 1:num_sgmnt
            for f = 1:size_arr
                if(all_labels(f,d) == 1)
    %                 p = randn(1);
    %                 if(p < 0.5)
    %                     temp_arr(f) = normrnd(mean(C(J:num_sgmnt)), 0.01);
                    temp_arr(f) = mean(C(J:num_sgmnt));
    %                 else
    %                     temp_arr(f) = normrnd(mean(C(J:num_sgmnt)), 0.01);
    %                     temp_arr(f) = mean(C(J:num_sgmnt));
    %                 end
                end
            end
        end

        mu = zeros(K,1);
        sigma = zeros(K,1);

        itr = 0;

        prev_mu = ones(K, 1);
        prev_sigma = ones(K, 1);

        while((itr < lim) && (abs(prev_mu(1)-mu(1)) >= epsilon1 || abs(prev_mu(2)-mu(2)) >= epsilon1 || abs(prev_sigma(1)-sigma(1)) >= epsilon2 || abs(prev_sigma(2)-sigma(2)) >= epsilon2))
            for l=1:K
                cluster = temp_arr(labels(1:size_arr)+1 == l);
                prev_mu(l) = mu(l);
                prev_sigma(l) = sigma(l);
                mu(l) = mean(cluster);
                sigma(l) = sqrt(var(cluster));
                if(sigma(l) == 0)
                    sigma(l) = epsilon2;
                end
            end
%             display('here');
%             display([prev_mu(1),mu(1), prev_sigma(1),sigma(1)]);
%             display('here1');
            j=0;
            for i=1:size_arr
                lambda = log(sigma(2)/sigma(1)) + 0.5* (((temp_arr(i)-mu(2))/sigma(2))^2 - ((temp_arr(i)-mu(1))/sigma(1))^2);
                lambda_arr(i) = lambda;
                if(lambda > 0)
                    j=j+1;
                    V1(j) = i;
                    V2(j) = s;
                    Weights(j) = lambda;
                else
                    j=j+1;
                    V1(j) = i;
                    V2(j) = t;
                    Weights(j) = -lambda;
                end
                if not(mod(i, size1) == 0)
                    j=j+1;
                    V1(j) = i;
                    V2(j) = i+1;
                    Weights(j) = beta;
                end
                if not(size_arr - i < size1)
                    j=j+1;
                    V1(j) = i;
                    V2(j) = i+size1;
                    Weights(j) = beta;
                end
            end
            G = graph(V1, V2, Weights);
            [~, ~, c1, c2] = maxflow(G, s, t);
            labels(c1) = 0;
            labels(c2) = 1;
            itr = itr+1;
        end

        for d = 1:num_sgmnt
            labels(all_labels(:,d) == 1) = 1;
        end
        all_labels(:,J) = mod(labels(1:size_arr)+1,2);
        
    end
    
    all_labels(:, num_sgmnt) = mod(sum(all_labels(:,1:num_sgmnt-1), 2)+1,2);
    
    final_labels1 = zeros(size1, size2, K);
    for g = 1:num_sgmnt
%         figure;
        final_labels1(:,:,g) =  reshape(all_labels(:,g), size1, size2);
    end
    sil = silhouette(final_labels1, orig_img);
    if(sil > max_sil)
        max_sil = sil;
        final_labels = final_labels1;
    end
    end
    end