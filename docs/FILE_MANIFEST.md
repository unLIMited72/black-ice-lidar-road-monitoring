# File integrity

RELEASE_MANIFEST.csv enumerates public-tree payload files with SHA256 and size, excluding itself and SHA256SUMS.txt to avoid circular hashes. SHA256SUMS.txt covers all files except itself. Run `python3 reproduction/verify_package.py` from the repository root for integrity/path/syntax checks only. These checks do not run simulations or generate outputs and do not grant publication rights.
