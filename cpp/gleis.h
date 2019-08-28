#ifndef GLEIS_H
#define GLEIS_H

#include "bogen.h"

class gleis {
public:
    gleis() {};
    gleis(const ray &startp):start(startp) {};
    gleis(double x,double y,double d):start(x,y,d) {};

    virtual ~gleis() {};

    virtual void clear() {
        gleise.clear();
    }

    virtual void setStart(const ray &stp) {
        start=stp;
    }
    virtual void setStart(double x,double y,double d) {
        start=ray(x,y,d);
    }

    virtual const ray & getStart() const {
        return start;
    }

    virtual void Append(double len,double fi)
    {
        gleise.push_back(Bogen(End(),len,fi));
    }

    virtual void Append(const point2d & endp)
    {
        gleise.push_back(Bogen(End(),endp));
    }

    virtual void Append(const Bogen &b)
    {
        gleise.push_back(b);
    }

    virtual void push_back(const Bogen &b) {
        gleise.push_back(b);
    }
    virtual void pop_back() {
        gleise.pop_back();
    }

    virtual ray End() const
    {
        if (gleise.empty())
            return start;
        return gleise.back().End();
    }

    virtual double Len() const;

    virtual void Draw(int v1,int v2,Image &img) const;
    virtual void Draw(int v,Image &img) const;

    virtual void Draw(int v1,int v2,Image &img,double xi,double yi,double xa,double ya) const;
    virtual void Draw(int v,Image &img,double xi,double yi,double xa,double ya) const;

    virtual int size() const {
        return gleise.size();
    }

    virtual void GetLimits(double &xi,double &yi, double &xa, double &ya,
                           bool cont=false) const;

    virtual Bogen & operator[](int i) {
        return gleise[i];
    }
    virtual const Bogen & operator[](int i) const {
        return gleise[i];
    }

    virtual void Divide(int i);

private:
    ray start;
    vector<Bogen> gleise;
};

void setLinearHeight(gleis &g,double h1,double h2);
#endif
