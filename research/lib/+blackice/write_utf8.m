function write_utf8(file,text)
%WRITE_UTF8 Write generated text without dependence on the system codepage.
fid=fopen(file,'w','n','UTF-8');
assert(fid>=0,'blackice:FileOpen','Cannot open %s',file);
closer=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',char(text));
end
