def int main<>
{
  if (true) {
    42;
  } else {
    bar; ~ Error: undeclared variable ~
  }
  return 0;
}