import argparse
from enum import Enum
from typing import List, Dict
import heapq
import sys
import traceback


gMAX_ALIGN_NOP = None
gMIN_CAVE_SIZE = None


class ExitCode(Enum):
    EXIT_SUCCESS = 0
    EXIT_FAILURE = 1

class DOSHeaderOffsets(Enum):
    magicNumber = 0x00
    ntHeaderStart = 0x3C
    sizeOfOptionalHeader = 0x14

class DOSHeaderSizes(Enum):
    magicNumber = 2
    ntHeaderStart = 4

class NTHeaderOffsets(Enum):
    startOfOptionalHeader = 0x18
    sizeOfOptionalHeader = 0x14

class NTHeaderSizes(Enum):
    sizeOfOptionalHeader = 2

class SectionHeaderOffsets(Enum):
    virtualSize = 0x08
    virtualAddress = 0x0C
    sizeOfRawData = 0x10

class SectionHeaderSizes(Enum):
    header = 40
    name = 8
    virtualSize = 4
    virtualAddress = 4
    sizeOfRawData = 4

class Section:
    startAddress: int
    virtualSize: int
    name: str

    def __init__(self, name: str, address: int, size: int):
        self.name = name
        self.startAddress = address
        self.virtualSize = size
        

    def __lt__(self, other):
        return self.startAddress < other.startAddress

class Cave:
    begin: int
    end: int

    def __init__(self, begin: int, end:int):
        self.begin = begin
        self.end = end

    def __repr__(self):
        return "\t[POTENTIAL CAVE]\n\t Start address: 0x{:X}\n\t End address: 0x{:X}\n".format(    \
            self.begin,                                                                     \
            self.end)
    
    def size(self) -> int:
        return self.end - self.begin
    

def value(enum: Enum) -> int:
    return enum.value

def save_cave_to_file(filepath: str, caves: Dict[int, List[Cave]]):
    global gMIN_CAVE_SIZE

    with open(filepath, 'w') as file:
        for caveSize, lstOfCaves in caves.items():
            if caveSize >= gMIN_CAVE_SIZE:
                file.write("[CAVE SIZE: {} bytes]\n".format(caveSize))
                for cave in lstOfCaves:
                    file.write("{}\n".format(cave))

def print_caves(caves: Dict[int, List[Cave]]):
    global gMIN_CAVE_SIZE

    for caveSize, lstOfCaves in caves.items():
        if caveSize >= gMIN_CAVE_SIZE:
            print("[CAVE SIZE: {} bytes]".format(caveSize))
            for cave in lstOfCaves:
                print(cave)

def nine_align_nop(fileContent, i: int) -> bool:
    # https://stackoverflow.com/questions/25545470/long-multi-byte-nops-commonly-understood-macros-or-other-notation
    # 9-byte alignment NOP
    if fileContent[i] != 0x66:
        return False
    elif fileContent[i + 1] != 0x0F:
        return False
    elif fileContent[i + 2] != 0x1F:
        return False
    elif fileContent[i + 3] != 0x84:
        return False
    elif fileContent[i + 4] != 0x00:
        return False
    elif fileContent[i + 5] != 0x00:
        return False
    elif fileContent[i + 6] != 0x00:
        return False
    elif fileContent[i + 7] != 0x00:
        return False
    elif fileContent[i + 8] != 0x00:
        return False
    
    return True

def eight_align_nop(fileContent, i: int) -> bool:
    # https://stackoverflow.com/questions/25545470/long-multi-byte-nops-commonly-understood-macros-or-other-notation
    # 8-byte alignment NOP
    if fileContent[i] != 0x0F:
        return False
    elif fileContent[i + 1] != 0x1F:
        return False
    elif fileContent[i + 2] != 0x84:
        return False
    elif fileContent[i + 3] != 0x00:
        return False
    elif fileContent[i + 4] != 0x00:
        return False
    elif fileContent[i + 5] != 0x00:
        return False
    elif fileContent[i + 6] != 0x00:
        return False
    elif fileContent[i + 7] != 0x00:
        return False
    
    return True

def seven_align_nop(fileContent, i: int) -> bool:
    # https://stackoverflow.com/questions/25545470/long-multi-byte-nops-commonly-understood-macros-or-other-notation
    # 7-byte alignment NOP
    if fileContent[i] != 0x0F:
        return False
    elif fileContent[i + 1] != 0x1F:
        return False
    elif fileContent[i + 2] != 0x80:
        return False
    elif fileContent[i + 3] != 0x00:
        return False
    elif fileContent[i + 4] != 0x00:
        return False
    elif fileContent[i + 5] != 0x00:
        return False
    elif fileContent[i + 6] != 0x00:
        return False
    
    return True

