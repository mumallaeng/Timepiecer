# Timepiecer

Basys 3 FPGA 보드에서 동작하는 `Timepiece + Timer` 통합 디지털 시계 시스템이다.
이 프로젝트는 단순히 시계와 타이머 기능을 각각 구현하는 데서 끝나지 않고, 입력 정제, FSM 기반 제어, datapath 분리, 표시 선택, 시뮬레이션 검증까지 포함한 전체 디지털 시스템 설계 흐름을 하나의 프로젝트로 정리하는 것을 목표로 한다.

## 프로젝트 정보

- 기간: `2026.04.16 ~ 2026.04.20`
- 팀: `김연우`, `이영현`
- 대상 보드: `Digilent Basys 3`

## 팀 역할 분담

| 이름 | 담당 범위 |
| --- | --- |
| 김연우 | `timepiece_fsm`, `timepiece_datapath`, `time_set_module`, `timepiecer` top 통합, Timepiece 관련 검증, 발표 자료 정리 |
| 이영현 | `debouncer`, `input_conditioning`, `timer_fsm`, `timer_datapath`, `timer_unit`, Timer 관련 검증 기반 구성 |

## 기술 스택

| 구분 | 내용 |
| --- | --- |
| HDL | `Verilog HDL` |
| EDA | `Vivado 2020.2` |
| Version Control | `Git`, `GitHub` |
| Board | `Digilent Basys 3` |
| Verification | `Behavioral Simulation`, `waveform capture (wcfg)` |

## 프로젝트 개요

Timepiecer는 하나의 상위 모듈 안에서 두 가지 기능을 제공한다.

- `Timepiece`
  - 실시간 시계 기능
  - 설정 모드 진입/종료
  - 편집 단위 이동
  - `+1 / -1 / +10 / -10` 시간 수정
  - `12h / 24h` 표시 전환
- `Timer`
  - `RUN / STOP`
  - `CLEAR`
  - `UP / DOWN` 방향 전환
  - `HH:MM / SS:MS` 표시 전환

이 프로젝트의 핵심은 다음과 같다.

- raw button을 직접 FSM에 넣지 않고 `input_conditioning`으로 정제한다.
- 제어부와 데이터 경로를 `FSM + datapath`로 분리한다.
- Timepiece는 `live time`과 `set time`을 분리해 편집 중에도 시간이 계속 흐르도록 설계한다.
- Timer와 Timepiece를 top level에서 통합하고, 하나의 4-digit FND로 선택적으로 표시한다.
- 모듈 단위 testbench와 top-level simulation으로 기능을 단계적으로 검증한다.

## 설계 사양

| 항목 | 값 |
| --- | --- |
| 보드 | Digilent Basys 3 |
| 주 클럭 | `100 MHz` |
| Timepiece 초기값 | `13:59:00.00` |
| 표시 형식 | `HH:MM`, `SS:MS` |
| 시간 포맷 | `24h`, `12h` |
| Timer tick 기준 | `100 Hz` |
| BtnR hold | `2.0 s` |
| BtnU / BtnD hold | `1.5 s` |
| hold repeat | `0.2 s` |

## 주요 동작

### Timepiece

- `sw0 = 0`일 때 활성화된다.
- 기본 실시간 시계 시작값은 `13:59:00.00`이다.
- `btnR hold`로 `SET` 모드에 진입하거나 종료한다.
- `SET` 모드 중에도 live clock은 계속 증가한다.
- 편집값은 별도 set bus에서 관리되며, `SET` 종료 시점에만 live clock에 1회 반영된다.
- `btnL`로 편집 위치를 이동한다.
- `btnU`, `btnD` short 입력은 `+1`, `-1` 편집에 사용된다.
- `btnU`, `btnD` hold 입력은 `+10`, `-10` 편집에 사용된다.
- `btnR short`는 `SET` 여부와 관계없이 `HH:MM <-> SS:MS` 표시를 전환한다.
- `sw15`로 `24h / 12h` 표시 형식을 전환한다.
- 설정 모드에서는 현재 편집 중인 자리만 blink 처리된다.

### Timer

- `sw0 = 1`일 때 활성화된다.
- short button 입력만 사용한다.
- `btnD`로 `RUN <-> STOP` 상태를 전환한다.
- `btnU`로 count 방향을 `UP / DOWN`으로 전환한다.
- `btnL`로 현재 timer 값을 초기화한다.
- `STOP`과 `RUN` 상태 모두에서 `CLEAR`와 `UP / DOWN` 제어가 가능하다.
- `btnR short`로 `HH:MM <-> SS:MS` 표시를 전환한다.

