def int a;
float b;

def int foo<int c, float d>
{
  int d;
  float e;
  b + a; ~ Error: float + int ~
  return d;
}

def int main<>
{
  return 0;
}
