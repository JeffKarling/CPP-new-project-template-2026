// Copyright (c) 2026 template2026 Contributors
// Licensed under the MIT License. See LICENSE file in the project root for details.

#pragma once

#include <string>
#include <vector>
#include <mutex>
#include <filesystem>
#include <databaseManagerInterface/itemDatabase.pb.h>

namespace template2026 {

    class DatabaseManager {
    public:
        [[nodiscard]] static auto get_instance() noexcept -> DatabaseManager&;

        [[nodiscard]] auto initialize(const std::filesystem::path& db_path) noexcept -> bool;
        
        [[nodiscard]] auto add_item(const template2026::Item& item) noexcept -> bool;
        
        [[nodiscard]] auto save() const noexcept -> bool;
        
        [[nodiscard]] auto save_to(const std::filesystem::path& path) const noexcept -> bool;
        
        [[nodiscard]] auto load() noexcept -> bool;
        
        [[nodiscard]] auto get_all_items() const noexcept -> std::vector<template2026::Item>;

    private:
        DatabaseManager() = default;
        ~DatabaseManager() = default;
        DatabaseManager(const DatabaseManager&) = delete;
        auto operator=(const DatabaseManager&) -> DatabaseManager& = delete;

        std::filesystem::path _dbPath;
        template2026::ItemDatabase _database;
        mutable std::mutex _dbMutex;
    };
} // namespace template2026
