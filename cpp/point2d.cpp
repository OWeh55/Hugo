#include <cmath>
#include "point2d.h"
#include "vector2d.h"

ostream &operator <<(ostream &os, const point2d &o)
{
  os << o.x << "," << o.y << endl;
  return os;
}

point2d point2d::rot0(double fi) const
{
  double s = sin(fi);
  double c = cos(fi);
  return point2d(x * c - y * s, x * s + y * c);
}

point2d point2d::rot(const point2d &center, double fi) const
{
  vector2d h = *this - center;
  return center + h.rot0(fi);
}


