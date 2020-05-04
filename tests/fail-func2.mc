def int foo<int a, bool b, int c> {return 0;}

def int bar<int a, bool b, int a> {return 0;} ~ Error: duplicate formal a in bar ~

def int main<>
{
  return 0;
}
