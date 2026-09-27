# Reproducibility boundary

| Level | Evidence / limit |
|---|---|
| Implementation reproducibility | MATLAB library, model builder, SLX and original tests supplied; scientific SLX members preserved. Runtime tests were not repeated for this release. |
| Numerical reproducibility | Stored CSVs, final table fragments, mappings and hashes supplied; no recalculation during packaging. The full E3 grid is a Zenodo-only overlay. |
| Simulation reproducibility | Original lower-level runners and configurations supplied. Historical checkpoint wrappers depend on internal preservation guards and third-party access manifests and are deliberately excluded. The documented lower-level sequence has been statically checked, not executed here. |
| Physical validation | NOT ESTABLISHED. Repository reproducibility is not physical validation. |

`test_full_e3_pipeline.m` and `test_black_ice_ablation.m` include tests requiring `level2_full_e3_results.mat`. That file is intentionally not bundled because it stores environment/configuration metadata. A future intentional full E3 run creates it. Do not claim all archived tests can be run against the CSV-only download. Other tests also execute computations; none was run during this packaging task.

Historical 84-test results and 240-case geometry comparisons are archived evidence, not fresh release certification. Figure 2's original MATLAB schematic is available; exact final editorial export is only supplied as a reference PDF. Final table prose is represented by current TeX fragments rather than historical CSV wording. Final PDF byte equality is not promised.

E1 published reassessment is optional and requires independently obtained source values. No filled published CSV, Figure 3 asset, S1 or mixed E1 claim ledger is bundled. Missing E1 input does not disable other exporters/extractors; full-grid extraction independently requires the Zenodo overlay. Scoped license application is described in LICENSE; external publication has not occurred.
