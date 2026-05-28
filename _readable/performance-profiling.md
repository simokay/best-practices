# Understanding Application Performance

Performance work is measurement work. The most common mistake in optimising a system's performance is changing something before understanding what is actually slow. Intuitions about performance are frequently wrong, because modern computing systems have complex, counterintuitive performance characteristics that are difficult to reason about without data.

The practical consequence is that you should always measure before optimising. Optimising a function that accounts for two percent of your application's runtime while a database query accounts for eighty percent accomplishes almost nothing. More dangerously, optimisation without measurement can make things worse — or make the code more complex without any user-visible improvement.

---

## What Performance Actually Is

Performance has several distinct dimensions, and it matters which one you are trying to improve.

**Throughput** is how much work a system completes in a given time period. **Latency** is how long a specific operation takes. These can pull in opposite directions: batching operations can improve throughput while increasing the latency of individual requests.

**Percentile latency** is more useful than average latency. If ninety-nine percent of requests complete in ten milliseconds but one percent take five seconds, the average might look reasonable while a significant fraction of users have a poor experience. High percentile measurements — the ninety-fifth and ninety-ninth percentile — capture the tail of the distribution where real problems often hide.

**Resource utilisation** — what fraction of available CPU, memory, network, or storage capacity is being used — determines headroom. A system running at ninety percent CPU utilisation has very little capacity to absorb traffic spikes.

---

## Observe First, Optimise Second

Before looking at application-level profiling, check the underlying resources.

For each resource your application depends on — CPU, memory, disk, network — ask three questions. What percentage of the time is it busy? Is a queue forming, meaning requests are waiting for access to this resource? And are there error events associated with it?

This approach surfaces bottlenecks that have nothing to do with your application code. A disk that is saturated, a network link that is dropping packets, or a CPU that is hitting thermal limits are all problems that no amount of application-level optimisation will fix.

For services, the complementary approach is to track, for each endpoint or operation: the request rate, the error rate, and the distribution of response times. These three signals tell you whether users are experiencing problems, and at what scale, before you need to look at any internals.

---

## Where Time Goes

When you do look at application-level profiling, it is important to understand the different places time can be spent.

A thread can be spending time executing instructions on the CPU. It can be off the CPU entirely, blocked waiting for an I/O operation, a lock, or a sleep. It can be spending time on memory access — traversing data structures that do not fit in CPU caches and require many slow round-trips to main memory. Or it can be runnable but waiting for a CPU core to become available.

A profiler that only measures CPU time — where the thread is actually executing — will be blind to the last three categories. This is the most common profiling mistake. An application that appears to have low CPU utilisation may still have high latency because threads are spending most of their time waiting rather than executing.

---

## Profiling Tool Approaches

**Sampling profilers** take a snapshot of the call stack at regular intervals. They have low overhead and can safely run against production systems. The result is a statistical picture of where time is spent across many samples — functions that appear frequently are consuming significant time. Flamegraphs are a particularly useful visualisation of sampling profiler output: they display the call stack hierarchy with width proportional to time, making it easy to see at a glance where time is concentrated.

**Instrumentation profilers** inject timing code around every function call. They produce precise per-call timings but impose significant overhead — ten to a hundred times normal — making them practical only in development environments.

Most languages have profiling tools built in or readily available. The key is to use wall-clock profiling, which captures all the time a thread is spending including waits, not just CPU time.

---

## Memory Performance

Memory behaviour has a large effect on performance that is easy to miss if you are only measuring CPU time.

Modern CPUs have caches at multiple levels — typically L1, L2, and L3. Accessing data in L1 cache takes roughly one nanosecond. Accessing data in main memory takes roughly one hundred nanoseconds. Accessing data on an SSD takes roughly one hundred microseconds. These are differences of two and five orders of magnitude respectively.

Code that accesses data with good spatial locality — meaning data that is used together is stored near each other in memory — will benefit from cache effects. Code that follows chains of pointers to scattered memory locations will repeatedly miss the cache, incurring that hundred-nanosecond penalty on every access. This is why compact, contiguous data structures often outperform pointer-based structures like linked lists for hot code paths.

**Allocation rate** matters in managed runtimes. A garbage collector must eventually collect everything that was allocated. High allocation rates in hot code paths mean high garbage collection pressure, which can cause periodic pauses or increased CPU overhead. Allocation profilers identify which code paths are generating the most allocations.

---

## Common Performance Anti-Patterns

**The N-plus-one query problem** occurs when code loads a list of records and then, for each record, makes an additional query to load related data. One hundred records produces one hundred and one queries. The fix is to load related data in a single query using a join or an in-clause lookup.

**Lock contention** occurs when multiple threads compete for the same lock. Threads that are blocked waiting for a lock appear as off-CPU time, invisible to CPU-only profilers. Symptoms include CPU utilisation that is low relative to the latency being observed, and throughput that plateaus well below what the hardware should support.

**Synchronous operations in asynchronous contexts** negate the benefits of asynchronous architecture. A single blocking call in an event loop stalls the entire loop for its duration.

**Unbounded queues** accumulate latency. A request that arrives when the system is overloaded and waits thirty seconds in a queue before being processed is worse for the user than an immediate rejection with a clear error. Apply backpressure: define queue bounds and handle overflow explicitly.

**Premature optimisation** is the anti-pattern that causes all the others. Optimise after you measure, based on what the profiler tells you, not on what you suspect or what you remember reading about once.

---

## A Profiling Workflow

Start by establishing a baseline. Before making any changes, measure current latency percentiles and resource utilisation under a realistic load pattern. Record the results.

Identify the widest bottleneck first. Check the system resources, then look at the application profile. Find the operation that accounts for the most time.

Profile under realistic conditions. A profiling run against a cold system with synthetic load will show a different profile than production. Warm up the runtime before profiling. Use traffic patterns that resemble real usage.

Change one thing at a time. Changing multiple things simultaneously makes it impossible to know which change produced which effect.

Validate in production with a gradual rollout. Monitor that the improvement holds under real traffic and that no other metric has regressed.
