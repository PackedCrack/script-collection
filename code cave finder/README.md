## Code cave finder
Scans the .text section of a PE file in order to find potential code caves.

### How to use
* python3 -file EXECUTABLE

### Options
* -file - The absolute filepath to the file that code caves should be identified in.
* -out - The name of the file to write the output to.
* -min - The minimum size of the code cave to look for.
* -base - The base address that the executable will be loaded at.
* -an - A range between 2-9 and represents the size of alignment NOPs that the script will search for.