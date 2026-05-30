// Copyright (c) 2026 template2026 Contributors
// Licensed under the MIT License. See LICENSE file in the project root for details.

#include <gtest/gtest.h>
#include <databaseManager/databaseManager.hpp>
#include <filesystem>
#include <vector>

TEST(DatabaseManagerTest, SingletonInstanceIsUnique) {
    auto& instance1 = template2026::DatabaseManager::get_instance();
    auto& instance2 = template2026::DatabaseManager::get_instance();
    EXPECT_EQ(&instance1, &instance2);
}

TEST(DatabaseManagerTest, AddAndRetrieveItemsWorks) {
    std::filesystem::path const test_db = "test_items.pb";
    std::error_code ec;
    std::filesystem::remove(test_db, ec);

    auto& db = template2026::DatabaseManager::get_instance();
    ASSERT_TRUE(db.initialize(test_db));

    template2026::Item item;
    item.set_id("ID_001");
    item.set_name("Test Item");
    item.set_value(100.50);

    EXPECT_TRUE(db.add_item(item));

    auto const items = db.get_all_items();
    ASSERT_EQ(items.size(), 1);
    EXPECT_EQ(items[0].id(), "ID_001");
    EXPECT_EQ(items[0].name(), "Test Item");
    EXPECT_DOUBLE_EQ(items[0].value(), 100.50);

    // Save and check file exists
    EXPECT_TRUE(db.save());
    EXPECT_TRUE(std::filesystem::exists(test_db));

    std::filesystem::remove(test_db, ec);
}
