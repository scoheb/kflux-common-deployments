#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

${SCRIPT_DIR}/setup-kind.sh
${SCRIPT_DIR}/setup-local-eso.sh
${SCRIPT_DIR}/setup-namespace.sh
${SCRIPT_DIR}/setup-secretstore.sh



