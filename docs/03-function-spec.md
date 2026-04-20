# Watch Project Function Specification

## 문서 목적

이 문서는 사용자가 실제로 보게 되는 `기능`을 정리한다.

여기서 말하는 기능은 아래처럼 해석한다.

- 버튼이나 스위치를 조작했을 때 사용자 입장에서 기대하는 동작
- 입력 장치와 연결된 동작 의미
- 표시 결과와 직접 연결되는 행위

즉, 이 문서는 `상태 변수`를 정의하는 문서가 아니라 `기능 동작`을 정리하는 문서다.

## 기능과 상태의 구분

기능과 상태는 아래처럼 구분한다.

| 구분 | 의미 | 예시 |
| --- | --- | --- |
| `Function` | 사용자가 수행하는 동작 또는 시스템이 제공하는 기능 | `Display Setting`, `RunStop`, `Increment`, `Clear` |
| `State` | 시스템이 내부적으로 기억해야 하는 현재 조건 | `VIEW`, `RUN`, `display_mode`, `position_shift` |

따라서 `BtnU short = Increment Ones`는 기능 정의이고, `position_shift = SHIFT_SEC`는 상태 정의다.

## 공통 기능

| 기능 ID | 기능 이름 | 입력 | 동작 설명 | 비고 |
| --- | --- | --- | --- | --- |
| `CF-01` | `Mode Select` | `SW0` | `Timepiece ↔ Timer` 모드를 전환한다. | `SW0=0`이면 `Timepiece`, `SW0=1`이면 `Timer` |
| `CF-02` | `Hour Format Setting` | `SW15` | `24-hour ↔ 12-hour` 형식을 전환한다. | 표시 형식에만 영향을 준다. |
| `CF-03` | `Display Setting` | `BtnR short` | `HH:MM ↔ SS:MS` 표시 형식을 전환한다. | 모드 전환 후에도 이전 선택을 유지한다. |
| `CF-04` | `Reset` | `BtnC` | 시스템 전체를 초기 상태로 되돌린다. | 모든 값과 상태를 초기화한다. |

## Timepiece 기능

| 기능 ID | 기능 이름 | 입력 | 동작 설명 | 비고 |
| --- | --- | --- | --- | --- |
| `TF-01` | `Time Setting` | `BtnR hold 2s` | 시간 설정 모드 진입 또는 종료를 수행한다. | `Timepiece` 계열에서만 유효 |
| `TF-02` | `Position Shift` | `BtnL` | 수정 대상 시간 단위를 순환 이동한다. | `MSEC → SEC → MIN → HOUR → MSEC` |
| `TF-03` | `Increment Ones` | `BtnU short` | 현재 선택 단위의 1의 자리를 1 증가시킨다. | `Up short = Increment Ones` |
| `TF-04` | `Increment Tens` | `BtnU hold 1.5s` | 현재 선택 단위의 10의 자리를 1 증가시킨다. | `Up hold = Increment Tens` |
| `TF-05` | `Decrement Ones` | `BtnD short` | 현재 선택 단위의 1의 자리를 1 감소시킨다. | `Down short = Decrement Ones` |
| `TF-06` | `Decrement Tens` | `BtnD hold 1.5s` | 현재 선택 단위의 10의 자리를 1 감소시킨다. | `Down hold = Decrement Tens` |
| `TF-07` | `Real-Time Count` | 내부 1초 tick | 현재 시각을 계속 증가시킨다. | `Timer` 모드로 넘어가도 백그라운드에서 계속 동작 |

## Timer 기능

| 기능 ID | 기능 이름 | 입력 | 동작 설명 | 비고 |
| --- | --- | --- | --- | --- |
| `TM-01` | `UpDown` | `BtnU` | 카운트 방향을 `up ↔ down`으로 전환한다. | `Timer` 계열에서만 유효 |
| `TM-02` | `RunStop` | `BtnD` | 타이머 실행 또는 정지를 전환한다. | 메인 상태 전이에 직접 연결된다. |
| `TM-03` | `Clear` | `BtnL` | 현재 타이머 값을 초기화한다. | `STOP` 여부와 무관하게 동작하도록 설계 가능 |
| `TM-04` | `Count` | 내부 tick | 설정된 방향으로 타이머 값을 갱신한다. | `RUN` 상태일 때만 동작 |

## 디스플레이 기능

| 기능 ID | 기능 이름 | 입력/조건 | 동작 설명 | 비고 |
| --- | --- | --- | --- | --- |
| `DF-01` | `Timepiece Display` | `Timepiece` 계열 상태 | `timepiece_value`를 FND에 표시한다. | `HH:MM` 또는 `SS:MS` 선택 가능 |
| `DF-02` | `Timer Display` | `Timer` 계열 상태 | `timer_value`를 FND에 표시한다. | `HH:MM` 또는 `SS:MS` 선택 가능 |
| `DF-03` | `Immediate Update` | 버튼 입력 또는 내부 tick | 값이 변하면 표시도 즉시 갱신된다. | `Display Select Logic` 반영 |

## 다음 문서와의 연결

이 문서 다음에는 `State Specification`으로 넘어간다.

그 이유는 다음과 같다.

- 기능 표는 버튼과 스위치의 역할을 설명한다.
- 상태 명세는 시스템이 무엇을 기억해야 하는지 설명한다.
- 상태도는 그 상태 명세를 기준으로 메인 상태 전이만 시각화한다.
