function [H, w] = bode_plt( A, B, C, D, E, w0, wf, np, plt_opt)
%BODE_PLT Computes the Bode plot for the frequency response of a system
%   Inputs:
%     a,b,c,d,e - system matrices
%     w0 - log_10 of the starting frequency (default = -4)
%     wf - log_10 of the ending frequency (default = 4)
%     np - number of points to plot (default = 100)
%

if nargin < 4
  error('You must at least supply A, B, C, D system matrices');
elseif nargin < 8
  np = 100;
  if nargin < 7
    wf = 4;
    if nargin < 6
      w0 = -4;
      if nargin < 5
        E = eye(size(A));
      end
    end
  end
end

w = logspace(w0,wf,np);
jw = 1i.*w;

%H = zeros(size(C,1),length(w));
n = size(A,1);
[p,m] = size(D);


  
H = zeros(p,np);

for k = 1:np
  Hmat = ( C * ( ( (jw(k).*E) - A)\B ) ) + D; 
  if m == 1
    H(:,k) = abs(Hmat);
  else
    [~,Hsv,~] = svd(Hmat);
    H(:,k) = abs(diag(Hsv));
  end
end

H = log10(H).*20;

if nargin == 9
  semilogx(w,H,plt_opt);
else
  semilogx(w,H);
end
title('Bode Plot');
xlabel('Frequency (rad/s)');
ylabel('Singular Values (dB)');


end

