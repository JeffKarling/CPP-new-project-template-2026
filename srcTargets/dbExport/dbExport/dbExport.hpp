// Copyright (c) 2026 template2026 Contributors
// Licensed under the MIT License. See LICENSE file in the project root for details.

#pragma once

#include <filesystem>

namespace template2026 {

    class DbExport {
    public:
        // Reads database from disk and summary-prints its contents to std::cout
        static void print_database(const std::filesystem::path& db_path) noexcept;
    };

} // namespace template2026