def six_align_nop(fileContent, i: int) -> bool:
    # https://stackoverflow.com/questions/25545470/long-multi-byte-nops-commonly-understood-macros-or-other-notation
    # 6-byte alignment NOP
    if fileContent[i] != 0x66:
        return False
    elif fileContent[i + 1] != 0x0F:
        return False
    elif fileContent[i + 2] != 0x1F:
        return False
    elif fileContent[i + 3] != 0x44:
        return False
    elif fileContent[i + 4] != 0x00:
        return False
    elif fileContent[i + 5] != 0x00:
        return False
    
    return True

def five_align_nop(fileContent, i: int) -> bool:
    # https://stackoverflow.com/questions/25545470/long-multi-byte-nops-commonly-understood-macros-or-other-notation
    # 5-byte alignment NOP
    if fileContent[i] != 0x0F:
        return False
    elif fileContent[i + 1] != 0x1F:
        return False
    elif fileContent[i + 2] != 0x44:
        return False
    elif fileContent[i + 3] != 0x00:
        return False
    elif fileContent[i + 4] != 0x00:
        return False
    
    return True

def four_align_nop(fileContent, i: int) -> bool:
    # https://stackoverflow.com/questions/25545470/long-multi-byte-nops-commonly-understood-macros-or-other-notation
    # 4-byte alignment NOP
    if fileContent[i] != 0x0F:
        return False
    elif fileContent[i + 1] != 0x1F:
        return False
    elif fileContent[i + 2] != 0x40:
        return False
    elif fileContent[i + 3] != 0x00:
        return False
    
    return True

def three_align_nop(fileContent, i: int) -> bool:
    # https://stackoverflow.com/questions/25545470/long-multi-byte-nops-commonly-understood-macros-or-other-notation
    # 3-byte alignment NOP
    if fileContent[i] != 0x0F:
        return False
    elif fileContent[i + 1] != 0x1F:
        return False
    elif fileContent[i + 2] != 0x00:
        return False
    
    return True

def two_align_nop(fileContent, i: int) -> bool:
    # 2-byte alignment NOP
    if fileContent[i] != 0x66:
        return False
    elif fileContent[i + 1] != 0x90:
        return False
    
    return True

def alignment_nop(fileContent, i: int) -> int:
    funcs = [two_align_nop, three_align_nop,    \
             four_align_nop, five_align_nop,    \
             six_align_nop, seven_align_nop,    \
             eight_align_nop, nine_align_nop]

    curSize = 2
    for is_nop_alignment in funcs:
        try:
            if curSize == gMAX_ALIGN_NOP:
                break

            if is_nop_alignment(fileContent, i):
                return curSize
            
            curSize = curSize + 1
        except IndexError:
            break

    return 0

def xchg(firstOpCode: int, secOpCode: int) -> bool:
    # XCHG EAX, EAX
    if firstOpCode != 0x87:
        return False
    elif secOpCode != 0xC0:
        return False
    
    return True

def rep_nop(firstOpCode: int, secOpCode: int) -> bool:
    REP = 0xF3
    NOP = 0x90

    if firstOpCode != REP:
        return False
    elif secOpCode != NOP:
        return False
    
    return True

# Returns 0 on no match. Otherwise returns the number of bytes of the match.
def multi_padding_byte(fileContent, i: int) -> int:
    if rep_nop(fileContent[i], fileContent[i + 1]):
        return 2
    elif xchg(fileContent[i], fileContent[i + 1]):
        return 2
    
    return alignment_nop(fileContent, i)

def padding_byte(byte: int) -> bool:
    NOP = 0x90
    INT1 = 0xF1
    INT3 = 0xCC
    HLT = 0xF4

    if byte == NOP:
        return True
    elif byte == INT1:
        return True
    elif byte == INT3:
        return True
    elif byte == HLT:
        return True
    
    return False

def find_caves(fileContent, basedAddress, searchStart, searchEnd) -> Dict[int, List[Cave]]:
    caves = {}
    cave = None

    for i in range(searchStart, searchEnd):
        opCode = fileContent[i]
        if padding_byte(opCode):
            if cave == None:
                cave = Cave(basedAddress + i, None)
            continue
        
        result = multi_padding_byte(fileContent, i)
        if result > 0:
            i = i + result
        else:
            if cave != None:
                cave.end = basedAddress + i
                caveSize = cave.size()

                if caveSize >= gMIN_CAVE_SIZE:
                    if caveSize not in caves:
                        caves[caveSize] = []

                    caves[caveSize].append(cave)
                
                cave = None

    return dict(sorted(caves.items(), reverse=True))

def as_unsigned_int(fileContent, start: int, size: Enum) -> int:
    endIndex = start + value(size)
    bytes = fileContent[start:endIndex]

    return int.from_bytes(bytes, byteorder='little', signed=False)

def nt_header_start(fileContent) -> int:
    return as_unsigned_int(fileContent, value(DOSHeaderOffsets.ntHeaderStart), DOSHeaderSizes.ntHeaderStart)

