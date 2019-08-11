function ret= findclosest(original_image,update,K)
sum=zeros(K,1);
count=zeros(K,1);
size1=size(original_image,1);
size2=size(original_image,2);
for i=1:size1
    for j=1:size2
        X=original_image(i,j);
        compute=zeros(K,1);
        for k=1:K
            Y=update(k);
            compute(k)=abs(X-Y);
        end
        [~,J]=min(compute);
        sum(J) = sum(J) +X;
        count(J) = count(J)+1;
    end
end
ret= sum./count;
end
        