def float myfloat<>
{
  float k;
  return k;
}

def int main<>{
  int i;

  i = myfloat<>; ~ Fail: assigning a float to an integer ~
  return 0;
}
