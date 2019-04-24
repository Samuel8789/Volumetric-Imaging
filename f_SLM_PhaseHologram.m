% Calculate the SLM hologram given the target points
% Author: Sean Quirin, modified by Weijian Yang 2014-2019

function [ phase ] = f_SLM_PhaseHologram( xyzp, SLMm, SLMn, weight, objectiveNA, objectiveRI, illuminationWavelength, handles )
%F_SLM_PHASEHOLOGRAM Summary of this function goes here
%   Detailed explanation goes here

    [ u, v ] = meshgrid(  linspace(-SLMm/SLMm,SLMm/SLMm,SLMm), ...
                         linspace(-SLMn/SLMn,SLMn/SLMn,SLMn) );
    SLMplane=0;
    defocus=zeros(SLMm, SLMn, size(xyzp,1));
    if nargin<4
        weight=zeros(1,size(xyzp,1))+1;
    end
    if nargin>=4
        for idx=1:size(xyzp,1)            
            defocus(:,:,idx) = SLMMicroscope_DefocusPhase( SLMm, SLMn, objectiveNA(idx), objectiveRI, illuminationWavelength );
        end
    end
    
    if handles.applyAO == 0 || isempty(handles.adaptiveOpticsCal_phase)    % do not apply AO
        for idx=1:size(xyzp,1)
            SLMplane=SLMplane+exp( 1i.*(2*pi.*xyzp(idx,1).*u ...
                                  + 2*pi.*xyzp(idx,2).*v ...
                                  + xyzp(idx,3).*defocus(:,:,idx)) )*weight(idx);
        end
    else                         % apply AO
        for idx = 1:size(xyzp,1)
            if xyzp(idx,3) >= handles.adaptiveOpticsCal_depth(end)
                AOphase = handles.adaptiveOpticsCal_phase(:,:,end);
            elseif xyzp(idx,3) <= handles.adaptiveOpticsCal_depth(1)
                AOphase = handles.adaptiveOpticsCal_phase(:,:,1);
            else % do linear interpolation
                depth_indx = find(xyzp(idx,3)>=handles.adaptiveOpticsCal_depth);
                depth_indx = depth_indx(end);
                AOphase = handles.adaptiveOpticsCal_phase(:,:,depth_indx)+...
                    (handles.adaptiveOpticsCal_phase(:,:,depth_indx+1)-handles.adaptiveOpticsCal_phase(:,:,depth_indx))*...
                    (xyzp(idx,3)-handles.adaptiveOpticsCal_depth(depth_indx))/...
                    (handles.adaptiveOpticsCal_depth(depth_indx+1)-handles.adaptiveOpticsCal_depth(depth_indx));
            end
            SLMplane = SLMplane+exp( 1i.*(2*pi.*xyzp(idx,1).*u ...
                                  + 2*pi.*xyzp(idx,2).*v ...
                                  + xyzp(idx,3).*defocus(:,:,idx) ...
                                  + AOphase) )*weight(idx);
        end
    end
        
    phase = angle(SLMplane);
    
end

function [ defocus ] = SLMMicroscope_DefocusPhase( SLMm, SLMn, objectiveNA, objectiveRI, illuminationWavelength )
    xlm = linspace(-1, 1, SLMm);
    xln = linspace(-1, 1, SLMn);
    [fX fY] = meshgrid( xlm, xln );
    [THETA RHO] = cart2pol( fX, fY );
    
    alpha = asin( (objectiveNA./objectiveRI) );
    k = 2*pi/illuminationWavelength;
    
% from 'Three dimensional imaging and photostimulation by remote focusing and holographic light patterning'
    c_0_2 = ( objectiveRI*k*(sin(alpha)^2)/(8*pi*sqrt(3)) ).*( 1 + (1/4)*(sin(alpha)^2) + (9/80)*(sin(alpha)^4) + (1/16)*(sin(alpha)^6) );
    c_0_4 = ( objectiveRI*k*(sin(alpha)^4)/(96*pi*sqrt(5)) ).*( 1 + (3/4)*(sin(alpha)^2) + (15/18)*(sin(alpha)^4) );
    c_0_6 = ( objectiveRI*k*(sin(alpha)^6)/(640*pi*sqrt(7)) ).*( 1 + (5/4)*(sin(alpha)^2) );
    Z_0_2 = sqrt(3).*( 2.*RHO.^2 - 1 );
    Z_0_4 = sqrt(5).*( 6.*RHO.^4 - 6.*RHO.^2 + 1 );
    Z_0_6 = sqrt(7).*( 20.*RHO.^6 - 30.*RHO.^4 + 12.*RHO.^2 - 1 );
    %figure; subplot(1,3,1); imagesc(Z_0_2.*(RHO<=1)); axis image; colorbar;
    %    subplot(1,3,2); imagesc(Z_0_4.*(RHO<=1)); axis image; colorbar;
    %    subplot(1,3,3); imagesc(Z_0_6.*(RHO<=1)); axis image; colorbar;
    %figure; imagesc(RHO); axis image; colorbar;
    %dsp_debug on line below can include HOA corrections...
%    defocus = 2*pi.*(c_0_2.*Z_0_2 + c_0_4.*Z_0_4 );%+ c_0_6.*Z_0_6;
    defocus = 2*pi.*(c_0_2.*Z_0_2 + c_0_4.*Z_0_4 + c_0_6.*Z_0_6);
%    defocus = -objectiveRI*k*sqrt(1-RHO.^2.*(sin(alpha)^2));
    
    % this is now formated for exp(i*defocus*z)
end