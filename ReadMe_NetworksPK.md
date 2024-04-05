*Creating functional networks for PrcKids on a vertex-wise level*
*Author: Shefali Rai*
*Last updated: July 17, 2023*

*Pre-processing scripts handle functional and structural pre-processing using custom python .py scripts, as well as censoring the functional data based on a given FD threshold*

Must have the following downloaded and in your Matlab path:
   ciftiopen.m 
   ciftisave.m
   ciftisavereset.m
   cifti-matlab-master
   gifti-1.6
   BCT folder (threshold_proportional.m)

Network creation requires the following folders and/or files:
   infomap-1.2.1
   Open_Cifti.m
   Create_Consensus_Networks.m
   Consensus_Communities.m
   Run_Infomap_ConsensusD.m
   Create_FinalNetworks.m

Steps:
1. Create an empty folder:
Create a new folder called Infomap_Out
2. To create individual networks run:


3. View networks:
After running the scripts, open the appropriate .spec file from your data_path/subject/MNINonLinear/fsaverage_LR32k folder in wb_view and click Load. 
Change the view to inflated.32k_fs_LR.surf.gii for both left and right surfaces
Double click to open the *_17networks.dscalar.nii file that was created from this script
Click the wrench tool (under settings) and select the power_surf palette (if needed)


***********************************************************************************************************
All intermediate files can be deleted if needed

***********************************************************************************************************
Shefali edits and notes: 
%initial error "Invalid MEX-file.../xml_findstr.mexmaci64':" was resolved by:%%%%%
%First finding the missing file in terminal for mac: 
%     bash-3.2$ otool -L xml_findstr.mexmaci64
%Then using terminal in mac to build file using mex command: 
%     bash-3.2$ cd /Users/shefalirai/Documents/MATLAB/PRCKIDS_1973_Scripts/Utilities/read_write_cifti/gifti/@xmltree/private
%     bash-3.2$ /Applications/MATLAB_R2021b.app/bin/mex -compatibleArrayDims xml_findstr.c
%                      Building with 'Xcode with Clang'.
%                      MEX completed successfully.
%Then test the file path again:
%      bash-3.2$ otool -L xml_findstr.mexmaci64
%                      xml_findstr.mexmaci64:
%	                      @rpath/libmx.dylib (compatibility version 0.0.0, current version 0.0.0)
%	                      @rpath/libmex.dylib (compatibility version 0.0.0, current version 0.0.0)
%	                      /usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 1500.65.0)
%	                      /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1319.100.3)
%Finally, the MEX-file error is resolved.



