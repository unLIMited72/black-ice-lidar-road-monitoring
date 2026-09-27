classdef test_full_e3_pipeline < matlab.unittest.TestCase
 methods(TestClassSetup)
  function setup(~)
   addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'scripts')); checkpoint_setup();
  end
 end
 methods(Test)
  function reproducibleCell(tc)
   c=level2_parameters();
   a=blackice.level2_cell(1.5,10,30,10,c.families(9,:),"R1",1000,190001,c);
   b=blackice.level2_cell(1.5,10,30,10,c.families(9,:),"R1",1000,190001,c);
   tc.verifyTrue(isequaln(a,b));
  end
  function coverageAndUnknown(tc)
   c=level2_parameters();
   a=blackice.level2_finalize(blackice.level2_cell(3,10,70,10,c.families(9,:),"R0",1000,190002,c),c);
   tc.verifyEqual(a.coverage+a.unknown_rate,ones(21,1),'AbsTol',1e-14);
   q=a(a.N_valid_ice>0,:);
   tc.verifyEqual(q.P_D_all,q.P_D.*q.coverage_ice,'AbsTol',1e-14);
  end
  function deterministicNoCoverage(tc)
   c=level2_parameters();
   a=blackice.level2_finalize(blackice.level2_cell(3,10,70,10,c.families(9,:),"R0",1000,190003,c),c);
   q=a(a.validity_index==3,:);
   tc.verifyEqual(q.N_valid,zeros(3,1),'AbsTol',0);
   tc.verifyTrue(all(isnan(q.P_D))); tc.verifyEqual(q.P_D_all,zeros(3,1),'AbsTol',0);
  end
  function nullClassTheoryAndMC(tc)
   c=level2_parameters();
   a=blackice.level2_finalize(blackice.level2_cell(1.5,0,30,10,c.families(9,:),"R1",10000,190004,c),c);
   q=a(a.validity_index==1,:);
   tc.verifyEqual(q.P_D_theory,q.P_FA_theory,'AbsTol',1e-14);
   tc.verifyLessThan(abs(q.P_D-q.P_FA),.025*ones(3,1)); % >5 joint sampling SE near p=.1
  end
  function perfectNoNoiseDecision(tc)
   tc.verifyEqual(blackice.level2_decide([0 .03],0,[true true]),int8([0 1]));
  end
  function zeroNoiseFullCell(tc)
   c=level2_parameters();
   a=blackice.level2_finalize(blackice.level2_cell(1.5,10,30,0,c.families(9,:),"R0",1000,190007,c),c);
   q=a(a.validity_index==1,:);
   tc.verifyEqual(q.P_FA,zeros(3,1),'AbsTol',0);
   tc.verifyEqual(q.P_D,ones(3,1),'AbsTol',0);
   tc.verifyEqual(q.P_D_theory,ones(3,1),'AbsTol',0);
  end
  function cellContainsAllAnalysisPoints(tc)
   c=level2_parameters();
   a=blackice.level2_cell(1.5,10,30,10,c.families(1,:),"R0",1000,190005,c);
   tc.verifySize(a,[21 36]); tc.verifyEqual(unique(a.pfa_target),[.01;.05;.1],'AbsTol',0);
  end
  function independentCountsAndPhysicalCensoring(tc)
   c=level2_parameters(); g=blackice.geometry(3,.01,70);
   a=blackice.level2_cell(3,10,70,20,c.families(10,:),"R1",5000,190006,c);
   sigma=.020/(cosd(70)^2)*(g.D_A_m/1.6)^2;
   s=blackice.draw_scores(g.D_A_m,g.D_I_m,sigma,"R1",5000,42,190006);
   good=s.ice_measured_m>0 & s.ice_reference_m>0;
   d=blackice.level2_decide(s.ice_score_m,blackice.threshold(.05,sqrt(2)*sigma),good);
   row=a(a.validity_index==1 & a.pfa_target==.05,:);
   tc.verifyEqual(row.detection_count,sum(d==1),'AbsTol',0);
   tc.verifyEqual(row.N_valid_ice,sum(d~=-1),'AbsTol',0);
   tc.verifyGreaterThan(row.physical_invalid_ice,0);
  end
  function executedFullMatrixGate(tc)
   c=level2_parameters(); x=load(fullfile(c.processed,'level2_full_e3_results.mat'),'T','summary');
   tc.verifyEqual(height(x.T),403200);
   tc.verifyEqual(height(unique(x.T(:,{'H_m','thickness_mm','angle_deg','sigma0_mm'}))),960);
   tc.verifyEqual(numel(unique(x.T.scenario_id)),134400);
   tc.verifyTrue(x.summary.simultaneous_gate_pass);
   tc.verifyEqual(x.summary.simultaneous_failures,0);
  end
 end
end
