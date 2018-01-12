# What is the purpose of this Script?
This python script copies notebooks from one account (source) to another account (target).  It supports copying notebooks between accounts of different environments (api & us supported currently ).  Script uses Rest API to get information (account, clusters, notebooks & users) for both source and target accounts and then copy notebooks via export\import API’s.

# What major tasks does the script perform?
-	Create directories (virtual foldering) along with hierarchies in the target account. Skips creating directories for user, if user does not exist in target account
-	Copies all notebooks (users and common) to their respective directory
-	Skips importing notebooks for the user, if user does not exist in target account
-	Apply Notebook Tags
-	Map notebooks to new cluster ids
-	Clusters between source and target accounts are matched using tags. If no matching cluster tag found in target account, notebook will be imported but won’t be mapped to any cluster
-	It generates path(s) for interpreter config file(s) that can be manually copied between source & target clusters, recommended if clusters have same instance type for slaves


# Any limitations?
-	Script does not copy notebook ACLs.
-	Qubole limits the notebook size to be 25mb or less. If notebook size is greater than 25mb, it skips the notebook.
-	Notebook name having special characters other than (- , _ , ' , @ and space ) will result in error, forced by quoble tier and will be skipped. Action - change the notebook name to remove any special characters in the source account.
-	If notebook names are common across two or more users in a source account, script exits by printing the duplicate notebook names. Rename the notebooks making them unique across the account and rerun the script.


# Does the script perform incremental copying of notebooks?
Yes, script can be run multiple times between accounts, it maintains a csv of notebook ids that got copied from source to target and skips them on next run. See – “What output does the script generate for reporting and logging?”

# Can the script be rerun in case of a failure?
Yes, script can be run multiple times between accounts, it maintains a csv of notebook ids that got copied from source to target and skips them on next run. See – “What output does the script generate for reporting and logging?”

# Can specific notebook(s) be copied again from source to target?
Lookup the notebookid that was copied in the csv file, to get the target notebookid. Delete the notebook from the target account using target notebookid and remove the entry from the csv. The next run of the script will copy it again with new notebookid.  Note: A new notebookid can break schedulers or other dependencies.

# Can Script overwrite notebooks in target account?
Script has a parameter (-r Y) for delete and copying of all notebooks which can act as overwriting all the notebooks. Note: This will generate new notebookid and can break schedulers or other dependencies. Currently no API exists to update an existing notebookid. 

# What output does the script generate for reporting & logging?
-	Successfully Copied notebooks CSV : A csv file is generated that maintains list of all copied notebooks between any two accounts . Do not delete it, in case of failure or incremental copying of notebooks this is very helpful. Every run of script will append to it if notebooks are successfully copied. Filename <SRC_ENV>_<SRC_ACC_ID>_TO_<TGT_ENV>_<TGT_ACC_ID>_NBCopySuccess.csv
-	Detailed log file: Script generates detail logging by default and interpreter paths are printed in the logs at the end. Filename <SRC_ENV>_<SRC_ACC_ID>_TO_<TGT_ENV>_<TGT_ACC_ID>_NBCopy_<timestamp>.log


# Any prerequisites for executing the script?
	pip install pandas
	pip install poster

# How to run the script?
	Download the “copyNotebooks.py” to a directory
	Syntax -> copyNotebooks.py -s $SRC_ACC_TOKEN –t $TGT_ACC_TOKEN –i $SRC_ENV –o $TGT_ENV &


