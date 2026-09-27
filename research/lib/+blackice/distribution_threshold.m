function tau = distribution_threshold(alpha,sigma,family,mode,policy)
%DISTRIBUTION_THRESHOLD Matched theoretical null or deliberately Gaussian-fixed.
validateattributes(alpha,{'numeric'},{'real','>',0,'<',.5});
if sigma==0, tau=zeros(size(alpha)); return; end
if policy=="Gaussian_fixed" || family=="Gaussian"
 tau=blackice.threshold(alpha,sigma*sqrt(1+double(mode=="R1")));
elseif family=="Uniform"
 a=sqrt(3)*sigma;
 if mode=="R0", tau=a*(1-2*alpha);
 else, tau=2*a*(1-sqrt(2*alpha)); end
elseif family=="Laplace"
 b=sigma/sqrt(2);
 if mode=="R0", tau=-b*log(2*alpha);
 else
  tau=arrayfun(@(v) b*fzero(@(z) (z+2)*exp(-z)/4-v,[0 100]),alpha);
 end
else
 error('blackice:NoiseFamily','Unknown noise family.');
end
end
