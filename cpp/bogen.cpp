#include <image_nonvis.h>
#include <cmath>
#include <iostream>

#include "trig.h"

#include "bogen.h"

using namespace std;

Bogen::Bogen(const ray &startp,
             const point2d &endp,
             double h1p, double gradp):start(startp),h1(h1p),grad(gradp)
{
    //  cout << startp << " -> " << endp << endl;
    //  double fi2=normal(atan2(endp.y-startp.y,endp.x-startp.x)-startp.dir);
    vector2d diff=endp-startp;
    double fi2=normal(diff.Phi()-startp.Dir());
    double d=diff.Len();
    //  double d=sqrt(d2);
    //  cout << "fi2: " << fi2  << " d: " << d << endl;
    //  cout << "sinc(fi2): " << sinc(fi2) << endl;
    len = d/sinc(fi2);
    fi = fi2*2;
    //  cout << len << "," << fi <<endl;
    //  cout << endp << " " << End() << endl;
}

ray Bogen::End() const
{
    return ray(start+vector2d(len*sinc(fi),len*cosc(fi)).rot0(start.Dir()),
               start.Dir()+fi);
}

Bogen Bogen::Inverse() const
{
    return Bogen(End(),normal(End().Dir()+M_PI),len,normal(-fi),H2(),-grad);
}

Bogen Bogen::Shift(double d,double dh) const
{
    ray newstart=start+ d * start.DirVec().right();
    ray newend=End() + d * End().DirVec().right();
    Bogen res(newstart,newend,h1+dh,grad);
    return res;
}

void Bogen::GetLimits(double &xi,double &yi, double &xa, double &ya,
                      bool cont) const
{
    if (!cont)
    {
        xi=start.x-len;
        yi=start.y-len;
        xa=start.x+len;
        ya=start.y+len;
    }
    else
    {
        if (start.x-len<xi) xi=start.x-len;
        if (start.x+len>xa) xa=start.x+len;
        if (start.y-len<yi) yi=start.y-len;
        if (start.y+len>ya) ya=start.y+len;
    }

    double xx=End().x;
    double yy=End().y;

    if (xx-len<xi) xi=xx-len;
    if (xx+len>xa) xa=xx+len;
    if (yy-len<yi) yi=yy-len;
    if (yy+len>ya) ya=yy+len;
}

point2d Bogen::Center() const
{
    point2d center(0,0);
    double rad=Rad();
    if (rad != 0.0)
        center=start+rad*vector2d(start.Dir()+M_PI/2);
    return center;
}

void Bogen::Draw(int val,Image &img) const
{
    Draw(val,img,0,0,img->xsize,img->ysize);
}

void Bogen::Draw(int val,Image &img,
                 double xi,double yi,double xa,double ya) const
{
    double fx=img->xsize/(xa-xi);
    double fy=img->ysize/(ya-yi);

    int step=RoundInt(len*10);
    if (step>2000) step=2000;

    double rad=Rad();

    if (rad<0)
    {
        Line((start.x-xi)*fx,(start.y-yi)*fy,(End().x-xi)*fx,(End().y-yi)*fy,val,img);
    }
    else
    {
        point2d mitte=Center();
        vector2d radv=start-mitte;
        for (int i=0; i<step; i++)
        {
            point2d punkt=mitte+radv;
            int xii=RoundInt((punkt.x-xi)*fx);
            int yii=RoundInt((punkt.y-yi)*fy);
// cout << xi << " " << yi << " " << xa <<" " << ya << " ";
// cout  << punkt.x << " " << punkt.y << " "  << xii << " " << yii << endl;
            if (Inside(img,xii,yii))
                PutVal(img,xii,yii,val);
            radv=radv.rot0(fi/step);
        }
    }
}
