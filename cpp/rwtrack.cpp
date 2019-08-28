#include <cmath>
#include <iostream>
#include <iomanip>

#include <fstream>

using namespace std;
#include "myex.h"

#include "bogen.h"
#include "gleis.h"

extern bool verbose;

bogen readtrack(ifstream &is,bool input_format=true)
{
    // input_format = format mit invertierungsflag
    double x,y,dir,winkel,len,h1,h2;
    int inv;
    bogen gleis;

    is >> x >> y >> dir >> winkel >> len >> h1 >> h2;
#if 0
    if (verbose)
    {
        if (is.good())
            cout << "+";
        else
            cout << "!!" ;
        cout << "Gleis Start: " << x << "," << y << " Richtung: " << dir;
        cout <<" Winkel: " << winkel << " Laenge: " << len << " H1: " << h1 << " H2: " << h2 << endl;
    }
#endif
    if (is.good())
    {
        gleis=bogen(point2d(x,y),Arc(dir),len,Arc(winkel),h1,h2);
        if (input_format)
        {
            is >> inv;
            if (inv)
                gleis=gleis.Inverse();
        }
        string s;
        getline(is,s); // überlesen bis zum Zeilenende
        //      cout <<">" << s << "<" << endl;
    }
    else if (!is.eof())
        throw myex("Fehler beim Lesen");
    return gleis;
}

void readtracks(const string &fn,gleis &g,bool fill)
{
    int anz=g.size();

    ifstream is(fn.c_str());

    bogen b=readtrack(is,false);
    if (fill)
    {
        for (int i=0; i<anz; i++)
        {
            b=readtrack(is,false);
            if (b.isValid())
                g[i]=b;
        }
    }
    else
    {
        g.clear();
        do {
            b=readtrack(is,false);
            if (b.isValid())
                g.push_back(b);
        } while (b.isValid());
    }
}

void writetrack(ofstream &of,const bogen &agl,bool extended_format=true)
{
    // parameters of track (for eep)
    ray start=agl.Start();
    of << setw(12) << start.x << ",";
    of << setw(12) << start.y << ",";
    of << setw(12) << Deg(start.dir) << ",";

    of << setw(12) << Deg(agl.Fi()) << ",";

    of << setw(12) << agl.Len() << ",";

    of  << setw(12) << agl.H1() << ",";
    of  << setw(12)<< agl.H2() ;
    if (extended_format)
    {
        of << "," ;
        // additional parameters xe,ye, xm,ym,rad,fi1,fi2
        point2d end=agl.End();
        of << setw(12) << end.x << ","  << setw(12)<< end.y << "," ;
        point2d center=agl.Center();
        of  << setw(12) << center.x << ","  << setw(12) << center.y << ",";
        of  << setw(12)<< agl.Rad() << "," ;
        of  << setw(12)<< Deg(agl.Fi1()) << ","  << setw(12) << Deg(agl.Fi2()) ;
    }
    of << endl;
}
