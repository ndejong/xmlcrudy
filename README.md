# xmlcrudy

xmlcrudy is a `/bin/sh` wrapper around XMLStarlet that provides a CRUD(+upsert) like shell interface for manipulating
XML files.

The tool was originally written as requirement to edit the XML configuration files of the OPNsense product in the 
boot process, hence part of the requirement was to have as few dependencies as possible without the flexibility of
having a full blown scripting language available.

The tool should be useful in any situation where simple XML document manipulation is required.

NB: this is `/bin/sh` not `/bin/bash` or some other shell.

**Examples**
```bash
#/bin/sh

# import the library
. /path/to/xmlcrudy.sh

# create - create a value at a new xpath
xmlcrudy /path/to/target.xml create '//system/new_xpath' 'some value'

# read - read a value from an existing xpath
result=$(xmlcrudy /path/to/target.xml read '//system/new_xpath')

# update - update an existing xpath value
xmlcrudy /path/to/target.xml update '//system/new_xpath' 'some new value'

# delete - delete an xpath
xmlcrudy /path/to/target.xml delete '//system/new_xpath'

# upsert - create a value at an xpath if non-existing or update the value if the xpath does exist
xmlcrudy /path/to/target.xml upsert '//system/another_xpath' 'a value'
xmlcrudy /path/to/target.xml upsert '//system/another_xpath' 'a different value'
```

Review `tests/tests.sh` for more examples.


## Authors
This code is managed by [Verb Networks](https://github.com/verbnetworks).

## License
Apache 2 Licensed. See LICENSE file for full details.
