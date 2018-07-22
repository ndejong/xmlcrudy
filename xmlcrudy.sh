#!/bin/sh

# Copyright (c) 2018 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
#  - All rights reserved.
#
# Apache License v2.0
#  - http://www.apache.org/licenses/LICENSE-2.0

xmlcrudy_temp_path='/tmp'
xmlcrudy_error_files_enable=1

if [ $(which xml | wc -l) -lt 1 ]; then
    echo 'FATAL: xmlcrudy requires the xml (XMLStarlet) binary, please install before using'
    exit 1
fi

xmlcrudy()
{
    local xmlfile="$1"
    local method=$(echo "$2" | tr '[:upper:]' '[:lower:]')
    local xpath="$3"
    local value="$4"

    local name
    local xpath_sub
    local md5bin

    if [ $(uname) = 'Linux' ]; then
        md5bin='md5sum'
    else
        md5bin='md5'
    fi

    local tempfile="$xmlcrudy_temp_path/xmlcrudy-$(date -u +%Y%m%dZ%H%M%S)-$(head /dev/urandom | $md5bin | head -c4)"

    # catch non-existing files first
    if [ ! -f "$xmlfile" ]; then
        echo 'x' > /dev/null

    # C - create, only if xpath does not yet exist
    elif [ $method = "create" ]; then
        if [ -z "$(xml sel --template --copy-of "$xpath" "$xmlfile")" ]; then
            name=$(echo "$xpath" | rev | cut -f1 -d'/' | rev)
            xpath_sub=$(echo "$xpath" | rev | cut -f2- -d'/' | rev)
            xml ed -P -s "$xpath_sub" -t "elem" -n "$name" -v "$value" "$xmlfile" > "$tempfile"
            if [ "$(xml sel --template --value-of "$xpath" "$tempfile" | tail -n1)" = "$value" ]; then
                mv "$tempfile" "$xmlfile"
                return 0
            fi
        fi

    # R - read, only if xpath exists
    elif [ $method = "read" ]; then
        if [ ! -z "$(xml sel --template --copy-of "$xpath" "$xmlfile")" ]; then
            echo "$(xml sel --template --value-of "$xpath" "$xmlfile")"
            return 0
        fi

    # U - update, only if xpath exists
    elif [ $method = "update" ]; then
        if [ ! -z "$(xml sel --template --copy-of "$xpath" "$xmlfile")" ]; then
            xml ed -P -u "$xpath" -v "$value" "$xmlfile" > "$tempfile"
            if [ "$(xml sel --template --value-of "$xpath" "$tempfile")" = "$value" ]; then
                mv "$tempfile" "$xmlfile"
                return 0
            fi
        fi

    # D - delete, irrespective of xpath existence
    elif [ $method = "delete" ]; then
        xml ed -P -d "$xpath" "$xmlfile" > "$tempfile"
        if [ -z "$(xml sel --template --value-of "$xpath" "$tempfile")" ]; then
            mv "$tempfile" "$xmlfile"
            return 0
        fi

    # Y - upsert, perform update if xpath exists, perform create if xpath not exist
    elif [ $method = "upsert" ]; then
        if [ -z "$(xml sel --template --copy-of "$xpath" "$xmlfile")" ]; then
            # C - create
            xmlcrudy "$xmlfile" 'create' "$xpath" "$value"
            if [ $? -eq 0 ]; then return 0; else return 1; fi
        else
            # U - update
            xmlcrudy "$xmlfile" 'update' "$xpath" "$value"
            if [ $? -eq 0 ]; then return 0; else return 1; fi
        fi
    fi

    # if we get this far we did not return "0" for success above
    if [ -z "$xmlcrudy_error_files_enable" ] || [ "$xmlcrudy_error_files_enable" -eq 0 ]; then
        if [ -f "$tempfile" ]; then
            rm "$tempfile"
        fi
    else
        echo "xmlcrudy() error" > "$tempfile.err"
        echo "xmlfile: $xmlfile" >> "$tempfile.err"
        echo "method: $method" >> "$tempfile.err"
        echo "xpath: $xpath" >> "$tempfile.err"
        echo "value: $value" >> "$tempfile.err"
        echo "tempfile: $tempfile" >> "$tempfile.err"
    fi

    return 1
}

