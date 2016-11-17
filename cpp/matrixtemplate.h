#ifndef MATRIX_TEMPLATE_H
#define MATRIX_TEMPLATE_H

#include <stdexcept>
#include <iostream>
#include <iomanip>
#include <vector>
#include <initializer_list>

template<typename T>
class matrix
{
private:
  int nColumns;
  int nRows;
  T *data;
  
public:
  matrix(): nColumns(0), nRows(0), data(nullptr) {}
  matrix(int r, int c, int init = -1):
    nColumns(c), nRows(r), data(new T[r * c])
  {
    initMatrix(init);
  }
  
  void initMatrix(int mode)
  {
    if (mode >= 0)
      {
        for (int i = 0; i < nColumns * nRows; i++)
          data[i] = 0.0;
        if (mode == 1)
          for (int i = 0; i < nColumns * nRows; i += nColumns + 1)
            data[i] = 1.0;
      }
  }

  matrix(const matrix &m): nColumns(m.nColumns), nRows(m.nRows)
  {
    data = new T[nColumns * nRows];
    
    for (int i = 0; i < nRows * nColumns; i++)
      data[i] = m.data[i];
  }
  
  matrix(int r, int c, const std::initializer_list<T> &l):
    nColumns(c), nRows(r), data(new T[r * c])
  {
    int i = 0;
    for (auto p = l.begin(); p != l.end(); ++p)
      data[i++] = *p;
  }
  
  ~matrix()
  {
    delete [] data;
  };
  
  void resize(int r, int c)
  {
    matrix<T> newmat(r, c);
    if (data != nullptr)
      {
        int nr = std::min(r, nRows);
        int nc = std::min(c, nColumns);
        for (int r = 0; r < nr; ++r)
          for (int c = 0; c < nc; ++c)
            newmat[r][c] = (*this)[r][c];
      }
    swap(newmat, *this);
  }
  
  void init(int r, int c, int init = -1)
  {
    delete [] data;
    nColumns = c;
    nRows = r;
    data = new T[r * c];
    initMatrix(init);
  }
  
  void set(T value)
  {
    for (int i = 0; i < nRows * nColumns; i++)
      data[i] = value;
  }

  friend void swap(matrix &m1, matrix &m2)
  {
    std::swap(m1.nRows, m2.nRows);
    std::swap(m1.nColumns, m2.nColumns);
    std::swap(m1.data, m2.data);
  }

  matrix<T> &operator =(matrix s)
  {
    swap(*this, s);
    return *this;
  }

  const T *getData() const
  {
    return data;
  }

  T *getData()
  {
    return data;
  }

  int cols() const
  {
    return nColumns;
  }
  int rows() const
  {
    return nRows;
  }

  matrix<T> operator()(int i1, int j1, int i2, int j2)
  {
    int newrows = i2 - i1 + 1;
    int newcols = j2 - j1 + 1;
    matrix<double> tm(newrows, newcols);
    for (int i = 0; i < newrows; ++i)
      for (int j = 0; j < newcols; ++j)
        tm[i][j] = data[(i + i1) * nColumns + (j + j1)];
    return tm;
  }
  //*************************************************************

  matrix<T> operator!() const
  {
    matrix<T> res(nColumns, nRows);

    for (int r = 0; r < nRows; ++r)
      for (int c = 0; c < nColumns; ++c)
        {
          res[c][r] = (*this)[r][c];
        }

    return res;
  }

  friend matrix<T> operator+(const matrix<T> &lhs,
                             const matrix<T> &rhs)
  {
    matrix<T> res(lhs);
    res += rhs;
    return res;
  }
  
  matrix<T> &operator +=(const matrix<T> &rhs)
  {
    for (int i = 0; i < nColumns * nRows; i++)
      data[i] += rhs.data[i];
    return *this;
  }
  
  friend matrix<T> operator-(const matrix<T> &lhs,
                             const matrix<T> &rhs)
  {
    matrix<T> res(lhs);
    res -= rhs;
    return res;
  }

  matrix<T> &operator -=(const matrix<T> &rhs)
  {
    for (int i = 0; i < nColumns * nRows; i++)
      data[i] -= rhs.data[i];

    return *this;
  }

  matrix<T> operator-() const
  {
    matrix<T> res(nRows, nColumns);

    for (int i = 0; i < nColumns * nRows; i++)
      res.data[i] = -data[i];

    return res;
  }

  matrix<T> operator*(T v) const
  {
    matrix<T> res(nRows, nColumns);

    for (int i = 0; i < nColumns * nRows; i++)
      res.data[i] = data[i] * v;

    return res;
  }

#define FNAME "matrix<T>::operator*"
  friend matrix<T> operator*(const matrix<T> &lhs,
                             const matrix<T> &rhs)
  {
    matrix<T> res(lhs.nRows, rhs.nColumns);
    
    if (lhs.nColumns != rhs.nRows)
      {
        throw std::length_error("wrong dimension in matrix multiplication");
      }

    for (int i = 0; i < lhs.nRows; i++)
      for (int j = 0; j < rhs.nColumns; j++)
        {
          double sum = 0;

          for (int k = 0; k < lhs.nColumns; k++)
            sum += lhs.data[i * lhs.nColumns + k] *
                   rhs.data[k * rhs.nColumns + j];

          res[i][j] = sum;
        }

    return res;
  }

  friend std::vector<T> operator*(const std::vector<T> &lhs,
                                  const matrix<T> &rhs)
  {
    std::vector<T> res(rhs.nColumns);

    if ((int)lhs.size() != rhs.nRows)
      {
        throw std::length_error("wrong dimension in matrix multiplication");
      }

    for (int j = 0; j < rhs.nColumns; ++j)
      {
        double sum = 0;
        for (int k = 0; k < rhs.nRows; ++k)
          sum += lhs[k] * rhs.data[k * rhs.nColumns + j];

        res[j] = sum;
      }

    return res;
  }

  friend std::vector<T> operator*(const matrix<T> &lhs,
                                  const std::vector<T> &rhs)
  {
    std::vector<T> res(lhs.nRows);

    if (lhs.nColumns != (int)rhs.size())
      {
        throw std::length_error("wrong dimension in matrix multiplication");
      }

    for (int i = 0; i < lhs.nRows; ++i)
      {
        double sum = 0;

        for (int k = 0; k < lhs.nColumns; ++k)
          sum += lhs.data[i * lhs.nColumns + k] * rhs[k];

        res[i] = sum;
      }

    return res;
  }
#undef FNAME

  //*******************************************************************

  template<typename T2>
  matrix<T> &operator *= (T2 d)
  {
    for (int i = 0; i < nColumns * nRows; i++)
      data[i] *= d;

    return *this;
  }

  template<typename T2>
  friend matrix<T> operator*(const matrix<T> &lhs,
                             T2 rhs)
  {
    matrix<T> res(lhs);
    res *= rhs;
    return res;
  }

  template<typename T2>
  friend matrix<T> operator*(T2 lhs,
                             const matrix<T> &rhs)
  {
    return rhs * lhs;
  }

  //*****************************************************

  T *operator[](int i)
  {
    return &data[i * nColumns];
  }
  const T *operator[](int i) const
  {
    return &data[i * nColumns];
  }
};
#endif
