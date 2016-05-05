function [ plt ] = cplot( c, opts, fig )
%CPLOT Plot complex number(s) on the complex plane
%   Given a vector of complex numbers, c, this function will plot them on
%   the complex plane.  You may specify the point type and color in the
%   options.

[m,n] = size(c);

if m > 1 && n > 1
  warning('c is a matrix.  Vectorizing and plotting all entries.\n\n');
end
c = c(:);
if nargin == 3
  figure(fig);
else
  figure('Name', 'Complex Plane'); 
end

set(0, 'defaultaxesfontsize',14,'defaultaxeslinewidth',1.0,...
       'defaultlinelinewidth',1.0,'defaultpatchlinewidth',1.0,...
       'defaulttextfontsize',18);
     
    
re = real(c);
im = imag(c);

stable_idx = find(re<0);
unstable_idx = find(re>=0);


maxRe = 1.1*max(abs(c));
maxIm = 1.1*max(abs(c));

ze = zeros(1,200);
if maxRe == 0
  re_axis=linspace(-1,1,200);
else
  re_axis = linspace(-maxRe, maxRe, 200);
end
if maxIm == 0
  im_axis = linspace(-1,1,200);
else
  im_axis = linspace(-maxIm, maxIm, 200);
end

if nargin == 1
  hold on
  plot(re_axis,ze,'k',ze,im_axis,'k');
  plot(re(stable_idx),im(stable_idx),'bo');
  plot(re(unstable_idx),im(unstable_idx), 'r*');
  hold off
  plt = 0;
else
  plt = plot(re_axis,ze,'k',ze,im_axis,'k',re,im,opts);
end
title('Complex Plane');
xlabel('Re');
ylabel('Im');
axis square

end

