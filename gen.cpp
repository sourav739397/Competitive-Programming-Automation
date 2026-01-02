#include "testlib.h"

int main(int argc, char* argv[]) {
  registerGen(argc, argv, 1);
  println(rnd.next(1, 10)); /* Random number in the range [1,10]. */
  println(rnd.next("[a-zA-Z0-9]{1,1000}")); /* Random word of length [1,1000]. */
}