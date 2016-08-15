#include "point2d.h"
#include "vector2d.h"
#include "ray.h"

point2d operator+(const point2d &p, const vector2d &r)
{
  return point2d(p.x + r.x, p.y + r.y);
}

point2d operator+(const vector2d &r, const point2d &p)
{
  return point2d(r.x + p.x, r.y + p.y);
}

point2d operator-(const point2d &p, const vector2d &r)
{
  return point2d(p.x - r.x, p.y - r.y);
}

vector2d operator-(const point2d &p, const point2d &r)
{
  return vector2d(p.x - r.x, p.y - r.y);
}

ray operator+(const ray &p, const vector2d &r)
{
  return ray(p.x + r.x, p.y + r.y, p.dir);
}

ray operator+(const vector2d &r, const ray &p)
{
  return ray(r.x + p.x, r.y + p.y, p.dir);
}
