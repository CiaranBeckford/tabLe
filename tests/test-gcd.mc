~def int gcd<int a, int b> {
  while (a != b) {
    if (a > b) a = a - b;
    else b = b - a;
  }
  return a;
}~

def int lolo<int a, int b>{
  ~if (a+b==13) return a;
  else return b;
  return 22;~
}
def int main<>
{
  ~
  print<gcd<2,14>>;
  print<gcd<3,15>>;
  print<gcd<99,121>>;~
  int x;
  x = lolo<8,5>;
  print<x>;
  return 0;
}
