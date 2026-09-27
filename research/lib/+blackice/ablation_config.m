function x = ablation_config(stage,c)
%ABLATION_CONFIG Shared explicit scenario defaults and incremental A0-A5 stages.
x=struct('stage',string(stage),'H_m',1.5,'t_mm',10,'theta_deg',30,'sigma0_mm',10, ...
 'p',1,'q',1,'reference_mode',"R1",'validity_index',1,'surface_enabled',false, ...
 'kappa',.5,'rho_rel',1,'Q_scale',c.Q_scale,'return_link',"rational", ...
 'noise_family',"Gaussian",'threshold_policy',"matched",'seed',42,'stream_id',400001);
switch string(stage)
 case "A0", x.sigma0_mm=0; x.p=0; x.q=0; x.reference_mode="R0";
 case "A1", x.p=0; x.q=0; x.reference_mode="R0";
 case "A2", x.reference_mode="R0";
 case "A3"
 case "A4", x.validity_index=6;
 case "A5", x.validity_index=6; x.surface_enabled=true;
 otherwise, error('blackice:AblationStage','Unknown ablation stage.');
end
end
