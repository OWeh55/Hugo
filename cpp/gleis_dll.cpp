#include "bogen.h"
#include "gleis.h"
#include "optimizer.h"
#include "generate.h"
#include "gleis_dll.h"

gleis DieVerbindung;
Bogen Gleis1;
Bogen Gleis2;

Bogen array2bogen(const double *array)
{
  Bogen b(point2d(array[ix], array[iy]), Arc(array[idir]),
          array[ilen], Arc(array[iangle]), array[ih1], Arc(array[igrad]), Arc(array[ibend]));
  return b;
}

void bogen2array(const Bogen &b, double *array)
{
  array[ix] = b.Start().x;
  array[iy] = b.Start().y;
  array[idir] = Deg(b.Start().Dir());

  array[iangle] = Deg(b.Fi());
  array[ilen] = b.Len();
  array[ih1] = b.H1();
  array[igrad] = Deg(b.Grad());
  array[ibend] = Deg(b.Bend());

  array[ih2] = b.H2();
  array[ixe] = b.End().x;
  array[iye] = b.End().y;
  array[ixm] = b.Center().x;
  array[iym] = b.Center().y;
  array[irad] = b.Rad();
  array[ifi1] = Deg(b.Fi1());
  array[ifi2] = Deg(b.Fi2());
}

extern "C" {
  int GLEIS_DLL gGetTrack(int nr, double *gleis)
  {
    if (nr < 0) return 1;
    if (nr > DieVerbindung.size()) return 2;
    bogen2array(DieVerbindung[nr], gleis);
    return 0;
  }

  int GLEIS_DLL gInitTrack()
  {
    DieVerbindung.clear();
    return 0;
  }

  int GLEIS_DLL gPutTrack(double *gleis)
  {
    Bogen b = array2bogen(gleis);
    DieVerbindung.Append(b);
    return 0;
  }

  int GLEIS_DLL gSetTrackParameter(const double *gleis, int sel)
  {
    if (sel == 0)
      Gleis1 = array2bogen(gleis);
    else
      Gleis2 = array2bogen(gleis);
    return 0;
  }

  int GLEIS_DLL gGetTrackParameter(int sel, double *gleis)
  {
    if (sel == 0)
      bogen2array(Gleis1, gleis);
    else
      bogen2array(Gleis2, gleis);
    return 0;
  }

  //=======================================================
  int GLEIS_DLL gInvert()
  {
    Gleis1 = Gleis1.Inverse();
    return 0;
  }
  int gShift(double d, double dh)
  {
    Gleis1 = Gleis1.Shift(d, dh);
    return 0;
  }
  //=======================================================
  int GLEIS_DLL gOptimize1(int gleisanz, int mode)
  {
    DieVerbindung.clear();
    for (int i = 0; i < gleisanz; i++)
      DieVerbindung.Append(60, 0);

    if (!Optimize1(DieVerbindung, Gleis1, Gleis2, mode))
      return -1;

    return DieVerbindung.size();
  }

  int GLEIS_DLL gGenerateKG()
  {
    DieVerbindung = GenerateKG(Gleis1, Gleis2);
    return DieVerbindung.size();
  }

  int GLEIS_DLL gGenerateGKG(double rad)
  {
    DieVerbindung = GenerateGKG(Gleis1, Gleis2, rad);
    return DieVerbindung.size();
  }

  int GLEIS_DLL gOptimize2(double rad)
  {
    if (!Optimize2(DieVerbindung, Gleis1, Gleis2, rad))
      return -1;
    return DieVerbindung.size();
  }

  int GLEIS_DLL gLinHeight()
  {
    setLinearHeight(DieVerbindung, Gleis1.H2(), Gleis2.H1());
    return DieVerbindung.size();
  }

  int GLEIS_DLL gOptHeight()
  {
    if (!OptimizeHoehe1(DieVerbindung, Gleis1, Gleis2))
      setLinearHeight(DieVerbindung, Gleis1.H2(), Gleis2.H1());
    return DieVerbindung.size();
  }

  int GLEIS_DLL gSplit(double maxlength)
  {
    DieVerbindung = SubDivide(DieVerbindung, maxlength);
    return DieVerbindung.size();
  }

}
