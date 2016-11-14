#include <iostream>
#define STATIC
#include "gleis_dll.h"

using namespace std;

int main(void)
{
  double gleis1[] = {0, 0, 14, 99, 0.6, 0.6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  double gleis2[] = {100, 20, 14, 99, 0.6, 0.6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  double gleis[] = {100, 20, 14, 99, 0.6, 0.6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  gSetTrackParameter(gleis1,0);
  gSetTrackParameter(gleis2,1);
  gOptimize1(5, 1);
  for (int i=0;i<5;++i)
    {
      gGetTrack(i,gleis);
      for (int i=0;i<16;++i)
	cout << gleis[i] << " ";
      cout << endl;
    }

  return 0;
}
