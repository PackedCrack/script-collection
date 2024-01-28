# CPPCHECK as build dependency in CMake projects.

## Usage
* Place cppcheck.sh and .suppress.cppcheck in your projects main directory
* Make sure cppcheck.sh is executable (chmod +x)
* Open cppcheck.cmake and change 'YOUR TARGET' to whatever your binary target is named.
* The 'cppcheck.sh' script contains the settings:
* --std=c++20 (Change to whatever cpp standard you're using)
* src/*.cpp (Change to where your cpp files are located)
* src/*.hpp (Change to where your hpp files are located)
* Add or remove whatever warnings you want to suppress from '.sppress.cppcheck'.