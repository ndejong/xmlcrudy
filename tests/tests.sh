#!/bin/sh

# Copyright (c) 2018 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
#  - All rights reserved.
#
# Apache License v2.0
#  - http://www.apache.org/licenses/LICENSE-2.0


# test sample input XML
test_source="$1"

if [ -z ${test_source} ]; then
    echo 'Usage: ./tests.sh <sample-xml-document>'
    exit 1
fi

# Linux or BSD
if [ $(uname) = 'Linux' ]; then md5bin='md5sum'; else md5bin='md5'; fi

# test target
test_target="/tmp/xmlcrudy-test-$(head /dev/urandom | $md5bin | head -c4)"
cp ${test_source} ${test_target}

# import the library
. $(realpath $(dirname $0)/../xmlcrudy.sh)


# ==== FAILURE SUCCESS MODES ==== #


# Create
test_name='Create value and new xpath'
xmlcrudy ${test_target} create '//system/newpath' 'some new value'
if [ $? -eq 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi

# Read
test_name='Read the value at the new xpath'
result=$(xmlcrudy ${test_target} read '//system/newpath')
if [ $? -eq 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi

# Update
test_name='Update the value at the new xpath'
xmlcrudy ${test_target} update '//system/newpath' 'some other value'
if [ $? -eq 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi

# Read again
test_name='Read the updated value at the new xpath'
result=$(xmlcrudy ${test_target} read '//system/newpath')
if [ $? -eq 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi

# Delete
test_name='Delete the new xpath'
xmlcrudy ${test_target} delete '//system/newpath'
if [ $? -eq 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi

# Upsert
test_name='Upsert a value into a non-existing xpath'
xmlcrudy ${test_target} upsert '//system/upsertpath' 'some upsert value'
if [ $? -eq 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi

# Read again
test_name='Read the value from the upsert to a non-existing xpath'
result=$(xmlcrudy ${test_target} read '//system/upsertpath')
if [ $? -eq 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi

# Upsert again
test_name='Upsert a new value into the same xpath'
xmlcrudy ${test_target} upsert '//system/upsertpath' 'some new upsert value'
if [ $? -eq 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi

# Read again
test_name='Read the new value upsertd into the xpath'
result=$(xmlcrudy ${test_target} read '//system/upsertpath')
if [ $? -eq 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi

# Delete for clean up
test_name='Delete the xpath that was upsertd'
xmlcrudy ${test_target} delete '//system/upsertpath'
if [ $? -eq 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi

# Delete even if it does not exist
test_name='Delete something that does not exist'
xmlcrudy ${test_target} delete '//system/upsertpath'
if [ $? -eq 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi


# ==== FAILURE TEST MODES ==== #


# Create over existing xpath - should fail
test_name='Create prevents overwriting an existing xpath'
xmlcrudy ${test_target} create '//system/hostname' 'naughty value'
if [ $? -ne 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi

# Read non-existing xpath - should fail
test_name='Read prevents returning a value for a non-existing xpath'
xmlcrudy ${test_target} read '//system/doesnotexist'
if [ $? -ne 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi

# Update non-existing xpath - should fail
test_name='Update prevents updating a non-existing xpath'
xmlcrudy ${test_target} update '//system/doesnotexist' 'naughty value'
if [ $? -ne 0 ]; then echo "$test_name: OKAY"; else echo "$test_name: FAIL!!"; fi


# ==== TEST XML FILE AT END IS SAME ==== #


if [ $($md5bin $test_target | cut -d' ' -f1) != $($md5bin $test_source| cut -d' ' -f1) ]; then
    echo "Source XML file does not equal tested XML file: FAIL!!"
else
    echo "Source XML file equals tested XML file: OKAY"
fi


# ==== Clean up ==== #


rm -f /tmp/xmlcrudy-*

