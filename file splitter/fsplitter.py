import sys

def split_file(filename, splitAmount):
	try:
		with open(filename, 'r') as file:
			content = file.readlines()

		linesPerFile = len(content) // splitAmount

		for i in range(splitAmount):
			start = i * linesPerFile
			end = (i + 1) * linesPerFile
			if i == splitAmount - 1:
				end = len(content)

			suffix = f"{i:03}"

			splitFilename = f"{filename}_{suffix}"
			with open(splitFilename, 'w') as splitFile:
				splitFile.writelines(content[start:end])

	except Exception as e:
		print(f"Error: {e}")



filename = str()
splitAmount = int()

argc = len(sys.argv)
if(argc < 4):
	print("Provide the filename of the file to split with '-f file.txt' and the amount of new files it should be split into with '-a 10'")

i = 0
while i < argc:
	if sys.argv[i] == "-f":
		filename = sys.argv[i + 1]
		i = i + 1
	elif sys.argv[i] == "-a":
		splitAmount = int(sys.argv[i + 1])
		i = i + 1
	
	i = i + 1

split_file(filename, splitAmount)

