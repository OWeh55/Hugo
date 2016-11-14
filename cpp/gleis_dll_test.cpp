#include <iostream>
#include <iomanip>
#include <string>

#define STATIC 

#include "gleis_dll.h"

using namespace std;

const int nTracks=5;

void printTrack(const string &name,const double *v)
{
  cout << setw(15) << name << ": ";
  for (int i = 0; i < 5; ++i)
    cout << setprecision(3) << setw(8) << v[i] << " ";
  cout << endl;
}

int main()
{
  //                 x     y   dir  angle len
  //  double gleis1[] = {-10,  0,   10,   -10,  10, 0.6, 0.6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  double gleis1[] = {-10,  0,   0,   0,  10, 0.6, 0.6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  double gleis2[] = {100,  0,   0,    0,  23, 0.6, 0.6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  double gleis[] = {100,   20, 14,    99, 0.6, 0.6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  gSetTrackParameter(gleis1, 0);
  gSetTrackParameter(gleis2, 1);
  gOptimize1(nTracks, 1);
  printTrack("start",gleis1);
  for (int i = 0; i < nTracks; ++i)
    {
      gGetTrack(i, gleis);
      printTrack(std::to_string(i),gleis);
      //    for (int i = 0; i < 5; ++i)
      //        cout << setprecision(3) << setw(8) << gleis[i] << " ";
      // cout << endl;
    }
  printTrack("end",gleis2);

  return 0;
}
