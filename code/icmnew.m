function label = icmnew(final_label,original_image,mask,muk,ck,K,beta,epsilon)
size1 = size(original_image,1);
size2 = size(original_image,2);
mymat= zeros(size1,size2,K);
filter = [0,1,0;1,0,1;0,1,0];
total_neighbours = conv2(mask,filter,'same');
for i=1:K
    mymat(:,:,i)= ((1-beta)*(((original_image-muk(i)).^2)/(ck(i)+epsilon)))+0.5*log((ck(i)+epsilon)/(1-beta)).*mask;
    modify = double(final_label==i);
    nextstep = conv2(modify,filter,'same');
    mymat(:,:,i) = mymat(:,:,i)+(beta*(total_neighbours-nextstep)).*mask;
end
[~,temp] = min(mymat,[],3);
label= temp.*mask;
end
