# Watch Project Function Specification

## 문서 목적

이 문서는 요구사항을 기능 단위로 다시 적되, 현재 `main` 코드에서 어느 정도까지 구현됐는지도 함께 보는 기준 문서임.

즉 기능 정의와 구현 상태를 같이 읽는 문서로 보면 됨.

## 공통 기능

| 기능 | 입력 | 목표 동작 | 현재 main 기준 |
| --- | --- | --- | --- |
| Mode Select | `SW0` | `Timepiece ↔ Timer` 선택 | `display_select`에서 구현됨 |
| Hour Format Select | `SW15` | `24h ↔ 12h` 선택 | `display_select`에서 구현됨 |
| Display Mode Select | `BtnR` | `HH:MM ↔ SS:MS` 전환 | `common_control`에 제어 흔적 있음 |
| Reset | `rst`, `BtnC` | 전체 초기화 | 각 모듈 `rst` 기준으로 부분 구현됨 |

## Timer 기능

| 기능 | 입력 | 목표 동작 | 현재 main 기준 |
| --- | --- | --- | --- |
| Run/Stop | `BtnD` | Timer 시작/정지 | `timer_fsm` 구현됨 |
| Up/Down | `BtnU` | 방향 전환 | `timer_fsm` 구현됨 |
| Clear | `BtnL` | 현재 Timer 값 초기화 | `timer_fsm + timer_datapath` 구현됨 |
| Count | 내부 100Hz tick | `msec/sec/min/hour` 갱신 | `timer_datapath` 구현됨 |

즉 `Timer` 기능은 현재 `main`에서 가장 구현이 앞서 있는 부분임.

## Timepiece 기능

| 기능 | 입력 | 목표 동작 | 현재 main 기준 |
| --- | --- | --- | --- |
| View | 기본 상태 | 현재 시각 유지/표시 | `timepiece_datapath` 구현 중 |
| Set Enter/Exit | `BtnR hold 2s` | `VIEW ↔ SET` | `timepiece_fsm` 미구현 |
| Index Shift | `BtnL` | 편집 단위 이동 | `time_set_module`에서 처리 예정 |
| Increment Ones | `BtnU short` | 현재 단위 +1 | `time_set_module` 일부 구현됨 |
| Increment Tens | `BtnU hold 1.5s` | 현재 단위 +10 | 아직 미구현 |
| Decrement Ones | `BtnD short` | 현재 단위 -1 | `time_set_module` 일부 구현됨 |
| Decrement Tens | `BtnD hold 1.5s` | 현재 단위 -10 | 아직 미구현 |
| Real-Time Count | 내부 100Hz tick | 백그라운드 시계 진행 | `timepiece_datapath` 기본 뼈대 구현 중 |

## Display 기능

| 기능 | 입력 | 목표 동작 | 현재 main 기준 |
| --- | --- | --- | --- |
| Timer 표시 | Timer 값 | FND에 표시 | `display_select + fnd_controller` 경로 있음 |
| Timepiece 표시 | Timepiece 값 | FND에 표시 | 구조는 잡힘, top 반영은 진행 중 |
| 12/24h 선택 | `SW15` | 표시 포맷 전환 | `display_select` 구현 있음 |

## 구현 기준 메모

이번 단계에서 `Timepiece`를 구현할 때 기능 분리는 아래처럼 가져가면 됨.

- 버튼 의미 해석: `input_conditioning`
- 상태 전이: `timepiece_fsm`
- 실제 값 변경: `time_set_module`, `timepiece_datapath`
- 출력 선택: `display_select`

즉 기능 문서 기준으로도 `Timepiece`는 `Timer`와 같은 분리 구조를 따르는 것이 맞음.
