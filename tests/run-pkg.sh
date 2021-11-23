#!/bin/bash

set -euo pipefail


#======================================================================================================================
# Welcome message.
#======================================================================================================================

echo "Welcome to the test suite."


#======================================================================================================================
# Create variable pointing to shUnit2 so it can be run easily.
# (Requires shunit2 package to be installed locally.)
#======================================================================================================================

export SHUNIT2=/usr/bin/shunit2


#======================================================================================================================
# Load all tests.
#======================================================================================================================

for FILE in $(find . -type f -name "test-*.sh") ; do
    echo "Running tests in ${FILE}."
    chmod +x ${FILE} && ${FILE}
done


#======================================================================================================================
# End message.
#======================================================================================================================

echo "Testing complete."
