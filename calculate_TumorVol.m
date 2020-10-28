function [ tumor_vol_cc ] = calculate_TumorVol(TumorMask, voxel_dim)

% This function evaluates the volume (cc) of tumor 

voxel_volume_cc = (voxel_dim(1)*voxel_dim(2)*voxel_dim(3))/1000;

tumor_vol_cc = sum(TumorMask(:))*voxel_volume_cc;
end


