# Reproduce tables

Final author-written TeX fragments for Tables 1–7 are in `final_tables/`. They preserve final labels and wording; historical CSVs are evidence/extracts and are not a substitute for revised prose in Tables 1–4 and 7. Typesetting requires your own document class; the MDPI class is not redistributed.

Tables 5 and 6 use saved representative CSVs. Their displayed selection/rounding is visible in the final fragments: Table 5 selects the stored family/angle rows; Table 6 uses angle 30 degrees from the stored ablation extract. Values are already supplied; inspecting them requires no calculation.

To intentionally re-extract numerical tables, copy the Zenodo overlay to `research/results/processed/level2_full_e3_results.csv`, then run `python3 research/scripts/prepare_manuscript_evidence.py` from the repository root in a disposable copy. The input is a frozen processed grid, not a new simulation. E1 absence skips S1; all independent extraction calculations and original N007-onward claim IDs are retained. The script writes simulation-only claim metadata; excluded mixed historical claim ledgers are not bundled. No extraction was executed for staging.

S2/S3/S4/S9 are supplied unchanged. S1 is optional user-supplied-input output, as described in [E1 instructions](E1_USER_INPUT.md). S4 compares geometry to cited manufacturer magnitudes; S9 is author literature synthesis. Neither redistributes a manual or source article. The source/output maps distinguish bundled inputs from generated destinations. Original manuscript numbering is preserved.
