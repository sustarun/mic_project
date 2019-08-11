function final_labels = EM(orig_img, num_sgmnt)

%     A = load('data/assignmentSegmentBrainGmmEmMrf.mat');
%     orig_img = phantom(128);
    orig_img(orig_img<=0)=0;
    rand('seed', 1);
    original_image = orig_img;
%     original_image = A.imageData;
    size1 = size(original_image,1);
    size2 = size(original_image,2);
    mask = ones(size1,size2);
%     num_sgmnt = 4;
    K=num_sgmnt;
    [row, col] = find(mask);
    epsilon= 1e-5;
    
    % %% Initialisation of means and variances of classes
    % temp=original_image.*mask+ (mask-ones(256,256))*10000;
    temp = original_image;
    initial_label= kmeans(temp(:),K);
    initial_label=reshape(initial_label,size1,size2);
    % initial_label=initial_label.*mask;
    % initial_label(initial_label==3)=2;
    % initial_label(initial_label==4)=3;
    muk=zeros(K,1);
    ck=zeros(K,1);
    muk_init=zeros(K,1);
    ck_init=zeros(K,1);
    for i=1:K
    check = initial_label==i;
    change=original_image.*check;
    counting=length(find(check));
    muk_init(i)= sum(sum(change))/counting;
    ck_init(i)= sum(sum((change-muk_init(i)).^2))/counting;
    end

    % %% 
    filter = [0,1,0;1,0,1;0,1,0];
    % objectivematafter=zeros(101,2);
    % objectivematbefore=zeros(101,2);
    optimalmuk =zeros(K,1);

    % %% Original corrupted image
%     figure;
%     imshow(original_image);

    % %%
    total_neighbours = conv2(mask,filter,'same');
    % in=1;
    beta_list = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
    lim = 50;
    
    max_sil = 0;
    
    for beta=beta_list
    %     %% EM algorithm
    final_label=initial_label;
    muk=muk_init;
    ck=ck_init;
    for i= 1:lim
        before_update = calc(final_label, original_image,row,col,muk,ck, mask,beta,epsilon);
%         objectivematbefore(i+1,in) = before_update;
        temp_label = icmnew(final_label,original_image,mask,muk,ck,K,beta,epsilon);
        after_update=calc(temp_label, original_image,row,col,muk,ck, mask,beta,epsilon);
%         objectivematafter(i+1,in) = after_update;
        if(after_update < before_update)
            final_label=temp_label;
        end
        
        membership= zeros(size1,size2,K);
        for j=1:K
            membership(:,:,j)= (1/((ck(j)+epsilon)^0.5)) * exp(-(((original_image-muk(j)).^2)/(ck(j)+epsilon))).*mask;
            modify = double(final_label==j);
            nextstep = conv2(modify,filter,'same');
            membership(:,:,j) = membership(:,:,j).* (exp(-(total_neighbours-nextstep)).*mask);
        end
        mat=sum(membership,3);
        for j=1:K
            membership(:,:,j) = (membership(:,:,j)./mat);
        end
        membership(isnan(membership))=0;
        for j=1:K
            muk(j)=sum(sum(membership(:,:,j).*original_image))/sum(sum(membership(:,:,j)));
            ck(j)= sum(sum(membership(:,:,j).*((original_image-muk(j)).^2)))/sum(sum(membership(:,:,j)));
        end
    end
    
%     %% Stores optimal means
%     optimalmuk(:)= muk;
    
%     %% Image plotting
%     imagemat=zeros(256,256);
%     imagemat(final_label==1) = muk(1);
%     imagemat(final_label==2) = muk(2);
%     imagemat(final_label==3) = muk(3);
%     label1= membership(:,:,1);
%     label2= membership(:,:,2);
%     label3= membership(:,:,3);
    
%     %% Label image estimate
%     figure;
%     imshow(imagemat);
%     title(['Label image estimate for beta ' num2str(beta)]);
%     %% Membership for class 1
%     for k=1:K
%         figure;
%         imshow(membership(:,:,k));
%         title(['Class' num2str(k) 'membership image estimate for beta ' num2str(beta) '\newline' ' with class mean intensity ' num2str(muk(k))]);
%     end
    all_labels = membership;
    sil = silhouette(all_labels, orig_img);
    if(sil > max_sil)
        max_sil = sil;
        final_labels = all_labels;
    end
    end
%     %% Membership for class 2
%     figure;
%     imshow(label2);
%     title(['Class 2 membership image estimate for beta ' num2str(beta) '\newline' ' with class mean intensity ' num2str(muk(2))]);
%     %% Membership for class 3
%     figure;
%     imshow(label3);
%     title(['Class 3 membership image estimate for beta ' num2str(beta) '\newline' ' with class mean intensity ' num2str(muk(3))]);

%     in = in+1;
end

% %% Objective function plot that is to be maximised
% figure;
% plot(-objectivematbefore(:,1));
% hold on;
% plot(-objectivematafter(:,1));
% title('Optimization function plot for icm');
% legend('before update','after update');


    