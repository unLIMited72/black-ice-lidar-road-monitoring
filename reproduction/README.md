# Reproduction workflow

This is an inspection-first workflow derived from the original source sequence. No computation below was executed during package preparation. Use a disposable copy for any output-producing step; original MATLAB scripts replace files under `research/results`.

1. Read the environment and model-boundary documents. Verify the package without simulation from the repository root:
   `python3 reproduction/verify_package.py`
2. Inspect geometry and parameters in `research/config`, `research/lib/+blackice/geometry.m` and `research/models`. For an intentional MATLAB geometry replay, from the repository root:
   ```matlab
   addpath('research/scripts'); checkpoint_setup();
   verify_geometry_analytical();
   validate_simulink_geometry();
   ```
   The included model can be used directly. The original `build_geometry_simulink_model` is available if rebuilding is needed; it opens Simulink and replaces the model, so it is not part of inspection.
3. For intentional simulation replay, initialize paths as above. The historical lower-level E3 sequence is:
   ```matlab
   [N,~] = run_level2_convergence();
   [T,S] = run_level2_full_e3(N);
   ```
   The return/robustness sequence is:
   ```matlab
   E4 = run_device_spec_analysis();
   [E5,E5s] = run_black_ice_observability();
   E6 = run_ablation_study();
   E7 = run_distribution_robustness();
   E8 = run_black_ice_specificity_control(E5);
   S = analyze_checkpoint03(E4,E5,E5s,E6,E7,E8);
   ```
   These are substantial simulation jobs. They reproduce model-conditional outputs, not new sensor evidence. The excluded run_checkpoint wrappers require internal reports/guards and must not be advertised as public entry points. Optional pilot source is supplied but not required for main frozen-data plotting.
4. For table extraction from stored outputs, obtain the Zenodo full-grid overlay first and follow reproduce_tables.md. No simulation is needed for that route.
5. For figure plotting from frozen inputs follow reproduce_figures.md. The Python exporter uses seven shipped input CSVs for nine exports. The eighth E1 input is optional and supplied independently; no model fitting or new inference is added.
6. Compare outputs to expected_outputs.md and reference assets. Renderer metadata, platform and fonts can change PDF hashes. The package verifier checks supplied bytes, not future rendered PDF identity.
7. Original MATLAB tests are supplied for intentional verification. Read the MAT dependency limitation before `runtests('research/tests')`. Full tests execute calculations and are not a dry run.

E1 is optional: [input schema and source instructions](E1_USER_INPUT.md). With no published table, all independent stages remain available; no automatic source download is implemented. Author-controlled source is provided under MIT; mixed-source and data/document scope is defined in LICENSE and docs/LICENSE_SCOPE.md.
