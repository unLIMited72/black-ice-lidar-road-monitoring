function write_new_file_manifest(root,project_root,baseline_file,out_file)
%WRITE_NEW_FILE_MANIFEST Hash only files introduced after the protected snapshot.
tokens=regexp(fileread(baseline_file),'"((?:[^"\\]|\\.)*)"\s*:\s*"[0-9a-f]{64}"','tokens');
old=strings(numel(tokens),1);
for j=1:numel(tokens), old(j)=string(jsondecode(['"' tokens{j}{1} '"'])); end
files=dir(fullfile(root,'**','*')); files=files(~[files.isdir]);
records=struct('path',{},'bytes',{},'sha256',{});
for j=1:numel(files)
 file=fullfile(files(j).folder,files(j).name); relative=string(file(numel(project_root)+2:end));
 if ismember(relative,old) || strcmp(file,out_file), continue; end
 if files(j).bytes==0, hash='e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
 else, hash=blackice.file_sha256(file); end
 records(end+1)=struct('path',char(relative),'bytes',files(j).bytes,'sha256',hash); %#ok<AGROW>
end
blackice.write_utf8(out_file,jsonencode(records,PrettyPrint=true));
end
