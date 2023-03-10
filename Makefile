GCCFLAGS := -m64 -no-pie
LIBS := -lX11

EXECUTABLE := cerise

INDEXASM := index.asm
INDEXO := index.o

RANDOMNUMBERASM := randomNumber.asm
RANDOMNUMBERO := randomNumber.o

GETDETERMINANTASM := getDeterminant.asm
GETDETERMINANTO := getDeterminant.o

MINMAXASM := minMax.asm
MINMAXO := minMax.o

OBJECTS := $(INDEXO) $(RANDOMNUMBERO) $(GETDETERMINANTO) $(MINMAXO)

$(EXECUTABLE): $(OBJECTS)
	gcc $(GCCFLAGS) -o $(EXECUTABLE) $(OBJECTS) $(LIBS)

$(INDEXO): $(INDEXASM)
	nasm -felf64 -o $(INDEXO) $(INDEXASM)

$(RANDOMNUMBERO): $(RANDOMNUMBERASM)
	nasm -felf64 -o $(RANDOMNUMBERO) $(RANDOMNUMBERASM)

$(GETDETERMINANTO): $(GETDETERMINANTASM)
	nasm -felf64 -o $(GETDETERMINANTO) $(GETDETERMINANTASM)

$(MINMAXO): $(MINMAXASM)
	nasm -felf64 -o $(MINMAXO) $(MINMAXASM)

clean:
	rm *.o $(EXECUTABLE)
