function [ output ] = CAD_RECIST( algorithm_type, DWI_3D_baseline, voxel_dim_baseline, DWI_3D_followup, voxel_dim_followup )
% ------------------------------------------------------------------------------------------------------------------------------
% function [ output ] = CAD_RECIST( algorithm_type, DWI_3D_baseline, voxel_dim_baseline, DWI_3D_followup, voxel_dim_followup )
% ------------------------------------------------------------------------------------------------------------------------------
% DESCRIPTION: 
% This function segments the 3D tumor mask and calculate the tumor diameter (maximum cross-sectional length) and
% tumor volume from the 3-dimentional (3D) array of Diffusion weighted MRI (DWI)
% data; where structure of 3-dimentional array is row:col:total_slice
% If DWI datasets at before and after treatment are provided, then this
% function evaluates 3D tumor mask, tumor diameter, tumor volume for both the datasets 
% and calculates RECIST (Response evaluation criteria in solid tumors) score
% and Volumetric-response score.
%-------------------------------------------------------------------------------------------------------------------------------
% Following operations are performed:
%
% 1. Pre-processing of the 3D DWI data to for intensity normalization and focus on target anatomical part.
% 2. Tumor segmentation based on Fuzzy C-means clustering (FCM) or Simple linear iterative clustering supervoxel (SLICs) algorithm.
% 3. Tumor diameter, slice number of maximun cross-sectional area of tumor (Max_burden_scliceno) and Tumor volume are evaluated.
% 4. If DWI data at second time-point is provided, Tumor segmentation is performed based on the previously selected algorithms and
%    the Tumor diameter and Tumor volume are evaluated and finally, the RECIST score [1] and Volumetric response score are evaluated.

% [1]  E.A. Eisenhauer, P. Therasse, J. Bogaerts, L.H. Schwartz, D. Sargent, R. Ford, J. Dancey, S. Arbuck, S. Gwyther, M. Mooney, 
%      L. Rubinstein, L. Shankar, L. Dodd, R. Kaplan, J. Lacombe, J. Verweij, New response evaluation criteria in solid tumours: 
%      revised RECIST guideline (version 1.1), Eur. J. Cancer (2009), 45, 228–247, https://doi.org/10.1016/j.ejca.2008.10.026.
% ---------------------------------------------------------------------------------------------------------------------------------
% INPUTS:
%  - algorithm_type: Numerical value specifying the segmentation algorithm, '1' for FCM and '2' for SLICs. 
%  - DWI_3D_baseline: 3D array containing the DWI dataset to analyze. 
%                     Input DWI preferably at b-value=800sec/mm2 or higher b-value.
%  - voxel_dim_baseline: Numerical value specifying the voxel dimension (mm)
%                        in [length height width] format.
%  - DWI_3D_followup: Same as DWI_4D_baseline. This input is optional, when
%                     provided, the function processes the DWI datasets at both time-points 
%                     and evaluates response scores otherwith process sigle DWI dataset only. 
%  - voxel_dim_followup: Same as voxel_dim_baseline. This input is optional, when not provided 
%                        value of voxel_dim_baseline is consedered for voxel_dim_followup.
% -------------------------------------------------------------------------
% OUTPUTS: output contains,
% - TumorMask_baseline 
% - Tumor_diameter_in_cm
% - Max_burden_sliceno
% - Tumor_volume_in_cc
%
% If DWI dataset at followup provided output also contains,
% - TumorMask_followup
% - Tumor_diameter_followup_in_cm
% - Max_burden_sliceno_followup
% - Tumor_volume_followup_in_cc  
% - RECIST_score
% - Volumetric_response_score

% -------------------------------------------------------------------------
% Example of usea:
%
% Data Loading: Load the DWI data as NIfTI file and extract 3D DWI stack preferably at 
%                        b-value = 800 sec/mm2 or higher b-value as *.mat file.
%   
%     DWI_4D = load_untouch_niigz('C:\Documents\MATLAB\DWI_4D_baseline.nii.gz');
%
%     [row,col,total_slice,total_bval] = size(DWI_4D.img);
%
%     DWI_3D = DWI_4D.img(:,:,:,total_bval);
%
% 1. For, single DWI dataset 'DWI_3D.mat' is provided as 3D array with voxel size of  
%    1.3mm x 1.3mm x 5.5mm and FCM algorithm is selected for segmentation, run:
%      
%       [ output ] = CAD_RECIST( 1, DWI_3D, [1.3 1.3 5.5]) 
%
% 2. For, DWI datasets 'DWI_3D_1.mat' and 'DWI_3D_2.mat' at baseline and follow-up respectively
%    are provided as 3D arrays with voxel size of 1.3mm x 1.3mm x 5.5mm and 
%    1.4mm x 1.4mm x 5mm respectively and SLICs algorithm is selected for segmentation, run:
%      
%       [ output ] = CAD_RECIST( 2, DWI_3D_1, [1.3 1.3 5.5], DWI_3D_2, [1.4 1.4 5]) 
%
% -------------------------------------------------------------------------
% Use of this project must be cited with the details as: 
% Baidya Kayal E., Kandasamy D., Yadav R., Bakhshi S., Sharma R., Mehndiratta, A. Computer aided diagnostic system for automatic 
% segmentation and RECIST score evaluation in osteosarcoma using diffusion MRI. European Journal of Radiology (2020). 
% doi:http://doi.org/10.1016/j.ejrad.2020.109359. 
%
% ----------------------------------------------------------------------------------------------------------------------------------
% For any detailed enquiry, please contact Dr Amit Mehndiratta, Indian Institute of Technology Delhi, India Email: amit.mehndiratta@keble.oxon.org
%
% --------------------------------------------------------------------------------------------------------------------------------------------------------------
% Disclaimer: These project can be used only for research purposes. Authors are not liable for any clinical use of it, authors could not held be responsible.
%
% --------------------------------------------------------------------------------------------------------------------------------------------------------------

