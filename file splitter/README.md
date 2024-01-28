## file splitter
Splits a file into multiple smaller files. Usefull if you e.g. want to split a password list (such as rockyou.txt) into many smaller ones and run several wfuzz sessions concurrently.
### How to use
* python3 -f YOURFILE -a NUMBEROFSPLITS
* e.g. python3 -f test.txt -a 10