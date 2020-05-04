def int foo<> {return 0;}

def int bar<> {
  int a;
  void b; ~ Error: illegal void local b ~
  bool c;

  return 0;
}

def int main<>
{
  return 0;
}
