function T = level2_cell(H,t_mm,angle,sigma0_mm,f,mode,N,stream_id,c,geometry)
%LEVEL2_CELL Vectorized trials, all validity profiles, three thresholds.
% geometry is supplied from verified Simulink in the full experiment.
if nargin<11, geometry=blackice.geometry(H,t_mm/1000,angle); end
DA=geometry.D_A_m; DI=geometry.D_I_m;
[sigma,A]=blackice.level2_sigma(sigma0_mm/1000,angle,DA,f.p,f.q,c.D_ref_m);
s=blackice.draw_scores(DA,DI,sigma,mode,N,c.master_seed,stream_id);
if s.sigma_score_m==0
    tau=zeros(size(c.pfa_points)); % strict >0: dry false alarms exactly zero
else
    tau=blackice.threshold(c.pfa_points,s.sigma_score_m);
end
[pvD,peD,methodD]=blackice.level2_theory(DA,DA,sigma,mode,tau);
[pvI,peI,methodI]=blackice.level2_theory(DA,DI,sigma,mode,tau);
physicalD=s.dry_measured_m>0 & s.dry_reference_m>0;
physicalI=s.ice_measured_m>0 & s.ice_reference_m>0;
u=RandStream('mrg32k3a','Seed',c.master_seed);
u.Substream=2000000+2*stream_id; ud=rand(u,N,1);
u.Substream=2000001+2*stream_id; ui=rand(u,N,1);
hitD=s.dry_score_m>tau; hitI=s.ice_score_m>tau;
names={'validity_index','pfa_target','threshold','N_total','N_valid_dry','N_valid_ice', ...
 'false_alarm_count','detection_count','mean_dry','std_dry','mean_ice','std_ice', ...
 'separation','d_prime','coverage_dry_theory','coverage_ice_theory', ...
 'P_FA_all_theory','P_D_all_theory','physical_invalid_dry','physical_invalid_ice', ...
 'stress_invalid_dry','stress_invalid_ice','p_valid_stress'};
B=nan(height(c.validities)*numel(tau),numel(names));
for v=1:height(c.validities)
    pv=blackice.level2_valid_probability(angle,DA,c.validities(v,:),c.D_ref_m);
    vd=physicalD & ud<pv; vi=physicalI & ui<pv;
    nd=sum(vd); ni=sum(vi);
    xd=s.dry_score_m(vd); xi=s.ice_score_m(vi);
    md=mean(xd); mi=mean(xi); sd=NaN; si=NaN;
    if nd>1, sd=std(xd,0); end
    if ni>1, si=std(xi,0); end
    sep=abs(mi-md); dp=sep/sqrt((sd^2+si^2)/2);
    kd=sum(hitD & vd,1); ki=sum(hitI & vi,1);
    ix=(v-1)*numel(tau)+(1:numel(tau));
    B(ix,:)=[repmat(v,3,1),c.pfa_points(:),tau(:),repmat([N nd ni],3,1),kd(:),ki(:), ...
      repmat([md sd mi si sep dp pv*pvD pv*pvI],3,1),pv*peD(:),pv*peI(:), ...
      repmat([sum(~physicalD) sum(~physicalI) sum(ud>=pv) sum(ui>=pv) pv],3,1)];
end
T=array2table(B,'VariableNames',names);
T.H_m(:)=H; T.thickness_mm(:)=t_mm; T.angle_deg(:)=angle;
T.slant_range_m(:)=DA; T.sigma0_mm(:)=sigma0_mm; T.sigma_eff_mm(:)=1000*sigma;
T.sigma_amplification(:)=A; T.p(:)=f.p; T.q(:)=f.q;
T.stream_id(:)=stream_id; T.master_seed(:)=c.master_seed;
T.sigma_score_m(:)=s.sigma_score_m;
T.theory_method=repmat(methodD+" / "+methodI,height(T),1);
end
