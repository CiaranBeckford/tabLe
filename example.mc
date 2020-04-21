int a;
int b;

int gcd(int a, int b) {
  while (a != b) {
    if (b < a) a = a - b;
    else b = b - a;
  }
  return a;
}

int main() {
  int x;
  int y;
  int z;
  a = 18;
  b = 9;
  x = 2;
  y = 14;
  z = 9%2;
  print(7/5); ~div~
  print(3*4); ~mult~
  print(z); ~mod~



  print(gcd(x,y));
  print(gcd(3,15));
  print(gcd(99,121));
  print(gcd(a,b));
  return 0;
}
