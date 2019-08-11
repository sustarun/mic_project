function value= calc(label,image,row,col, muk,ck,mask,beta,epsilon)
size1 = size(image,1);
size2 = size(image,2);
N=length(row);
value=0;
L=[1,0,0,1,-1,0,0,-1];
for i=1:N
    x=row(i);
    y=col(i);
    pix= image(row(i),col(i));
    in=label(row(i),col(i));
    value=value+ (1-beta)*((pix-muk(in))^2)/(ck(in)+epsilon) + 0.5*log((ck(in)+epsilon)/(1-beta));
    prior=0;
    for j=[1,3,5,7]
        x1=x+L(j);
        y1=y+L(j+1);
        if(not(x1 <= 0 || x1 > size1 || y1 <= 0 || y1 > size2))
%         if(mask(x1,y1)==1)
            index = label(x1,y1);
            if(in~=index)
                prior=prior+1;
            end
        end
    end
    value=value+0.5*beta*prior;
end
end
        