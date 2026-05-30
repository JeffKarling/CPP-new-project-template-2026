// Copyright (c) 2026 template2026 Contributors
// Licensed under the MIT License. See LICENSE file in the project root for details.

#include <iostream>
#include <vector>
#include <string>
#include <filesystem>
#include <databaseManager/databaseManager.hpp>
#include <tbbAlgos/tbbAlgos.hpp>
#include <dbExport/dbExport.hpp>

int main() {
    std::cout << "========================================\n";
    std::cout << "       template2026 Showcase App        \n";
    std::cout << "========================================\n\n";

    // 1. Initialize Database Manager
    std::filesystem::path const db_path = "template_database.pb";
    std::error_code ec;
    std::filesystem::remove(db_path, ec);

    std::cout << "[PROTOBUF] Initializing database at: " << db_path.string() << "\n";
    if (template2026::DatabaseManager::get_instance().initialize(db_path) == false) {
        std::cerr << "[ERROR] Failed to initialize DatabaseManager.\n";
        return 1;
    }

    // 2. Prepare some values and double them in parallel using TBB
    std::vector<int> numbers = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120};
    std::cout << "[TBB] Doubling values in parallel using TBB parallel_for_each...\n";
    template2026::TbbAlgos::parallel_double(numbers);

    // 3. Add transformed values into the Protobuf database
    std::cout << "[PROTOBUF] Populating database with items...\n";
    for (std::size_t i = 0; i < numbers.size(); ++i) {
        template2026::Item item;
        item.set_id("ITEM_" + std::to_string(i + 1));
        item.set_name("Showcase Item " + std::to_string(i + 1));
        item.set_value(static_cast<double>(numbers[i]));
        (void)template2026::DatabaseManager::get_instance().add_item(item);
    }

    // Save database to disk
    if (template2026::DatabaseManager::get_instance().save() == false) {
        std::cerr << "[ERROR] Failed to save database to disk.\n";
        return 1;
    }
    std::cout << "[PROTOBUF] Database successfully saved.\n\n";

    // 4. Use third target (dbExport) to query and print database to console
    std::cout << "[DBEXPORT] Querying and printing database:\n";
    template2026::DbExport::print_database(db_path);

    // Clean up database file
    std::filesystem::remove(db_path, ec);
    std::cout << "\n[INFO] Showcase application completed successfully!\n";

    return 0;
}
