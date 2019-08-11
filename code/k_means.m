function labels = k_means(original_image,K)
% X=randi(length(row),K,1);
% X=[1;10000;20000];
% for i=1:K
%     X(i) = 
% end
initial_mean = zeros(K,1);
for i=1:K
    x1 = randi(size(original_image, 1));
    y1 = randi(size(original_image, 2));
    initial_mean(i)= original_image(x1,y1);
end
update = initial_mean;
lim=1;
for i=1:lim
%     display('sdbkcsbdc');
    mark= findclosest(original_image,update,K);
    update=mark;
%     display('sdbkcsbdcnfkjscbx');
end
% muk=update;
% summ=zeros(K,1);
% count=zeros(K,1);
% N=length(row);
size1 = size(original_image,1);
size2 = size(original_image,2);
% siz=length(original_image);
% label=zeros(size1,size2);
labels = zeros(size1, size2, K);
% display('here');
for i=1:size1
    for j=1:size2
        X=original_image(i,j);
        compute=zeros(K,1);
        for k=1:K
            Y=update(k);
            compute(k)=abs(X-Y);
        end
        [~,J]=min(compute);
        labels(i,j,J)=1;
%         summ(J) = summ(J) +X^2;
%         count(J) = count(J)+1;
    end
end
% display('here2');
% wk=count/sum(count);
% ck= summ./count;
end