# Problem-86-Standard-Single-Port-Synchronous-RAM-Read-First-vs-Write-First-
Simple 16×8 RAM implementing selectable memory write modes (READ_FIRST vs WRITE_FIRST) to control what data is presented on dout when reading and writing to the exact same address on the same clock cycle.


# Single-Port Synchronous RAM (Read-First vs. Write-First)

## Overview

In traditional or basic RAM architectures, data output (`dout`) is typically only valid during a **Read operation** (`we = 0`). During a **Write operation** (`we = 1`), the `dout` signal is usually ignored, undefined, or left holding garbage data.

In this implementation, **we have data output (`dout`) available during both Read AND Write operations**. 

When a write occurs (`we = 1`), the RAM uses a selectable mode to define what predictable value is placed on `dout` during that exact same clock cycle.

---

## Operating Modes (`we = 1`)

### 1. Read-First Mode
When `Read-First` is enabled during a write operation (`we = 1`):
* **Read Phase:** The RAM outputs the **previously stored (old) data** from the specified address to `dout`.
* **Write Phase:** Simultaneously, the **new incoming data** (`din`) is written into that memory location.
* **Key Use Case:** Useful for Read-Modify-Write operations, swapping variables, or popping from stacks where you need the old value before overwriting it.

### 2. Write-First Mode
When `Write-First` is enabled during a write operation (`we = 1`):
* **Trash & Overwrite:** The old data stored at the address is overwritten (trashed).
* **Direct Route:** The **new incoming data** (`din`) is loaded directly into the memory location **AND** immediately routed straight to the `dout` pin on the exact same clock edge.
* **Key Use Case:** Useful for data forwarding and bypassing in CPU pipelines, allowing downstream logic to consume the fresh data without wasting a clock cycle.

---

## Mode Comparison Summary

| Mode | Active Control Signal | Data Written to RAM | Data Output on `dout` |
| :--- | :--- | :--- | :--- |
| **Normal Read** | `we = 0` | None (Unchanged) | Existing data at `addr` |
| **Read-First Write** | `we = 1`, `mode = READ_FIRST` | New Data (`din`) | **Old Data** previously at `addr` |
| **Write-First Write** | `we = 1`, `mode = WRITE_FIRST` | New Data (`din`) | **New Data** (`din`) |

---
