---
title: Performance Profiling
nav_order: 4
---

# Application-Level Performance Profiling

> Synthesized from **Brendan Gregg** (Systems Performance: Enterprise and the Cloud; BPF Performance Tools — Netflix/Meta), **Martin Thompson** (LMAX Disruptor, Mechanical Sympathy blog), **Cliff Click** (HotSpot JVM performance, Azul Systems), **Aleksey Shipilëv** (JVM performance, OpenJDK, Red Hat), and **Jeff Dean** (Google Systems infrastructure, Latency Numbers Every Programmer Should Know).

---

## First Principles: What Performance Actually Is

Brendan Gregg's framing: performance work begins with **observability**, not optimization. Before changing anything, you must understand the system's actual behavior under realistic load. Most performance work fails because practitioners optimize the wrong thing.

**The two failure modes:**
1. Profiling a cold or synthetic workload, then optimizing what shows up — which may not match production
2. Premature optimization without measurement, driven by intuition

Martin Thompson adds a hardware perspective: **mechanical sympathy** — writing software that works *with* the underlying hardware, not against it. Understanding memory hierarchies, CPU caches, branch prediction, and NUMA topology is necessary for serious performance work.

---

## The Brendan Gregg Methodology

### USE Method (Utilization, Saturation, Errors)

For every resource (CPU, memory, disk I/O, network, GPU):
- **Utilization**: What percentage of time is the resource busy?
- **Saturation**: Is there a queue forming? Are requests waiting for the resource?
- **Errors**: Are there error events for this resource?

Apply to all system resources first. This eliminates a large class of bottlenecks before you look at application-level profiling.

### RED Method (for services — from Tom Wilkie)

For every service endpoint:
- **Rate**: Requests per second
- **Errors**: Error rate (5xx, exceptions, timeouts)
- **Duration**: Distribution of response times (p50, p95, p99, p999)

These three metrics tell you whether users are experiencing problems before you need to look at internals.

### Latency Analysis: The Four Pillars

Gregg identifies four sources of latency that every profiler must reason about:
1. **CPU time**: Thread is on CPU, executing instructions
2. **Wait time**: Thread is off CPU — blocked on I/O, lock, or sleep
3. **Memory access patterns**: Cache misses, NUMA effects, TLB pressure
4. **Scheduling**: Thread is runnable but waiting for a CPU slot

A profiling tool that only captures CPU time (sampling profiler without off-CPU analysis) will miss categories 2–4 entirely. This is the most common profiling mistake.

---

## Profiling Tool Taxonomy

### CPU Profiling