## Basys 3 제어 매핑

| Input | Timepiece 모드 (`sw0 = 0`) | Timer 모드 (`sw0 = 1`) |
| --- | --- | --- |
| `sw0` | Timepiece 선택 | Timer 선택 |
| `sw15` | `24h/12h` 표시 전환 | Timer 표시에서는 미사용 |
| `btnR` short | `HH:MM <-> SS:MS` 전환 | `HH:MM <-> SS:MS` 전환 |
| `btnR` hold | `SET` 모드 진입/종료 | 미사용 |
| `btnL` | 편집 인덱스 이동 | 현재 timer 값 클리어 |
| `btnU` short | 선택된 필드를 `1` 증가 | 카운트 방향 전환 |
| `btnU` hold | 선택된 필드를 `10` 증가 | 미사용 |
| `btnD` short | 선택된 필드를 `1` 감소 | Run/Stop 전환 |
| `btnD` hold | 선택된 필드를 `10` 감소 | 미사용 |

## 시스템 아키텍처

Timepiecer는 아래 블록들로 구성된다.

- `input_conditioning`
  - 버튼 입력 debounce
  - short / hold / repeat 이벤트 생성
- `common_control`
  - 표시 모드 전환 제어
- `timer_unit`
  - Timer FSM + Timer datapath
- `timepiece_unit`
  - Timepiece FSM + Timepiece datapath + time_set_module
- `display_select_logic`
  - Timer / Timepiece 출력 선택
  - `24h / 12h` 표시 반영
- `fnd_controller`
  - 4-digit FND 스캔
  - blink 제어
  - 가운데 DP 제어

전체 데이터 흐름은 다음 순서로 구성된다.

`입력 정제 -> 제어/데이터 경로 -> 표시 선택 -> FND 출력`

## 제어부와 데이터 경로

### Timepiece 제어부

`timepiece_fsm`은 다음 상태를 중심으로 동작한다.

- `VIEW`
- `SET`
- `INDEX_SHIFT`
- `INCREMENT_ONES`
- `INCREMENT_TENS`
- `DECREMENT_ONES`
- `DECREMENT_TENS`

이 FSM은 시간 값을 직접 수정하지 않고, 버튼 이벤트를 datapath 제어 펄스로 변환한다.

- `o_set_mode`
- `o_set_index`
- `o_index_shift`
- `o_increment`
- `o_increment_tens`
- `o_decrement`
- `o_decrement_tens`

이 구조를 통해 제어 경로와 데이터 경로를 분리하고 검증을 쉽게 만들었다.

### Timer 제어부

`timer_fsm`은 다음 네 가지 논리 상태를 사용한다.

- `STOP`
- `RUN`
- `CLEAR`
- `UPDOWN`

`CLEAR`와 `UPDOWN`은 1-step action state이며, 동작 후 `previous_state`를 기준으로 원래 안정 상태로 복귀한다. 따라서 Timer는 `RUN`과 `STOP` 상태 모두에서 clear 또는 방향 전환을 수행할 수 있다.

### Datapath 핵심

- Timer datapath는 `100 Hz` tick 기준으로 `msec -> sec -> min -> hour` 카운트 체인을 구성한다.
- Timepiece datapath는 실시간 시간 증가와 편집용 set bus를 분리하여 관리한다.
- `SET` 모드 종료 시 편집값을 live clock에 1회 반영한다.

## 설계 전략

| 항목 | 적용 전략 |
| --- | --- |
| 입력 안정성 | `input_conditioning`으로 raw button을 직접 FSM에 넣지 않음 |
| 제어/데이터 분리 | FSM과 datapath를 분리해 해석과 검증을 쉽게 함 |
| Timepiece 설정 | live time와 set time을 분리해 편집 중 동작 안정성 확보 |
| 표시 일관성 | Timepiece는 가운데 점 ON, Timer는 OFF로 구분 |
| 보드 한계 대응 | Basys 3에 실제 `:`가 없으므로 가운데 DP로 대체 |

## 검증

이 프로젝트는 [`Timepiecer.srcs/sim_1/new/`](Timepiecer.srcs/sim_1/new/) 아래에 모듈 단위 및 top-level simulation 소스를 포함한다.

