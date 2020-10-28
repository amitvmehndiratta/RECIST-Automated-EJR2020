function [ output_DWI_3D ] = Img_preprocessing( DWI_3D )

%   This function performs pre-processing of input DWI dataset

% collect DWI at highest b-value 

  [row,col,total_slice] = size(DWI_3D);  

% collect mid-slice in DWI_stack

  n = int16(total_slice/2);
  D = double(DWI_3D(:,:,n));

% crop anatomical part from image sequences  
  
  D=max(0,D);

  D_norm = (D-min(min(D)))/(max(max(D))-min(min(D)));
%     figure,imagesc(D_norm);
  
  [threshold,EM] = multithresh(D_norm,2);
  BW= imbinarize(D_norm,threshold(1));  %%%
  
  se = strel('disk',3); 
  se1 = strel('disk',10);
 
  closeBW = bwareaopen(BW, 100);
  %  figure, imshow(closeBW);

  closeBW = imdilate(closeBW,se);
  closeBW = imerode(closeBW,se);
 
 closeBW = imdilate(closeBW,se1);
 closeBW = imerode(closeBW,se1);

 closeBW = bwareaopen(closeBW, 1000);
 closeBW = imfill(closeBW,'holes');
 closeBW = imdilate(closeBW,se1);
 closeBW = imdilate(closeBW,se1);

% get crop information      
 st = regionprops(closeBW, 'BoundingBox', 'Area' );
 [maxArea, indexOfMax] = max([st.Area]);
 image_cropinfo =  [st(indexOfMax).BoundingBox(1),st(indexOfMax).BoundingBox(2),st(indexOfMax).BoundingBox(3),st(indexOfMax).BoundingBox(4)];

% Crop image sequences

  for i=1:total_slice
     
      DWI_croped(:,:,i) = imcrop(DWI_3D(:,:,i),image_cropinfo);
   
  end

  DWI_croped(:,:,1:5) = 0;
  DWI_croped(:,:,total_slice-5:total_slice) = 0;
  
output_DWI_3D = DWI_croped;

end

