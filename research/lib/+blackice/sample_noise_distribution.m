function e = sample_noise_distribution(family,sigma_m,N,seed,substream)
%SAMPLE_NOISE_DISTRIBUTION Equal measurement variance sigma_m^2, local RNG.
validateattributes(sigma_m,{'numeric'},{'scalar','finite','nonnegative'});
validateattributes(N,{'numeric'},{'scalar','integer','positive'});
r=RandStream('mrg32k3a','Seed',seed); r.Substream=substream;
switch string(family)
 case "Gaussian", e=sigma_m*randn(r,N,1);
 case "Uniform", e=sqrt(3)*sigma_m*(2*rand(r,N,1)-1);
 case "Laplace"
  u=rand(r,N,1)-.5;
  e=-(sigma_m/sqrt(2))*sign(u).*log1p(-2*abs(u));
 otherwise, error('blackice:NoiseFamily','Unknown noise family.');
end
end
