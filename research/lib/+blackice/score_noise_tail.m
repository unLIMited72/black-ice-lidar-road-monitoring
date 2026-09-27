function p = score_noise_tail(x,sigma,family,mode)
%SCORE_NOISE_TAIL Analytic symmetric score-noise survival function, no censoring.
if sigma==0, p=double(x<0); return; end
z=abs(x);
switch string(family)
 case "Gaussian"
  p=blackice.normal_tail(x,0,sigma*sqrt(1+double(mode=="R1"))); return
 case "Uniform"
  a=sqrt(3)*sigma;
  if mode=="R0", tail=max(0,(a-z)/(2*a));
  else, tail=max(0,2*a-z).^2/(8*a^2); end
 case "Laplace"
  u=z/(sigma/sqrt(2));
  if mode=="R0", tail=.5*exp(-u);
  else, tail=(u+2).*exp(-u)/4; end
 otherwise, error('blackice:NoiseFamily','Unknown noise family.');
end
p=tail; p(x<0)=1-tail(x<0);
end
