#ifndef OPTIMIZER_H
#define OPTIMIZER_H

#include "gleis.h"

bool Optimize1(gleis &g,
               const Bogen &start, const Bogen &end, // Anschlussbedingungen
               int mode = 0); // fehlerfunktion

bool Optimize2(gleis &g,
               const Bogen &start, const Bogen &end,
               double rad);

bool OptimizeHoehe1(gleis &g, const Bogen &start, const Bogen &end);

#endif
