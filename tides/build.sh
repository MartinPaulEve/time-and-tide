#!/bin/bash
export WRKDIR=$(pwd)
export LYR_DIR="layer-python"

#Init Packages Directory
mkdir -p packages/

# Building Python-layer
cd ${WRKDIR}/${LYR_DIR}/
${WRKDIR}/${LYR_DIR}/build_layer.sh
zip -r ${WRKDIR}/packages/Python3-10.zip .
rm -rf ${WRKDIR}/${LYR_DIR}/python/