def size_of_optional_header(fileContent) -> int:
    return as_unsigned_int(fileContent,                                                                 \
                           nt_header_start(fileContent) + value(NTHeaderOffsets.sizeOfOptionalHeader),  \
                           NTHeaderSizes.sizeOfOptionalHeader)

def optional_header_start(fileContent) -> int:
    return nt_header_start(fileContent) + value(NTHeaderOffsets.startOfOptionalHeader)

def section_headers_start(fileContent) -> int:
    return optional_header_start(fileContent) + size_of_optional_header(fileContent)

def section_virtual_size(fileContent, sectionHeaderStart) -> int:
    return as_unsigned_int(fileContent,                                                     \
                           sectionHeaderStart + value(SectionHeaderOffsets.virtualSize),    \
                           SectionHeaderSizes.virtualSize)

def section_start_address(fileContent, sectionHeaderStart) -> int:
    return as_unsigned_int(fileContent,                                                     \
                           sectionHeaderStart + value(SectionHeaderOffsets.virtualAddress), \
                           SectionHeaderSizes.virtualAddress)

def section_starts(fileContent) -> List[Section]:
    sectionHeaderStart = section_headers_start(fileContent)
    
    minHeap = []
    while (chr(fileContent[sectionHeaderStart]) == '.'):
        sectionName = ""
        sectionNameEnd = sectionHeaderStart + value(SectionHeaderSizes.name)
        for i in range(sectionHeaderStart, sectionNameEnd):
            sectionName += chr(fileContent[i])
        
        a = Section(sectionName.rstrip('\0'),                                   \
                    section_start_address(fileContent, sectionHeaderStart),     \
                    section_virtual_size(fileContent, sectionHeaderStart))
        print("Section name: {}. Section start address: 0x{:X}".format(a.name, a.startAddress))

        heapq.heappush(minHeap, a)
        sectionHeaderStart += value(SectionHeaderSizes.header)

    return minHeap

def search_range(fileContent):
    sections = section_starts(fileContent)

    begin = 0
    end = 0
    while len(sections) != 0:
        section = heapq.heappop(sections)

        if section.name == ".text":
            begin = section.startAddress

            # Send end to start of next section if it exist
            if len(sections) != 0:
                section = heapq.heappop(sections)
                end = section.startAddress    
            else:
                # Else fallback to virtual size
                end = begin + section.virtualSize
        
    if begin != 0 and end != 0:
        return begin, end
    else:
        raise Exception("PE file is missing a .text section. Is it packed?")

def file_is_pe(fileContent):
    magicNumber = ""
    for i in range(value(DOSHeaderOffsets.magicNumber), value(DOSHeaderSizes.magicNumber)):
        magicNumber += chr(fileContent[i])
    
    return magicNumber == "MZ"

def file_content(filepath: str):
    with open(filepath, 'rb') as file:
        return file.read()

def output_filepath(args) -> str:
    return args.out

def min_cave_size(args) -> int:
    value = args.min
    if value == None:
        return 2
    else:
        return value

def max_nop_alignment(args) -> int:
    value = args.an
    if value == None:
        return 3
    else:
        return value

def base_address(args) -> int:
    address = args.base
    if address == None:
        return 0x400000
    else:
        return address

def filepath(args) -> str:
    return args.file

def make_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('-file', type=str, help='The absolute filepath to the file that code caves should be identified in')
    parser.add_argument('-base', type=int, help="The base address that the executable will be loaded at.")
    parser.add_argument('-an', type=int, help="A range between 2-9 and represents the size of alignment NOPs that the script will search for.")
    parser.add_argument('-min', type=int, help="The minimum size of the code cave to look for.")
    parser.add_argument('-out', type=str, help="The name of the file to write the output to.")

    return parser

def main() -> int:
    global gMAX_ALIGN_NOP
    global gMIN_CAVE_SIZE

    try:
        parser = make_parser()
        args = parser.parse_args()

        file = file_content(filepath(args))
        baseAddress = base_address(args)
        gMAX_ALIGN_NOP = max_nop_alignment(args)
        gMIN_CAVE_SIZE = min_cave_size(args)

        if not file_is_pe(file):
            raise Exception("Provided file must be a PE file.")

        begin, end = search_range(file)
        print("Search range: 0x{:X} - 0x{:X}".format(baseAddress + begin, baseAddress + end))
        caves = find_caves(file, baseAddress, begin, end)

        outputPath = output_filepath(args)
        if outputPath == None:
            print_caves(caves)
        else:
            save_cave_to_file(outputPath, caves)

        return value(ExitCode.EXIT_SUCCESS)
    except Exception as err:
        traceback.print_exc()
        print("{}".format(err))
        return value(ExitCode.EXIT_FAILURE)
    

if __name__ == "__main__":
    sys.exit(main())