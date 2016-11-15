#ifndef GLEIS_DLL_H
#define GLEIS_DLL_H

#ifndef STATIC
#ifdef BUILDING_DLL
#define GLEIS_DLL __stdcall __declspec(dllexport)
#else
#define GLEIS_DLL __stdcall __declspec(dllimport)
#endif
#else
#define GLEIS_DLL
#endif

const int tracksize = 16;

// indices of values in track as AutoIt-Array
const int ix = 0;
const int iy = 1;
const int idir = 2;
const int iangle = 3;
const int ilen = 4;
const int ih1 = 5;
const int igrad = 6;
const int ibend = 7;

// indices of extended values in track as AutoIt-Array
const int ih2 = 8;
const int ixe = 9;
const int iye = 10;
const int ixm = 11;
const int iym = 12;
const int irad = 13;
const int ifi1 = 14;
const int ifi2 = 15;

extern "C" {
  // globale Gleisverbindung verwalten
  int GLEIS_DLL gGetTrack(int nr, double *gleis);
  int GLEIS_DLL gInitTrack();
  int GLEIS_DLL gPutTrack(double *gleis);

  // (Globale) Werte für Start- und Endgleis übergeben

  int GLEIS_DLL gSetTrackParameter(const double *gleis, int sel);
  int GLEIS_DLL gGetTrackParameter(int sel, double *gleis);

  // Gleis invertieren
  int GLEIS_DLL gInvert();

  // Gleis seitlich und vertikal "verschieben"
  int GLEIS_DLL gShift(double d, double dh);

  // Optimierung und Konstruktion von Gleisverbindungen
  int GLEIS_DLL gOptimize1(int gleisanz, int mode);
  int GLEIS_DLL gOptimize2(double rad);

  int GLEIS_DLL gGenerateKG();
  int GLEIS_DLL gGenerateGKG(double rad);

  // Längenreduktion als Nachbearbeitung
  int GLEIS_DLL gSplit(double maxlength);

  // Höhen festlegen
  int GLEIS_DLL gLinHeight();
  int GLEIS_DLL gOptHeight();
}
#endif  // GLEIS_DLL_H