**Sampling profilers** (low overhead, statistical):
- Take a stack trace snapshot at regular intervals (e.g., every 10ms or every N CPU cycles)
- Show where CPU time is spent across the aggregate
- **Flamegraphs** (Gregg's invention): visualize sampling output as a hierarchy of stack frames, width proportional to time

**Instrumentation profilers** (high overhead, precise):
- Inject timing code around every function entry/exit
- Accurate call counts and timings but 10–100x runtime overhead — only for development

**Linux tools (Gregg's toolkit):**
- `perf record -g` + `perf report` — hardware counter-based, low overhead
- `BPF/eBPF` (bpftrace, BCC) — kernel tracing with near-zero overhead, programmable
- `async-profiler` (JVM) — samples both JIT-compiled and interpreted frames, native stack

**JVM-specific (Aleksey Shipilëv's guidance):**
- JMH (Java Microbenchmark Harness) for microbenchmarks — eliminates JIT warmup artifacts
- `-XX:+PrintCompilation` and `-XX:+PrintInlining` to observe JIT decisions
- async-profiler for wall-clock and CPU profiling without safepoint bias (JVisualVM and older profilers only sample at safepoints, massively biasing results)

### Memory Profiling

**Allocation profiling:**
- Identifies hot allocation paths (where objects are created most frequently)
- High allocation rates drive GC pressure

**Heap analysis:**
- Memory snapshots (heap dumps in JVM, core dumps) analyzed for object retention
- Tools: Eclipse MAT, VisualVM, `jmap -dump`, Pyspy (Python), Heaptrack (C++)

**Memory leak detection:**
- Leak = memory allocated, retained longer than needed, and never freed
- JVM: object count growth over time in GC logs / heap profilers
- C/C++: Valgrind (Memcheck), AddressSanitizer, HeapTrack
- Go: `pprof` heap profiles, `runtime.MemStats`

**Cache performance (Martin Thompson's focus):**
- L1 cache: ~1ns access, typically 32–64KB
- L2 cache: ~4ns, 256KB–1MB
- L3 cache: ~10–40ns, 4–64MB
- RAM: ~100ns
- NVMe SSD: ~100μs
- Network round-trip (local DC): ~500μs

Cache miss rates matter enormously. Accessing 64 bytes of data at a random location in RAM is 100x slower than accessing it in L1 cache. Data structures that maintain spatial locality (arrays, struct-of-arrays) outperform pointer-chained structures (linked lists, tree nodes) for hot paths.

### I/O Profiling

**Disk I/O:**
- `iostat -x`: utilization, saturation, service time, wait time
- `biolatency` (BCC/BPF): histogram of block I/O latency
- Distinguish sequential vs. random access — SSDs still have higher random I/O latency than sequential

**Network I/O:**
- `ss -s`, `netstat`: connection state overview
- `tcpdump`, Wireshark: packet-level analysis
- `nettop` / `nethogs`: per-process bandwidth
- TCP retransmits and receive buffer overruns are signs of saturation

**Database query profiling:**
- Enable slow query logs (MySQL, PostgreSQL `pg_stat_statements`, `EXPLAIN ANALYZE`)
- Look for: full table scans, missing indexes, N+1 queries, lock contention, connection pool exhaustion

---

## The Flamegraph

Brendan Gregg invented flamegraphs in 2011 as a visualization of profiling stack samples.

**Reading a flamegraph:**
- X-axis: alphabetically sorted stack frames (NOT time order) — width represents the total sample count
- Y-axis: stack depth — bottom is the root, top is the leaf (the function on CPU at sample time)
- Wide boxes at the top of a tower = hot functions consuming significant CPU time
- "Cliffs" (sudden drops in width going up) = most callers returned quickly, only a few paths went deeper

**Variants:**
- **CPU flamegraph**: on-CPU samples
- **Off-CPU flamegraph**: time threads are blocked (shows lock contention, I/O waits)
- **Memory flamegraph**: allocation call stacks
- **Differential flamegraph**: compares two profiles, shows regressions or improvements

---

## Jeff Dean's Latency Numbers

Numbers every engineer working on distributed systems should internalize (approximate, circa 2023):

| Operation | Latency |
|---|---|
| L1 cache reference | 1 ns |
| L2 cache reference | 4 ns |
| Mutex lock/unlock | 17 ns |
| Main memory reference | 100 ns |
| Read 1MB sequentially from memory | 3 μs |
| Redis GET (local) | ~100 μs |
| Read 1MB from NVMe SSD | ~100 μs |
| Round trip in same datacenter | 500 μs |
| Read 1MB from SSD | 1 ms |
| PostgreSQL query (simple, indexed, local) | 1–5 ms |
| Round trip from US to Europe | 150 ms |
| Read 1MB from spinning disk | 20 ms |

Use these to sanity-check profiling results and identify implausible measurements.

---

## Common Performance Anti-Patterns

### The N+1 Query Problem
```python
# N+1: 1 query for the list + N queries for each item's related data
users = db.query("SELECT * FROM users")
for user in users:
    user.posts = db.query(f"SELECT * FROM posts WHERE user_id = {user.id}")

# Correct: 1 query with JOIN, or 2 queries with IN clause
users = db.query("SELECT u.*, p.* FROM users u JOIN posts p ON p.user_id = u.id")
```

### Lock Contention (Martin Thompson)
Threads blocked waiting for a mutex appear as off-CPU time, invisible to CPU-only profilers. Symptoms: CPU utilization low despite high latency; throughput plateaus far below hardware limits.

**Solutions:** Lock-free data structures, fine-grained locking, sharding (partition data so each partition has its own lock), read-write locks for read-heavy workloads.

### False Sharing
Two threads update different fields in the same cache line (64 bytes). The CPU must synchronize the cache line between cores on every write, serializing what should be independent operations.

```c
// False sharing: counter_a and counter_b in the same cache line
struct { int counter_a; int counter_b; } shared;

// Fixed: pad to separate cache lines
struct { int counter_a; char pad[60]; int counter_b; };
```

### Synchronous I/O in Async Context
Blocking a thread (or event loop) with synchronous I/O negates the benefits of async architecture. In Node.js, calling `fs.readFileSync` blocks the event loop. In a connection-per-thread server, one slow DB query blocks that thread's capacity.

### Unbounded Queues
Queues that grow without backpressure accumulate latency. A request served 30 seconds after arrival is worse than a request rejected immediately. Set queue bounds and handle overflow explicitly.

### JVM-Specific: GC Pressure
Cliff Click and Aleksey Shipilëv both emphasize: the JVM GC is not free. Allocating 1GB/s of short-lived objects means 1GB/s of objects to collect.

**Signals:** GC logs showing long stop-the-world pauses; `jstat -gcutil <pid>` showing frequent GC runs; heap profiler showing high allocation rates in hot paths.

**Solutions:** Object pooling for frequently allocated objects (but profile first — premature pooling adds complexity); escape analysis often eliminates heap allocation automatically if objects are truly short-lived; prefer value types (Java's Project Valhalla direction; already available in Kotlin/value classes, C# structs).

---

## Profiling Workflow

### Step 1: Establish Baselines
Before any optimization:
- Measure current p50/p95/p99 latency under realistic load
- Capture CPU, memory, I/O utilization
- Record baseline via load test (wrk, vegeta, k6, JMeter)

### Step 2: Identify the Bottleneck
Apply USE method to eliminate systemic bottlenecks. Then profile the application.

**Gregg's rule**: Always look at the widest bottleneck first. Optimizing a function that consumes 2% of CPU while a DB query consumes 80% is waste.

### Step 3: Profile Under Realistic Load
- Warm up the JVM / runtime before profiling
- Profile under production-representative traffic patterns
- Use wall-clock profiling (not just CPU) to catch I/O and lock waits

### Step 4: Hypothesize and Optimize
- Change one thing at a time
- Re-run the same benchmark to isolate the effect of your change
- Flamegraph before vs. after

### Step 5: Validate in Production
- Canary or shadow traffic
- A/B latency comparison
- Monitor for regressions in non-optimized paths

---

## Language-Specific Quick Reference

### Python
- `cProfile` / `profile` — built-in CPU profiler
- `py-spy` — sampling profiler, no code changes needed, safe for production
- `memray` — memory profiler
- `line_profiler` — line-by-line timing for hot functions
- PyPy for CPU-bound workloads

### JavaScript / Node.js
- Chrome DevTools Performance tab (V8 profiler)
- `--prof` flag on Node.js → `node --prof-process` → flamegraph
- `clinic.js` (nearForm) — all-in-one profiling toolkit
- `0x` — flamegraph generator for Node.js

### Go
- `pprof` built into the standard library; enable with `net/http/pprof`
- `go test -bench` for microbenchmarks
- `go tool trace` for goroutine-level scheduling analysis

### JVM (Java, Kotlin, Scala)
- async-profiler — sampling with no safepoint bias
- JMH for microbenchmarks (mandatory for anything you'll publish)
- GC logs: `-Xlog:gc*:file=gc.log` (JDK 9+)
- Flight Recorder / JMC (Java Mission Control)

### Rust
- `cargo bench` with Criterion.rs
- `perf` + flamegraph
- `heaptrack` for memory

---

## Key References

- Gregg, B. (2020). *Systems Performance: Enterprise and the Cloud* (2nd ed.). Addison-Wesley.
- Gregg, B. (2019). *BPF Performance Tools*. Addison-Wesley.
- Thompson, M. — Mechanical Sympathy blog: https://mechanical-sympathy.blogspot.com
- Shipilëv, A. — JVM performance blog: https://shipilev.net
- Gregg, B. — Flamegraph repository and papers: https://www.brendangregg.com/flamegraphs.html
- Dean, J. & Ghemawat, S. (2004). MapReduce. OSDI. (Latency numbers from subsequent talks.)
