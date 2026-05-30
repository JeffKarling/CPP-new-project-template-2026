# Advanced Debugging & Profiling Guide

This guide details how to use the built-in compiler configurations, command-line profiling targets, and Intel ITT instrumentation to debug, profile, and optimize the `template2026` database scanning engine.

---

## 1. Debug Configurations

The project provides two distinct levels of debugging targets inside CMake and CLion:

### A. Standard Debug (`GNU_Custom_Debug` / `Clang_Custom_Debug`)
* **Optimization:** `-O1` (enables minor optimizations for basic performance while maintaining complete debug symbols).
* **Diagnostics:** 
  * Uses modern DWARF v5 (`-gdwarf-5`) debug formats.
  * Preserves frame pointers (`-fno-omit-frame-pointer`) and disables tail-calls (`-fno-optimize-sibling-calls`) to guarantee accurate stack traces.
  * **Clang:** Enables standard `libc++` debugging assertions via `_LIBCPP_HARDENING_MODE_DEBUG`.
  * **GCC:** Enables standard library safety checks via `_GLIBCXX_DEBUG`.

### B. Deep Debug (`GNU_Custom_Debug_Deep` / `Clang_Custom_Debug_Deep`)
* **Optimization:** `-O0` (disabled optimization completely for GCC; `-O1` for Clang to resolve Abseil link-time compatibility).
* **Diagnostics (Exhaustive):**
  * **Clang:** Upgraded to the maximum extensive hardening mode: `_LIBCPP_HARDENING_MODE_EXTENSIVE`. Performs exhaustive, heavier runtime STL assertions.
  * **GCC:** Upgraded to the maximum standard library checks: `_GLIBCXX_DEBUG` + `_GLIBCXX_DEBUG_PEDANTIC`. Activates full safe-iterators, strict sequence checks, and STL container validation.
  * *Note: Deep debug modes carry a substantial performance overhead (up to 10x slower execution) and change container layouts (ABI-breaking in GCC), but they are incredibly powerful at exposing silent memory corruption, out-of-bounds reads, or invalid iterator dereferences.*

---

## 2. Low-Noise Profiling with VTune ITT API

To eliminate compiler setup, Google Test runner overhead, and JSON/Protobuf file serialization noise, the TBB parallel scanning engine is instrumented with the **Intel Instrumentation and Tracing Technology (ITT) API**.

Inside [tbbAlgos.cpp](../srcTargets/tbbAlgos/tbbAlgos.cpp):
1. **Immediate Pause:** On entering the scanning method, VTune collection is explicitly paused (`__itt_pause()`), ignoring all configuration parsing and file-walking setups.
2. **Hot-Path Focus:** Right before activating the TBB Flow Graph, we register a custom ITT domain (`TbbScannerDomain`) and a custom task (`ParallelScanAndExtract`). We trigger `__itt_frame_begin_v3()`, `__itt_task_begin()`, and then **`__itt_resume()`** to start data collection.
3. **Immediate Post-Pause:** As soon as `g.wait_for_all()` finishes, we call `__itt_pause()` again to ignore database flushing and serialization.

### Running with Paused Collection:
To leverage this low-noise instrumentation, you must start the VTune analysis with data collection paused:
* **VTune GUI:** Under the target configuration, check the **"Start with data collection paused"** box.
* **VTune CLI:** Add the `-start-paused` flag:
  ```bash
  vtune -collect threading -start-paused -- ./Build/OneApi_Custom_RelWithDebInfo/srcTargets/exeMain/template2026 targets.txt
  ```

---

## 3. Custom CMake Profiling Targets

To make profiling incredibly convenient within IDEs like CLion, several custom targets are exposed. All profiling results are cleanly isolated inside your workspace's **`production_artifacts/profiling/`** folder.

### Choosing the Right Tool: Advisor vs. VTune vs. Perf

