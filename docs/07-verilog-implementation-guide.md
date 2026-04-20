# Watch Project Verilog Implementation Guide

## 문서 목적

이 문서는 현재 `main` 소스에 실제로 있는 모듈 이름과 포트 기준으로 구현 방향을 맞추기 위한 문서임.

즉 추상 이름보다, 지금 프로젝트 파일 이름과 실제 포트를 우선 기준으로 삼음.

## 현재 구현된 핵심 모듈

| 모듈 | 역할 | 구현 상태 |
| --- | --- | --- |
| `debouncer` | 버튼 1회 펄스 + hold 펄스 생성 | 구현됨 |
| `input_conditioning` | 버튼/스위치 입력 정리 | 구현됨 |
| `common_control` | display mode 저장 | 구현됨 |
| `timer_fsm` | Timer 상태 제어 | 구현됨 |
| `timer_datapath` | Timer 카운트 체인 | 구현됨 |
| `timer_unit` | Timer wrapper | 구현됨 |
| `display_select` | Timer/Timepiece, 12h/24h 선택 | 구현됨 |
| `timepiece_datapath` | Timepiece 데이터 경로 | 구현 중 |
| `time_set_module` | Timepiece 설정 버스 | 구현 중 |
| `timepiece_fsm` | Timepiece 상태 제어 | 스텁 |

## 구현 기준 포트 해석

### `input_conditioning`

현재 포트 기준:

- 입력: `btnU`, `btnD`, `btnL`, `btnR`, `sw0`, `sw15`
- 출력: `o_btnU`, `o_btnD`, `o_btnL`, `o_btnR`, `o_btnU_hold`, `o_btnD_hold`, `o_btnL_hold`, `o_btnR_hold`, `o_sw0`, `o_sw15`

즉 Timepiece FSM은 raw button 대신 이 출력을 기준으로 설계하는 것이 맞음.

### `timer_fsm`

현재 포트 기준:

- 입력: `i_btnD`, `i_btnL`, `i_btnU`, `i_sw0`
- 출력: `o_runstop`, `o_clear`, `o_updown`

즉 Timer는 "버튼 이벤트 -> FSM -> datapath 제어신호" 구조가 이미 잡혀 있음.

### `timer_datapath`

현재 포트 기준:

- 입력: `i_runstop`, `i_clear`, `i_updown`
- 출력: `msec`, `sec`, `min`, `hour`

즉 Timepiece datapath도 비슷하게 "FSM 출력 -> datapath 제어 입력" 구조로 맞추는 것이 좋음.

### `timepiece_datapath`

현재 구현 방향 기준:

- 입력: `i_set_mode`, `i_set_index`, `i_index_shift`, `i_increment`, `i_decrement`, `i_time_24`
- 출력: `o_set_time`, `o_timepiece_vault`, `o_sec_tick`, `o_min_tick`, `o_hour_tick`, `msec`, `sec`, `min`, `hour`

즉 Timepiece는 Timer보다 설정 경로가 하나 더 들어간 datapath로 보면 됨.

## 구현 방향 요약

Timer 쪽을 기준으로 보면 Timepiece는 아래처럼 구현하면 됨.

- `timer_fsm` 역할 → `timepiece_fsm`
- `timer_datapath` 역할 → `timepiece_datapath`
- Timer에 없는 설정 버스 → `time_set_module`

즉 현재 코드 스타일을 유지하려면

- 입력 정제는 `input_conditioning`
- 상태 제어는 `timepiece_fsm`
- 데이터 경로는 `timepiece_datapath`
- 설정 버스는 `time_set_module`

으로 나누는 것이 가장 자연스러움.

## 현재 문서 기준 reg/wire 해석

| 항목 | 권장 타입 |
| --- | --- |
| `*_state`, `previous_state`, `updown_state` | `reg` |
| `o_display_mode` | `reg` |
| `msec/sec/min/hour` 내부 저장값 | `reg` |
| `o_set_time`, `o_timepiece_vault` | `wire` 출력 |
| `w_tick_100hz`, `w_sec_tick`, `w_min_tick`, `w_hour_tick` | `wire` |
| `*_next` | 조합논리용 `reg` |

## 구현 기준 메모

- 현재 `main` 기준으로 가장 완성된 스타일은 `timer_fsm + timer_datapath + timer_unit`
- Timepiece도 이 패턴을 따라가는 것이 문서와 코드가 가장 잘 맞음
- `top_stopwatch_watch`는 아직 최종 구조 기준 문서로 삼기보다, 개별 모듈 구조를 우선 기준으로 보는 것이 좋음
