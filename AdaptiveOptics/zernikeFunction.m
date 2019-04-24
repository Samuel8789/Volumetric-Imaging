% zernike function
% Author: Weijian Yang, Shuting Han, 2017-2019

function [ Zmn ] = zernikeFunction( n,m,SLMm,SLMn )
%ZERNIKEFUNCTION Summary of this function goes here
%   Detailed explanation goes here
    xlm = linspace(-1, 1, SLMm);
    xln = linspace(-1, 1, SLMn);
    [fX fY] = meshgrid( xlm, xln );
    [THETA RHO] = cart2pol( fX, fY );
    
    R=0;
    for s=0:(n-abs(m))/2
        R=R+factorial(n-s)*(-1)^s/factorial(s)/factorial(0.5*(n+abs(m))-s)/factorial(0.5*(n-abs(m))-s)*(RHO.^(n-2*s));
    end
    if m>=0
        Zmn=R.*cos(m*THETA);
    else
        Zmn=-R.*sin(m*THETA);
    end
end

