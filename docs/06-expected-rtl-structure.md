# Watch Project Expected RTL Structure

## 문서 목적

이 문서는 현재 `main` 소스 기준으로 RTL이 어떻게 보여야 하는지 정리하는 문서임.

즉 "앞으로 이상적으로 이렇게 될 것"만 적는 문서가 아니라,

- 현재 구현된 Timer 구조
- 곧 채워질 Timepiece 구조

를 함께 보는 문서임.

## 현재 구현 기준 상위 RTL 구조

현재 소스를 기준으로 예상되는 상위 구조는 아래와 같음.

- `debouncer`
- `input_conditioning`
- `common_control`
- `timer_fsm`
- `timer_datapath`
- `timer_unit`
- `timepiece_fsm`
- `timepiece_datapath`
- `time_set_module`
- `display_select`
- `fnd_controller`

## 현재 구현된 Timer 쪽 예상 RTL

Timer 쪽은 실제로 아래 구조가 잡혀 있어야 함.

1. `input_conditioning` 안에 버튼별 `debouncer` 인스턴스 존재
2. `timer_fsm` 안에
   - `current_state`
   - `next_state`
   - `previous_state`
   - `updown_state`
   레지스터 존재
3. `timer_datapath` 안에
   - `tick_gen_100hz`
   - `tick_counter` 4개
   가 `msec -> sec -> min -> hour` 체인으로 존재
4. `timer_unit`이 `timer_fsm + timer_datapath`를 래핑함

즉 Timer 쪽은 이미 "제어 + 데이터 경로 분리"가 구현된 상태로 기대하면 됨.

## Timepiece 쪽 예상 RTL

Timepiece 쪽은 Timer 구조를 그대로 따라가면 됨.

예상 구조:

1. `timepiece_fsm`이 상태를 가짐
2. `timepiece_datapath`가 실시간 시계값을 가짐
3. `time_set_module`이 설정 버스를 관리함
4. `timepiece_datapath` 안에
   - `tick_gen_100hz`
   - `tick_counter` 4개
   - `time_set_module`
   가 연결됨

즉 Timepiece 쪽은 "Timer 구조의 대칭 복제 + setting 경로 추가"로 이해하면 됨.

## 현재 구현에서 바로 볼 수 있는 저장값

| 구분 | 현재 기준 |
| --- | --- |
| Timer 상태 레지스터 | `current_state`, `next_state`, `previous_state` |
| Timer 방향 저장 | `updown_state` |
| 공통 표시 저장 | `o_display_mode` |
| Timepiece 설정 버스 | `o_set_time` |
| Timepiece 실시간 버스 | `o_timepiece_vault` |

## 구조 해석 메모

- `common_control`은 현재 `display_mode` 쪽 저장값만 담당함
- `display_select`는 `SW0`, `SW15`를 받아 표시 대상을 선택함
- `top_stopwatch_watch`는 아직 최종 top이 아니므로, RTL 기대 구조는 개별 모듈 기준으로 보는 것이 더 정확함

즉 RTL schematic에서 가장 먼저 확인할 것은

- Timer 경로가 의도대로 분리되어 있는가
- Timepiece 경로가 Timer와 같은 패턴으로 올라가고 있는가

임.
