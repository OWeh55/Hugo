#include <fstream>
#include "gleis.h"
#include "optimizer.h"
#include "lmdif.h"
#include "myex.h"

extern bool verbose;

void UpdateGleisFromAngleVector(const Vector &fi, double flen, gleis &g)
{
  g.clear();
  for (unsigned int i = 0; i < fi.size(); i++)
    {
      g.Append(flen, fi[i]);
    }
}

void UpdateAngleVectorFromGleis(const gleis &g, Vector &fi)
{
  fi.Clear();
  for (int i = 0; i < g.size(); i++)
    {
      fi.Append(g[i].Fi());
    }
}

void Init(gleis &verbindung,
          const Bogen &start, const Bogen &end,
          int mode)
{
  unsigned int gleise = verbindung.size();
  if (gleise == 0) gleise = 5;

  verbindung = gleis(start.End());

  // different modes for initialization
  switch (mode)
    {
    case 0:
    {
      // gerade Gleise vom Startpunkt in Startrichtung
      for (unsigned int i = 0; i < gleise; i++)
        verbindung.Append(60, 0);
    }
    break;

    case 1:
      // Gleise bilden einen Kreis-Bogen zum Endpunkt
    {
      Bogen g(start.End(), end.Start());
      for (unsigned int i = 0; i < gleise; i++)
        verbindung.Append(g.Len() / gleise, g.Fi() / gleise);
    }
    break;

    case 2:
      // "geradlinige" Verbindung: Gleisenden liegen auf einer
      // Geraden zum Endpunkt
    {
      vector2d dist = end.Start() - start.End();

      for (unsigned int i = 0; i < gleise; i++)
        verbindung.Append(start.End() + dist * ((i + 1.0) / gleise));
    }
    break;
    }
}

class GleisFehler: public LMFunctor
{
protected:
  constexpr static double curvature_change_weight = 1000;
  constexpr static double end_point_weight = 1000;
  gleis &g;

  double startcurv;

  ray end;

  double endcurv;

  double &len; // length to be optimized
  Vector &fi; // angles to be optimized

  int mode; // mode of optimization - parameter of error function

public:
  GleisFehler(gleis &gp, const Bogen &startp,
              const Bogen &endp,
              double &lenp, Vector &fip,
              int pmode):
    g(gp),
    startcurv(startp.Curvature()),
    end(endp.Start()), endcurv(endp.Curvature()),
    len(lenp), fi(fip),
    mode(pmode)
  {
    Init(g, startp, endp, 1);
    UpdateAngleVectorFromGleis(g, fi);
  };

  virtual int operator()(Vector &res) const
  {
    UpdateGleisFromAngleVector(fi, len, g);

    unsigned int ind = 0;

    if ((mode & 1) > 0) // change of curvature
      {
        // change from previous track to first track
        res[ind++] = (g[0].Curvature() - startcurv) * curvature_change_weight;

        // changes between tracks
        for (unsigned int i = 1; i < fi.size(); i++)
          {
            res[ind++] = (g[i].Curvature() - g[i - 1].Curvature()) * curvature_change_weight;
          }

        // changes from last track to next track
        res[ind++] = (g[g.size() - 1].Curvature() - endcurv) * curvature_change_weight;
      }

    if ((mode & 2) > 0) // curvature
      {
        for (unsigned int i = 0; i < fi.size(); i++)
          {
            res[ind++] = g[i].Curvature();
          }
      }

    //  of end point (with high weight)
    res[ind++] = (g.End().x - end.x) * end_point_weight;
    res[ind++] = (g.End().y - end.y) * end_point_weight;
    res[ind++] = normal(g.End().Dir() - end.Dir()) * end_point_weight;

    return OK;
  }

  virtual int funcdim() const
  {
    int dim = 3; // endpunkt, richtung
    if (mode & 1) dim += g.size() + 1;
    if (mode & 2) dim += g.size();
    return dim;
  }
};

bool Optimize1(gleis &g, const Bogen &start, const Bogen &end,
               int mode)
{
  double len = 60;
  Vector f;

  GleisFehler ff(g, start, end, len, f, mode);

  vector<double *> pz; // variables to optimize (length and angles)
  pz.push_back(&len); // one length

  for (int i = 0; i < g.size(); i++)
    {
      pz.push_back(&f[i]); // n angles
    }

  int inumber;
  int info = LMDif(pz, ff, 10000, inumber);

//  cout << inumber << endl;

  UpdateGleisFromAngleVector(f, len, g);

  // Gleishoehe wird hier nicht behandelt

  return (info > 0) && (info < 5);
}

void UpdateGleisFromLengthVector(const Vector &len,
                                 double rad1, double rad2,
                                 gleis &g)
{
  g.clear();
  if (len[0] > 0)
    g.Append(len[0], len[0] / rad1);
  else
    g.Append(len[0], 0);
  g.Append(len[1], 0);
  if (len[2] > 0)
    g.Append(len[2], len[2] / rad2);
  else
    g.Append(len[2], 0);
}

class GleisFehler2: public LMFunctor
{
protected:
  gleis &g;

