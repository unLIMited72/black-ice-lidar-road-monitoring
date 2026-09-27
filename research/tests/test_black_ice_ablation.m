classdef test_black_ice_ablation < matlab.unittest.TestCase
 methods(TestClassSetup)
  function setup(~)
   addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'scripts')); checkpoint_setup();
  end
 end
 methods(Test)
  function nullThicknessRemovesIcePenalty(tc)
   c=checkpoint03_parameters(); x=blackice.ablation_config("A5",c); x.t_mm=0;
   x.kappa=1.5; x.rho_rel=.5; q=blackice.observability_cell(x,c);
   tc.verifyEqual(q.Q_norm_dry,q.Q_norm_ice,'AbsTol',0);
   tc.verifyEqual(q.P_D_theory,q.P_FA_theory,'AbsTol',1e-14);
  end
  function zeroSurfaceContrastHasNoSpecificityEffect(tc)
   c=checkpoint03_parameters(); x=blackice.ablation_config("A5",c); x.kappa=0;
   a=blackice.observability_cell(x,c); x.stage="C0_height_only"; b=blackice.observability_cell(x,c);
   tc.verifyEqual(a.P_D_all-b.P_D_all,zeros(3,1),'AbsTol',0);
   tc.verifyEqual(a.coverage_ice-b.coverage_ice,zeros(3,1),'AbsTol',0);
  end
  function overallUsesIceCoverage(tc)
   c=checkpoint03_parameters(); x=blackice.ablation_config("A5",c); q=blackice.observability_cell(x,c);
   tc.verifyEqual(q.P_overall_detect,q.P_D.*q.coverage_ice,'AbsTol',1e-14);
   tc.verifyGreaterThanOrEqual([q.P_D;q.P_FA;q.coverage],0);
   tc.verifyLessThanOrEqual([q.P_D;q.P_FA;q.coverage],1);
  end
  function noNoiseGeometry(tc)
   c=checkpoint03_parameters(); x=blackice.ablation_config("A0",c); q=blackice.observability_cell(x,c);
   tc.verifyEqual(q.P_D,ones(3,1),'AbsTol',0); tc.verifyEqual(q.P_FA,zeros(3,1),'AbsTol',0);
  end
  function level1Reduction(tc)
   c=checkpoint03_parameters(); x=blackice.ablation_config("A1",c);
   a=blackice.observability_cell(x,c);
   b=blackice.level2_finalize(blackice.level2_cell(x.H_m,x.t_mm,x.theta_deg,x.sigma0_mm,c.families(1,:),"R0",c.N,x.stream_id,c),c);
   b=b(b.validity_index==1,:);
   tc.verifyEqual(a.P_D,b.P_D,'AbsTol',0); tc.verifyEqual(a.P_FA,b.P_FA,'AbsTol',0);
  end
  function gaussianSavedCheckpoint02Replay(tc)
   c=checkpoint03_parameters(); saved=load(fullfile(c.processed,'level2_full_e3_results.mat'),'T');
   b=saved.T(saved.T.H_m==1.5 & saved.T.thickness_mm==10 & saved.T.angle_deg==30 & saved.T.sigma0_mm==10 & saved.T.family_index==9 & saved.T.reference_mode=="R1" & saved.T.validity_index==6,:);
   G=readtable(fullfile(c.processed,'level2_geometry_inputs.csv')); G=G(G.H_m==1.5 & G.thickness_mm==10 & G.angle_deg==30,:);
   g=struct('D_A_m',G.D_A_m,'D_I_m',G.D_I_m,'geometry_valid',true);
   x=blackice.ablation_config("A4",c); x.stream_id=b.stream_id(1);
   a=blackice.observability_cell(x,c,g);
   tc.verifyEqual(a.P_D_all,b.P_D_all,'AbsTol',0); tc.verifyEqual(a.P_FA_all,b.P_FA_all,'AbsTol',0);
   tc.verifyEqual(a.coverage,b.coverage,'AbsTol',0);
   tc.verifyEqual(a.mean_ice,b.mean_ice,'AbsTol',1e-14);
  end
 end
end
