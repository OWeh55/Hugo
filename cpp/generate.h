#ifndef GENERATE_H
#define GENERATE_H

#include "gleis.h"

gleis GenerateKG(const Bogen &startgleis, const Bogen &endgleis);
gleis GenerateGKG(const Bogen &startgleis, const Bogen &endgleis, double radius);
gleis SubDivide(const gleis &verbindung, double maxlen = 60);

#endif
