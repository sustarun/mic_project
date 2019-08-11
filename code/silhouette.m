function silhoutte_val = silhouette(all_labels, img)

%     t1= [1 0 0; 1 0 0; 0 0 0];
%     t2= [0 1 0; 0 1 0; 1 0 0];
%     t3= [0 0 1; 0 0 1; 0 1 1];
%     t = zeros(3,3,3);
%     t(:,:,1) = t1;
%     t(:,:,2) = t2;
%     t(:,:,3) = t3;
%     all_labels = t;
%     img = [0.01 0.23 0.47; 0.12 0.34 0.56; 0.23 0.78 0.56];

    size1 = size(all_labels, 1);
    size2 = size(all_labels, 2);
    size3 = size(all_labels, 3);
%     display(size1);
%     display(size2);
%     display(size3);

    b = zeros(size1, size2);
    a = zeros(size1, size2);
    s = zeros(size1, size2);
    
    for i=1:size1
%         display(i);
        for j=1:size2
            [~, pos] = max(all_labels(i,j,:));
            sum_b = 0;
            count_b = 0;
%             display('toomuchtime');
            for k=1:size3
                if(k == pos)
                    sum_a = sum(sum(all_labels(:,:,k).*(abs(img-img(i,j)))));
                    count_a = sum(sum(all_labels(:,:,k)));
                else
                    sum_b = sum_b + sum(sum(all_labels(:,:,k).*(abs(img-img(i,j)))));
                    count_b = count_b + sum(sum(all_labels(:,:,k)));
                end
            end
            if(isnan(sum_a) || isnan(count_a) || isnan(sum_b) || isnan(count_b))
                display('ankit');
            end 
%             display('toomuchtime1');
            b(i,j) = sum_b/count_b;
            a(i,j) = sum_a/count_a;
            s(i,j) = (b(i,j) - a(i,j)) / max(a(i,j), b(i,j));
        end
%         display('okkk1');
    end
%     display('over');
%     silhoutte_val = sum(sum(s>=0))-sum(sum(s < 0));
    silhoutte_val = sum(sum(s));
end

