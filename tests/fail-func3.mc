def int foo<int a, bool b, int c> {return 0;}

def int bar<int a, void b, int c> {return 0;} ~ Error: illegal void formal b ~

def int main<>
{
  return 0;
}
