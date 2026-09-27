function summary = run_level1_pilot_monte_carlo()
%RUN_LEVEL1_PILOT_MONTE_CARLO Simulation-only, constant Gaussian pilot.
cfg=checkpoint_setup();
validation=load(fullfile(cfg.processed,'simulink_geometry_validation.mat'),'summary');
assert(validation.summary.pass,'blackice:UnverifiedGeometry','Run V1 first.');
nt=numel(cfg.thicknesses_mm); na=numel(cfg.angles_deg); ns=numel(cfg.sigmas_mm);
% Actual Simulink ranges drive the MATLAB noise/analysis stage. The closed
% form remains an independent reference for theoretical score separation.
[pt,pa]=ndgrid(cfg.thicknesses_mm/1000,cfg.angles_deg);
pH=repmat(cfg.pilot_H_m,numel(pt),1);
simGeometry=blackice.simulate_geometry(pH,pt(:),pa(:),cfg);
analytic=blackice.geometry(pH,pt(:),pa(:));
assert(all(simGeometry.geometry_valid));
assert(max(abs(simGeometry.delta_m-analytic.delta_m))<cfg.geometry_atol_m);
pilotGeometry=table(pH,pt(:),pa(:),simGeometry.D_A_m,simGeometry.D_I_m, ...
    simGeometry.delta_m,analytic.delta_m,'VariableNames', ...
    {'H_m','t_m','theta_deg','D_A_sim_m','D_I_sim_m','delta_sim_m','delta_theory_m'});
writetable(pilotGeometry,fullfile(cfg.processed,'pilot_geometry_inputs.csv'));
ncell=nt*na*ns*2;
raw=cell(ncell,1); rows=cell(ncell,1); roc_preview=cell(ncell,1);
idx=0;
for it=1:nt
    for ia=1:na
        for is=1:ns
            for ir=1:2
                idx=idx+1;
                t_mm=cfg.thicknesses_mm(it); angle_deg=cfg.angles_deg(ia);
                sigma_mm=cfg.sigmas_mm(is); mode=cfg.reference_modes(ir);
                g=blackice.geometry(cfg.pilot_H_m,t_mm/1000,angle_deg);
                ig=it+(ia-1)*nt;
                g.D_A_m=simGeometry.D_A_m(ig); g.D_I_m=simGeometry.D_I_m(ig);
                samples=blackice.draw_scores(g.D_A_m,g.D_I_m,sigma_mm/1000, ...
                    mode,cfg.pilot_N,cfg.master_seed,idx);
                assert(samples.invalid_count==0,'blackice:InvalidPilotRange', ...
                    'Invalid simulated range: extend validity policy before using this cell.');
                meta=struct('scenario_id',sprintf('L1_%03d_%s',idx,mode), ...
                    'reference_mode',mode,'H_m',cfg.pilot_H_m, ...
                    'thickness_mm',t_mm,'angle_deg',angle_deg,'sigma_mm',sigma_mm, ...
                    'master_seed',cfg.master_seed,'stream_id',idx, ...
                    'geometry_source',"Simulink standard-block model");
                rows{idx}=blackice.summarize_scores(samples,meta,cfg.pfa_points,g.delta_m,cfg.ci_alpha);
                roc=blackice.empirical_roc(samples.dry_score_m,samples.ice_score_m);
                raw{idx}=struct('metadata',meta,'geometry',g,'samples',samples,'roc',roc);
                % CSV preview; raw MAT retains EVERY empirical ROC point.
                take=unique(round(linspace(1,height(roc),101)));
                preview=roc(take,:);
                preview.scenario_id=repmat(string(meta.scenario_id),height(preview),1);
                roc_preview{idx}=preview;
            end
        end
    end
end
T=vertcat(rows{:}); roc_preview=vertcat(roc_preview{:});
writetable(T,fullfile(cfg.processed,'level1_pilot_results.csv'));
writetable(roc_preview,fullfile(cfg.processed,'level1_roc_preview.csv'));
save(fullfile(cfg.raw,'level1_pilot_raw.mat'),'raw','cfg','-v7');

% Representative convergence at fixed, predeclared t=10,theta=30,sigma=10.
C=cell(2*numel(cfg.convergence_N),1); ci=0;
for ir=1:2
    pick=find(T.thickness_mm==cfg.example_t_mm & T.angle_deg==cfg.example_angle_deg & ...
        T.sigma_mm==cfg.example_sigma_mm & string(T.reference_mode)==cfg.reference_modes(ir),1);
    cellIndex=T.stream_id(pick); ref=raw{cellIndex};
    for n=cfg.convergence_N
        samples=blackice.draw_scores(ref.geometry.D_A_m,ref.geometry.D_I_m, ...
            cfg.example_sigma_mm/1000,cfg.reference_modes(ir),n,cfg.master_seed,cellIndex);
        ci=ci+1;
        C{ci}=blackice.summarize_scores(samples,ref.metadata,cfg.pfa_points,ref.geometry.delta_m,cfg.ci_alpha);
    end
end
C=vertcat(C{:});
writetable(C,fullfile(cfg.processed,'level1_convergence.csv'));

% 95% individual intervals need NOT all cover: thousands of comparisons.
% Conservative simultaneous EXACT interval verification; family alpha .01.
% Wilson is retained for descriptive 95% intervals but is approximate in
% extreme tails. Clopper-Pearson avoids an invalid score-normal approximation.
alphaEach=cfg.family_alpha/(2*height(T));
[faLo,faHi]=blackice.binomial_exact_interval(T.false_alarm_count,T.N,alphaEach);
[pdLo,pdHi]=blackice.binomial_exact_interval(T.detection_count,T.N,alphaEach);
familyPass=all(T.P_FA_theory>=faLo-1e-14 & T.P_FA_theory<=faHi+1e-14 & ...
    T.P_D_theory>=pdLo-1e-14 & T.P_D_theory<=pdHi+1e-14);
summary=struct('scenario_count',ncell,'result_rows',height(T), ...
    'N_per_class_per_cell',cfg.pilot_N,'master_seed',cfg.master_seed, ...
    'score_samples',2*cfg.pilot_N*ncell, ...
    'max_abs_PFA_error',max(abs(T.P_FA_mc-T.P_FA_theory)), ...
    'max_abs_PD_error',max(abs(T.P_D_mc-T.P_D_theory)), ...
    'pfa_pointwise_95_coverage',mean(T.pfa_theory_in_ci), ...
    'pd_pointwise_95_coverage',mean(T.pd_theory_in_ci), ...
    'simultaneous_exact_interval_pass',familyPass, ...
    'simultaneous_family_alpha',cfg.family_alpha,'invalid_count',sum(T.invalid_count));
save(fullfile(cfg.processed,'level1_pilot_results.mat'),'T','C','summary','cfg');
disp(summary);
assert(familyPass,'blackice:ProbabilityVerification','Simultaneous MC/theory verification failed.');
end
