function [ TumorMask_SLICs ] = Seg_SLICs( DWI_3D )

%  3D Tumor segmentation usign
%  simple-linear-iterative-clustering-suverpixel (SLICs)

   dwi_croped1 = DWI_3D(:,:,:);
  [Labelmatrix_dwi,Pixellist_dwi] = superpixels3(dwi_croped1,20, 'compactness', 0.025, 'method', 'slic', 'NumIterations', 50);
 
 %Create a stack of RGB images to display the boundaries in color
 
 [row,col,total_slice] = size(dwi_croped1);

 for slice = 1:total_slice
     BW1dwi_all(:,:,slice) = boundarymask(Labelmatrix_dwi(:, :, slice));
     BW2dwi_all(:,:,slice) = imcomplement(BW1dwi_all(:,:,slice));
     BW3dwi_all(:,:,slice) = BW2dwi_all(:,:,slice).*double(dwi_croped1(:,:,slice));
 end

% Averaging the superpixel areas

   meandwi_all = zeros(size(dwi_croped1),'like',dwi_croped1);
   pixelIdxlist = label2idx(Labelmatrix_dwi);
 
   for superpixel = 1:Pixellist_dwi
       memberPixelIdx = pixelIdxlist{superpixel};
       meandwi_all(memberPixelIdx) = mean(dwi_croped1(memberPixelIdx));
   end

  [level,EM] = multithresh(meandwi_all(:),4);
  
% Marge superpixels with highper-signal in DWI amd Morphological operations

    se2 = strel('disk',5); 
  
   for n= 1:total_slice
       suppix_tumormask_dwi = imbinarize(double(meandwi_all(:,:,n)),level(3));
       closeBW = suppix_tumormask_dwi;
       closeBW = imclearborder(closeBW, 8);
       closeBW= bwareaopen(closeBW, 10);
    %  closeBW = bwpropfilt(closeBW, 'Area',1);
       closeBW = imdilate(closeBW,se2);
       closeBW = imerode(closeBW,se2);
    %  closeBW = imfill(closeBW,'holes');
       closeBW= bwareaopen(closeBW,100);

       suppix_tumormask_dwi_all(:,:,n) = closeBW;
   end
  
   TumorMask_SLICs = suppix_tumormask_dwi_all;
end

