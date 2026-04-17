# Watch Project State Diagram Specification

## 문서 목적

이 문서는 `State Diagram`을 그릴 때 어떤 상태를 노드로 쓰고, 어떤 전이를 화살표로 표현할지 기준을 정리한다.

이번 설계에서는 `TIMEPIECE FSM`과 `TIMER FSM`을 분리해서 해석하므로, 상태도도 가능하면 두 개로 나누어 그리는 것이 가장 자연스럽다.

## 상태도 작성 원칙

- 상태도는 `04-state-spec.md`에 정의된 FSM 상태만 사용한다.
- `Function` 문서의 기능 이름은 화살표 라벨 설명으로만 사용한다.
- `hour_format`, `display_mode`, `position_shift`, `count_updown`은 상태도 노드가 아니라 저장값이므로 보조 주석으로만 표현한다.
- `position_shift` 보조 주석은 `SHIFT_MSEC → SHIFT_SEC → SHIFT_MIN → SHIFT_HOUR` 순환을 명시한다.

## Timepiece FSM 상태도 대상

Timepiece FSM 상태도에서 사용할 노드는 아래 일곱 개다.

- `VIEW`
- `SET`
- `INDEX_SHIFT`
- `INCREMENT_ONES`
- `INCREMENT_TENS`
- `DECREMENT_ONES`
- `DECREMENT_TENS`

### Timepiece FSM 전이 표

| 전이 ID | FSM | 출발 상태 | 입력/조건 | 도착 상태 | 설명 |
| --- | --- | --- | --- | --- | --- |
| `TP-01` | `TIMEPIECE` | `INIT` | `Reset Release` | `VIEW` | 기본 시작 상태 |
| `TP-02` | `TIMEPIECE` | `VIEW` | `BtnR hold 2s` | `SET` | 시간 설정 모드 진입 |
| `TP-03` | `TIMEPIECE` | `SET` | `BtnR hold 2s` | `VIEW` | 시간 설정 모드 종료 |
| `TP-04` | `TIMEPIECE` | `SET` | `BtnL` | `INDEX_SHIFT` | 시간 단위 이동 처리 |
| `TP-05` | `TIMEPIECE` | `SET` | `BtnU short` | `INCREMENT_ONES` | 1의 자리 증가 처리 |
| `TP-06` | `TIMEPIECE` | `SET` | `BtnU hold 1.5s` | `INCREMENT_TENS` | 10의 자리 증가 처리 |
| `TP-07` | `TIMEPIECE` | `SET` | `BtnD short` | `DECREMENT_ONES` | 1의 자리 감소 처리 |
| `TP-08` | `TIMEPIECE` | `SET` | `BtnD hold 1.5s` | `DECREMENT_TENS` | 10의 자리 감소 처리 |
| `TP-09` | `TIMEPIECE` | `INDEX_SHIFT` | `done` | `SET` | 단위 이동 후 복귀 |
| `TP-10` | `TIMEPIECE` | `INCREMENT_ONES` | `done` | `SET` | 증가 후 복귀 |
| `TP-11` | `TIMEPIECE` | `INCREMENT_TENS` | `done` | `SET` | 증가 후 복귀 |
| `TP-12` | `TIMEPIECE` | `DECREMENT_ONES` | `done` | `SET` | 감소 후 복귀 |
| `TP-13` | `TIMEPIECE` | `DECREMENT_TENS` | `done` | `SET` | 감소 후 복귀 |

## Timer FSM 상태도 대상

Timer FSM 상태도에서 사용할 노드는 아래 네 개다.

- `STOP`
- `RUN`
- `COUNT_UPDOWN`
- `COUNT_CLEAR`

### Timer FSM 전이 표

| 전이 ID | FSM | 출발 상태 | 입력/조건 | 도착 상태 | 설명 |
| --- | --- | --- | --- | --- | --- |
| `TM-01` | `TIMER` | `INIT` | `Timer Mode Entry` | `STOP` | Timer 기본 진입 상태 |
| `TM-02` | `TIMER` | `STOP` | `BtnD` | `RUN` | 타이머 시작 |
| `TM-03` | `TIMER` | `RUN` | `BtnD` | `STOP` | 타이머 정지 |
| `TM-04` | `TIMER` | `STOP` | `BtnU` | `COUNT_UPDOWN` | 방향 전환 처리 |
| `TM-05` | `TIMER` | `RUN` | `BtnU` | `COUNT_UPDOWN` | 동작 중 방향 전환 처리 |
| `TM-06` | `TIMER` | `STOP` | `BtnL` | `COUNT_CLEAR` | 정지 상태 초기화 처리 |
| `TM-07` | `TIMER` | `RUN` | `BtnL` | `COUNT_CLEAR` | 동작 중 초기화 처리 |
| `TM-08` | `TIMER` | `COUNT_UPDOWN` | `done` | `STOP` 또는 `RUN` | 이전 동작 상태로 복귀 |
| `TM-09` | `TIMER` | `COUNT_CLEAR` | `done` | `STOP` 또는 `RUN` | 설계 기준에 따라 복귀 |

## 라벨링 기준

상태도 라벨은 아래 기준으로 쓴다.

- 노드 이름: `VIEW`, `SET`, `STOP`, `RUN`, `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS`, `COUNT_UPDOWN`, `COUNT_CLEAR`
- 화살표 라벨: `BtnR hold 2s`, `BtnU short / Increment Ones`, `BtnU hold 1.5s / Increment Tens`, `BtnD short / Decrement Ones`, `BtnD hold 1.5s / Decrement Tens`, `done`
- 다이어그램 제목 또는 주석: `Timepiece FSM`, `Timer FSM`

즉, 상태명은 짧게 두고, 어느 FSM 다이어그램인지로 문맥을 구분한다.

## 권장 작성 순서

1. `Timepiece FSM` 상태도 작성
2. `Timer FSM` 상태도 작성
3. 각 다이어그램 하단에 `display_mode`, `hour_format`, `position_shift`, `count_updown`은 저장값이라는 주석 추가
4. `Timepiece` 상태도 옆에는 `BtnU/BtnD short=1의 자리`, `BtnU/BtnD hold 1.5s=10의 자리` 메모를 같이 둔다.
5. 필요하면 마지막에 `SW0`로 두 FSM 중 어느 출력이 활성화되는지 별도 메모 추가

## 상태도 범위 결정

현재 단계에서는 아래 두 가지 중 하나를 선택하면 된다.

- `간단 버전`: `VIEW ↔ SET`, `STOP ↔ RUN`만 먼저 그림
- `확장 버전`: `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS`, `COUNT_UPDOWN`, `COUNT_CLEAR`까지 포함

지금처럼 FSM 상태를 실제로 parameter 정의해서 쓸 예정이면, `확장 버전`까지 그리는 편이 구현과 문서 일치성이 더 좋다.
