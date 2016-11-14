#include <fstream>
#include "gleis.h"
#include "optimizer.h"
#include "LMSolver.h"
#include "myex.h"

extern bool verbose;

void UpdateGleisFromAngleVector(const vector<double> &fi, double flen, gleis &g)
{
  g.clear();
  for (unsigned int i = 0; i < fi.size(); i++)
    {
      g.Append(flen, fi[i]);
    }
}

void UpdateAngleVectorFromGleis(const gleis &g, vector<double> &fi)
{
  fi.clear();
  for (int i = 0; i < g.size(); i++)
    {
      fi.push_back(g[i].Fi());
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
      //               e
      //               |
      //
      //
      //   s------------
      for (unsigned int i = 0; i < gleise; i++)
        verbindung.Append(60, 0);
    }
    break;

    case 1:
      // Gleise bilden einen Kreis-Bogen zum Endpunkt
      //         e
      //         |
      //         |
      //         /
      //        /
      //   s---/
    {
      Bogen g(start.End(), end.Start());
      for (unsigned int i = 0; i < gleise; i++)
        verbindung.Append(g.Len() / gleise, g.Fi() / gleise);
    }
    break;

    case 2:
      // "geradlinige" Verbindung: Gleisenden liegen auf einer
      // Geraden zum Endpunkt
      //         e
      //         |
      //        /
      //       /
      //      /
      //   s-
    {
      vector2d dist = end.Start() - start.End();

      for (unsigned int i = 0; i < gleise; i++)
        verbindung.Append(start.End() + dist * ((i + 1.0) / gleise));
    }
    break;
    }
}

double SQRT(double x)
{
  if (x>0)
    return sqrt(x);
  else
    return -sqrt(-x);
}

class GleisFehler: public LMFunctor
{
  // Gleis mit n gleich langen Gleisen
  // Fehlermass für Strecke wählbar mit pmode
  // 1 - \Delta Curvature
  // 2 - Curvature
  // 3 - both
protected:
  constexpr static double curvature_change_weight = 1000;
  constexpr static double end_point_weight = 1000;

  Bogen start;
  Bogen end;

  int nTracks;
  int mode; // mode of optimization - parameter of error function

public:
  GleisFehler(const Bogen &startp,
              const Bogen &endp,
	      int nTracksp,
              int pmode):
    start(startp),
    end(endp),
    nTracks(nTracksp),
    mode(pmode)
  {
  };
  
  virtual int operator()(const vector<double> &x, vector<double> &res) const
  {
    gleis g(start.End());
    //    cout << x[0] << " ";
    for (unsigned int i = 1; i < x.size(); i++)
      {
	// cout << x[i] << " ";
	g.Append(x[0], x[i]);
      }
    //    cout << endl;

    unsigned int resultIndex = 0;

    if ((mode & 1) > 0) // change of curvature
      {
        // change from previous track to first track
	res[resultIndex++] = (SQRT(g[0].Curvature()) - SQRT(start.Curvature())) * curvature_change_weight;
      // res[resultIndex++] = (g[0].Curvature() - start.Curvature()) * curvature_change_weight;
	
	// changes between tracks
	for (int i = 1; i < g.size(); i++)
	  {
	    res[resultIndex++] = (SQRT(g[i].Curvature()) - SQRT(g[i - 1].Curvature())) * curvature_change_weight;
	  }
	
	// changes from last track to next track
	res[resultIndex++] = (SQRT(g[g.size() - 1].Curvature()) - SQRT(end.Curvature())) * curvature_change_weight;
      }
    
    if ((mode & 2) > 0) // curvature
      {
        for (int i = 0; i < g.size(); i++)
          {
            res[resultIndex++] = g[i].Curvature();
          }
      }

    //  of end point (with high weight)
    res[resultIndex++] = (g.End().x - end.Start().x) * end_point_weight;
    res[resultIndex++] = (g.End().y - end.Start().y) * end_point_weight;
    res[resultIndex++] = normal(g.End().Dir() - end.Start().Dir()) * end_point_weight;

    //    for(int i=0;i<res.size();++i)
    //      cout << res[i] << " " ;
    //    cout << endl;

    return 0;
  }

  virtual int getDimension() const
  {
    int dim = 3; // endpunkt, richtung
    if (mode & 1) dim += nTracks + 1;
    if (mode & 2) dim += nTracks;
    return dim;
  }
};

