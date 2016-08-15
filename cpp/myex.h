#ifndef _MYEX_H
#define _MYEX_H

class myex
{
private:
  const string msg;
public:
  myex(const string &m): msg(m) {}
  myex(const char *m): msg(m) {}
  string Msg() const
  {
    return msg;
  }
};

#endif
