function summary = reproduce_paper_table()
%REPRODUCE_PAPER_TABLE Publication-data reproduction, not new simulation.
cfg=checkpoint_setup();
folder=fullfile(cfg.root,'data','paper');
input_file=fullfile(folder,'paper_temperature_transcription.csv');
if ~isfile(input_file)
    fprintf('E1 skipped: optional user-supplied input absent. See reproduction/E1_USER_INPUT.md.\n');
    summary=struct('status','SKIPPED_OPTIONAL_INPUT');
    return
end
T=readtable(input_file);
required={'temperature_C','asphalt_m','black_ice_m','reported_difference_m'};
assert(all(ismember(required,T.Properties.VariableNames)), ...
    'blackice:InputSchema','E1 input must contain documented numeric columns.');
assert(height(T)>0,'blackice:EmptyInput','E1 input must not be empty.');
for k=1:numel(required)
    assert(isnumeric(T.(required{k})) && all(isfinite(T.(required{k}))), ...
        'blackice:InputType','E1 columns must be finite numeric values.');
end
T.recomputed_difference_m=T.asphalt_m-T.black_ice_m;
T.source_2023=repmat("2023 PDF p4, journal p868, Korean Table 2 (English caption Table 1)",height(T),1);
T.source_2025=repmat("2025 PDF p3, journal p103, Table 2",height(T),1);
T.notes=repmat("Publication-data reproduction; same values in both PDFs",height(T),1);
mismatch=abs(T.reported_difference_m-T.recomputed_difference_m)>1e-12;
T.notes(mismatch)="Numerical inconsistency requiring reproduction check; reported value preserved";
writetable(T,fullfile(folder,'paper_temperature_table.csv'));
writetable(T(mismatch,:),fullfile(cfg.processed,'paper_difference_mismatches.csv'));
summary=struct('row_count',height(T),'mismatch_temperature_C',T.temperature_C(mismatch), ...
    'reported_at_mismatch_m',T.reported_difference_m(mismatch), ...
    'recomputed_at_mismatch_m',T.recomputed_difference_m(mismatch), ...
    'mean_difference_m',mean(T.recomputed_difference_m), ...
    'median_difference_m',median(T.recomputed_difference_m));
save(fullfile(cfg.processed,'paper_reproduction.mat'),'T','summary');
fprintf('E1 comparison from user-supplied input: %d rows.\n',summary.row_count);
disp(T(mismatch,{'temperature_C','reported_difference_m','recomputed_difference_m'}));
end