| Profiling Tool | Primary Focus | Best Used For | Key Metrics Delivered |
| :--- | :--- | :--- | :--- |
| **Intel Advisor** | **Computational & SIMD Efficiency** | Finding loop vectorization barriers, analyzing data locality, and evaluating thread computation against physical hardware boundaries. | GFLOPS/GINTOPS, Arithmetic Intensity (OP/Byte), Roofline Model mapping, and compiler-inline analysis. |
| **Intel VTune** | **Parallel Scaling & Thread Coordination** | Debugging thread synchronization bottlenecks, core load imbalance, parallel runtime overhead, and lock contention. | Thread active vs. wait time, lock-waits, thread scheduling overhead, and overall hardware core utilization. |
| **Linux `perf`** | **Micro-Architectural Hardware Counters** | Rapid CLI analysis of CPU pipeline stalls, cache misses, branch mispredictions, and assembly-level instructions. | IPC (Instructions Per Cycle), L1/L2/L3 cache misses, branch misprediction rates, and context switches. |

Select the **`OneApi_Custom_RelWithDebInfo`** build preset, select one of the following targets in your target selector, and click **Run**:

### A. Linux `perf` Targets
* **`Perf`**: Prints hardware counter statistics (cache misses, cycles, instructions, branch mispredictions) directly to the CLion console.
* **`Perf_multithread`**: Attaches to the TBB worker threads and displays thread migrations, context switches, and task clocks in the console.
* **`Perf_record`**: Records low-level CPU samples and saves the raw database as `perf.data` inside `production_artifacts/profiling/perf/`.
* **`Perf_report`**: Launches the interactive terminal-based TUI inside CLion to navigate the recorded `perf.data` samples.

### B. Intel VTune Targets & Web-Based Server Workflow

> [!NOTE]
> **Wayland/Gnome GUI Workaround:**
> In modern Wayland Gnome environments, Intel VTune's CEF-based standalone desktop GUI often crashes due to GTK symbol version conflicts (GTK 2/3 vs 4). To solve this, our workflow relies on VTune's high-performance built-in web server backend (`vtune-backend`).

The project provides two custom CMake targets for VTune:
* **`Vtune_collect`**: Runs the VTune CLI collector for a **Threading Analysis** on your parallel database scanner, saving the results in `production_artifacts/profiling/vtune/`.
  
  > [!WARNING]
  > **Automatic Directory Clean & Overwrite Behavior:**
  > Every time you run the `Vtune_collect` target, the script executes `rm -rf` on the prior results directory (`production_artifacts/profiling/vtune/`) before starting the trace. This prevents stale profiling data and lock conflicts, meaning **the folder always holds the absolute latest profiling run.**

* **`Vtune_gui`**: Triggers a transient Systemd user service (`vtune-web.service`) in the background using `systemd-run`. If an instance is already running, it stops it first and launches a fresh one. This mounts the workspace profiling directory automatically and starts the server on port `8082` without blocking your IDE/terminal window.

---

### C. Transient Systemd User Service Workflow (Dynamic Background Server)

To avoid keeping a manual CLion target session blocking or polluting the disk with static, hardcoded configuration files (like a static `.service` unit file), the VTune web backend is launched as a **transient Systemd user service** using `systemd-run`.

The custom target dynamically registers the service under the unit name **`vtune-web.service`**, configuring it with automatic crash recovery (`Restart=always` and `RestartSec=5`), bound to port `8082` and mounted to your workspace's profiling directory (`production_artifacts/profiling/`).

#### 1. Managing the Service Manually
You do not need to compile or register files on disk. You can start the dynamic service, check its status, or stop it using standard Systemd commands:

```bash
# Start the dynamic service manually
systemd-run --user --unit=vtune-web --property=Restart=always --property=RestartSec=5 /opt/intel/oneapi/vtune/latest/bin64/vtune-backend --web-port=8082 --enable-server-profiling --allow-remote-access --data-directory=/path/to/template2026/production_artifacts/profiling/

# Check the running status and view quick logs
systemctl --user status vtune-web.service

# Stop the running background server
systemctl --user stop vtune-web.service

# View the full server logs in Systemd journal
journalctl --user -u vtune-web.service -n 100
```

