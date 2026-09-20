#include <fmt/core.h>
#include <nlohmann/json.hpp>

int main() {
    nlohmann::json j = {
        {"name", "Conan"},
        {"language", "Python"},
        {"stars", 9000}
    };

    fmt::print("Hello, {}!\n", j["name"].get<std::string>());
    fmt::print("{}\n", j.dump(2));
    return 0;
}
