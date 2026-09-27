function hash = file_sha256(file)
%FILE_SHA256 Hash bytes of a source file using the MATLAB JVM.
fid=fopen(file,'rb');
assert(fid>=0,'blackice:FileOpen','Cannot open %s',file);
closer=onCleanup(@()fclose(fid)); %#ok<NASGU>
bytes=fread(fid,Inf,'*uint8');
md=java.security.MessageDigest.getInstance('SHA-256');
md.update(typecast(bytes,'int8'));
digest=typecast(md.digest(),'uint8');
hash=lower(reshape(dec2hex(digest,2).',1,[]));
end
