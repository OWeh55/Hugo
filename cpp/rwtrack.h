#ifndef RWTRACK_H
#define RWTRACK_H

#include <fstream>

#include "bogen.h"
#include "gleis.h"

bogen readtrack(ifstream &is,bool input_format=true);

void readtracks(const string &fn,gleis &g,bool fill);

void writetrack(ofstream &of,const bogen &agl,bool extended_format=true);

#endif
