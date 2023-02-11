GCCFLAGS := -m64 -no-pie
LIBS := -lX11

EXECUTABLE := cerise

INDEXASM := index.asm
INDEXO := index.o

OBJECTS := $(INDEXO)

$(EXECUTABLE): $(OBJECTS)
	gcc $(GCCFLAGS) -o $(EXECUTABLE) $(OBJECTS) $(LIBS)

$(INDEXO): $(INDEXASM)
	nasm -felf64 -o $(INDEXO) $(INDEXASM)

clean:
	rm *.o $(EXECUTABLE)
