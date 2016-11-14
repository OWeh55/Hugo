/*
 * ICE - C++ - Library for image processing
 *
 * Copyright (C) 2002 FSU Jena, Digital Image Processing Group
 * Contact: ice@pandora.inf.uni-jena.de
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
#include <stdlib.h>
#include <math.h>
#include <fstream>

//#include "matrix_function.h"
//#include "numbase.h"
#include "ludecomp.h"

#include "MatrixAlgebra.h"

#define PRECISION 1e-200

using std::vector;
namespace ice
{
  double Determinant(const matrix<double> &m)
  {
    if (m.cols() != m.rows())
      throw std::length_error("wrong dimension in determinant");

    if (m.rows() == 1) return m[0][0];

    int dim = m.rows();

    int sign = 1;

    // copy matrix
    matrix<double> h(m);

    double q, pivot;

    vector<int> p_k(dim);

    for (int k = 0; k < dim; k++)
      {
        double max = 0;
        p_k[k] = 0;

        for (int i = k; i < dim; i++)
          {
            double s = 0;

            for (int j = k; j < dim; j++)
              {
                s = s + fabs(h[i][j]);
              }

            if (s != 0)
              {
                q = fabs(h[i][k]) / s;
              }
            else
              {
                q = 0;
              }

            if (q > max)
              {
                max = q;
                p_k[k] = i;
              }
          }

        if (max == 0) return 0;

        if (p_k[k] != k)
          {
            sign = -sign;

            for (int j = 0; j < dim; j++)
              {
                double hilf = h[k][j];
                h[k][j] = h[p_k[k]][j];
                h[p_k[k]][j] = hilf;
              }
          }

        pivot = h[k][k];

        for (int j = (k + 1); j < dim; j++)
          {
            double faktor = (-(h[j][k]) / pivot);

            for (int i = 0; i < dim; i++)
              {
                h[j][i] = h[j][i] + (h[k][i] * faktor);
              }
          }

        for (int j = (k + 1); j < dim; j++)
          h[j][k] = 0;
      }

    double det = sign;

    for (int k = 0; k < dim; k++)
      {
        det = det * h[k][k];
      }

    return det;
  }
#undef FNAME

  int SolveLinearEquation1(const matrix<double> &A,
                           const std::vector<double> &b,
                           std::vector<double> &x)
  {
    // Matrix is square, v has correct size

    matrix<double> LU;
    vector<int> index;

    // LU-Zerlegung
    LUDecompositionPacked(A, LU, index, true);
    // Lösen von L*U*x=b
    x = LUSolve(LU, index, b);
    return 0;
  }

#define FNAME "SolveLinearEquation"
  std::vector<double> SolveLinearEquation(const matrix<double> &m,
                                          const std::vector<double> &b)
  {
    std::vector<double> res(m.cols());

    if ((int)b.size() != m.rows())
      throw std::length_error("matrix format error");

    if (m.cols() > m.rows())
      throw std::length_error("matrix format error");

    // Ausgleichsrechnung bei überbestimmten Gleichungsystemen
    if (m.cols() < m.rows())
      {
        matrix<double> a = !m * m; // m^T * m
        std::vector<double> bb(m.cols());
        for (int i = 0; i < m.cols(); ++i)
          {
            bb[i] = 0;
            for (int k = 0; k < m.rows(); ++k)
              bb[i] += m[k][i] * b[k];
          }
        SolveLinearEquation1(a, bb, res);
      }
    else
      {
        SolveLinearEquation1(m, b, res);
      }

    return res;
  }
#undef FNAME
} // namespace ice
