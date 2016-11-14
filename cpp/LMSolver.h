#ifndef LMSOLVER_H
#define LMSOLVER_H
// C
#include <limits.h>
#include <float.h>
#include <cmath>
// C++
#include <stdexcept>
#include <vector>
// ice
#include "matrixtemplate.h"

  class LMFunctor
  {
  public:
    virtual int operator()(const std::vector<double>& x,
                           std::vector<double>& result) const = 0;
    virtual int getDimension() const = 0;
  };
  
  class LMSolver
  {
  public:
    LMSolver(const LMFunctor& fn): fn(fn), functionDim(fn.getDimension()), stop(0)
    {
    }

    void solve(std::vector<double>& x) throw(std::logic_error);
    void solve(std::vector<double>& x, const std::vector<int>& select)
      throw(std::logic_error);
    
    int getNIterations() const
    {
      return nIterations;
    }

    int getInfo() const
    {
      return stop;
    }

    double getErrorValue() const
    {
      return errorValue;
    }

    void setStopConditions(double ftol, double xtol, double gtolp, int maxIter)
    {
      if (ftol > 0)
        ftol2 = ftol * ftol;
      if (xtol > 0)
        xtol2 = xtol * xtol;
      if (gtolp > 0)
        gtol = gtolp;
      if (maxIter > 0)
        maxIterations = maxIter;
    }

  private:
    bool getJacobian(const std::vector<double>& x,
                     const std::vector<int>& select,
                     const std::vector<double>& fv0,
                     matrix<double>& jm) const;

    const LMFunctor& fn;
    int functionDim;
    int nVars;

    // parameters for stop of iteration
    double ftol2 = 1e-16; // actual and predicted reductions < ftol
    double xtol2 = 1e-16; // step width between two consecutive iterates < xtol
    double gtol = 1e-5;   // cosine of the between FVEC and partial derivatives < gtol
    int maxIterations = INT_MAX; // maximum number of iterations

    // stepwidth for calculation of jacobi matrix
    double eps = DBL_EPSILON * 1e4;

    // additional results
    int nIterations = -1;    // number of iterations
    int stop = -1;           // stop condition
    double errorValue = -1;  // remaining error
  };

#endif
