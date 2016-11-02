#include "gleis.h"

void gleis::GetLimits(double &xi, double &yi, double &xa, double &ya, bool cont) const
{
  if (gleise.empty())
    {
      if (!cont)
        xi = yi = xa = ya = 0.0;
    }
  else
    {
      gleise[0].GetLimits(xi, yi, xa, ya, cont);
      for (unsigned int i = 1; i < gleise.size(); i++)
        {
          gleise[i].GetLimits(xi, yi, xa, ya, true);
        }
    }
}

void gleis::Divide(int idx)
// teilt = halbiert das Gleis mit Index idx
{
  Bogen hgleis1 = gleise[idx] * 0.5;
  Bogen hgleis2 = hgleis1;
  hgleis2.Start() = hgleis1.End();
  hgleis2.setH(hgleis1.H2());
  gleise[idx] = hgleis2;
  gleise.insert(gleise.begin() + idx, hgleis1);
}

double gleis::Len() const
{
  double len = 0.0;
  for (unsigned int i = 0; i < gleise.size(); i++)
    len += gleise[i].Len();
  return len;
}

void setLinearHeight(gleis &g, double h1, double h2)
{
// Gleishöhe linear setzen
  double h = h1;
  double total_len = 0;
  for (int i = 0; i < g.size(); i++)
    {
      total_len += g[i].Len();
    }

  double dh = h2 - h;
  double grad = dh / total_len;
  double alen = 0;
  for (int i = 0; i < g.size(); i++)
    {
      g[i].setHeights(h + alen * grad, grad);
      alen += g[i].Len();
    }
}