  ray end;
  Vector &length;
  double rad1;
  double rad2;

public:
  GleisFehler2(gleis &gp, ray start, ray endp,
               Vector &lenp, double radp1, double radp2):
    g(gp), end(endp),
    length(lenp), rad1(radp1), rad2(radp2)
  {
    vector2d diff = endp - gp.getStart();
    double phid = diff.Phi();
    double phi1 = normal(phid - start.Dir());
    double phi2 = normal(endp.Dir() - phid);
    length[0] = fabs(rad1 * phi1);
    length[1] = diff.Len();
    length[2] = fabs(rad2 * phi2);
    g.setStart(start);
    UpdateGleisFromLengthVector(length, rad1, rad2, g);
    //    cout << length << endl;
  };

  virtual int operator()(Vector &res) const
  {
    UpdateGleisFromLengthVector(length, rad1, rad2, g);
    //  of end point (with high weight)
    int ind = 0;
    res[ind++] = (g.End().x - end.x);
    res[ind++] = (g.End().y - end.y);
    res[ind++] = normal(g.End().Dir() - end.Dir());

#if 0
    if (verbose)
      cout << res << endl;
#endif

    return OK;
  }

  virtual int funcdim() const
  {
    int dim = 3; // endpunkt, richtung
    return dim;
  }
};

bool Optimize2(gleis &g,
               const Bogen &start, const Bogen &end,
               double rad1, double rad2)
{
  // drei gleise:
  //    Kreis (rad1)
  //    Strecke
  //    Kreis (rad2)
  // Längen werden optimiert

  Vector len(3);
  GleisFehler2 ff(g, start.End(), end.Start(), len, rad1, rad2);

  vector<double *> pz; // variables to optimize (length)
  pz.push_back(&len[0]); // first length
  pz.push_back(&len[1]); // second length
  pz.push_back(&len[2]); // third length

  int inumber;

  int rc = LMDif(pz, ff, 10000, inumber);
  if (rc < 1 || rc > 4)
    return false;
#if 0
  if (verbose)
    {
      cout << "Versuche: " << inumber << endl;
      cout << len << endl;
    }
#endif
  if (len[0] < 1.0) return false;
  if (len[1] < 1.0) return false;
  if (len[2] < 1.0) return false;
  return true;
}

bool Optimize2(gleis &g, const Bogen &start, const Bogen &end, double rad)
{
  Vector len(3);

  if (Optimize2(g, start, end, rad, rad)  ||
      Optimize2(g, start, end, -rad, rad) ||
      Optimize2(g, start, end, rad, -rad) ||
      Optimize2(g, start, end, -rad, -rad))
    {

      // Gleishoehe wird hier nicht behandelt
      return true;
    }
  return false;
}

class hsegment
{
private:
  double h0;
  double grad0;
  double len;
  double dg;
public:
  hsegment(double h0p, double grad0p,
           double lenp, double dgp)
    : h0(h0p), grad0(grad0p), len(lenp), dg(dgp)
  {};

  void last(double &h2, double &a2) const
  {
    h2 = h0 + len * tan(grad0 + dg / 2);
    a2 = grad0 + dg;
  }
};

class HoehenFehler1: public LMFunctor
{
protected:
  double len1, len2, len3;

  double a0, a3s;

  double h0, h3s;

  double &k1;
  double &k3;

public:
  HoehenFehler1(double len1p, double len2p, double len3p,
                double a0p, double a3sp,
                double h0p, double h3sp,
                double &k1p, double &k3p):
    len1(len1p), len2(len2p), len3(len3p),
    a0(a0p), a3s(a3sp),
    h0(h0p), h3s(h3sp),
    k1(k1p), k3(k3p)
  {
  };

  virtual int operator()(Vector &res) const
  {
    double hn, an;
    hsegment s1(h0, a0, len1, k1);
    s1.last(hn, an);
    hsegment s2(hn, an, len2, 0);
    s2.last(hn, an);
    hsegment s3(hn, an, len3, k3);
    s3.last(hn, an);

    res[0] = hn - h3s;
    res[1] = an - a3s;

    return OK;
  }

  virtual int funcdim() const
  {
    int dim = 2; // endhoehe, endanstieg
    return dim;
  }
};

bool OptimizeHoehe1(gleis &g,
                    const Bogen &start,
                    const Bogen &end)
{
  double k1 = 0.001;
  double k3 = -0.001;

  int nTracks = g.size();

  double len = g.Len();

  double len1 = g[0].Len();
  double len3 = g[nTracks - 1].Len();
  double len2 = len - len1 - len3;

  HoehenFehler1 ff(len1, len2, len3,
                   start.GradEnd(), end.Grad(),
                   start.H2(), end.H1(),
                   k1, k3);

  vector<double *> pz; // variables to optimize (length)
  pz.push_back(&k1);
  pz.push_back(&k3);

  int inumber;

  int rc = LMDif(pz, ff, 10000, inumber);
  if (rc < 1 || rc > 4)
    return false;

  double hn, an;

  hsegment s1(start.H2(), start.Grad(), len1, k1);
  s1.last(hn, an);
  hsegment s2(hn, an, len2, 0);
  s2.last(hn, an);
  hsegment s3(hn, an, len3, k3);
  s3.last(hn, an);

  double h = start.H2();
  double a = start.GradEnd();
  g[0].setHeights(h, a, k1);
  h = g[0].H2();
  a = g[0].GradEnd();
  for (int i = 1; i < g.size() - 1; ++i)
    {
      g[i].setHeights(h, a, 0);
      h = g[i].H2();
    }
  g[g.size() - 1].setHeights(h, a, k3);
  return true;
}
