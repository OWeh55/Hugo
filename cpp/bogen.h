#ifndef BOGEN_H
#define BOGEN_H

#include <image_nonvis.h>
#include <cmath>
#include <iostream>

#include "myex.h"
#include "point2d.h"
#include "vector2d.h"
#include "ray.h"

using namespace std;

#include "trig.h"

class Bogen
{
protected:
  ray start; // Gleisanfang
  double len;
  double fi;
  double h1;
  double grad;
  double bend; // "Biegung" vertikal
public:
  // Konstruktoren / Destruktor

  Bogen(): len(0), fi(0) {};

  Bogen(const ray &startp,
        double lenp, double fip,
        double h1p = 0.6, double gradp = 0.0, double bendp = 0.0):
    start(startp), len(lenp), fi(fip), h1(h1p), grad(gradp), bend(bendp)
  {
  };

  Bogen(const point2d &posp, double dirp, double lenp, double fip,
        double h1p = 0.6, double gradp = 0.0, double bendp = 0.0):
    start(posp, dirp), len(lenp), fi(fip), h1(h1p), grad(gradp), bend(bendp)
  {};

  Bogen(const ray &startp,
        const point2d &endp,
        double h1 = 0.6, double gradp = 0.0, double bendp = 0.0);

  virtual ~Bogen() {}

  bool isValid()
  {
    return len != 0;
  }

  // Zugriff auf Elemente

  virtual const ray &Start() const
  {
    return start;
  }
  virtual ray &Start()
  {
    return start;
  }

  virtual double &Len()
  {
    return len;
  }
  virtual const double &Len() const
  {
    return len;
  }

  virtual double &Fi()
  {
    return fi;
  }
  virtual const double &Fi() const
  {
    return fi;
  }

  virtual void setH(double h)
  {
    // setzt (start-)gleishoehe auf h
    // bei gleichbleibendem Anstieg
    h1 = h;
  }

  virtual double H1() const
  {
    return h1;
  }

  virtual void setHeights(double newH1, double newGrad, double newBend = 0.0)
  {
    h1 = newH1;
    grad = newGrad;
    bend = newBend;
  }

  virtual void setH1(double newH1)
  {
    // setzt start-gleishöhe
    // endgleishöhe wird beibehalten
    if (len != 0)
      {
        double h2 = H2();
        double gradmean = tan((h2 - newH1) / len);
        grad = gradmean - bend / 2;
      }
    h1 = newH1;
  }

  virtual double H2() const
  {
    double gradmean = tan(grad + bend / 2);
    return h1 + len * gradmean;
  }

  virtual void setH2(double h)
  {
    // setzt enggleishöhe
    // startgleishöhe und biegung wird beibehalten
    if (len != 0)
      {
        double gradmean = atan((h - h1) / len);
        grad = gradmean - bend / 2;
      }
    else
      h1 = h;
  }

  virtual void setGrad(double g)
  {
    grad = g;
  }

  virtual double Grad() const
  {
    return grad;
  }

  virtual double GradEnd() const
  {
    return grad + bend;
  }

  virtual void setBend(double g)
  {
    bend = g;
  }

  virtual double Bend() const
  {
    return bend;
  }

  // Zugriff auf (berechnete) Größen

  virtual ray End() const;

  virtual double Rad() const
  {
    if (fabs(fi) < 0.01) return 0;
    return len / fi;
  }

  virtual double Fi1() const
  {
    return start.Dir() - M_PI / 2;
  }

  virtual double Fi2() const
  {
    return Fi1() + fi;
  }

  virtual point2d Center() const;

  virtual double Curvature() const
  {
    double l = len;
    if (l < 0.0001) l = 0.0001;
    return fi / l;
  }

  virtual void GetLimits(double &xi, double &yi,
                         double &xa, double &ya, bool cont = false) const;

  virtual Bogen Inverse() const;
  virtual Bogen Shift(double d, double dh = 0.0) const;
  virtual void ShiftHeight(double dh = 0.0)
  {
    h1 += dh;
  }

  virtual void Draw(int val, Image &img) const;
  virtual void Draw(int val, Image &img,
                    double xi, double yi, double xa, double ya) const;

  Bogen operator *(double fak)
  {
    return Bogen(start, len * fak, fi * fak, h1, grad);
  }
};
#endif
