% function all_labels = genetic(orig_img, num_sgmnt)
image = load('../data/assignmentSegmentBrain.mat');
brainimg= image.imageData;
% brainimg = phantom(64);
% brainimg = imnoise(phantom(64), 'gaussian', 0, 0.001);
% seed = randi(100000);
rand('seed', 1);
% brainimg=rgb2gray(imread('../data/fruit.png'));
% brainimg=double(brainimg)/255;
imshow(brainimg);
% brainimg = orig_img;
siz1=size(brainimg,1);
siz2=size(brainimg,2);
popsize=20;
num_sgmnt = 4;
chrosize = num_sgmnt+2;
% chrosize=6;
tobe=brainimg(:);
chromosomes=zeros(popsize,chrosize*4);
alpha=10000;
tournsize=5;
%  L=regiongrowing(brainimg,300,600,thresh);
idx = kmeans(brainimg(:), chrosize);
for i=1:popsize
    chromosomes(i,1:chrosize) = randi([0,1],1,chrosize);
    if(length(find(chromosomes(i,1:chrosize)==0)) ==chrosize)
        pick=randi(chrosize);
        chromosomes(i,pick)=1;
    end
    B = zeros(chrosize,1);
    for k=randperm(chrosize)
        temp_arr = find(idx == k);
        temp_t =  randi(length(temp_arr));
        B(k) = temp_arr(temp_t);
    end
%     B=randi(length(brainimg(:)),1,chrosize);
    chromosomes(i,chrosize+1:chrosize*2) = tobe(B);
    temp=ceil(B/siz1);
    chromosomes(i,chrosize*2+1:chrosize*3) = B-(temp-1)*siz1;
    chromosomes(i,chrosize*3+1:chrosize*4) = temp;
end
% display(chromosomes);
thresh=0.15;
maxgen=30;
fittest=zeros(maxgen,chrosize*4);
best=zeros(maxgen,1);

for qwe=1:maxgen
    fitnessmat=zeros(1,popsize);
    for i= 1:popsize
        regionsmarked=zeros(siz1*siz2,1);
        for j=1:chrosize
            if(chromosomes(i,j)==1)
                xvalue=chromosomes(i,2*chrosize+j);
                yvalue=chromosomes(i,3*chrosize+j);
                inten = chromosomes(i,chrosize+j);
                L=regiongrowing(brainimg,xvalue,yvalue,thresh);
                fitnessmat(1,i)= fitnessmat(1,i) + sum((tobe(L==1)-mean(tobe(L==1))).^2);
                regionsmarked(L==1)=1;
            end
        end
        uncover=find(regionsmarked==0);
        fitnessmat(1,i)= fitnessmat(1,i) + alpha.*sum((tobe(uncover)-mean(tobe(uncover))).^2);
    end
    [bes,origfit]=min(fitnessmat);
    [~,worst]=max(fitnessmat);
    best(qwe)=bes;
    fittest(qwe,:)=chromosomes(origfit,:);
    if(qwe>1)
        if(best(qwe-1)<best(qwe))
            chromosomes(worst,:)=chromosomes(origfit,:);
            chromosomes(origfit,:)=fittest(qwe-1,:);
        else
            chromosomes(worst,:)=fittest(qwe-1,:);
        end
    end
    newchromosomes=zeros(popsize,chrosize*4);
    for i=1:popsize
        randmat=randi(popsize,tournsize,1);
        [~,fit]=min(fitnessmat(randmat));
        newchromosomes(i,:)= chromosomes(randmat(fit),:);
    end
    chromosomes=newchromosomes;
    pair1=randperm(popsize,popsize/2);
    parent=1:popsize;
    parent(pair1)=[];
    pair2=parent(randperm(popsize/2));
    offspring=zeros(popsize,chrosize*4);
    for i=1:popsize/2
        prob=rand(1,chrosize);
        for t=1:chrosize
            if(prob(t)>=0.5)
                for r=1:4
                    offspring(2*i-1,chrosize*(r-1)+t)=chromosomes(pair2(i),chrosize*(r-1)+t);
                    offspring(2*i,chrosize*(r-1)+t)=chromosomes(pair1(i),chrosize*(r-1)+t);
                end
            else
                for r=1:4
                    offspring(2*i-1,chrosize*(r-1)+t)=chromosomes(pair1(i),chrosize*(r-1)+t);
                    offspring(2*i,chrosize*(r-1)+t)=chromosomes(pair2(i),chrosize*(r-1)+t);
                end
            end
        end
    end
    chromosomes=offspring;
    for r=1:popsize
        genrand = randi(chrosize);
        chromosomes(r,genrand)=1-chromosomes(r,genrand);
    end
end


% size1 = size(brainimg, 1);
% size2 = size(brainimg, 2);

all_labels = zeros(siz1, siz2, num_sgmnt);
j=1;
figure;
numbert= length(fittest(maxgen,1:chrosize)==1);
for i=1:chrosize
    if(fittest(maxgen,i)==1)
        L=regiongrowing(brainimg,fittest(maxgen,2*chrosize+i),fittest(maxgen,3*chrosize+i),thresh);
        subplot(1,numbert,j);
        imshow(L);
        title('Genetic algorithm \newline segmentation');
        all_labels(:,:,j) = L;
        j = j+1;
    end
end
% end