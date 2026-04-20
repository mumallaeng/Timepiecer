# Watch Project Overview

## 문서 목적

이 폴더는 `Watch Project`를 현재 구현 기준으로 이해하고, 그 위에 `Timepiece`를 이어서 구현하기 위한 기준 문서 묶음임.

이번 문서 정리 기준은 아래 두 가지임.

- `main`에 이미 구현된 `Timer` 계열 코드를 먼저 기준으로 삼기
- `Timepiece`는 그 구조를 따라 확장하는 방향으로 정리하기

## 현재 main 구현 스냅샷

현재 소스 트리에서 확인되는 핵심 모듈은 아래와 같음.

| 구분 | 모듈 | 상태 |
| --- | --- | --- |
| 입력 정제 | `debouncer`, `input_conditioning` | 구현됨 |
| Timer 제어 | `timer_fsm` | 구현됨 |
| Timer 데이터 경로 | `timer_datapath` | 구현됨 |
| Timer 래퍼 | `timer_unit` | 구현됨 |
| 공통 표시 제어 | `common_control` | 구현됨 |
| 표시 선택 | `display_select` | 구현됨 |
| Timepiece 제어 | `timepiece_fsm` | 스텁 상태 |
| Timepiece 데이터 경로 | `timepiece_datapath`, `time_set_module` | 구현 중 |
| 상위 top | `top_stopwatch_watch` | legacy stopwatch 기준, 최종 top 아님 |

즉 현재 `main`은 `Timer` 쪽이 먼저 구현되어 있고, `Timepiece`는 그 구조를 참고해 맞춰가는 단계로 보는 것이 맞음.

## 현재 문서 해석 기준

이 문서 묶음은 "최종 이상 구조"만 적는 문서가 아니라, 아래를 함께 담는 기준으로 정리함.

- 현재 `main`에 실제로 구현된 구조
- 그 구조를 바탕으로 `Timepiece`가 들어가야 할 위치
- 아직 구현되지 않은 부분은 어디인지

따라서 `Timer` 관련 문서는 "현재 구현 반영", `Timepiece` 관련 문서는 "구현 예정 구조"가 함께 들어감.

## 핵심 구현 흐름

현재 `main` 기준으로 이해해야 할 큰 흐름은 아래와 같음.

1. `debouncer`가 버튼을 정제함
2. `input_conditioning`이 버튼별 short/hold 이벤트를 만듦
3. `timer_fsm`이 Timer 상태를 제어함
4. `timer_datapath`가 실제 시간을 셈
5. `display_select`가 `Timepiece/Timer`, `24h/12h`를 선택함
6. `fnd_controller`가 표시를 담당함

`Timepiece`는 이 흐름에서

- `timepiece_fsm`
- `timepiece_datapath`
- `time_set_module`

세 블록을 채워 넣는 방향으로 구현하면 됨.

## 현재 문서 읽는 순서

1. `01-requirement.md`
2. `02-architecture-and-block-diagram.md`
3. `03-function-spec.md`
4. `04-state-spec.md`
5. `05-state-diagram-spec.md`
6. `06-expected-rtl-structure.md`
7. `07-verilog-implementation-guide.md`
8. `08-rtl-schematic-check.md`
9. `09-design-decisions.md`
10. `10-implementation-and-simulation-plan.md`

특히 이번 단계에서는

- `02`, `04`, `05`, `06`, `07`

이 다섯 문서가 실제 구현 방향을 잡는 데 가장 중요함.
