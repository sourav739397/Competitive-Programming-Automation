#include <bits/stdc++.h>
using namespace std;
#define uid(a, b) uniform_int_distribution<int>(a, b)(rng)
mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());




int main() {
    cout << 1 << "\n";
    int n = uid(1, 10), m = uid(1, n);
    cout << n << " " << m << "\n";

    for (int i = 0; i < n; ++i) {
        cout << uid(1, 10) << " \n"[i == n - 1];
    }

    for (int i = 0; i < m; ++i) {
        cout << uid(1, 10) << " \n"[i == m - 1];
    }

    return 0;
}
