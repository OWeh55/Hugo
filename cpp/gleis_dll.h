#ifndef GLEIS_DLL_H
#define GLEIS_DLL_H

#ifdef BUILDING_DLL
#define GLEIS_DLL __stdcall __declspec(dllexport)
#else
#define GLEIS_DLL __stdcall __declspec(dllimport)
#endif

const int tracksize=15;

// indices of values in track as AutoIt-Array
const int ix=0;
const int iy=1;
const int idir=2;
const int iangle=3;
const int ilen=4;
const int ih1=5;
const int igrad=6;

// indices of extended values in track as AutoIt-Array
const int ih2=7;
const int ixe=8;
const int iye=9;
const int ixm=10;
const int iym=11;
const int irad=12;
const int ifi1=13;
const int ifi2=14;

extern "C" {
    // globale Gleisverbindung verwalten
    int GLEIS_DLL gGetTrack(int nr,double *gleis);
    int GLEIS_DLL gInitTrack();
    int GLEIS_DLL gPutTrack(double *gleis);

    // (Globale) Werte für Start- und Endgleis übergeben

    int GLEIS_DLL gSetTrackParameter(const double *gleis,int sel);
    int GLEIS_DLL gGetTrackParameter(int sel,double *gleis);

    // Gleis invertieren
    int GLEIS_DLL gInvert();

    // Gleis seitlich und vertikal "verschieben"
    int GLEIS_DLL gShift(double d,double dh);

    // Konstruktion von Gleisverbindungen
    int GLEIS_DLL gOptimize1(int gleisanz,int mode);

    int GLEIS_DLL gGenerateKG();
    int GLEIS_DLL gGenerateGKG(double rad);

    int GLEIS_DLL gOptimize2(double rad);

    int GLEIS_DLL gLinHeight();
    int GLEIS_DLL gOptHeight(double trans,double maxshort);
}
#endif  // GLEIS_DLL_H
