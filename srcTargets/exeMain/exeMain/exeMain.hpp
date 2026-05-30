#pragma once

#include <vector>
#include <filesystem>

[[nodiscard]] auto read_config_file(const std::filesystem::path& config_path) -> std::vector<std::filesystem::path>;
