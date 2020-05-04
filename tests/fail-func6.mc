def int foo<int a, bool b>
{
  return 0;
}

def int main<>
{
  foo<42, true>;
  foo<42>; ~ Wrong number of arguments ~
  return 0;
}
