function [ TumorMask_FCM ] = Seg_FCM( DWI_3D )

%   3D Tumor segmentation usign Fuzzy c-means clustering

  data = DWI_3D(:);
  options = [NaN 50 0.001 0];
  [centers,U,objFun] = fcm(double(data),3,options);

  centre_max = max(centers);
  class = find(centers==centre_max);

  img = U(class,:);
  th = otsuthresh(img);

  img(img>th) = 1;
  img(img<=th) = 0;
  img_seg = reshape(img,size(DWI_3D));

  
% Morphological operations

  se2 = strel('disk',5); 
 
  for i = 1:size(DWI_3D,3)
    
      imagNew = img_seg(:,:,i);
      closeBW = imagNew;
      closeBW = imclearborder(closeBW, 8);
      closeBW = bwareaopen(closeBW, 10); 
    % closeBW = bwpropfilt(closeBW, 'Area',1); 
    % figure, imdisp(closeBW);
      closeBW = imdilate(closeBW,se2);
      closeBW = imerode(closeBW,se2);
    % closeBW = imfill(closeBW,'holes');
      closeBW = bwareaopen(closeBW, 100);

      imagNew_all(:,:,i) = closeBW;
  end

  TumorMask_FCM = imagNew_all;
end

