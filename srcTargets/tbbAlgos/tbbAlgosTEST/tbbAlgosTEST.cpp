// Copyright (c) 2026 template2026 Contributors
// Licensed under the MIT License. See LICENSE file in the project root for details.

#include <gtest/gtest.h>
#include <tbbAlgos/tbbAlgos.hpp>
#include <vector>

TEST(TbbAlgosTest, ParallelDoubleSquaresValues) {
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    template2026::TbbAlgos::parallel_double(numbers);
    
    std::vector<int> const expected = {2, 4, 6, 8, 10};
    EXPECT_EQ(numbers, expected);
}

TEST(TbbAlgosTest, ParallelDoubleHandlesEmptyVector) {
    std::vector<int> numbers;
    template2026::TbbAlgos::parallel_double(numbers);
    
    EXPECT_TRUE(numbers.empty());
}
