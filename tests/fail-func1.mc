def int foo<> {return 0;}

def int bar<> {return 0;}
def int baz<> {return 0;}

def float bar<> {return 3.0;} ~ Error: duplicate function bar ~

def int main<>
{
  return 0;
}
