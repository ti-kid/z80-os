all:
	brass -s src/os.asm
	packxxu os.hex -o os.8xu -t 83p -q 04 -v 0.01 -h 255
	rabbitsign -t 8xu -K 0A -g -p -r -v os.8xu
	mv os-signed.8xu os.8xu
	rompatch ti84plus.rom -4 os.hex
	rm os.hex
