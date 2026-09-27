# Reproduce figures

An intentional `python3 research/scripts/export_figures.py` from this repository root renders nine independent exports from seven supplied frozen CSVs. Figure 3 is skipped unless the user has prepared the optional E1 processed CSV using [E1 instructions](E1_USER_INPUT.md); that input enables the tenth export. Outputs are placed in `reproduced/figures`, `reproduced/editable` and `reproduced/figure_export_manifest.json`. No plotting was executed during staging.

Figure 2 is the conceptual coordinate schematic. Its project generator is the Figure 2 block of `research/scripts/generate_manuscript_figures.m`; the function exports the other historical styles as well and now skips E1 if absent. The final schematic reference is supplied, but its exact final editorial export is not reconstructed. Figure 1 and Figure 2 have no experimental image input. Public release authority for project assets remains separate from this origin evidence.

See [map](../docs/FIGURE_REPRODUCTION_MAP.csv). Historical filenames remain stable: printed supplementary S3/S4 use file prefixes 04/08. No byte-identical rendering promise is made. All filters, stored-value plotting, unit conversions and intervals outside the optional-input gate remain unchanged.
