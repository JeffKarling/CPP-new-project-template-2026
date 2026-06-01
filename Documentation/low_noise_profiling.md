# Low-Noise Profiling Integration

To support hardware-level performance engineering, the template integrates low-noise profiling capabilities. This setup eliminates framework overhead and system noise during execution analysis.

---

## 1. Hot-Path Isolation (Intel ITT API)

Standard profiling runs collect execution data over the entire lifecycle of a binary. In C++ projects, this introduces profiling noise from:
* Google Test harness setup and test suite registration.
* Configurations, environment variable checking, and file-system directory walking.
* JSON or Google Protobuf file parsing and initialization.

To eliminate this noise and isolate performance tracking to the C++ core execution block, the project uses the **Intel Instrumentation and Tracing Technology (ITT) API**.

### Code Instrumentation Example
Inside the target parallel algorithm block, the profiler data collection is managed explicitly:

```cpp
#include <ittnotify.h>

// 1. Instantly pause collection on entering the method to ignore setup overhead
__itt_pause();

// 2. Perform file setup, configuration parsing, and memory allocations
initialize_environment();

// 3. Define a custom ITT domain and task descriptor for the hot-path
__itt_domain* domain = __itt_domain_create("ParallelScannerDomain");
__itt_string_handle* task_handle = __itt_string_handle_create("ParallelScanAndExtract");

// 4. Signal the start of the execution frame and resume profiling collection
__itt_frame_begin_v3(domain, nullptr);
__itt_task_begin(domain, __itt_null, __itt_null, task_handle);
__itt_resume();

// 5. Execute the performance-critical parallel algorithm (TBB Flow Graph)
execute_parallel_algorithm();

// 6. Immediately pause collection as soon as the parallel work completes
__itt_pause();
__itt_task_end(domain);
__itt_frame_end_v3(domain, nullptr);

// 7. Execute disk flushes, database serialization, and cleanup actions
serialize_results_to_disk();
```

By explicitly pausing collection at entry and exit, performance reports display the hardware metrics (e.g., active execution time, cache misses, vectorization rates, and thread load balancing) of the parallel algorithm, completely free of initialization and teardown noise.

---

## 2. Optional Profiling Build Option (`ENABLE_ITT`)

Linking against the ITT API is optional and managed by the CMake compilation parameter `ENABLE_ITT`:
* **Development Profiling**: The `OneApi_Custom_RelWithDebInfo` compilation preset automatically sets `"ENABLE_ITT": "ON"`. This enables the ITT control macros during compilations without requiring manual configuration.
* **Standard Production**: In normal release and distribution builds, `ENABLE_ITT` defaults to `OFF`. The ITT macro calls compile into empty statements, removing any linkage requirements or execution overhead.

---

## 3. Web-Based Server Workflow (Intel VTune)

In Wayland and Gnome-based environments, Intel VTune's desktop GUI can experience graphical issues due to library conflicts. To bypass this, the profiling setup relies on VTune's built-in web server backend (`vtune-backend`), hosted as a **transient Systemd user service**.

### Dynamic Background Server
The custom CMake target `Vtune_gui` uses `systemd-run` to start the web backend in the background as a transient service named `vtune-web.service`. This allows the server to run continuously, mounted to the local profiling workspace directory:

```bash
# Start the dynamic service manually
systemd-run --user --unit=vtune-web --property=Restart=always --property=RestartSec=5 /opt/intel/oneapi/vtune/latest/bin64/vtune-backend --web-port=8082 --enable-server-profiling --allow-remote-access --data-directory=/path/to/template2026/production_artifacts/profiling/
```

### Access and Overwrite Workflow
1. **No-Lock Concurrent Collections**: Unlike standalone desktop interfaces, the VTune Web Server does not lock profiling files during idle background execution. Developers can run compilation profiling targets (like `Vtune_collect`) concurrently while the server remains active.
2. **Directory Overwrites**: To prevent stale database files and lock conflicts, every execution of `Vtune_collect` deletes the previous result directory (`production_artifacts/profiling/vtune/`) before starting the trace.
3. **Web Browser Interface**: Results are analyzed in the browser at [https://localhost:8082/](https://localhost:8082/) using the security passphrase `Lasse21man!`. Refreshing the browser page immediately loads the newly recorded collection.

---

## 4. Loop Analysis (Intel Advisor)

To analyze vectorization efficiency and instruction optimization:
* **`Advisor_collect`**: Runs the CLI collector for a sequential Survey analysis followed by Tripcounts/FLOPs analysis, generating a **Roofline Model** mapped to physical hardware limitations.
* **Compiler Optimization Reports**: The Intel compiler (`icpx`) is configured to output detailed optimization reports directly into the Advisor results directory (`production_artifacts/profiling/advisor/compiler_opt_report.txt`). Intel Advisor automatically parses this report to map vectorization decisions directly to C++ source lines.
* *Note: Standard desktop Advisor GUI processes lock project databases during active viewing. Standalone GUIs must be closed before executing a new collector target.*
