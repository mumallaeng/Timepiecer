English | [한국어](README.ko.md)

# Timepiecer

2026.04.16 ~ 2026.04.20

> A project carried out in the Verilog class of *[Consortium] On-Device AI System Semiconductor Design, 2nd Cohort*.

<img width="400" height="400" alt="stopwatch+watch-x2-timepiece" src="https://github.com/user-attachments/assets/7f7573ad-3501-4338-9902-16e2dba8d566" />

<img width="400" height="400" alt="stopwatch+watch-x2-timer" src="https://github.com/user-attachments/assets/f085ffe0-6fec-4139-8cd8-3adc5b4a19fc" />

| Name | Responsibility |
| --- | --- |
| Yeonwoo Gim ([@mumallaeng](https://github.com/mumallaeng)) | **Timepiece design·implementation·verification**: timepiece_fsm, timepiece_datapath, time_set_module, timepiecer |
| Younghyun Lee ([@younghyun0702](https://github.com/younghyun0702)) | **Timer design·implementation·verification**: debouncer, input_conditioning, timer_fsm, timer_datapath, timer_unit |

## 1. Overview

### 1.1 Purpose and Goals

The purpose of this project is to design Timepiecer, which runs on a Basys 3 board, and to implement the Timer and Timepiece functions as a single integrated system. This is not just about building individual features in isolation — it's meant to directly work through the full digital system design flow, including button input handling, state transitions, the data path, display control, and simulation verification.

The concrete goals are as follows.

- Design the Timepiece and Timer functions independently, then integrate them into a single project at the top module.
- Implement an input structure that operates reliably on real board hardware through short press, hold, and debounce handling of button input.
- Separate the FSM and datapath to clearly understand the difference between state control and data update roles.
- Implement clock-like functionality including HH:MM/SS:MS display switching, 12-hour/24-hour format switching, and set-mode editing.
- Design the system so that even when Timer and Timepiece are selectively displayed, their internal operation is maintained according to requirements.
- Verify the design results step by step through module-level testbenches, integrated simulation, and board-level checks.

In other words, this project comprehensively carries out the full design process — from input handling, to state control, to data processing, to FND display, to verification — using Verilog HDL, with the final goal of confirming it on an actual FPGA board.

### 1.2 Design Scope

The design scope of this project consists of four areas: Timepiece, Timer, Display, and Verification. The functions handled in each area are as follows.

| Category | Content |
| --- | --- |
| Timepiece | Real-time clock, set entry/exit, unit movement, +1/-1/+10/-10, 12h/24h display |
| Timer | run/stop, clear, up/down, HH:MM/SS:MS display |
| Display | 4-digit FND, center DP, set blink |
| Verification | unit TB, top TB, waveform capture |

This report summarizes the system design structure and implementation results based on the scope above.

### 1.3 Project Summary

Timepiecer is a Basys 3-based Timepiece + Timer integrated digital clock system. It provides clock and timer functionality together within a single top-level structure, and performs actions such as time setting, display switching, run control, and direction switching via button input.

<img alt="system_function" src="https://github.com/user-attachments/assets/9528a50d-7e47-4efd-ac8e-1c90d43649fc" />

The clock function maintains the current time while providing editing via set mode, and the timer function is configured to allow run/stop, clear, and up/down control. The display uses a 4-digit FND and selectively outputs either the HH:MM or SS:MS format.

### 1.4 Specification Summary

| Item | Value |
| --- | --- |
| Board | Digilent Basys 3 |
| Main clock | 100 MHz |
| Timepiece initial value | 13:59:00.00 |
| Display format | HH:MM, SS:MS |
| Time format | 24h, 12h |
| Timer tick base | 100 Hz |
| BtnR hold | 2.0 s |
| BtnU/BtnD hold | 1.5 s |
| hold repeat | 0.2 s |

## 2. Project Management

### 2.1 Roles & Responsibilities

| Category | Yeonwoo Gim([@mumallaeng](https://github.com/mumallaeng)) | Younghyun Lee([@younghyun0702](https://github.com/younghyun0702)) |
| --- | --- | --- |
| Actual scope | Full Timepiece implementation, Time Set implementation, final top-level integration | Full Timer implementation, initial input-conditioning draft, initial top-level integration |
| Main implementation files (common excluded) | timepiece_fsm.v, timepiece_datapath.v, time_set_module.v, timepiecer.v | timer_fsm.v, timer_datapath.v, timer_unit.v, top_stopwatch_watch.v |
| Testbench files | tb_time_set.v, tb_timepiece.v, tb_timepiece_fsm.v, tb_timepiecer.v | tb_debouncer.v, tb_input_conitioning.v, tb_timer_fsm.v, tb_timer_datapath.v, tb_timer_unit.v |
| Supporting commits | c10e779, d74f9b8, 1e940c6, 0352d5f, 8f5d71c, c7dff1c, e47b79a, 588605e | 9460045, 5444819, 9a00eb4, 1c73393, e4a79bd, 6369c6e |

**Common work files**

| Category | Yeonwoo Gim([@mumallaeng](https://github.com/mumallaeng)) | Younghyun Lee([@younghyun0702](https://github.com/younghyun0702)) |
| --- | --- | --- |
| debouncer.v | Corrected it so repeated input after hold works in Timepiece's set mode | First wrote the base debounce and hold-detection structure so button input is recognized only once |
| input_conditioning.v | Added the rules for BtnR 2s hold and UP/DOWN 1.5s hold and repeat input needed to enter Timepiece's set mode | First wrote the base structure that conditions button input before passing it to the Timer FSM |
| display_select.v | Corrected the HH:MM ↔ SS:MS and Timepiece ↔ Timer set-mode retention rules to match the final UX | Wrote the initial structure in the early top module for selecting and displaying the Timer ↔ Stopwatch screen |
| common_control.v | Defined the common control rule so that a short press on the right button switches the screen and a hold enters/exits set mode | Wrote the common control draft that forms the basic framework for switching display mode based on buttons and switches |
| fnd_controller.v | Handled blink for the digit currently being set in Timepiece | Wrote the initial code for displaying the FND dot position |

### 2.2 Schedule

| Period | Work |
| --- | --- |
| 2026.04.16 ~ 2026.04.17 | Requirements gathering, block structure design |
| 2026.04.17 ~ 2026.04.18 | Timer / Timepiece module implementation and revision |
| 2026.04.18 ~ 2026.04.19 | Testbench writing, waveform verification, top-level integration |
| 2026.04.20 | Presentation materials and report writing |

### 2.3 Development Environment

| Item | Content |
| --- | --- |
| HDL | Verilog HDL |
| EDA | Vivado 2020.2 [1] |
| Version control | Git, GitHub |
| Working environment | Windows 11 Pro |

### 2.4 Design Environment

| Item | Content |
| --- | --- |
| Top module | timepiecer.v |
| Verification | Behavioral simulation, wcfg-based waveform capture |
| Target board | Basys 3 [0] |

## 3. Architecture

### 3.1 System Structure

<img alt="system-architecture" src="https://github.com/user-attachments/assets/30feec9e-b837-4c0a-9565-3fdfd66afacf" />

| Block | Role | Content |
| --- | --- | --- |
| input_conditioning | Input conditioning | Generates button short/hold/repeat |
| common_fsm | Common control | Stores display mode based on BtnR short press |
| timer_unit | Timer path | Timer state control and counting |
| timepiece_unit | Timepiece path | Clock control, live time, set bus |
| display_select_logic | Display selection | Timepiece/Timer, 24h/12h display selection |
| fnd_controller | Display output | FND scan, blink, center DP control |

The data flow is organized in the order: input conditioning -> control/data path -> display selection -> FND output.

### 3.2 Theory & Background

#### 3.2.1. FSM

**Timepiecer**

<img width="543" height="703" alt="timepiecer-FSM" src="https://github.com/user-attachments/assets/ba073ed2-fffe-4ac5-ad32-0becd39b2b32" />

The Timepiece FSM distinguishes between short press and hold input and converts them into the various control pulses needed for set-mode control and time editing. In other words, it is the control block that maps the meaning of a user's button input into edit commands the Datapath can interpret.

**Timer**

<img width="722" height="521" alt="timer-FSM" src="https://github.com/user-attachments/assets/b0466ac4-b286-4c91-a54d-e75d9dd7b3c5" />

The Timer FSM only uses short press input, and converts it into clear, count up/down, and run/stop control signals. In both the STOP and RUN states, CLEAR and UPDOWN actions are possible, and after the action completes it returns to the original state based on previous_state.

#### 3.2.2. ASM

**Timepiece_unit**

<img width="1881" height="1377" alt="timepiece-ASM" src="https://github.com/user-attachments/assets/2b01562e-c4ef-46fe-a690-88754200346d" />

This ASM shows the overall control flow of the Timepiece FSM. Timepiece basically operates in the VIEW state, entering the SET state on a btnR_hold input, or returning to VIEW again. In the SET state, the set index matching the current display mode is selected; a btnL input moves the edit position via INDEX_SHIFT, and short presses of btnU/btnD transition to 1-step increment/decrement respectively, while hold input transitions to 10-step increment/decrement respectively. These INDEX_SHIFT, INCREMENT, and DECREMENT-family states are all action states held for only a single clock, after which they return to the SET state. Also, if the display mode changes during setting, the set index is remapped to match the currently visible unit. It can be described as the core control block that distinguishes between short press and hold input, and converts them into set-mode control and time-editing control pulses.

**timer_unit**

<img width="1230" height="1100" alt="timer-ASM" src="https://github.com/user-attachments/assets/7d3e62ef-6fcc-49c5-b9cf-3b5fd2250b0f" />

This ASM shows the state transition structure of the Timer FSM. The Timer control section is only active when sw0 == 1, and consists of the persistent states STOP and RUN, and the momentary-action states CLEAR and UPDOWN. A btnD input toggles between STOP and RUN, a btnL input triggers the CLEAR state to reset the counter value, and a btnU input triggers the UPDOWN state to reverse the count direction. The CLEAR and UPDOWN states are also designed to return to the original state after the action, based on previous_stat, so initialization and direction switching are possible in both the STOP and RUN states. Through this structure, the Timer FSM is responsible for converting a user's short press input into run/stop, clear, and up/down control signals.

**display_unit**

<img width="893" height="590" alt="display_unit-ASM" src="https://github.com/user-attachments/assets/70d5c59d-968d-4abf-b16d-d841635faad7" />

This ASM shows the behavior of the display mode control block. This controller can be viewed as a simple ASM structure operating based on a single-bit state variable called o_display_mode. On reset, the default display mode is determined based on the sw0 state, and afterward, when a btnR short press comes in, o_display_mode toggles on the next clock and the displayed screen switches. If there is no input, the current display mode is maintained as-is. Therefore, rather than controlling the operation of Timepiece and Timer themselves, this block performs the role of switching the display format shown to the user.

## 4. Detailed Design

### 4.1 RTL

<img alt="timepiecer-RTL" src="https://github.com/user-attachments/assets/8f7f4556-d6c9-4bf4-9f5f-b568cc59a643" />

| Module | Description |
| --- | --- |
| timer_fsm | STOP/RUN/UPDOWN/CLEAR state control |
| timer_datapath | msec/sec/min/hour count chain |
| timer_unit | Timer FSM + Datapath wrapper |
| timepiece_unit | Timepiece FSM + Datapath wrapper |
| display_select | display_select + fnd_controller wrapper |

### 4.2 Datapath / Control

| Category | Content |
| --- | --- |
| Timer control | run/stop via BtnD, direction switching via BtnU, clear via BtnL |
| Timer datapath | Updates msec -> sec -> min -> hour based on a 100 Hz tick |
| Timepiece control | Set entry/exit via BtnR hold, index shift via BtnL, value edits via BtnU/BtnD |
| Timepiece datapath | Live time keeps increasing while the set value is edited on a separate bus |

**Important implementation facts:**

| Item | Content |
| --- | --- |
| Timepiece initial value | 13:59:00.00 |
| Behavior during set | The live clock keeps running |
| At set exit | The edited value is applied to the live clock once |
| BtnR short | Switches HH:MM ↔ SS:MS regardless of view/set |
| BtnR hold | Dedicated to Timepiece set entry/exit |
| blink | Only the unit currently being edited blinks in set mode |

### 4.3 Timing Design

| Item | Content |
| --- | --- |
| Main clock | 100 MHz |
| Timer count tick | 100 Hz |
| Debounce sample | 100 kHz-based sampling |
| BtnR hold | 2.0 s |
| BtnU/BtnD hold | 1.5 s |
| hold repeat | 0.2 s |

### 4.4 Design Strategy

| Item | Applied strategy |
| --- | --- |
| Input stability | Raw buttons are not fed directly into the FSM; they go through input_conditioning |
| Control/data separation | Separates FSM and datapath to make interpretation and verification easier |
| Timepiece setting | Separates live time and set time to secure stable behavior during set |
| Display consistency | Timepiece keeps the center dot ON, Timer keeps it OFF, to distinguish them |
| Board limitation workaround | Basys 3 has no real `:`, so the center DP is used instead |

## 5. Simulation & Verification

### 5.1 Testbench

| Testbench | Verified content |
| --- | --- |
| tb_debouncer.v | short/hold input conditioning |
| tb_input_conitioning.v | short/hold/repeat separation |
| tb_time_set.v | set bus editing, +1/-1/+10/-10, wrap |
| tb_timepiece_fsm.v | state transitions, set_index, tens pulse |
| tb_timepiece.v | live/set separation, apply load, 12h/24h |
| tb_timer_fsm.v | STOP/RUN/UPDOWN/CLEAR transitions |
| tb_timer_datapath.v | increment, decrement, clear, carry |
| tb_timer_unit.v | Timer FSM + Datapath integration |
| tb_timepiecer.v | final top-level integrated behavior |

### 5.2 Simulation Scenarios

Among the testbenches, tb_timepiecer.v's simulation scenario is covered as a representative example.

| Scenario | Expected behavior |
| --- | --- |
| Timepiece set entry | VIEW -> SET after a 2s BtnR hold |
| Timepiece editing | Current unit is edited according to BtnL, BtnU, BtnD |
| Timepiece apply | The edited value is applied to the live clock when set exits |
| Timer run/stop | STOP <-> RUN according to BtnD |
| Timer up/down | Direction switches according to BtnU |
| Timer clear | Value resets according to BtnL |
| Top integration | Display/mode switches according to SW0, SW15, BtnR |

### 5.3 Waveform Analysis

<img alt="waveform-1" src="https://github.com/user-attachments/assets/fb98f9c6-dd21-48fe-b805-382a01be975f" />

This waveform shows the result of verifying the overall behavior flow of Timepiece at the top level. The red section confirms set-mode entry after screen switching, the blue section confirms the value-editing operation, and the yellow section confirms the 12-hour format switching operation. Finally, by confirming that the edited value after set exit is applied to the actual clock value, it was verified that Timepiece's setting and display behavior operates normally.

<img alt="waveform-2" src="https://github.com/user-attachments/assets/8fd93b6c-bccb-4b21-8b1c-e6708a1f3bb6" />

This is a waveform confirming the overall behavior flow of Timer at the top level. In the red section, counting begins according to a btnD input after switching to Timer mode via sw0, and in the yellow section, the displayed screen switches according to a btnR short input — this section verifies both behaviors.

<img alt="waveform-3" src="https://github.com/user-attachments/assets/c5489613-9f6b-4fba-8fbb-0554a7321f55" />

This waveform confirms whether a btnL input applies clear and resets the timer value, showing that the CLEAR feature operates correctly.

## 6. Analysis & Trouble Shooting

### 6.1 FPGA Results

In the final implementation, the Timepiece and Timer functions were correctly connected and operated within the top module timepiecer.v. For Timepiece, the flow of screen switching, set-mode entry, value editing, 12-hour/24-hour switching, and applying the edited value after set exit was confirmed.

For Timer, mode switching followed by RUN start, display switching, and the reset behavior from a CLEAR input were confirmed. Also, the display structure using the 4-digit FND and DP operated as intended, allowing the output states of Timepiece and Timer to be distinguished and confirmed.

### 6.2 Root Cause Analysis

<img alt="analysis" src="https://github.com/user-attachments/assets/9c8b069b-495a-4198-8d9a-720df89d3656" />

The most significant issue during implementation was that a CLEAR input was not immediately applied while the Timer was in the RUN state. At first this looked like an error in the datapath itself, but after checking the simulation waveform, the actual cause turned out to be that the tick signal was being processed with priority over clear. In other words, even when clear came in, the next counting tick was applied first, so the tick_counter performed a counting operation instead of resetting — causing CLEAR to not take effect immediately.

### 6.3 Improvement

<img alt="trouble-shooting" src="https://github.com/user-attachments/assets/03a8c9dd-ed81-4a77-afc1-a9ccf7ba1aae" />

This issue was resolved by reorganizing the priority between clear and tick in the timer-side tick_counter implementation. After the fix, even during RUN, a clear input now causes a reset to happen before counting, securing the intended behavior. Through this experience, it became clear that when combining an FSM and a datapath, it's not enough to just check that a feature exists — the priority and timing of input signals must also be verified together. Going forward, control signals such as clear, tick, and run/stop should also be explicitly verified for priority in the testbench and waveform.

## 7. Conclusion

This project integrated the Timepiece and Timer functions into a single system on a Basys 3 basis, and organized the design into a structure that separates input conditioning, state control, the data path, and display selection. Each function was composed as a separate module, and by integrating them at the top level, the overall behavior flow could be consistently confirmed. Simulation and testbenches also verified that key features — set-mode entry, value editing, timer operation, display switching, and reset — behave as intended.

In terms of design outcomes, Timepiece, Timer, Top, and Testbench were integrated into a consistent layered structure on a Basys 3 basis, and the key functions were verified to operate normally. In terms of learning outcomes, applying FSM, Datapath, input conditioning, FND display control, module separation, and the verification flow to an actual design made it possible to directly implement and confirm the entire process of digital system design.

## References

[0] [Digilent, Basys 3 FPGA Board Reference Manual](https://digilent.com/reference/_media/basys3:%20basys3_rm.pdf?srsltid=AfmBOorSfp1B2JzTFeFYNMqdJCBcHI4_QOj_uAB7sJ0rpZ4jlHAIujej)

[1] [AMD, Vivado Design Suite User Guide](https://docs.amd.com/r/en-US/ug949-vivado-design-methodology/Finding-Additional-Documentation)
