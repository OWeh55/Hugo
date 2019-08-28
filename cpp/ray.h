#ifndef RAY_H
#define RAY_H

#include "point2d.h"
#include "trig.h"

class ray:public point2d
{
public:
    ray():dir(0) {}
    ray(point2d punkt,double dirp):point2d(punkt),dir(dirp) {}
    ray(double xp,double yp,double dirp):point2d(xp,yp),dir(dirp) {}

    virtual double & Dir() {
        return dir;
    }
    virtual const double & Dir() const {
        return dir;
    }

    virtual vector2d DirVec() const {
        return vector2d(dir);
    }
    virtual ray DirInverse() const
    {
        return ray(point2d(*this),normal(dir+M_PI));
    }

    friend ray operator+(const ray &p,const vector2d &r);
    friend ray operator+(const vector2d &r,const ray &p);

protected:
    double dir;
};

point2d Intersection(const ray &s1,const ray &s2);
point2d Intersection(const ray &s1,const ray &s2,double &l1,double &l2);
#endif
