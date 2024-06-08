# Helper script to turn a hex dump into a c++ std::array

## Usage
python3 hex_dump_to_array.py /filepath/to/hexdump /filepath/to/output

### Note
Hexdump file refers to a file result from e.g. hexdump or od

Output file should probably be .h or .hpp since the script will write a compile time constant std::array: *static constexpr std::array<uint8_t, SIZE> data{ 0x00, 0x01 }*