bool Optimize1(gleis &g, const Bogen &start, const Bogen &end,
               int mode)
{
  Init(g,start,end,1); // Initialisierung als Kreisbogen

  double len = g[0].Len();

  vector<double> f;

  f.push_back(len);
  for (int i=0;i<g.size();++i)
    f.push_back(g[i].Fi());
  
  GleisFehler ff(start, end, g.size(), mode);

  LMSolver opt(ff);

  opt.solve(f);

  int info = opt.getInfo();
  
  g.clear();
  for (unsigned int i = 1; i < f.size(); i++)
    {
      g.Append(f[0], f[i]);
    }

  // Gleishoehe wird hier nicht behandelt !!
  return (info > 0) && (info < 5);
}

void UpdateGleisFromLengthVector(const vector<double> &len,
                                 double rad1, double rad2,
                                 gleis &g)
{
}

class GleisFehler2: public LMFunctor
{
protected:
  ray start;
  ray end;
  double rad1;
  double rad2;

public:
  GleisFehler2(ray startp, ray endp,
               double radp1, double radp2):
    start(startp), end(endp),
    rad1(radp1), rad2(radp2)
  {
  };
  
  virtual int operator()(const vector<double> &x,vector<double> &res) const
  {
    gleis g(start);
    if (x[0] > 0)
      g.Append(x[0], x[0] / rad1);
    else
      g.Append(x[0], 0);
    g.Append(x[1], 0);
    if (x[2] > 0)
      g.Append(x[2], x[2] / rad2);
    else
      g.Append(x[2], 0);
    
    //  end point (with high weight)
    res[0] = (g.End().x - end.x);
    res[1] = (g.End().y - end.y);
    res[2] = normal(g.End().Dir() - end.Dir());

#if 0
    if (verbose)
      cout << res << endl;
#endif

    return 0;
  }

  virtual int getDimension() const
  {
    return 3;
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

  GleisFehler2 ff(start.End(), end.Start(), rad1, rad2);
  LMSolver opt(ff);

  vector<double> f(3, 60); // all tracks same length
  opt.solve(f);

  int rc = opt.getInfo();
  if (rc < 1 || rc > 4)
    return false;
#if 0
  if (verbose)
    {
      cout << "Versuche: " << inumber << endl;
      cout << len << endl;
    }
#endif
  if (f[0] < 1.0 || f[1] < 1.0 || f[2] < 1.0) return false;
  g.clear();
  g.setStart(start.End());
  g.Append(f[0],f[0]/rad1);
  g.Append(f[1],0);  
  g.Append(f[2],f[2]/rad2);
  return true;
}

bool Optimize2(gleis &g, const Bogen &start, const Bogen &end, double rad)
{
  vector<double> len(3);

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

public:
  HoehenFehler1(double len1p, double len2p, double len3p,
                double a0p, double a3sp,
                double h0p, double h3sp):
    len1(len1p), len2(len2p), len3(len3p),
    a0(a0p), a3s(a3sp),
    h0(h0p), h3s(h3sp)
  {
  };

  virtual int operator()(const vector<double> &x, vector<double> &res) const
  {
    double hn, an;
    hsegment s1(h0, a0, len1, x[0]);
    s1.last(hn, an);
    hsegment s2(hn, an, len2, 0);
    s2.last(hn, an);
    hsegment s3(hn, an, len3, x[1]);
    s3.last(hn, an);

    res[0] = hn - h3s;
    res[1] = an - a3s;

    return 0;
  }

  virtual int getDimension() const
  {
    int dim = 2; // endhoehe, endanstieg
    return dim;
  }
};

bool OptimizeHoehe1(gleis &g,
                    const Bogen &start,
                    const Bogen &end)
{
  int nTracks = g.size();

  double len = g.Len();

  double len1 = g[0].Len();
  double len3 = g[nTracks - 1].Len();
  double len2 = len - len1 - len3;

  HoehenFehler1 ff(len1, len2, len3,
                   start.GradEnd(), end.Grad(),
                   start.H2(), end.H1());

  vector<double> k(2); // variables to optimize ()
  k[0]=0.0001;
  k[1]=-0.0001;
  
  LMSolver lms(ff);
  
  lms.solve(k);
  int rc = lms.getInfo();
  if (rc < 1 || rc > 4)
    return false;
  
  double hn, an;

  hsegment s1(start.H2(), start.Grad(), len1, k[0]);
  s1.last(hn, an);
  hsegment s2(hn, an, len2, 0);
  s2.last(hn, an);
  hsegment s3(hn, an, len3, k[1]);
  s3.last(hn, an);
  
  double h = start.H2();
  double a = start.GradEnd();
  g[0].setHeights(h, a, k[0]);
  h = g[0].H2();
  a = g[0].GradEnd();
  for (int i = 1; i < g.size() - 1; ++i)
    {
      g[i].setHeights(h, a, 0);
      h = g[i].H2();
    }
  g[g.size() - 1].setHeights(h, a, k[1]);
  return true;
}
