def int main<>
{
  float mean_res;
  float variance_res;
  float stdev_res;
  float min_res;
  float max_res;

  float arrays x;
  x = [2.0, 4.0, 6.22, 4.5, 6.0];

  mean_res = mean<x>;
  prints<"Mean: ">;
  printf<mean_res>;

  variance_res = variance<x>;
  prints<"Variance: ">;
  printf<variance_res>;

  stdev_res = stdev<x>;
  prints<"stdev: ">;
  printf<stdev_res>;

  min_res = min<x>;
  prints<"Min: ">;
  printf<min_res>;

  max_res = max<x>;
  prints<"Max: ">;
  printf<max_res>;

  return 0;
}
