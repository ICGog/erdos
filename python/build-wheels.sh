#!/bin/bash
set -ex

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
export PATH="$HOME/.cargo/bin:$PATH"
rustup default nightly-2020-06-22

cd /io

for PYBIN in /opt/python/{cp35-cp35m,cp36-cp36m,cp37-cp37m,cp38-cp38}/bin; do
    export PATH_BACKUP=$PATH
    PATH="$PYBIN:$PATH"
    # Require wheel==0.31.1 because auditwheel breaks on newer versions
    "${PYBIN}/pip" install -U setuptools wheel==0.31.1 setuptools-rust
    "${PYBIN}/python" python/setup.py bdist_wheel
    PATH=$PATH_BACKUP
done

for whl in dist/*.whl; do
    auditwheel repair "$whl" -w dist/
done
