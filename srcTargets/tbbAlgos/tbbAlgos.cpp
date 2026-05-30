// Copyright (c) 2026 template2026 Contributors
// Licensed under the MIT License. See LICENSE file in the project root for details.

#include <tbbAlgos/tbbAlgos.hpp>
#include <oneapi/tbb/parallel_for_each.h>
#include <cmath>

#ifdef USE_ITT
#include <ittnotify.h>
#endif

namespace template2026 {
    void TbbAlgos::parallel_double(std::vector<int>& numbers) noexcept {
#ifdef USE_ITT
        // Create an ITT domain and string handle for the parallel workload
        static __itt_domain* domain = __itt_domain_create("TbbAlgosDomain");
        static __itt_string_handle* sh_double = __itt_string_handle_create("ParallelDoubleWorkload");
        
        // Start the ITT frame and task, then resume data collection
        __itt_frame_begin_v3(domain, nullptr);
        __itt_task_begin(domain, __itt_null, __itt_null, sh_double);
        __itt_resume();
#endif

        oneapi::tbb::parallel_for_each(numbers.begin(), numbers.end(), [](int& n) noexcept {
            // CPU-intensive workload to generate meaningful profiling data
            // Declared volatile to prevent the compiler from optimizing the loop away
            volatile double result = 0.0;
            for (int i = 0; i < 20'000'000; ++i) {
                result = result + std::sin(static_cast<double>(i * n)) * std::cos(static_cast<double>(i + n));
            }
            // Preserve n = n * 2 exactly
            n = n * 2;
        });

#ifdef USE_ITT
        // Pause data collection immediately after hot-path completion
        __itt_pause();
        __itt_task_end(domain);
        __itt_frame_end_v3(domain, nullptr);
#endif
    }
} // namespace template2026

