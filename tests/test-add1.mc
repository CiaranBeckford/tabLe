def int add<int x, int y>
{
  return x + y;
}

def int main<>
{
  int sum;
  sum  = add<17, 25>;
  print<sum>;
  return 0;
}
