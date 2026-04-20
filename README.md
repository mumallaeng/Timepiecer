# Timepiecer

2026.04.16 ~ 2026.04.20

<img width="400" height="400" alt="stopwatch+watch-x2-timepiece" src="https://github.com/user-attachments/assets/7f7573ad-3501-4338-9902-16e2dba8d566" />

<img width="400" height="400" alt="stopwatch+watch-x2-timer" src="https://github.com/user-attachments/assets/f085ffe0-6fec-4139-8cd8-3adc5b4a19fc" />

| 이름 | 담당 |
| --- | --- |
| 김⁠연⁠우 | **Timepiece 설계·구현·검증**: timepiece_fsm, timepiece_datapath, time_set_module, timepiecer |
| 이⁠영⁠현 | **Timer 설계·구현·검증**: debouncer, input_conditioning, timer_fsm, timer_datapath, timer_unit |

## 1. 개요 (Overview)

### 1.1 목적 및 목표

이번 프로젝트의 목적은 Basys 3 보드에서 동작하는 Timepiecer를 설계하고, Timer와 Timepiece 기능을 하나의 시스템으로 통합하여 구현하는 것이다. 단순히 개별 기능을 만드는 데서 끝나는 것이 아니라, 버튼 입력 처리, 상태 전이, 데이터 경로, 디스플레이 제어, 시뮬레이션 검증까지 포함한 전체 디지털 시스템 설계 흐름을 직접 확인하는 데 의미가 있다.

구체적인 목표는 다음과 같다.

- Timepiece와 Timer 기능을 각각 독립적으로 설계하고, 상위 모듈에서 하나의 프로젝트로 통합한다.
- 버튼 입력의 short press, hold, debounce 처리를 통해 실제 보드 환경에서 안정적으로 동작하는 입력 구조를 구현한다.
- FSM과 datapath를 분리하여 상태 제어와 데이터 갱신의 역할 차이를 명확히 이해한다.
- HH:MM과 SS:MS 표시 전환, 12-hour / 24-hour 형식 전환, set mode 편집 기능 등 실제 시계 동작에 가까운 기능을 구현한다.
- Timer와 Timepiece가 선택적으로 표시되더라도 내부 동작은 요구사항에 맞게 유지되도록 시스템 구조를 설계한다.
- 모듈 단위 testbench, 통합 시뮬레이션, 보드 동작 확인을 통해 설계 결과를 단계적으로 검증한다.

즉, 이번 프로젝트는 Verilog HDL을 이용하여 입력 처리 -> 상태 제어 -> 데이터 처리 -> FND 표시 -> 검증으로 이어지는 전체 설계 과정을 종합적으로 수행하고, 이를 실제 FPGA 보드에서 확인하는 것을 최종 목표로 한다.

### 1.2 설계 범위

이번 프로젝트의 설계 범위는 Timepiece, Timer, Display, Verification 네 영역으로 구성된다. 각 영역에서 담당하는 기능은 다음과 같다.

| 구분 | 내용 |
| --- | --- |
| Timepiece | 실시간 시계, set 진입/종료, 단위 이동, +1/-1/+10/-10, 12h/24h 표시 |
| Timer | run/stop, clear, up/down, HH:MM/SS:MS 표시 |
| Display | 4-digit FND, 가운데 DP, set blink |
| Verification | unit TB, top TB, waveform capture |

본 보고서에서는 위 범위를 기준으로 시스템의 설계 구조와 구현 결과를 정리한다.

### 1.3 프로젝트 요약

Timepiecer는 Basys 3 기반의 Timepiece + Timer 통합 디지털 시계 시스템이다. 하나의 상위 구조 안에서 시계 기능과 타이머 기능을 함께 제공하며, 버튼 입력을 통해 시간 설정, 표시 전환, 실행 제어, 방향 전환 등의 동작을 수행한다.

<img alt="system_function" src="https://github.com/user-attachments/assets/9528a50d-7e47-4efd-ac8e-1c90d43649fc" />

