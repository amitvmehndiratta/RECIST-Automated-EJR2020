function [ max_dia, max_slice ] = calculate_TumorDia(TumorMask, voxel_dim)

% This function identifies the slice with maximun cross sectional area of
% tumor and evaluates the length of tumor diameter 

voxel_length_cm = voxel_dim(1)/10;

for slice=1:size(TumorMask,3)
   
     BW = bwpropfilt( logical(TumorMask(:,:,slice)), 'MajorAxisLength',1);
     dia = regionprops(BW, 'MajorAxisLength');
     if(~isempty(dia))
          dia_all(slice) = dia.MajorAxisLength*voxel_length_cm;
     else
          dia_all(slice) = 0;
     end     
end

[max_dia, max_slice] = max(dia_all);

end


