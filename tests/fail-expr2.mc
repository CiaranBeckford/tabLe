int a;
bool b;

def int foo<int c, bool d>
{
  int d;
  bool e;
  b + a; ~ Error: bool + int ~
  return d;
}

def int main<>
{
  return 0;
}
