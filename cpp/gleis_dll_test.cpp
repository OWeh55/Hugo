#include <iostream>
#include "gleis_dll.h"

int main(void)
{
  double gleis1[] = {0, 0, 14, 99, 0.6, 0.6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  double gleis2[] = {100, 20, 14, 99, 0.6, 0.6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  gOptimize1(5, gleis1, gleis2, 1);

  return 0;
}
