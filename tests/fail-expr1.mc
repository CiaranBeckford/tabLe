int a;

def int foo<int c, bool d>
{
  int dd;
  bool e;
  a + c;
  c - a;
  a * 3;
  c / 2;
  d + a; ~ Error: bool + int ~
  return 0;
}

def int main<>
{
  return 0;
}
