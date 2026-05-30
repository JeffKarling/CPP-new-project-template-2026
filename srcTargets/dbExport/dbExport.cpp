// Copyright (c) 2026 template2026 Contributors
// Licensed under the MIT License. See LICENSE file in the project root for details.

#include <dbExport/dbExport.hpp>
#include <databaseManagerInterface/itemDatabase.pb.h>
#include <fstream>
#include <iostream>

namespace template2026 {

    void DbExport::print_database(const std::filesystem::path& db_path) noexcept {
        template2026::ItemDatabase db;
        std::ifstream input(db_path.string(), std::ios::in | std::ios::binary);
        if (!input.is_open()) {
            std::cerr << "[EXPORT ERROR] Failed to open database file: " << db_path.string() << "\n";
            return;
        }
        if (db.ParseFromIstream(&input) == false) {
            std::cerr << "[EXPORT ERROR] Failed to parse database binary.\n";
            return;
        }

        std::cout << "Items Database Snapshot:\n";
        std::cout << "----------------------------------------\n";
        for (auto i = 0; i < db.items_size(); ++i) {
            auto const& item = db.items(i);
            std::cout << "  Item ID:   " << item.id() << "\n";
            std::cout << "  Name:      " << item.name() << "\n";
            std::cout << "  Value:     " << item.value() << "\n";
            std::cout << "----------------------------------------\n";
        }
    }

} // namespace template2026
