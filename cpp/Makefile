OBJECTS= bogen.o generate.o gleis.o optimizer.o point2d.o ray.o vector2d.o voperator.o

ifndef ICEDIR
ICEDIR=../../../ice
endif

LOPT := $(OPT)
COPT := $(OPT) -static-libgcc -static-libstdc++
LIBS := -lice `wx-config --libs` -ljpeg

LOPT := $(LOPT) -Wl,--enable-auto-import --static -static-libgcc -static-libstdc++
LIBS := $(LIBS) -Wl,--subsystem,console -mconsole

ifndef MACHTYPE
MACHTYPE := some_machine
endif

#CXX=g++
#CXX=icc

COPT := -O4 $(COPT) -g -Wall -ffast-math -fno-strict-aliasing 

INCLUDE := -I$(ICEDIR)/src `wx-config --cxxflags`
LIBRARY := -L$(ICEDIR)/lib/$(MACHTYPE)

ifndef NOFFTW3
LIBS := $(LIBS) -lfftw3 
endif

%.o:%.c
	$(CC) $(COPT) $(INCLUDE) -c $*.c

%.o:%.cpp
	$(CXX) $(COPT) $(INCLUDE) -c $*.cpp

%: %.o
	$(CXX) $(COPT) $(LOPT) $(LIBRARY) -o $* $*.o $(LIBS)

%:%.cpp
	$(CXX) $(COPT) $(INCLUDE) -c $*.cpp
	$(CXX) $(LIBRARY) $(LOPT) -o $* $*.o $(LIBS)

#$(MAIN): $(OBJECTS) $(ICEDIR)/lib/$(MACHTYPE)/libice.a
#	$(CXX) $(LOPT) $(LIBRARY) -o $(MAIN) $(OBJECTS) $(LIBS)

gleis.dll gleis_test.dll libgleis_dll.a: gleis_dll.o $(OBJECTS)
	g++ $(LOPT) $(LIBRARY) -shared -o gleis_test.dll gleis_dll.o $(OBJECTS) $(LIBS) -Wl,--out-implib,libgleis_dll.a,--subsystem,windows
	g++ $(LOPT) $(LIBRARY) -shared -o ../AutoIt/gleis.dll gleis_dll.o $(OBJECTS) $(LIBS) -Wl,--subsystem,windows,--kill-at
	strip ../AutoIt/gleis.dll

gleis_dll.o: gleis_dll.cpp gleis_dll.h
	g++ -c -DBUILDING_DLL $(COPT) $(INCLUDE) gleis_dll.cpp


gleis_dll_test.o: gleis_dll_test.cpp gleis_dll.h
	g++ -c gleis_dll_test.cpp

gleis_dll_test:	gleis_dll_test.o gleis_test.dll
	g++ -o gleis_dll_test gleis_dll_test.o -L. -lgleis_dll

clean:
	-rm -f *.o depend *~ 

dep:
	-rm depend 
	touch depend
	$(CXX) -M $(COPT) $(INCLUDE) *.cpp >> depend	

-include depend
