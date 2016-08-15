#include "gleis.h"
#include "generate.h"

gleis GenerateKG(const Bogen &startgleis, const Bogen &endgleis)
{
  gleis verbindung;
  ray start = startgleis.End();
  ray end = endgleis.Start().DirInverse();

  verbindung.setStart(start);

  double l1, l2;
  point2d schnitt, hp;
  try
    {
      schnitt = Intersection(start, end, l1, l2);

      //  cout << l1 << "," << l2 << endl;
      //  cout << schnitt << endl;

      //  if ( l1 * l2 < 0.0 )
      //    throw("Intersection not usable");

      if (l1 > l2)
        {
          hp = start + (l1 - l2) * vector2d(start.Dir());
        }
      else
        {
          hp = end + (l2 - l1) * vector2d(end.Dir());
        }
    }
  catch (const char *msg)
    {
      // kein schnittpunkt
      verbindung.clear();
      return verbindung;
    }
  //  cout << start << endl << hp << endl << end << endl;
  verbindung.Append(hp);
  verbindung.Append(end);

  // Gleishoehe wird hier nicht behandelt
  // Anpassung der Länge der Gleise wird von Hugo aus aktiviert
  return verbindung;
}

gleis GenerateGKG(const Bogen &startgleis, const Bogen &endgleis, double radius)
{
  gleis verbindung;
  ray start = startgleis.End();
  ray end = endgleis.Start().DirInverse();

  verbindung.setStart(start);

  double l1, l2;
  try
    {
      point2d schnitt = Intersection(start, end, l1, l2);

      //  cout << l1 << "," << l2 << endl;
      //  cout << schnitt << endl;

      //  if ( l1 * l2 < 0.0 )
      //    throw("Intersection not usable");

      // Winkel zwischen den Strahlen
      double phi = start.Dir() - end.Dir();

      double lb = radius / fabs(tan(phi / 2));

      if (lb < l1 && lb < l2)
        {

          point2d hp1 = start + (l1 - lb) * vector2d(start.Dir());
          point2d hp2 = end + (l2 - lb) * vector2d(end.Dir());

          //  cout << start << endl << hp << endl << end << endl;

          verbindung.Append(hp1);
          verbindung.Append(hp2);
          verbindung.Append(end);

          // Gleishoehe wird hier nicht behandelt
          // Reduktion der Länge der Gleise wird von Hugo später aktiviert
        }
    }
  catch (const char *msg)
    {
      verbindung.clear();
      return verbindung;
    }
  return verbindung;
}

gleis SubDivide(const gleis &verbindung, double maxlength)
{
  gleis res;

  res.setStart(verbindung.getStart());

  for (int i = 0; i < verbindung.size(); i++)
    {
      const Bogen &gleis = verbindung[i];

      if (gleis.Len() < maxlength)
        {
          if (gleis.Len() > 1.0)
            res.push_back(gleis);
        }
      else
        {
          // Zerlegen eines Gleises in Teilstücke
          // notwendige Zahl der Teile
          int anz = (int)ceil(gleis.Len() / maxlength);
          // Ermittlung der Parameter des Teilstückes
          double fak = 1.0 / anz;
          double dh = (gleis.H2() - gleis.H1()) * fak;

          // Anlegen des ersten Teilstückes
          Bogen teil = Bogen(gleis.Start(),
                             gleis.Len() * fak, gleis.Fi() * fak,
                             gleis.H1(), gleis.Grad());
          for (int k = 0; k < anz; k++)
            {
              res.push_back(teil);
              // nächstes Teilstück durch Verschieben
              // an Ende des vorigen
              teil.Start() = teil.End();
              teil.ShiftHeight(dh);
            }
        }
    }
  return res;
}
