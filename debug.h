#pragma once

#ifdef LOCAL

#include <bits/stdc++.h>

template <typename A, typename B>
std::ostream &operator<<(std::ostream &os, const std::pair<A, B> &p) {
    return os << '(' << p.first << ", " << p.second << ')';
}

template <typename T_container,
          typename T = typename std::enable_if<
              !std::is_same<T_container, std::string>::value,
              typename T_container::value_type>::type>
std::ostream &operator<<(std::ostream &os, const T_container &v) {
    os << '{';
    std::string sep;
    for (const T &x : v)
        os << sep << x, sep = ", ";
    return os << '}';
}

inline void dbg_out() {
    std::cerr << " |\n";
}

template <typename Head, typename... Tail>
inline void dbg_out(Head H, Tail... T) {
    std::cerr << " | \033[31m" << H << "\033[0m";
    dbg_out(T...);
}

inline void err_prefix(const std::string &func, int line,
                       const std::string &args) {
    std::cerr
        << "\033[1;31mDEBUG\033[0m"
        << " | "
        << "\033[34m" << func << "\033[0m"
        << ":"
        << "\033[34m" << line << "\033[0m"
        << ":["
        << "\033[34m" << args << "\033[0m"
        << "] =>";
}

#define dbg(...) \
    err_prefix(__func__, __LINE__, #__VA_ARGS__), dbg_out(__VA_ARGS__)

#else

#define dbg(...) 42

#endif