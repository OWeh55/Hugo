#ifndef VECTOR2D_H
#define VECTOR2D_H

#include <cmath>
#include <iostream>

using namespace std;

class point2d;

class vector2d
{
public:
    vector2d():x(0),y(0) {}
    vector2d(double xp,double yp):x(xp),y(yp) {}
    vector2d(double fi)
    {
        x=cos(fi);
        y=sin(fi);
    }

    virtual ~vector2d() {}

    virtual double & X() {
        return x;
    }
    virtual const double & X() const {
        return x;
    }

    virtual double & Y() {
        return y;
    }
    virtual const double & Y() const {
        return y;
    }

    virtual double Len() const;

    virtual vector2d operator +(const vector2d &b) const
    {
        return vector2d(x+b.x,y+b.y);
    }

    virtual vector2d operator -(const vector2d &b) const
    {
        return vector2d(x-b.x,y-b.y);
    }

    virtual vector2d operator *(double f) const
    {
        return vector2d(f*x,f*y);
    }

    friend ostream & operator <<(ostream &os,const vector2d &o);

    friend vector2d operator*(double f,const vector2d &b);
    friend point2d operator+(const point2d &p,const vector2d &r);
    friend point2d operator+(const vector2d &r,const point2d &p);
    friend point2d operator-(const point2d &p,const vector2d &r);

    virtual void Normalize() ;
    virtual double Phi() const {
        return atan2(y,x);
    }

    virtual vector2d rot0(double fi) const;
    virtual vector2d rot(const vector2d &center,double fi) const;

    virtual vector2d right() const {
        vector2d res(y,-x);
        res.Normalize();
        return res;
    }

    double x,y;
};

#endif
