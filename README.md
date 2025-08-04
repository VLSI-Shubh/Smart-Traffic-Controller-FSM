
# 🚦 FSM Traffic Controller – Sensor-Based Smart Control

This project implements a **sensor-aware traffic light controller** using a **Finite State Machine (FSM)** in Verilog. The design is enhanced to dynamically react to real-time traffic on **4 roads (R1–R4)** and determine optimal green light allocation between **roads 1 & 3** and **roads 2 & 4** based on vehicle presence.

## 🧠 Project Overview

This FSM monitors a 4-bit `Traffic` input representing traffic density (binary flags) on four roads:
- `Traffic[0]` – Road 1
- `Traffic[1]` – Road 2
- `Traffic[2]` – Road 3
- `Traffic[3]` – Road 4

The controller groups the roads as:
- Group 1–3 (R1 and R3)
- Group 2–4 (R2 and R4)

Whenever traffic is detected on a group, it activates **Green** lights for that group, while the other group is held at **Red**. Transition between Green → Yellow → Red is time-controlled using internal countdown logic.

## 🔷 FSM State Diagram

![FSM Diagram](https://github.com/VLSI-Shubh/Traffic-Controller-using-FSM/blob/32de1aec6563966cb09b189a13eb93384b69c19a/images/Traffic%20Controller%20FSM.png)

## 🔁 FSM Logic & Transitions

The traffic controller FSM operates in **five states**, reacting to live sensor inputs and sequencing through light phases using internal timers. Here’s a detailed breakdown:

### ➤ State Overview

- `s_idle`: Default state where all traffic lights are Red. The controller monitors the `Traffic` input.
- `s_13gg`: If traffic is detected on Road 1 or 3, FSM enters this state, turning Green on R1 and R3.
- `s_13yy`: Yellow phase for R1 and R3 before returning to idle.
- `s_24gg`: When traffic is detected on Roads 2 or 4 (and no traffic on Roads 1 or 3 after the s_idle state), the FSM transitions to this state, turning the green light on Roads 2 and 4.
- `s_24yy`: Yellow phase for R2 and R4 before returning to idle.

### ➤ Priority-Based Selection

- When `Traffic != 0000`, the FSM prioritizes:
  - Group R1 & R3 if either `Traffic[0]` or `Traffic[2]` is high
  - Else, Group R2 & R4 if either `Traffic[1]` or `Traffic[3]` is high
- If both groups have traffic, **R1/R3 are preferred** by design.

### ➤ Timer-Based Phase Transitions

- Green and Yellow lights are **governed by counters**.
- A signal `done` goes high when the timer hits zero, prompting state transition.
- This ensures each Green/Yellow phase is held for a precise number of cycles.

### ➤ FSM Transition Summary

| Current State | Condition              | Next State |
|---------------|------------------------|------------|
| `s_idle`      | `Traffic[0] or Traffic[2]` | `s_13gg`   |
| `s_idle`      | `Traffic[1] or Traffic[3]` | `s_24gg`   |
| `s_13gg`      | `done == 1`             | `s_13yy`   |
| `s_13yy`      | `done == 1`             | `s_idle`   |
| `s_24gg`      | `done == 1`             | `s_24yy`   |
| `s_24yy`      | `done == 1`             | `s_idle`   |

This FSM is designed to be scalable and deterministic, making it well-suited for adaptive traffic signal systems in smart city applications. (*Future enhancements will include pedestrian control features to improve safety and usability.*)


## ⏱️ Timers & Control

Timers are implemented internally using a counter:

```verilog
parameter GREEN_TIME  = 16'd55;
parameter YELLOW_TIME = 16'd10;
```

Each Green/Yellow state initializes the `max_timer`, and decrements it every clock. Once it reaches zero, the `done` signal triggers the state change.

## 🎯 Output Encoding

| Output Signals | Meaning                    |
|----------------|----------------------------|
| `Red[3:0]`     | Red lights for R1–R4       |
| `Green[3:0]`   | Green lights for R1–R4     |
| `Yellow[3:0]`  | Yellow lights for R1–R4    |

Example:
- In `s_13gg`: R1 and R3 are Green, R2 and R4 are Red.
- In `s_24yy`: R2 and R4 are Yellow, R1 and R3 are Red.


## 🖥️ Simulation Output & Timing Behavior

The FSM was verified using a testbench and simulated using `vvp`. Below is a summary of key behaviors observed from the simulation:

### 📷 Waveform Output

Below is a snapshot of the waveform from the simulation highlighting state transitions and output signal changes (Red, Green, Yellow):

![Waveform Output](https://github.com/your-repo/images/traffic_waveform.png)


### 🔍 Key Observations from Output Log

- **Initial State (`s_idle`)**: From 0 to 25000 ns, no traffic is detected (`T = 0000`), and all lights are Red.
- **Traffic Detected on Road 1 (`T = 1000`)**: At 25000 ns, the FSM begins evaluation and transitions to `s_24gg` (State 3), where Roads 2 & 4 receive Green lights.
- **Green Phase**: The FSM stays in `s_24gg` for 55 clock cycles, decrementing the internal timer from 55 down to 0.
- **Transition to Yellow (`s_24yy`)**: Once timer hits zero (at 595000 ns), FSM enters `s_24yy` and Yellow lights for Roads 2 & 4 are activated.
- **Cycle Completion**: After Yellow phase, FSM returns to `s_idle` and re-evaluates traffic. This dynamic continues for every new traffic input pattern.


### 📈 Representative Simulation States

| Time (ns) | T (Traffic) | State | R | G | Y | Timer | Done |
|-----------|-------------|-------|---|---|---|--------|------|
| 25000     | 1000        | s_idle → s_24gg | 0101 | 1010 | 0000 | 0 → 55 | 0 |
| 595000    | 1000        | s_24gg → s_24yy | 0101 | 0000 | 1010 | 0 | 1 |
| 615000    | 1000        | s_24yy → s_idle | 1111 | 0000 | 0000 | — | 0 |
| 625000    | 0100        | s_idle → s_24gg | 0101 | 1010 | 0000 | 55 | 0 |
| 1195000   | 1010        | s_idle → s_13gg | 1010 | 0101 | 0000 | 55 | 0 |

**Note:** State IDs were decoded based on FSM encoding. `s_idle = 0`, `s_13gg = 1`, `s_13yy = 2`, `s_24gg = 3`, `s_24yy = 4`.

---

# 📘 FSM Design (Schematic View)

To provide a hardware-level view of the FSM, the schematic below represents the synthesized structure of the controller.

This schematic was generated using tools like **Vivado** and **EDA Playground**, and offers insight into:

- Register and flip-flop arrangement
- State transition logic
- Combinational and sequential blocks used in synthesis

> 📄 View the full schematic in:  
[`circuits/fsm_schematic_vivado.pdf`](./circuits/fsm_schematic_vivado.pdf)


# 💻 Project Files

| File | Description |
|------|-------------|
| `traffic_controller.v`     | Main FSM Verilog code |
| `traffic_controller_tb.v`  | Testbench for verification |
| `*.vcd`                    | Waveform dumps for simulation |
| `*.vvp`                    | Compiled simulation output (for use with Icarus Verilog) |
| `images/`                  | FSM diagrams and waveform screenshots |
| `circuits/`                | Synthesized FSM circuits (PDFs of RTL schematics) |


## ✅ Conclusion

This project demonstrates a **realistic traffic control FSM** that dynamically responds to real-time traffic conditions, improving flow and reducing idle time. With modular timing control, sensor-based input logic, and clear visual outputs, it serves as a foundational design in **digital design**, **RTL FSM modeling**, and **hardware-aware traffic systems**.

## 📎 Future Enhancements

- Add pedestrian crossing logic and timers
- Implement traffic priority (e.g., emergency vehicle override)
- Integrate countdown display on each signal
- Simulate with different traffic patterns
## 🛠️ Tools Used

This project was developed, tested, and visualized using the following tools:

| Tool            | Purpose                                           |
|------------------|---------------------------------------------------|
| **Icarus Verilog** (`iverilog`) | Compilation and simulation of Verilog code |
| **GTKWave**      | Viewing waveform outputs (`.vcd` files)          |
| **EDA Playground** | Online Verilog editor and schematic viewer for quick prototyping |
| **Vivado**       | RTL synthesis, schematic generation, and design analysis |


## 📝 License

This project is licensed under the terms of the [MIT License](./LICENSE.txt).

.

