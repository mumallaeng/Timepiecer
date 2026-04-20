# Watch Project State Specification

## 문서 목적

이 문서는 현재 `main`에서 실제로 구현된 상태와, `Timepiece` 구현 시 그대로 따라가야 할 상태를 함께 정리하는 문서임.

즉 `Timer`는 구현 기준, `Timepiece`는 구현 예정 기준으로 읽으면 됨.

## 상태 명명 기준

- 상태명은 `대문자`
- FSM 안에서만 유일하면 됨
- 동작이 바로 보이게 짧게 쓰기

현재 기준 상태명:

- `TIMEPIECE`: `VIEW`, `SET`, `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS`
- `TIMER`: `STOP`, `RUN`, `UPDOWN`, `CLEAR`

## Timer FSM 상태 정의

아래 표는 현재 `main`의 `timer_fsm.v`를 기준으로 함.

| FSM | 상태명 | 의미 | 현재 구현 여부 |
| --- | --- | --- | --- |
| `TIMER` | `STOP` | 타이머 정지 상태 | 구현됨 |
| `TIMER` | `RUN` | 타이머 동작 상태 | 구현됨 |
| `TIMER` | `UPDOWN` | 방향 전환 처리 상태 | 구현됨 |
| `TIMER` | `CLEAR` | 값 초기화 처리 상태 | 구현됨 |

### Timer 저장값

| 이름 | 의미 | 현재 구현 여부 |
| --- | --- | --- |
| `previous_state` | `UPDOWN`, `CLEAR` 후 복귀할 상태 저장 | 구현됨 |
| `updown_state` | 현재 카운트 방향 저장 | 구현됨 |

## Timepiece FSM 상태 정의

아래 표는 현재 문서 설계 기준이며, `timepiece_fsm.v` 구현 시 그대로 따라가면 됨.

| FSM | 상태명 | 의미 | 현재 구현 여부 |
| --- | --- | --- | --- |
| `TIMEPIECE` | `VIEW` | 기본 시계 표시 상태 | 예정 |
| `TIMEPIECE` | `SET` | 설정 대기 상태 | 예정 |
| `TIMEPIECE` | `INDEX_SHIFT` | 편집 단위 이동 상태 | 예정 |
| `TIMEPIECE` | `INCREMENT_ONES` | 현재 단위 +1 처리 | 예정 |
| `TIMEPIECE` | `INCREMENT_TENS` | 현재 단위 +10 처리 | 예정 |
| `TIMEPIECE` | `DECREMENT_ONES` | 현재 단위 -1 처리 | 예정 |
| `TIMEPIECE` | `DECREMENT_TENS` | 현재 단위 -10 처리 | 예정 |

## 상태 외 저장값

| 이름 | 의미 | 현재 구현 기준 |
| --- | --- | --- |
| `display_mode` | `HH:MM ↔ SS:MS` 선택 | `common_control`에 반영 시작 |
| `set_index` | 현재 편집 단위 저장 | `time_set_module` 내부에 두는 구조 |
| `o_set_time[23:0]` | 설정 버스 | `time_set_module` 출력 |
| `o_timepiece_vault[23:0]` | 현재 시계 실시간 버스 | `timepiece_datapath` 출력 |
| `timer_value` | 현재 타이머 값 | `timer_datapath` 출력 |

## Timepiece 구현 기준

`Timepiece`는 아래 방식으로 구현하면 현재 `Timer`와 구조가 맞음.

- 상태 저장: `timepiece_fsm`
- 단위 저장: `time_set_module`의 `set_index`
- 실시간 카운트: `timepiece_datapath`
- 편집 버스: `o_set_time`

즉 `position_shift`, `edit_action` 같은 추상 이름보다, 현재 코드 기준에서는

- `set_index`
- `index_shift`
- `increment`
- `decrement`

처럼 직접 제어신호 이름으로 맞추는 편이 더 자연스러움.
