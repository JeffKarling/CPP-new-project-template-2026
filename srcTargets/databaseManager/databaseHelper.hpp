// Copyright (c) 2026 template2026 Contributors
// Licensed under the MIT License. See LICENSE file in the project root for details.

#pragma once

#include <filesystem>

namespace template2026::detail {

    // Validates if a directory path is writable.
    [[nodiscard]] bool is_writable_path(const std::filesystem::path& path) noexcept;

    // Checks if a file exists and is readable.
    [[nodiscard]] bool file_exists_and_is_readable(const std::filesystem::path& path) noexcept;

} // namespace template2026::detail
