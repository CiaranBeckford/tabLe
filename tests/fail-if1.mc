def int main<>
{
  if (true) {}
  if (false) {} else {}
  if (42) {} ~ Error: non-bool predicate ~
  return 0;
}
