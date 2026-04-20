# Watch Project State Diagram Specification

## 문서 목적

이 문서는 `main`에 이미 구현된 Timer 상태도와, 앞으로 구현할 Timepiece 상태도를 같은 기준으로 그리기 위한 문서임.

즉 Timer는 "현재 코드 그대로", Timepiece는 "곧 구현할 기준안"으로 읽으면 됨.

## 작성 원칙

- `Timer`는 현재 `timer_fsm.v` 기준으로 그리기
- `Timepiece`는 `timepiece_fsm` 구현 목표 기준으로 그리기
- `set_index`, `updown_state`, `display_mode`는 노드가 아니라 보조 저장값으로 보기

## Timer FSM 상태도 기준

현재 `main` 구현 기준 상태는 아래 네 개임.

- `STOP`
- `RUN`
- `UPDOWN`
- `CLEAR`

### Timer 전이 표

| 전이 ID | 출발 | 조건 | 도착 | 설명 |
| --- | --- | --- | --- | --- |
| `TM-01` | `INIT` | `reset_release` | `STOP` | reset 후 기본 상태 |
| `TM-02` | `STOP` | `BtnD` | `RUN` | 실행 시작 |
| `TM-03` | `RUN` | `BtnD` | `STOP` | 실행 정지 |
| `TM-04` | `STOP` | `BtnU` | `UPDOWN` | 방향 전환 진입 |
| `TM-05` | `RUN` | `BtnU` | `UPDOWN` | 방향 전환 진입 |
| `TM-06` | `STOP` | `BtnL` | `CLEAR` | clear 진입 |
| `TM-07` | `RUN` | `BtnL` | `CLEAR` | clear 진입 |
| `TM-08` | `UPDOWN` | `previous_state == STOP` | `STOP` | 정지 상태로 복귀 |
| `TM-09` | `UPDOWN` | `previous_state == RUN` | `RUN` | 실행 상태로 복귀 |
| `TM-10` | `CLEAR` | `previous_state == STOP` | `STOP` | 정지 상태로 복귀 |
| `TM-11` | `CLEAR` | `previous_state == RUN` | `RUN` | 실행 상태로 복귀 |

## Timepiece FSM 상태도 기준

구현 목표 상태는 아래 일곱 개임.

- `VIEW`
- `SET`
- `INDEX_SHIFT`
- `INCREMENT_ONES`
- `INCREMENT_TENS`
- `DECREMENT_ONES`
- `DECREMENT_TENS`

### Timepiece 전이 표

| 전이 ID | 출발 | 조건 | 도착 | 설명 |
| --- | --- | --- | --- | --- |
| `TP-01` | `INIT` | `reset_release` | `VIEW` | 기본 상태 진입 |
| `TP-02` | `VIEW` | `BtnR hold 2s` | `SET` | 설정 진입 |
| `TP-03` | `SET` | `BtnR hold 2s` | `VIEW` | 설정 종료 |
| `TP-04` | `SET` | `BtnL` | `INDEX_SHIFT` | 편집 단위 이동 |
| `TP-05` | `SET` | `BtnU short` | `INCREMENT_ONES` | +1 처리 |
| `TP-06` | `SET` | `BtnU hold 1.5s` | `INCREMENT_TENS` | +10 처리 예정 |
| `TP-07` | `SET` | `BtnD short` | `DECREMENT_ONES` | -1 처리 |
| `TP-08` | `SET` | `BtnD hold 1.5s` | `DECREMENT_TENS` | -10 처리 예정 |
| `TP-09` | `INDEX_SHIFT` | `done` | `SET` | 단위 이동 후 복귀 |
| `TP-10` | `INCREMENT_ONES` | `done` | `SET` | 증가 후 복귀 |
| `TP-11` | `INCREMENT_TENS` | `done` | `SET` | 증가 후 복귀 |
| `TP-12` | `DECREMENT_ONES` | `done` | `SET` | 감소 후 복귀 |
| `TP-13` | `DECREMENT_TENS` | `done` | `SET` | 감소 후 복귀 |

## 상태도 메모

- `Timer`는 `previous_state`가 실제 구현에 존재하므로 다이어그램에도 반영하기
- `Timepiece`는 `set_index`가 상태 노드가 아니라 `time_set_module` 내부 저장값임
- `BtnU/BtnD hold`는 현재 문서에는 남겨두되, datapath는 아직 `+10/-10` 미구현 상태임

즉 Timepiece 상태도는 "구현 목표", Timer 상태도는 "현재 구현 사실"로 보는 것이 맞음.