#### 2. Accessing the Web GUI
Once the service (or the `Vtune_gui` target) is running, you can connect to the VTune interface from your browser:
* **URL**: [https://localhost:8082/](https://localhost:8082/)
* **SSL Warning**: Because VTune uses a self-signed local SSL certificate, your browser will display a warning. It is safe to click **"Advanced"** and select **"Proceed to localhost (unsafe)"**.
* **Password**: `Lasse21man!` *(The local web server security passphrase)*

#### 3. Analyzing the Profiled Collection
* The server runs with the `--data-directory` pointing directly to your local project's `/path/to/template2026/production_artifacts/profiling/` folder.
* Inside the Web GUI, your profile collection will be visible in the right-hand panel under **"Recent Results"**.
* Since the `Vtune_collect` target automatically overwrites the `vtune` folder on every run, the result labeled **`vtune`** in the list will **always represent your absolute latest profiling run**. Old stale data will never accumulate under that path.

#### 4. Running Collections while the Server is Active
Unlike the legacy standalone desktop GUI, **the VTune Web Server does not lock your collection files during idle background execution.** 
* **Safe Concurrent Runs:** You can safely run the `Vtune_collect` CMake target at any time while the background Systemd server is active. The directory cleanup (`rm -rf`) and new profiling run will succeed flawlessly without any permission or access conflicts.
* **Viewing Updates:** Once the collection target completes in your terminal or CLion, the server automatically indexes the new data in the background. Simply refresh your browser page or click on the **"Recent Results"** panel again to view the updated profiling trace.
* **Browser Note:** If you are actively viewing a detailed timeline graph in your browser tab at the exact moment the files are wiped by `Vtune_collect`, that specific tab may show a temporary loading error. Simply reload/refresh the page once the collection completes, and the new trace will load perfectly.



### D. Intel Advisor Targets
* **`Advisor_collect`**: Runs the CLI collector for a complete **Roofline Model analysis** (sequential Survey analysis + Tripcounts/FLOPs analysis), saving the merged database in `production_artifacts/profiling/advisor/`.
* **`Advisor_gui`**: Launches the Intel Advisor standalone GUI with your recorded project already loaded and ready for Roofline inspection.

> [!WARNING]
> **Active GUI File Locks & Auto-Refresh Limitation (Standalone GUIs Only):**
> **Intel Advisor** (and legacy standalone desktop VTune GUI) dynamically lock the project database files (`.advixeproj`, `.advidb2`, and active databases under `e000/`) in memory and **will not automatically refresh or hot-reload their views** when a new collection is written.
> 
> Because our custom CMake targets (`Advisor_collect` / `Vtune_collect`) perform a clean sweep and overwrite the target directories:
> 1. **You must completely exit and close the standalone Advisor GUI before re-running the Advisor collection target.**
> 2. Re-running an Advisor collection while the desktop GUI is open will lead to database access violations, dynamic write failures, and corrupted "No Roofline Data Available" errors in the GUI.
> 3. Once the collection target completes successfully in the console, you can safely re-launch the GUI via `Advisor_gui`.
> 
> *Note: This limitation **does not** apply to the new VTune Web Server workflow (`vtune-web.service` / `Vtune_gui` target). You can keep the web server running continuously without locking conflict issues.*


---

## 4. Intel Compiler Optimization Reports

When you compile using the `OneApi_Custom_RelWithDebInfo` preset, the Intel compiler (`icpx`) generates a comprehensive optimization report showing loop vectorizations, inlining decisions, and vectorization barriers.

* **Path:** **[compiler_opt_report.txt](../production_artifacts/profiling/advisor/compiler_opt_report.txt)**
* **Advisor GUI Integration:** By saving the optimization report directly inside the Advisor collection result directory, **Intel Advisor will automatically find and parse this report in the background!** You will immediately see loop vectorization details, SIMD statistics, and inlining decisions mapped directly to your source code lines without requiring any manual Search Path configuration in your project settings.
