#
# Hongda Lin: Assembly Makefile
# Modify Date: 31/3/2021

all:  tags headers

encrypted1: makefile
	encryption < test1 > encrypted1

encrypted2: makefile
	encryption < test2 > encrypted2

encrypted3: makefile
	encryption < test3 > encrypted3

decrypted1: makefile
	decryption < encrypted1 > decrypted1

decrypted2: makefile
	decryption < encrypted2 > decrypted2

decrypted3: makefile
	decryption < encrypted3 > decrypted3


#*********************************************************

clean: 
	rm -rf *.o

removeAll:
	rm -rf encrypted1 encrypted2 encrypted3 decrypted1 decrypted2 decrypted3 

# Build executable #
encryption: encryption.o
	gcc -g -o $@ $^

decryption: decryption.o
	gcc -g -o $@ $^

#*********************************************************

# building the zip file.

lab5.zip: makefile *.s
	zip lab5.zip makefile *.s test1 test2 test3 readme
	rm –rf install
	# create the install folder
	mkdir install
	# unzip to the install folderunzip *.zip –d install
	unzip lab5.zip -d install
	# make ONLY the * target, not *.zip
	make –C install lab5

#*********************************************************

%.o: %.s
	gcc -g -m64 -c -o $@ $^

#*********************************************************
