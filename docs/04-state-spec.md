# Watch Project State Specification

## 문서 목적

이 문서는 실제 RTL에서 `parameter` 또는 `localparam`으로 정의해 사용할 `FSM 상태`를 정리한다.

이번 설계에서는 상태를 `main/aux`로 나누기보다, `어느 FSM에서 쓰는 상태인지`를 기준으로 정리한다.

즉 상태명은 짧게 두고, 표에서 `FSM` 소속을 함께 표시하는 방식을 기준으로 한다.

## 상태 명명 기준

상태명은 아래 기준을 따른다.

- 상태명은 `대문자`로 쓴다.
- 같은 FSM 안에서만 유일하면 되므로, 불필요하게 긴 접두사는 붙이지 않는다.
- 상태 의미가 바로 보이도록 동작 중심 이름을 쓴다.

예시:

- `TIMEPIECE FSM`: `VIEW`, `SET`, `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS`
- `TIMER FSM`: `STOP`, `RUN`, `COUNT_UPDOWN`, `COUNT_CLEAR`

## 기능과 상태의 구분

기능과 상태는 아래처럼 구분한다.

| 항목 | 기능 | 상태 |
| --- | --- | --- |
| 의미 | 사용자가 수행하는 동작 | FSM이 현재 머무는 상태 |
| 예시 | `RunStop`, `Increment Ones`, `Clear` | `RUN`, `INCREMENT_TENS`, `COUNT_CLEAR` |
| 문서 역할 | 버튼/스위치 역할 설명 | 상태도와 RTL state parameter 정의 기준 |

즉 `BtnU hold 1.5s = Increment Tens`는 기능 정의이고, `INCREMENT_TENS`는 그 기능을 처리하기 위해 진입하는 상태 정의다.

## FSM별 상태 정의

### Timepiece FSM

| FSM | 상태명 | 의미 | 주요 진입 조건 | 주요 동작 | 다음 전이 |
| --- | --- | --- | --- | --- | --- |
| `TIMEPIECE` | `VIEW` | 기본 시계 표시 상태 | reset 이후 기본 진입, `SET` 종료 시 복귀 | 현재 시각을 표시하고 내부 1초 tick에 따라 증가시킨다. | `BtnR hold 2s`이면 `SET`, `SW0=Timer`이면 Timer 계열로 해석 |
| `TIMEPIECE` | `SET` | 시계 설정 대기 상태 | `VIEW`에서 `BtnR hold 2s` | 사용자가 단위 이동 또는 값 증감을 기다리는 상태다. | `BtnL`이면 `INDEX_SHIFT`, `BtnU short`이면 `INCREMENT_ONES`, `BtnU hold 1.5s`이면 `INCREMENT_TENS`, `BtnD short`이면 `DECREMENT_ONES`, `BtnD hold 1.5s`이면 `DECREMENT_TENS`, `BtnR hold 2s`이면 `VIEW` |
| `TIMEPIECE` | `INDEX_SHIFT` | 수정 대상 시간 단위 이동 상태 | `SET`에서 `BtnL` | 편집 위치를 다음 시간 단위로 이동시킨다. | 동작 후 `SET` 복귀 |
| `TIMEPIECE` | `INCREMENT_ONES` | 현재 선택 단위의 1의 자리 증가 상태 | `SET`에서 `BtnU short` | 현재 선택 단위의 1의 자리를 1 증가시킨다. | 동작 후 `SET` 복귀 |
| `TIMEPIECE` | `INCREMENT_TENS` | 현재 선택 단위의 10의 자리 증가 상태 | `SET`에서 `BtnU hold 1.5s` | 현재 선택 단위의 10의 자리를 1 증가시킨다. | 동작 후 `SET` 복귀 |
| `TIMEPIECE` | `DECREMENT_ONES` | 현재 선택 단위의 1의 자리 감소 상태 | `SET`에서 `BtnD short` | 현재 선택 단위의 1의 자리를 1 감소시킨다. | 동작 후 `SET` 복귀 |
| `TIMEPIECE` | `DECREMENT_TENS` | 현재 선택 단위의 10의 자리 감소 상태 | `SET`에서 `BtnD hold 1.5s` | 현재 선택 단위의 10의 자리를 1 감소시킨다. | 동작 후 `SET` 복귀 |

### Timer FSM

| FSM | 상태명 | 의미 | 주요 진입 조건 | 주요 동작 | 다음 전이 |
| --- | --- | --- | --- | --- | --- |
| `TIMER` | `STOP` | 타이머 정지 상태 | Timer 계열 기본 진입, `RUN` 종료 시 복귀 | 현재 타이머 값을 유지한다. | `BtnD`이면 `RUN`, `BtnU`이면 `COUNT_UPDOWN`, `BtnL`이면 `COUNT_CLEAR` |
| `TIMER` | `RUN` | 타이머 동작 상태 | `STOP`에서 `BtnD` | 내부 tick에 따라 타이머 값을 갱신한다. | `BtnD`이면 `STOP`, `BtnU`이면 `COUNT_UPDOWN`, `BtnL`이면 `COUNT_CLEAR` |
| `TIMER` | `COUNT_UPDOWN` | 카운트 방향 전환 상태 | `STOP` 또는 `RUN`에서 `BtnU` | `up ↔ down` 방향을 전환한다. | 이전 동작 상태로 복귀 |
| `TIMER` | `COUNT_CLEAR` | 타이머 값 초기화 상태 | `STOP` 또는 `RUN`에서 `BtnL` | 현재 타이머 값을 초기화한다. | 이전 동작 상태로 복귀 또는 설계 기준에 따라 `STOP` 복귀 |

## 상태 외 저장값

아래 항목은 FSM 상태라기보다 별도 레지스터로 유지되는 값이다.

| 이름 | 값 | 의미 | 비고 |
| --- | --- | --- | --- |
| `hour_format` | `HOUR_24`, `HOUR_12` | 시계 표시 형식 선택 | `SW15`로 제어 |
| `display_mode` | `DISP_HH_MM`, `DISP_SS_MS` | FND 표시 형식 선택 | `BtnR short`로 제어 |
| `position_shift` | `SHIFT_MSEC`, `SHIFT_SEC`, `SHIFT_MIN`, `SHIFT_HOUR` | Timepiece 편집 단위 저장값 | `INDEX_SHIFT` 상태에서 갱신 |
| `count_updown` | `COUNT_UP`, `COUNT_DOWN` | Timer 방향 저장값 | `COUNT_UPDOWN` 상태에서 갱신 |
| `timepiece_value` | 구현 의존 | 현재 시각 값 | `VIEW`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS`에서 갱신 |
| `timer_value` | 구현 의존 | 현재 타이머 값 | `RUN`, `COUNT_CLEAR`에서 갱신 |

## 상태 설계 해석 기준

- `VIEW`, `SET`, `STOP`, `RUN`은 지속 상태로 해석한다.
- `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS`, `COUNT_UPDOWN`, `COUNT_CLEAR`는 동작 처리용 상태로 해석한다.
- 동작 처리용 상태는 한 번 동작을 수행한 뒤 다시 기준 상태로 복귀하는 구조를 권장한다.
- 상태표의 `FSM` 열이 상태 소속을 구분하므로, 상태명 자체는 짧게 유지한다.
