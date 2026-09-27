function T = observability_cell(x,c,g)
%OBSERVABILITY_CELL Geometry + uncertainty + independent return gate.
% Optional g permits exact replay of saved Simulink ranges, without rerunning E3.
if nargin<3, g=blackice.geometry(x.H_m,x.t_mm/1000,x.theta_deg); end
assert(all(g.geometry_valid),'blackice:InvalidGeometry','Invalid geometry.');
DA=g.D_A_m; DI=g.D_I_m;
[sigma,A]=blackice.level2_sigma(x.sigma0_mm/1000,x.theta_deg,DA,x.p,x.q,c.D_ref_m);
s=blackice.distribution_scores(DA,DI,sigma,x.reference_mode,c.N,x.seed,x.stream_id,x.noise_family);
tau=blackice.distribution_threshold(c.pfa_points,sigma,x.noise_family,x.reference_mode,x.threshold_policy);
[qD,~]=blackice.return_proxy(x.theta_deg,DA,1,c.n_diffuse,0,c.D_ref_m);
effectiveKappa=x.kappa; effectiveRho=x.rho_rel;
if x.t_mm==0, effectiveKappa=0; effectiveRho=1; end
[qI,penalty]=blackice.return_proxy(x.theta_deg,DI,effectiveRho,c.n_diffuse,effectiveKappa,c.D_ref_m);
poD=1; poI=1;
if x.surface_enabled
 poD=blackice.surface_observability(qD,x.Q_scale,x.return_link);
 poI=blackice.surface_observability(qI,x.Q_scale,x.return_link);
end
pv=blackice.level2_valid_probability(x.theta_deg,DA,c.validities(x.validity_index,:),c.D_ref_m);
u=RandStream('mrg32k3a','Seed',x.seed);
u.Substream=2000000+2*x.stream_id; vd=rand(u,c.N,1)<pv;
u.Substream=2000001+2*x.stream_id; vi=rand(u,c.N,1)<pv;
u.Substream=6000000+2*x.stream_id; od=rand(u,c.N,1)<poD;
u.Substream=6000001+2*x.stream_id; oi=rand(u,c.N,1)<poI;
phyD=s.dry_measured_m>0 & s.dry_reference_m>0;
phyI=s.ice_measured_m>0 & s.ice_reference_m>0;
validD=vd & od & phyD; validI=vi & oi & phyI;
nd=sum(validD); ni=sum(validI);
kd=sum(s.dry_score_m>tau & validD,1); ki=sum(s.ice_score_m>tau & validI,1);
xd=s.dry_score_m(validD); xi=s.ice_score_m(validI);
md=mean(xd); mi=mean(xi); sd=NaN; si=NaN;
if nd>1, sd=std(xd,0); end
if ni>1, si=std(xi,0); end
if x.noise_family=="Gaussian"
 [vpD,epD]=blackice.level2_theory(DA,DA,sigma,x.reference_mode,tau);
 [vpI,epI]=blackice.level2_theory(DA,DI,sigma,x.reference_mode,tau);
else
 tailBound=blackice.score_noise_tail(min(DA,DI),sigma,x.noise_family,"R0")*2;
 assert(tailBound<=1e-12,'blackice:TailDomain','Non-Gaussian positivity approximation outside declared domain.');
 vpD=1; vpI=1;
 epD=blackice.score_noise_tail(tau,sigma,x.noise_family,x.reference_mode);
 epI=blackice.score_noise_tail(tau-(DA-DI),sigma,x.noise_family,x.reference_mode);
end
T=table(c.pfa_points(:),tau(:),kd(:),ki(:),'VariableNames',{'pfa_target','threshold','false_alarm_count','detection_count'});
T.N_total(:)=c.N; T.N_valid_dry(:)=nd; T.N_valid_ice(:)=ni;
T.mean_dry(:)=md; T.std_dry(:)=sd; T.mean_ice(:)=mi; T.std_ice(:)=si;
T.separation(:)=abs(mi-md); T.d_prime(:)=abs(mi-md)/sqrt((sd^2+si^2)/2);
T.coverage_dry_theory(:)=pv*poD*vpD; T.coverage_ice_theory(:)=pv*poI*vpI;
T.P_FA_all_theory=pv*poD*epD(:); T.P_D_all_theory=pv*poI*epI(:);
T.physical_invalid_dry(:)=sum(~phyD); T.physical_invalid_ice(:)=sum(~phyI);
T.validity_index(:)=x.validity_index;
T=blackice.level2_finalize(T,c);
T.range_warning=T.gaussian_range_warning; T.gaussian_range_warning=[];
fields=fieldnames(x);
for j=1:numel(fields)
 value=x.(fields{j}); T.(fields{j})=repmat(value,height(T),1);
end
T.H_m(:)=x.H_m; T.thickness_mm(:)=x.t_mm; T.angle_deg(:)=x.theta_deg;
T.sigma_eff_mm(:)=sigma*1000; T.sigma_amplification(:)=A;
T.D_A_m(:)=DA; T.D_I_m(:)=DI; T.delta_mm(:)=(DA-DI)*1000;
T.Q_norm_dry(:)=qD; T.Q_norm_ice(:)=qI; T.specular_penalty(:)=penalty;
T.P_return_dry(:)=poD; T.P_return_ice(:)=poI;
T.P_generic_valid(:)=pv; T.master_seed(:)=x.seed;
T.P_overall_detect=T.P_D_all;
T.no_layer_control(:)=x.t_mm==0;
T.surface_id=repmat("S"+string(find(c.kappas==x.kappa,1)-1),height(T),1);
end
