// Copyright (c) 2026 template2026 Contributors
// Licensed under the MIT License. See LICENSE file in the project root for details.

#pragma once

#include <vector>

namespace template2026 {
    class TbbAlgos {
    public:
        // A simple parallel transform using tbb::parallel_for_each
        static void parallel_double(std::vector<int>& numbers) noexcept;
    };
} // namespace template2026
