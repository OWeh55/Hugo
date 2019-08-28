#include <cmath>
#include <iostream>
#include <iomanip>

#include <fstream>
#include <getopt.h>

using namespace std;

#include <image_nonvis.h>

#include "myex.h"
#include "bogen.h"
#include "gleis.h"
#include "rwtrack.h"
#include "optimizer.h"
#include "generate.h"

#define PROGNAME "gerda"


//***************************************************************************
int usage(const string &pn)
{
    cout << pn << "  (c) Wolfgang Ortmann" << endl << endl;
    cout << "Usage:" << endl;
    cout << pn << " <options>"<<endl;
    cout << "Options:" << endl;
    cout << "-m <nr>   Optimierungsmodus" << endl;
    cout << "-n <nr>   Initialisierungsmodus" << endl;
    cout << "-i <file> Eingabe-Filename"<< endl;
    cout << "-o <file> Ausgabe-Filename" << endl;
    cout << "-r <rad>  Radius (nur -m5)" << endl;
    cout << "-h        This help" << endl;

    exit(1);
}

static unsigned int initmode=1;
static unsigned int mode=1;
bool verbose=false;

int writetracks(const string &outfile,
                const bogen &startgleis,
                const gleis &verbindung,
                const bogen &endgleis,
                const string &message="")
{
    ofstream of(outfile.c_str());

    of << verbindung.size() << endl;

    writetrack(of,startgleis,true);

    for (int i=0; i<verbindung.size(); i++)
    {
        writetrack(of,verbindung[i],true);
    }

    writetrack(of,endgleis,true);
    return OK;
}

int main(int argc,char *argv[])
{
    string infile;
    string outfile;

    bogen startgleis;
    bogen endgleis;

    gleis verbindung;

    try {
        int rc;
        int rad=100;

        while ((rc=getopt(argc,argv,"hm:n:o:i:xr:v"))>=0)
        {
            switch (rc)
            {
            case 'm':
                mode=atol(optarg);
                break;
            case 'n':
                initmode=atol(optarg);
                break;
            case 'i':
                infile=optarg;
                break;
            case 'o':
                outfile=optarg;
                break;
            case 'r':
                rad=atol(optarg);
                break;
            case 'v':
                verbose=true;
                break;
            case 'h':
            default:
                usage(argv[0]);
                break;
            }
        }

        ifstream is(infile.c_str());

        if (!is.is_open())
            throw myex("Kann Eingabedatei nicht lesen");

        // start und endgleis mit irgendwelchen startwerten
        startgleis=readtrack(is);
        endgleis=readtrack(is);

        unsigned int anzahl;

        is >> anzahl;
        if (verbose)
            cout << "Anzahl: " << anzahl << endl;

        for (unsigned int i=0; i<anzahl; i++)
            verbindung.Append(60,0);

        //    ray ende=endgleis.Start();

        switch (mode)
        {
        case 1:
        case 2:
        case 3:
        {
            if (!Optimize1(verbindung, startgleis, endgleis, mode))
                throw myex("Optimierung fehlgeschlagen");
            break;
        }

        case 4:
            verbindung = GenerateKG(startgleis, endgleis);
            break;

        case 5:
        {
            if (!Optimize2(verbindung, startgleis, endgleis,rad))
                throw myex("Optimierung fehlgeschlagen");
            verbindung = SubDivide(verbindung,60);
            break;
        }

        default:
            throw myex("Falscher Modus: " + NumberString(mode));
        }
        writetracks(outfile,startgleis,verbindung,endgleis);
        return OK;
    }
    catch(myex m)
    {
        //    cout << m.Msg();
        if (!outfile.empty())
        {
            //  ofstream os(outfile.c_str());
            //  os << "-1" << endl;
            verbindung.clear();
            writetracks(outfile,startgleis,verbindung,endgleis);
            // os << m.Msg() << endl;
        }
        else
            cout << "Exception: " << m.Msg() << endl;
        return 1;
    }
}
