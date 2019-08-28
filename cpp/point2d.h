#ifndef POINT2D_H
#define POINT2D_H

#include <cmath>
#include <iostream>

using namespace std;

class vector2d;

class point2d
{
public:
    double x,y;

    point2d():x(0),y(0) {}
    point2d(double xp,double yp):x(xp),y(yp) {}

    virtual ~point2d() {}

    virtual double & X() {
        return x;
    }
    virtual double & Y() {
        return y;
    }

    virtual const double & X() const {
        return x;
    }
    virtual const double & Y() const {
        return y;
    }

    friend point2d operator+(const point2d &p,const vector2d &r);
    friend point2d operator+(const vector2d &r,const point2d &p);

    friend point2d operator-(const point2d &p,const vector2d &r);
    friend vector2d operator-(const point2d &p,const point2d &r);

    friend ostream & operator <<(ostream &os,const point2d &o);

    virtual point2d rot0(double fi) const;
    virtual point2d rot(const point2d &center,double fi) const;
};
#endif
