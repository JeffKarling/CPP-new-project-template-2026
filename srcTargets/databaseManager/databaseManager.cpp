// Copyright (c) 2026 template2026 Contributors
// Licensed under the MIT License. See LICENSE file in the project root for details.

#include <databaseManager/databaseManager.hpp>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <ranges>

namespace template2026 {

    [[nodiscard]] auto DatabaseManager::get_instance() noexcept -> DatabaseManager& {
        static DatabaseManager instance;
        return instance;
    }

    [[nodiscard]] auto DatabaseManager::initialize(const std::filesystem::path& db_path) noexcept -> bool {
        std::lock_guard<std::mutex> const lock(_dbMutex);
        _dbPath = db_path;
        return load();
    }

    [[nodiscard]]
    auto DatabaseManager::add_item(const template2026::Item& item) noexcept -> bool {
        auto const lock{std::lock_guard<std::mutex>(_dbMutex)};
        
        // Update existing if ID matches
        for (auto i = 0; i < _database.items_size(); ++i) {
            if (_database.items(i).id() == item.id()) {
                *(_database.mutable_items(i)) = item;
                return true;
            }
        }
        
        // Otherwise add new item
        *(_database.add_items()) = item;
        return true;
    }

    [[nodiscard]] auto DatabaseManager::save() const noexcept -> bool {
        return save_to(_dbPath);
    }

    [[nodiscard]] auto DatabaseManager::save_to(const std::filesystem::path& path) const noexcept -> bool {
        if (path.empty()) {
            return false;
        }
        
        std::ofstream out(path.string(), std::ios::out | std::ios::binary | std::ios::trunc);
        if (not out.is_open()) {
            std::cerr << "[DATABASE ERROR] Failed to open " << path.string() << " for writing.\n";
            return false;
        }
        if (_database.SerializeToOstream(&out) == false) {
            std::cerr << "[DATABASE ERROR] Failed to serialize database to binary.\n";
            return false;
        }
        return true;
    }

    [[nodiscard]] auto DatabaseManager::load() noexcept -> bool {
        if (_dbPath.empty()) {
            return false;
        }
        
        std::ifstream input(_dbPath.string(), std::ios::in | std::ios::binary);
        if (!input.is_open()) {
            _database.Clear();
            return true;
        }
        if (_database.ParseFromIstream(&input) == false) {
            std::cerr << "[DATABASE ERROR] Failed to parse binary database from " << _dbPath.string() << ".\n";
            _database.Clear();
            return false;
        }
        return true;
    }

    [[nodiscard]] auto DatabaseManager::get_all_items() const noexcept -> std::vector<template2026::Item> {
        auto const lock {std::lock_guard(_dbMutex)};
        return std::ranges::to<std::vector<template2026::Item>>(_database.items());
    }

} // namespace template2026
