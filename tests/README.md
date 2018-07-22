
# xmlcrudy tests

A script to test each method, Create, Read, Update, Delete and Upsert is provided that makes effort to confirm each of 
the operations works as expected on the sample input files available.

**example**
```bash
$ ./tests.sh samples/opnsense-config-sample.xml 
Create value and new xpath: OKAY
Read the value at the new xpath: OKAY
Update the value at the new xpath: OKAY
Read the updated value at the new xpath: OKAY
Delete the new xpath: OKAY
Upsert a value into a non-existing xpath: OKAY
Read the value from the upsert to a non-existing xpath: OKAY
Upsert a new value into the same xpath: OKAY
Read the new value upsertd into the xpath: OKAY
Delete the xpath that was upsertd: OKAY
Delete something that does not exist: OKAY
Create prevents overwriting an existing xpath: OKAY
Read prevents returning a value for a non-existing xpath: OKAY
Update prevents updating a non-existing xpath: OKAY
Source XML file equals tested XML file: OKAY
```
