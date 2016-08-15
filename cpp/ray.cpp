#include "vector2d.h"
#include "ray.h"

point2d Intersection(const ray &s1, const ray &s2)
{
  double l1, l2;
  return Intersection(s1, s2, l1, l2);
}

point2d Intersection(const ray &s1, const ray &s2, double &l1, double &l2)
{
  vector2d dir1(s1.Dir());
  vector2d dir2(s2.Dir());
  double a11 = dir1.x;
  double a12 = - dir2.x;
  double a21 = dir1.y;
  double a22 = - dir2.y;
  double b1 = s2.x - s1.x;
  double b2 = s2.y - s1.y;
  double nn = a22 * a11 - a12 * a21;

  if (nn == 0.0)
    throw "No Intersection";

  l2 = (a21 * b1 - a11 * b2) / -nn;
  l1 = (a22 * b1 - a12 * b2) / nn;
//   cout << s1.x << " " << s1.y << endl;
//   cout << s2.x << " " << s2.y << endl;
//   cout << dir1.x << " " << dir1.y << endl;
//   cout << dir2.x << " " << dir2.y << endl;
//  cout << l1 << " " << l2 << endl;
//  cout << (s1 + l1 * dir1) << endl;
  return s1 + l1 * dir1;
}


