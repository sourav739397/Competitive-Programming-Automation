#include <bits/stdc++.h>

template<typename A, typename B>
std::ostream& operator<<(std::ostream& os, const std::pair<A, B>& p) {
    return os << '(' << p.first << ", " << p.second << ')';
}

template<typename T_container, typename T = typename std::enable_if<
    !std::is_same<T_container, std::string>::value,
    typename T_container::value_type
>::type>
std::ostream& operator<<(std::ostream& os, const T_container& v) {
    os << '{';
    std::string sep;
    for (const T& x : v) os << sep << x, sep = ", ";
    return os << '}';
}

void dbg_out() { std::cerr << " |\n"; }

template<typename Head, typename... Tail>
void dbg_out(Head H, Tail... T) {
    std::cerr << " | " << "\033[31m" << H << "\033[0m";
    dbg_out(T...);
}

void err_prefix(const std::string& func, int line, const std::string& args) {
std::cerr 
    << "\033[0;31m\u001b[1mDEBUG\033[0m"
    << " | "
    << "\u001b[34m" << func << "\033[0m"
    << ":"
    << "\u001b[34m" << line << "\033[0m"
    << " >> [" << args << "] =";

}

#define dbg(...) err_prefix(__func__, __LINE__, #__VA_ARGS__), dbg_out(__VA_ARGS__)
