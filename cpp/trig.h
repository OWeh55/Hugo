#ifndef TRIG_H
#define TRIG_H

#include <cmath>

using namespace std;

inline double Arc(double fi)
{
  return fi * M_PI / 180.0;
}
inline double Deg(double fi)
{
  return fi * 180.0 / M_PI;
}

inline double sinc(double fi)
{
// function sinc x = sin(x) / x (radian)
  if (fabs(fi) < 0.001)
    return 1.0 - (1.0 / 6.0) * fi * fi;
  else
    return sin(fi) / fi;
}

inline double cosc(double fi)
{
// function ( 1 - cos(x)) / x (radian)
  if (fabs(fi) < 0.001)
    return 0.5 * fi;
  else
    return (1.0 - cos(fi)) / fi;
}

inline double normal(double fi)
{
  while (fi > M_PI) fi -= 2 * M_PI;
  while (fi <= -M_PI) fi += 2 * M_PI;
  return fi;
}

#endif
