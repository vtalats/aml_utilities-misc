function [ ] = zplot( z, opts )
%CPLOT Plot complex number(s) on the complex plane
%   Given a vector of complex numbers, c, this function will plot them on
%   the complex plane.  You may specify the point type and color in the
%   options.

[m,n] = size(z);

if m > 1 && n > 1
  warning('c is a matrix.  Vectorizing and plotting all entries.\n\n');
end
z = z(:);

set(0, 'defaultaxesfontsize',14,'defaultaxeslinewidth',1.0,...
       'defaultlinelinewidth',1.0,'defaultpatchlinewidth',1.0,...
       'defaulttextfontsize',18);
     
figure('Name', 'Complex Plane');     
re   = real(z);
im   = imag(z);
zmod = abs(z);
stable_idx = find(zmod<1);
unstable_idx = find(zmod>=1);



maxMod = 1.1*max(abs(z));
axis_lim = linspace(-maxMod, maxMod, 200);
ze = zeros(1,200);

plt_angles = linspace(0,2*pi,200);
unit_circ = exp(1i.*plt_angles);

if nargin == 1
  plot(axis_lim,ze,'k',ze,axis_lim,'k',        ...
       re(stable_idx),im(stable_idx),'bo',     ...
       real(unit_circ),imag(unit_circ),'k',    ...
       re(unstable_idx),im(unstable_idx), 'r*');
else
  plot(axis_lim,ze,'k',ze,axis_lim,'k',        ...
       real(unit_circ),imag(unit_circ),'k',    ...
       re,im,opts);
end
title('Complex Plane');
xlabel('Re');
ylabel('Im');
axis equal


end

