// Copyright (c) 2026 template2026 Contributors
// Licensed under the MIT License. See LICENSE file in the project root for details.

#include "databaseHelper.hpp"
#include <fstream>
#include <system_error>

namespace template2026::detail {

    [[nodiscard]] bool is_writable_path(const std::filesystem::path& path) noexcept {
        if (path.empty()) {
            return false;
        }
        auto parent = path.parent_path();
        if (parent.empty()) {
            parent = ".";
        }
        std::error_code ec;
        if (!std::filesystem::exists(parent, ec)) {
            return false;
        }
        return (std::filesystem::status(parent, ec).permissions() & std::filesystem::perms::owner_write) != std::filesystem::perms::none;
    }

    [[nodiscard]] bool file_exists_and_is_readable(const std::filesystem::path& path) noexcept {
        if (path.empty()) {
            return false;
        }
        std::error_code ec;
        if (!std::filesystem::exists(path, ec) || std::filesystem::is_directory(path, ec)) {
            return false;
        }
        std::ifstream file(path.string(), std::ios::in | std::ios::binary);
        return file.is_open();
    }

} // namespace template2026::detail
