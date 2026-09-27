function report = verify_hash_manifest(manifest,project_root)
%VERIFY_HASH_MANIFEST Read-only preservation guard for arbitrary checkpoint snapshots.
tokens=regexp(fileread(manifest),'"((?:[^"\\]|\\.)*)"\s*:\s*"([0-9a-f]{64})"','tokens');
for j=1:numel(tokens)
 relative=jsondecode(['"' tokens{j}{1} '"']); file=fullfile(project_root,relative);
 assert(isfile(file),'blackice:MissingProtectedFile','Missing protected file: %s',file);
 d=dir(file);
 if d.bytes==0, hash='e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
 else, hash=blackice.file_sha256(file); end
 assert(strcmpi(hash,tokens{j}{2}),'blackice:ProtectedFileChanged','Protected file changed: %s',file);
end
report=struct('protected_count',numel(tokens),'all_unchanged',true);
end