- `tb_debouncer.v`
- `tb_input_conitioning.v`
- `tb_time_set.v`
- `tb_timepiece_fsm.v`
- `tb_timepiece.v`
- `tb_timer_fsm.v`
- `tb_timer_datapath.v`
- `tb_timer_unit.v`
- `tb_timepiecer.v`

검증 항목은 다음과 같다.

- 디바운싱된 short / hold 입력 동작
- short / hold / repeat 분리 검증
- Timepiece의 set 진입/종료
- `+1 / -1 / +10 / -10` 편집 규칙
- 편집 중 live time 유지
- `12h / 24h` 표시 변환
- Timer의 `STOP / RUN / UPDOWN / CLEAR` 전이
- Timer datapath의 증가, 감소, clear, carry
- top-level 통합 동작과 표시 선택

대표적인 top-level 시뮬레이션 시나리오는 다음과 같다.

- `BtnR hold 2s` 후 `VIEW -> SET`
- `BtnL`, `BtnU`, `BtnD`에 따른 현재 단위 수정
- `SET` 종료 시 편집값 반영
- `BtnD`에 따른 `STOP <-> RUN`
- `BtnU`에 따른 방향 전환
- `BtnL`에 따른 timer 초기화
- `SW0`, `SW15`, `BtnR`에 따른 표시/모드 전환

발표 및 디버깅에 사용한 waveform 설정은 [`wcfg/`](wcfg/)에 정리되어 있다.

## 결과 및 트러블슈팅

최종 구현 결과, `timepiecer.v` 상위 모듈에서 Timepiece와 Timer 기능은 정상적으로 연동되었다.

- Timepiece에서는 설정 모드 진입, 값 편집, `12h / 24h` 전환, 설정 종료 후 편집값 반영까지 확인했다.
- Timer에서는 모드 전환 후 `RUN` 시작, 표시 전환, `CLEAR` 입력에 따른 초기화 동작을 확인했다.
- 4-digit FND와 가운데 DP를 사용해 Timepiece와 Timer의 출력 상태를 구분해서 표시했다.

구현 과정에서 가장 중요한 문제는 Timer가 `RUN` 상태일 때 `CLEAR` 입력이 즉시 반영되지 않는 점이었다. waveform 분석 결과, 원인은 datapath 내부에서 `clear`보다 `tick`이 먼저 처리되는 우선순위 구조였다. 이 때문에 clear가 들어와도 다음 counting tick이 먼저 반영되어 초기화 대신 counting 동작이 수행되었다.

이 문제는 timer 쪽 `tick_counter` 구현에서 `clear`와 `tick`의 우선순위를 다시 정리함으로써 해결했다. 수정 후에는 `RUN` 중이더라도 clear 입력이 들어오면 counting보다 먼저 초기화가 수행되도록 바뀌었다. 이 경험을 통해 FSM과 datapath를 결합할 때는 기능 존재 여부뿐 아니라, 입력 신호의 우선순위와 반영 시점까지 함께 검증해야 한다는 점을 확인했다.

## 저장소 구조

- [`Timepiecer.srcs/sources_1/new/`](Timepiecer.srcs/sources_1/new/)
  - 현재 설계의 주요 RTL 소스
- [`Timepiecer.srcs/sim_1/new/`](Timepiecer.srcs/sim_1/new/)
  - 활성 simulation 소스
- [`vivado/`](vivado/)
  - 프로젝트 재생성 및 빌드 helper 스크립트
- [`wcfg/`](wcfg/)
  - 저장된 waveform 뷰
- [`Timepiecer.xpr`](Timepiecer.xpr)
  - Vivado 프로젝트 파일

## Vivado 사용법

### Tcl로 기준 프로젝트 재생성

```tcl
source vivado/create_timepiecer_project.tcl
```

### macOS에서 container helper로 빌드

```bash
./vivado/build_and_program_basys3.sh --build-only
```

### Basys 3 프로그래밍

```bash
openFPGALoader -b basys3 ./Timepiecer.runs/impl_1/timepiecer_nonproject.bit
```

### 빌드와 프로그래밍을 한 번에 수행

```bash
./vivado/build_and_program_basys3.sh
```

## 참고 및 관련 문서

- Basys 3 FPGA Board Reference Manual
- AMD Vivado Design Suite User Guide
- 장문의 설계/보고 문서는 저장소 외부 문서에서 관리한다.
- 현재 팀 작업 노트 경로:
  - `~/git/Vault/activities/korcham/notes/verilog-hdl/reports/watch-project-timepiece-timer/`
