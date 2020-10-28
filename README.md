# RECIST-Automated-EJR2020

Automatic Segmentation and RECIST Score Evaluation in Osteosarcoma using Diffusion MRI: A Computer Aided System Process

General Information:  In this project, a fully automated system for tumor segmentation and RECIST1.1 (Response evaluation criteria in solid tumors) annotation & scoring, using diffusion weighted MRI (DWI) has been implemented.

This computer aided system uses DWI slices as input, and produces the tumor masks that delineates the tumor in all slices covering whole tumor volume, identifies the DWI slice with maximum tumor burden and then annotates and measures the longest diameter of the tumor in that slice. After measuring the Tumor-diameters at different time points for a patient, tool then evaluates the change in the Tumor-diameter (maximum) across time points and evaluate the RECIST1.1 score for treatment response assessment. The tool also measures Tumor-volume and its change across time points as an assessment to the therapeutic response.

Following operations are performed during processing:

1.	Pre-processing of the 3-dimentional (3D) DWI data for intensity normalization and focus on anatomical part.
2.	Tumor segmentation based on two segmentation methods: i) Fuzzy c-means clustering (FCM) & ii) Simple linear iterative clustering superpixel (SLICs) algorithm.
3.	Tumor-diameter, slice number of maximum cross-sectional diameter of tumor (Max_burden_scliceno) and Tumor-volume are evaluated.
4.	If DWI data at second time-point is provided, tumor segmentation is performed using the same segmentation algorithms (selected earlier in step 2) and the Tumor-diameter and Tumor-volume are evaluated.
5.	Finally, the RECIST1.1 score and Volumetric response score are evaluated using both the datasets, based on the changes in Tumor-diameter and Tumor-volume across time-points during treatment. 

RECIST1.1 score is evaluated according to the following criterion proposed by Eisenhauer et al, “New response evaluation criteria in solid tumours: revised RECIST guideline (version 1.1)”, Eur. J. Cancer (2009), 45, 228–247, https://doi.org/10.1016/j.ejca.2008.10.026.:
Complete-response (CR): total disappearance of tumor;
Partial-response (PR): minimum 30% decrease in Tumor-diameter; 
Progressive-disease (PD): minimum 20% and 5mm absolute increase in Tumor-diameter; 
Stable-disease (SD): neither PR nor PD. 
Similarly, Volumetric response score is evaluated as: 
Complete-response (CR): total disappearance of tumor; 
Partial response (PR): minimum 30% decrease in Tumor-volume; 
Progressive-disease (PD): minimum 20% increase in Tumor-volume; 
Stable-disease (SD): neither PR nor PD.


Functions:
CAD_RECIST.m
Img_preprocessing.m
Seg_FCM.m
Seg_SLICs.m
Calculate_TumorDia.m
Calculate_TumorVol.m

Example of uses:

Data Loading: Load the DWI data as NIfTI file and extract 3D DWI stack preferably at 
                        b-value =800sec/mm2 or higher b-value as *.mat file.

     DWI_4D = load_untouch_niigz('C:\Documents\MATLAB\DWI_4D_baseline.nii.gz');

     [row, col, total_slice, total_bval] = size(DWI_4D.img);

     DWI_3D = DWI_4D.img( : , : , : , total_bval);


1. For, single DWI dataset 'DWI_3D.mat' is provided as 3D array with voxel size of  
    1.3mm x 1.3mm x 5.5mm and FCM algorithm is selected for segmentation, run:
      
       [ output ] = CAD_RECIST( 1, DWI_3D, [1.3 1.3 5.5]) 

2. For, DWI datasets 'DWI_3D_1.mat' and 'DWI_3D_2.mat' at baseline and follow-up  
    respectively are provided as 3D arrays with voxel size of 1.3mm x 1.3mm x 5.5mm and 
  1.4mm x 1.4mm x 5mm respectively and SLICs algorithm is selected for segmentation, run:
      
      [ output ] = CAD_RECIST( 2, DWI_3D_1, [1.3 1.3 5.5], DWI_3D_2, [1.4 1.4 5]) 


INPUTS:
- algorithm_type: Numerical value specifying the segmentation algorithm, '1' for FCM and '2'
                             for SLICs. 
- DWI_3D_baseline: 3D array containing the DWI dataset to analyze where structure of 3D 
                                  array is [row : col : total_slice]. Input 3D DWI data preferably at 
                                  b-value = 800 sec/mm2 or higher b-value.
- voxel_dim_baseline: Numerical value specifying the voxel dimension (mm)
                                     in [length height width] format.
- DWI_3D_followup: Same as DWI_3D_baseline. This input is optional, when   provided,
                                    the function processes the DWI datasets at both time-points and 
                                    evaluates response scores otherwise process single DWI dataset only. 
- voxel_dim_followup: Same as voxel_dim_baseline. This input is optional, when not 
                                      provided value of voxel_dim_baseline is considered for 
                                      voxel_dim_followup.

OUTPUTS: 
- TumorMask_baseline 
- Tumor_diameter_in_cm
- Max_burden_sliceno
- Tumor_volume_in_cc
If DWI dataset at 2nd time-point is provided output also contains,
- TumorMask_followup
- Tumor_diameter_followup_in_cm
- Max_burden_sliceno_followup
- Tumor_volume_followup_in_cc 
- RECIST_score
- Volumetric_response_score

Example DWI datasets: DWI_4D_baseline.nii.gz, DWI_4D_followup.nii.gz 


Use of this project must be cited as: 
Baidya Kayal E., Kandasamy D., Yadav R., Bakhshi S., Sharma R., Mehndiratta, A. Computer aided diagnostic system for automatic segmentation and RECIST score evaluation in osteosarcoma using diffusion MRI. European Journal of Radiology (2020). doi:http://doi.org/10.1016/j.ejrad.2020.109359.

For any detailed enquiry, please contact Dr Amit Mehndiratta, Indian Institute of Technology Delhi, India Email: amit.mehndiratta@keble.oxon.org
Disclaimer: These project can be used only for research purposes. Authors are not liable for any clinical use of it, authors could not held be responsible.