시계 기능은 현재 시간을 유지하면서 set mode를 통한 편집 기능을 제공하고, 타이머 기능은 run/stop, clear, up/down 제어가 가능하도록 구성함. 표시부는 4-digit FND를 사용하며, HH:MM 또는 SS:MS 형식을 선택적으로 출력한다.

### 1.4 설계 사양 요약 (Specification Summary)

| 항목 | 값 |
| --- | --- |
| 보드 | Digilent Basys 3 |
| 주 클럭 | 100 MHz |
| Timepiece 초기값 | 13:59:00.00 |
| 표시 형식 | HH:MM, SS:MS |
| 시간 포맷 | 24h, 12h |
| Timer tick 기준 | 100 Hz |
| BtnR hold | 2.0 s |
| BtnU/BtnD hold | 1.5 s |
| hold repeat | 0.2 s |

## 2. 프로젝트 관리 (Project Management)

### 2.1 역할 분담

| 분류 | 김⁠연⁠우([@mumallaeng](https://github.com/mumallaeng)) | 이⁠영⁠현([@younghyun0702](https://github.com/younghyun0702)) |
| --- | --- | --- |
| 실제 담당 범위 | Timepiece 전체 구현, Time Set 구현, 최종 top 연동 | Timer 전체 구현, 입력 정제 초안 구현, 초기 top 결합 |
| 주요 구현 파일 (공통 제외) | timepiece_fsm.v, timepiece_datapath.v, time_set_module.v, timepiecer.v | timer_fsm.v, timer_datapath.v, timer_unit.v, top_stopwatch_watch.v |
| 테스트벤치 파일 | tb_time_set.v, tb_timepiece.v, tb_timepiece_fsm.v, tb_timepiecer.v | tb_debouncer.v, tb_input_conitioning.v, tb_timer_fsm.v, tb_timer_datapath.v, tb_timer_unit.v |
| 근거 커밋 | c10e779, d74f9b8, 1e940c6, 0352d5f, 8f5d71c, c7dff1c, e47b79a, 588605e | 9460045, 5444819, 9a00eb4, 1c73393, e4a79bd, 6369c6e |

**공통 작업 파일**

| 분류 | 김⁠연⁠우([@mumallaeng](https://github.com/mumallaeng)) | 이⁠영⁠현([@younghyun0702](https://github.com/younghyun0702)) |
| --- | --- | --- |
| debouncer.v | Timepiece의 set에서 hold 이후 반복 입력이 가능하도록 보정함 | 버튼 입력을 한 번만 인식할 수 있도록 debounce와 기본 hold 검출 구조를 처음 작성함 |
| input_conditioning.v | Timepiece의 set에 진입하기 위한 BtnR 2초 hold, UP/DOWN 1.5초 hold, 반복 입력 규칙을 추가함 | 버튼 입력을 정제해서 Timer FSM에 전달하는 기본 구조를 처음 작성함 |
| display_select.v | HH:MM ↔ SS:MS, Timepiece ↔ Timer 설정 모드 유지 규칙이 최종 UX와 맞도록 보정함 | 초기 top에서 Timer ↔ Stopwatch 화면을 선택해서 표시하는 기본 구조를 작성함 |
| common_control.v | 오른쪽 버튼 short는 화면 전환, hold는 설정 진입/종료가 되도록 공통 제어 규칙을 정리함 | 공통 제어 초안을 작성해서 버튼과 스위치에 따라 표시 모드가 바뀌는 기본 틀을 만듦 |
| fnd_controller.v | Timepiece의 set 중인 자리 blink 처리 | FND dot 위치를 표시하는 초기 코드를 작성함 |

### 2.2 일정 계획 (Schedule)

| 기간 | 작업 |
| --- | --- |
| 2026.04.16 ~ 2026.04.17 | 요구사항 정리, 블록 구조 설계 |
| 2026.04.17 ~ 2026.04.18 | Timer / Timepiece 모듈 구현 및 수정 |
| 2026.04.18 ~ 2026.04.19 | testbench 작성, waveform 검증, top 통합 |
| 2026.04.20 | 발표 자료 및 보고서 정리 |

<img alt="schedule-1" src="https://github.com/user-attachments/assets/afb07951-7a8c-496b-bc37-aa9ce10bec1a" />

<img alt="schedule-2" src="https://github.com/user-attachments/assets/4dde07f6-86b0-4431-b8e7-bae37c4a0e3d" />

### 2.3 개발 환경 (Development Environment)

| 항목 | 내용 |
| --- | --- |
| HDL | Verilog HDL |
| EDA | Vivado 2020.2 [1] |
| 버전 관리 | Git, GitHub |
| 작업 환경 | Windows 11 Pro |

### 2.4 설계 환경 (Design Environment)

| 항목 | 내용 |
| --- | --- |
| Top module | timepiecer.v |
| Verification | Behavioral Simulation, wcfg 기반 waveform capture |
| 대상 보드 | Basys 3 [0] |

## 3. 아키텍처 설계 (Architecture)

### 3.1 시스템 구조

<img alt="system-architecture" src="https://github.com/user-attachments/assets/30feec9e-b837-4c0a-9565-3fdfd66afacf" />

| 블록 | 역할 | 내용 |
| --- | --- | --- |
| input_conditioning | 입력 정제 | 버튼 short/hold/repeat 생성 |
| common_fsm | 공통 제어 | BtnR short에 의한 display mode 저장 |
| timer_unit | Timer 경로 | Timer 상태 제어 및 카운트 |
| timepiece_unit | Timepiece 경로 | 시계 제어, 실시간 시간, 설정 버스 |
| display_select_logic | 표시 선택 | Timepiece/Timer, 24h/12h 표시 선택 |
| fnd_controller | 표시 출력 | FND 스캔, blink, 가운데 DP 제어 |

데이터 흐름은 입력 정제 -> 제어/데이터 경로 -> 표시 선택 -> FND 출력 순서로 구성된다.

### 3.2 설계 이론 및 배경 (Theory & Background)

#### 3.2.1. FSM

**Timepiecer**

<img width="543" height="703" alt="timepiecer-FSM" src="https://github.com/user-attachments/assets/ba073ed2-fffe-4ac5-ad32-0becd39b2b32" />

Timepiece FSM은 short press와 hold 입력을 구분하여 처리하며, 이를 설정 모드 제어와 시간 편집에 필요한 각종 control pulse로 변환한다. 즉, 사용자의 버튼 입력 의미를 Datapath가 해석 가능한 편집 명령으로 매핑하는 제어 블록이라 할 수 있다.

**Timer**

<img width="722" height="521" alt="timer-FSM" src="https://github.com/user-attachments/assets/b0466ac4-b286-4c91-a54d-e75d9dd7b3c5" />

Timer FSM은 short press 입력만을 사용하며, 이를 clear, count up/down, run/stop 제어 신호로 변환한다. 또한 STOP과 RUN 상태 모두에서 CLEAR 및 UPDOWN 동작이 가능하며, 동작 완료 후에는 previous_state를 기준으로 원래 상태로 복귀하도록 구성되어 있다.

#### 3.2.2. ASM

**Timepiece_unit**

<img width="1881" height="1377" alt="timepiece-ASM" src="https://github.com/user-attachments/assets/2b01562e-c4ef-46fe-a690-88754200346d" />

본 ASM은 Timepiece FSM의 전체 제어 흐름을 나타낸다. Timepiece는 기본적으로 VIEW 상태에서 동작하며, btnR_hold 입력에 의해 SET 상태로 진입하거나 다시 VIEW 상태로 복귀한다. 설정 상태에서는 현재 표시 모드에 맞는 set index가 선택되며, btnL 입력은 편집 위치를 이동시키는 INDEX_SHIFT, btnU와 btnD의 short 입력은 각각 1-step 증가 및 감소, hold 입력은 각각 10-step 증가 및 감소 상태로 전이된다. 이들 INDEX_SHIFT, INCREMENT, DECREMENT 계열 상태는 모두 1클럭 동안만 유지되는 action state로 동작한 뒤 다시 SET 상태로 복귀한다. 또한 설정 도중 표시 모드가 변경되면 현재 보이는 단위에 맞추어 set index가 remap되도록 구성되어 있다. short press와 hold 입력을 구분하여 해석하고, 이를 설정 모드 제어와 시간 편집용 control pulse로 변환하는 핵심 제어 블록이라 할 수 있다.

**timer_unit**

<img width="1230" height="1100" alt="timer-ASM" src="https://github.com/user-attachments/assets/7d3e62ef-6fcc-49c5-b9cf-3b5fd2250b0f" />

본 ASM은 Timer FSM의 상태 전이 구조를 나타낸다. Timer 제어부는 sw0 == 1일 때만 활성화되며, 지속 상태인 STOP과 RUN, 그리고 순간 동작 상태인 CLEAR와 UPDOWN으로 구성된다. btnD 입력은 STOP과 RUN 상태를 상호 전환시키며, btnL 입력은 CLEAR 상태를 발생시켜 카운터 값을 초기화하고, btnU 입력은 UPDOWN 상태를 발생시켜 count 방향을 반전시킨다. 또한 CLEAR와 UPDOWN 상태는 동작 후 previous_stat를 기준으로 원래 상태로 복귀하도록 설계되어 있으므로, STOP과 RUN 상태 모두에서 초기화와 방향 전환이 가능하다. 이와 같은 구조를 통해 Timer FSM은 사용자의 short press 입력을 run/stop, clear, up/down 제어 신호로 변환하는 역할을 담당한다.

**display_unit**

<img width="893" height="590" alt="display_unit-ASM" src="https://github.com/user-attachments/assets/70d5c59d-968d-4abf-b16d-d841635faad7" />

본 ASM은 display mode control 블록의 동작을 나타낸다. 해당 제어기는 o_display_mode라는 1비트 상태 변수를 기반으로 동작하는 단순 ASM 구조로 볼 수 있다. Reset 시에는 sw0 상태에 따라 기본 표시 모드가 결정되며, 이후 btnR의 short 입력이 들어오면 다음 클럭에서 o_display_mode가 toggle되어 표시 화면이 전환된다. 입력이 없을 경우에는 현재 표시 모드가 그대로 유지된다. 따라서 이 블록은 Timepiece와 Timer의 동작 자체를 제어하기보다는, 사용자에게 보여 주는 표시 형식을 전환하는 역할을 수행한다.

## 4. 상세 설계 (Detailed Design)

### 4.1 RTL

<img alt="timepiecer-RTL" src="https://github.com/user-attachments/assets/8f7f4556-d6c9-4bf4-9f5f-b568cc59a643" />

| 모듈 | 설명 |
| --- | --- |
| timer_fsm | STOP/RUN/UPDOWN/CLEAR 상태 제어 |
| timer_datapath | msec/sec/min/hour 카운트 체인 |
| timer_unit | Timer FSM + Datapath 래핑 |
| timepiece_unit | Timepiece FSM + Datapath 래핑 |
| display_select | display_select + fnd_controller 래핑 |

### 4.2 Datapath / Control

| 구분 | 내용 |
| --- | --- |
| Timer control | BtnD로 run/stop, BtnU로 방향 전환, BtnL로 clear |
| Timer datapath | 100 Hz tick 기준으로 msec -> sec -> min -> hour 갱신 |
| Timepiece control | BtnR hold set 진입/종료, BtnL index shift, BtnU/BtnD 값 수정 |
| Timepiece datapath | 실시간 시간은 계속 증가하고, 설정값은 별도 bus에서 편집 |

**중요 구현 사실:**

| 항목 | 내용 |
| --- | --- |
| Timepiece 초기값 | 13:59:00.00 |
| set 중 동작 | live clock가 계속 흐름 |
| set 종료 | 편집값을 live clock에 1회 반영 |
| BtnR short | view/set 구분 없이 HH:MM ↔ SS:MS 전환 |
| BtnR hold | Timepiece set 진입/종료 전용 |
| blink | set 모드에서 현재 편집 단위만 blink |

### 4.3 Timing 설계

| 항목 | 내용 |
| --- | --- |
| Main clock | 100 MHz |
| Timer count tick | 100 Hz |
| Debounce sample | 100 kHz 기준 샘플링 |
| BtnR hold | 2.0 s |
| BtnU/BtnD hold | 1.5 s |
| hold repeat | 0.2 s |

### 4.4 설계 전략 (Design Strategy)

| 항목 | 적용 전략 |
| --- | --- |
| 입력 안정성 | input_conditioning으로 raw button을 직접 FSM에 넣지 않음 |
| 제어/데이터 분리 | FSM과 datapath를 분리하여 해석과 검증을 쉽게 함 |
| Timepiece 설정 | live time와 set time을 분리하여 set 중 동작 안정성 확보 |
| 표시 일관성 | Timepiece는 가운데 점 ON, Timer는 OFF로 구분 |
| 보드 한계 대응 | Basys 3에 실제 :가 없으므로 가운데 DP로 대체 |

## 5. 시뮬레이션 및 검증 (Simulation & Verification)

### 5.1 Testbench

| Testbench | 확인 내용 |
| --- | --- |
| tb_debouncer.v | short/hold 입력 정제 |
| tb_input_conitioning.v | short/hold/repeat 분리 |
| tb_time_set.v | set bus 편집, +1/-1/+10/-10, wrap |
| tb_timepiece_fsm.v | 상태 전이, set_index, tens pulse |
| tb_timepiece.v | live/set 분리, apply load, 12h/24h |
| tb_timer_fsm.v | STOP/RUN/UPDOWN/CLEAR 전이 |
| tb_timer_datapath.v | 증가, 감소, clear, carry |
| tb_timer_unit.v | Timer FSM + Datapath 통합 |
| tb_timepiecer.v | 최종 top 통합 동작 |

### 5.2 시뮬레이션 시나리오

Testbanch 중에서 대표로 tb_timepiecer.v의 시뮬레이션 시나리오를 다룬다.

| 시나리오 | 기대 동작 |
| --- | --- |
| Timepiece set 진입 | BtnR hold 2s 후 VIEW -> SET |
| Timepiece 편집 | BtnL, BtnU, BtnD에 따라 현재 단위 수정 |
| Timepiece apply | set 종료 시 편집값이 live clock에 반영 |
| Timer run/stop | BtnD에 따라 STOP <-> RUN |
| Timer up/down | BtnU에 따라 방향 전환 |
| Timer clear | BtnL에 따라 값 초기화 |
| Top integration | SW0, SW15, BtnR에 따라 표시/모드 전환 |

### 5.3 Waveform 분석

<img alt="waveform-1" src="https://github.com/user-attachments/assets/fb98f9c6-dd21-48fe-b805-382a01be975f" />

본 파형은 Top level에서 Timepiece의 전체 동작 흐름을 검증한 결과이다. 빨간 구간에서는 화면 전환 후 설정 모드 진입을, 파란 구간에서는 값 편집 동작을, 노란 구간에서는 12시간제 전환 동작을 확인하였다. 최종적으로 설정 종료 이후 편집한 값이 실제 시계값에 반영되는 것을 확인함으로써, Timepiece의 설정 및 표시 동작이 정상적으로 수행됨을 검증하였다.

<img alt="waveform-2" src="https://github.com/user-attachments/assets/8fd93b6c-bccb-4b21-8b1c-e6708a1f3bb6" />

Top level에서 Timer의 전체 동작 흐름을 확인한 파형으로, 빨간 구간에서는 sw0를 통한 Timer 모드 전환 이후 btnD 입력에 따라 count가 시작되고, 노란 구간에서는 btnR short 입력에 따라 표시 화면이 전환되는 동작을 검증한 구간이다.

<img alt="waveform-3" src="https://github.com/user-attachments/assets/c5489613-9f6b-4fba-8fbb-0554a7321f55" />

btnL 입력 시 clear가 반영되어 timer 값이 초기화되는지를 확인한 파형으로, CLEAR 기능이 정상적으로 수행됨을 보여준다.

## 6. 결과 분석 및 트러블슈팅 (Analysis & trouble shooting)

### 6.1 FPGA 결과

최종 구현 결과, Timepiece와 Timer 기능은 상위 모듈 timepiecer.v 안에서 정상적으로 연결되어 동작하였다. Timepiece에서는 화면 전환 후 설정 모드 진입, 값 편집, 12-hour / 24-hour 전환, 설정 종료 후 편집값 반영까지의 흐름을 확인하였다.

Timer에서는 모드 전환 후 RUN 시작, 표시 화면 전환, CLEAR 입력에 따른 초기화 동작을 확인하였다. 또한 4-digit FND와 DP를 이용한 표시 구조도 의도한 방식대로 동작하여, Timepiece와 Timer의 출력 상태를 구분해 확인할 수 있었다.

### 6.2 문제 원인 분석

<img alt="analysis" src="https://github.com/user-attachments/assets/9c8b069b-495a-4198-8d9a-720df89d3656" />

구현 과정에서 가장 중요한 문제는 Timer가 RUN 상태일 때 CLEAR 입력이 즉시 반영되지 않는 점이었다. 처음에는 datapath 자체의 오류로 보였으나, 시뮬레이션 파형을 확인한 결과 실제 원인은 tick 신호가 clear보다 우선으로 처리되고 있었기 때문이었다. 즉, clear가 들어와도 다음 counting tick이 먼저 반영되면서 tick_counter가 초기화 대신 counting 동작을 수행하였고, 이로 인해 CLEAR가 즉시 적용되지 않는 문제가 발생하였다.

### 6.3 개선 방안

<img alt="trouble-shooting" src="https://github.com/user-attachments/assets/03a8c9dd-ed81-4a77-afc1-a9ccf7ba1aae" />

이 문제는 timer 쪽 tick_counter 구현에서 clear와 tick의 우선순위를 다시 정리함으로써 해결하였다. 수정 후에는 RUN 중이라도 clear 입력이 들어오면 counting보다 먼저 초기화가 수행되도록 하여 의도한 동작을 확보하였다. 이번 경험을 통해 FSM과 datapath를 결합할 때는 기능 존재 여부만 확인하는 것이 아니라, 입력 신호의 우선순위와 반영 시점까지 함께 검증해야 한다는 점을 확인하였다. 따라서 이후 설계에서도 clear, tick, run/stop과 같은 제어 신호는 testbench와 waveform에서 우선순위를 명확히 검증하는 방식으로 진행할 필요가 있다.

## 7. 결론

본 프로젝트는 Basys 3 기반에서 Timepiece와 Timer 기능을 하나의 시스템으로 통합 구현하고, 입력 정제, 상태 제어, 데이터 경로, 표시 선택을 분리한 구조로 설계를 정리한 것이다. 각 기능은 모듈 단위로 분리하여 구성하였으며, Top level에서 이를 연동함으로써 전체 동작 흐름을 일관되게 확인할 수 있도록 하였다. 또한 simulation과 testbench를 통해 설정모드 진입, 값 편집, 타이머 동작, 표시 전환, 초기화와 같은 주요 기능이 의도한 대로 동작함을 검증하였다.

설계 성과 측면에서는 Basys 3 기반에서 Timepiece, Timer, Top, Testbench를 일관된 계층 구조로 통합하고, 주요 기능이 정상적으로 동작함을 검증하였다. 학습 내용 측면에서는 FSM, Datapath, 입력 정제, FND 표시 제어, 모듈 분리 및 검증 흐름을 실제 설계에 적용해 보면서 디지털 시스템 설계의 전체 과정을 직접 구현하고 확인할 수 있었다.

## 참고 문헌

[0] [Digilent, Basys 3 FPGA Board Reference Manual](https://digilent.com/reference/_media/basys3:%20basys3_rm.pdf?srsltid=AfmBOorSfp1B2JzTFeFYNMqdJCBcHI4_QOj_uAB7sJ0rpZ4jlHAIujej)

[1] [AMD, Vivado Design Suite User Guide](https://docs.amd.com/r/en-US/ug949-vivado-design-methodology/Finding-Additional-Documentation)
