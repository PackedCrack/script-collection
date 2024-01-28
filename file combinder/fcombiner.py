import sys


def append_file_contents(filename, dst):
    try:
        # Open filename in read mode
        with open(filename, 'r') as fileToRead:
            content = fileToRead.read()

        # Open sourceFilename in append mode
        with open(dst, 'a') as fileToAppend:
            fileToAppend.write(content)

    except FileNotFoundError as fileError:
        print(f"File not found: {fileError}")
    except Exception as e:
        print(f"An error occurred: {e}")


argc = len(sys.argv)
for i in range(1, argc):
	append_file_contents(sys.argv[i], "combined.txt")
