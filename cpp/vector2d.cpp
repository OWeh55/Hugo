#include "vector2d.h"

double vector2d::Len() const
{
  return sqrt(x * x + y * y);
}

void vector2d::Normalize()
{
  double l = Len();
  if (l == 0.0)
    {
      x = 1;
      y = 0;
    }
  else
    {
      x /= l;
      y /= l;
    }
}

vector2d vector2d::rot0(double fi) const
{
  double s = sin(fi);
  double c = cos(fi);
  return vector2d(x * c - y * s, x * s + y * c);
}

vector2d vector2d::rot(const vector2d &center, double fi) const
{
  vector2d h = *this - center;
  return center + h.rot0(fi);
}

vector2d operator*(double f, const vector2d &b)
{
  return b * f;
}

ostream &operator <<(ostream &os, const vector2d &o)
{
  os << o.x << "," << o.y << endl;
  return os;
}
