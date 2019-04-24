This set of codes are used to measure the aberrations and create SLM correction phase masks. The SLM masks can then be used as part of the calibration in "ImagingControl.m".

Procedure:
1. Run "AdaptiveOptics_modal.m" to measure the aberrations and create SLM correction phase mask for different imaging depths.
2. Run "assemble_ao_phase.m" to assemble the correction mask for different imaging depths into a single calibration file, which can then be used as part of the calibration in "ImagingControl.m" when performing volumetric imaging. 


