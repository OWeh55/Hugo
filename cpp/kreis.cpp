#include <image_nonvis.h>
#include <cmath>
#include <iostream>

using namespace std;

#include "bogen.h"
#include "gleis.h"

Image img;

class GleisFehlerX:public LMFunctor
{
protected:
    gleis &g;
    v2d endp;
    double enddir;
    Vector &len;
    Vector &fi;

    double fidiff(double fi1,double fi2) const
    {
        double diff=fi1-fi2;
        while (diff<180) diff+=360;
        while (diff>180) diff-=360;
        return diff;
    }

public:
    GleisFehlerX(gleis &gp,v2d endpp,double enddirp,Vector &lenp,Vector &fip):
        g(gp),endp(endpp),enddir(enddirp),len(lenp),fi(fip)
    {
        len.clear();
        fi.clear();
        for (unsigned int i=0; i<g.size(); i++)
        {
//	cout << i << endl;
            len.Append(g.Len(i));
            fi.Append(g.Fi(i));
        }
    };
};

class GleisFehler1:public GleisFehlerX
{
public:
    GleisFehler1(gleis &gp,v2d endpp,double enddirp,Vector &lenp,Vector &fip):
        GleisFehlerX(gp,endpp,enddirp,lenp,fip) {};

    virtual int operator()(Vector &res) const
    {
        g.clear();
        for (unsigned int i=0; i<len.size(); i++)
        {
            g.Append(fabs(len[i]),fi[i]);
        }

//      g.Draw(2,4,img);
//      GetChar();

        unsigned int ind=0;

        res[ind++]=fidiff(0,fi[0]);
        for (unsigned int i=1; i<len.size(); i++)
        {
            res[ind++]=len[i]-len[i-1];
            res[ind++]=fidiff(fi[i],fi[i-1]);
        }

        res[ind++]=fidiff(fi[len.size()-1],0);

        res[ind++]=(g.endpos().x-endp.x)*1000;
        res[ind++]=(g.endpos().y-endp.y)*1000;
        res[ind++]=fidiff(g.enddir(),enddir)*10000;

        cout << len << endl;
        cout << fi << endl;

        return OK;
    }
    virtual int funcdim() const {
        return 2*g.size()+1+3;
    }
};

int main(int argc,char *argv[])
{
    Print("Gleise");
    img=Image(1024,767,255);
    Image bg(1024,767,255);
    ClearImg(img);
    SetImg(bg,255);
    Show(OVERLAY,bg,img);

    gleis k(100,100,0);

    for (int i=0; i<10; i++)
    {
        k.Append(80,8);
    }

    k.Draw(2,3,img);

    Vector l;
    Vector f;

    GleisFehler1 ff(k,v2d(600,600),90,l,f);

    vector<double*> pz;
    for (unsigned int i=0; i<k.size(); i++)
    {
        pz.push_back(&l[i]);
        pz.push_back(&f[i]);
    }


    int inumber;
    int info=LMDif(pz,ff,1000,inumber);

    cout << info << " : "<< inumber << endl;

    k.Draw(2,1,img);

    Enter("Fertig");
    return OK;
}