% VERIFICATION OF SOME INPUTS


% Verify that the function is called with a minimum of three and maximum of five input arguments; else through error message.  

narginchk(3,5)

Total_argument = nargin;

% Validate the size and class of the inputs

validateattributes(algorithm_type,{'numeric'},{'scalar'}, 1);

if (algorithm_type ~= 1 && algorithm_type ~= 2)
    error('Algorithm_type must either be ''1'' for ''FCM'' or ''2'' for SLICs')
end
    

validateattributes(DWI_3D_baseline,{'numeric'},{'ndims',3}, 2);
validateattributes( voxel_dim_baseline,{'numeric'},{'numel',3}, 3);

if (Total_argument >= 4)
validateattributes(DWI_3D_followup,{'numeric'},{'ndims',3}, 4);
   if (Total_argument == 5)
       validateattributes( voxel_dim_followup,{'numeric'},{'numel',3}, 5);
   end 
end
  

% fprintf('\n Total number of agruments = %d',Total_argument);

if (Total_argument == 3)
    fprintf('\n DWI dataset at single time-point is provided. Tumor MAsk and Tumor dimension will be evaluated.\n');
elseif(Total_argument >= 4)     
    fprintf('\n DWI datasets at two time-points are provided. Tumor Mask, Tumor dimension and RESCIST score will be evaluated.\n');
end
 
% preprocessing the DWI

output_DWI_3D_1 = Img_preprocessing(DWI_3D_baseline);

% Tumor segmentation 

if (algorithm_type == 1) 
  fprintf('\n Executing FCM-based method');  
  TumorMask_1 = Seg_FCM(output_DWI_3D_1); 
elseif (algorithm_type == 2) 
  fprintf('\n Executing SLICs-based method');    
  TumorMask_1 = Seg_SLICs(output_DWI_3D_1); 
end  

% Tumor diameter and volume calculation

   [Tumor_dia_1, Max_burden_slice_1] = calculate_TumorDia(TumorMask_1, voxel_dim_baseline);
  Tumor_vol_1 = calculate_TumorVol(TumorMask_1, voxel_dim_baseline);
  
  output.TumorMask_baseline = TumorMask_1;
  output.Tumor_diameter_in_cm = Tumor_dia_1;
  output.Max_burden_sliceno = Max_burden_slice_1;
  output.Tumor_volume_in_cc = Tumor_vol_1;
  
  if (Total_argument == 3)
      fprintf('\n Execution complete\n\n');  
      disp(output);
  end    

if (Total_argument > 3)
   
    
  % preprocessing the DWI

output_DWI_3D_2 = Img_preprocessing(DWI_3D_followup);


% Tumor segmentation 

if (algorithm_type == 1) 
  TumorMask_2 = Seg_FCM(output_DWI_3D_2); 
elseif (algorithm_type == 2) 
  TumorMask_2 = Seg_SLICs(output_DWI_3D_2); 
end  

  if (Total_argument == 4)
      voxel_dim_followup = voxel_dim_baseline;
  end    
% Tumor diameter and volume calculation

  [Tumor_dia_2, Max_burden_slice_2] = calculate_TumorDia(TumorMask_2, voxel_dim_followup);
  Tumor_vol_2 = calculate_TumorVol(TumorMask_2, voxel_dim_followup);
  
% RECIST score calculation

   TumorDia_percent_change = ((Tumor_dia_2 - Tumor_dia_1)/Tumor_dia_1)*100;
   
      if (Tumor_dia_2 == 0)
          RECIST_score = 'Complete response';
      elseif (TumorDia_percent_change <= -30)
          RECIST_score = 'Partial response';
      elseif (TumorDia_percent_change >= 20 || (Tumor_dia_2 - Tumor_dia_1) >=5 )  
           RECIST_score = 'Prograssive disease';
      else
           RECIST_score = 'Stable disease';
      end
 
% Volumetric-response score calculation

   TumorVol_percent_change = ((Tumor_vol_2 - Tumor_vol_1)/Tumor_vol_1)*100;
   
    if (Tumor_vol_2 == 0)
          Vol_response_score = 'Complete response';
      elseif (TumorVol_percent_change <= -30)
          Vol_response_score = 'Partial response';
      elseif (TumorVol_percent_change >= 20)  
           Vol_response_score = 'Prograssive disease';
      else
           Vol_response_score = 'Stable disease';
    end
      
  output.TumorMask_followup = TumorMask_2;
  output.Tumor_diameter_followup_in_cm = Tumor_dia_2;
  output.Max_burden_sliceno_followup = Max_burden_slice_2;
  output.Tumor_volume_followup_in_cc = Tumor_vol_2;  
  
  output.RECIST_score = RECIST_score;
  output.Volumetric_response_score = Vol_response_score;
end  

fprintf('\n Execution complete\n\n');  
  
disp(output);

end

