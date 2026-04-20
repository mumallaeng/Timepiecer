# Watch Project Architecture and Block Diagram

## 문서 목적

이 문서는 현재 `main`에 구현된 블록 구조를 기준으로, 앞으로 `Timepiece`를 어디에 끼워 넣어야 하는지 설명하기 위한 문서임.

즉 단순 이상 구조가 아니라, "현재 구현 + 앞으로 채울 자리"를 함께 보여주는 문서로 봐야 함.

## 현재 main 기준 상위 구조

현재 코드 기준으로 해석하면 상위 구조는 아래처럼 보는 것이 가장 자연스러움.

- `Input Conditioning`
- `Common Control`
- `Timer Unit`
- `Timepiece FSM`
- `Timepiece Datapath`
- `Display Select`
- `FND Controller`
- `Top`

여기서 실제로 이미 동작하는 중심 축은 `Timer Unit` 쪽임.

## 현재 구현된 블록 기준 설명

| 블록 | 현재 구현 모듈 | 역할 | 상태 |
| --- | --- | --- | --- |
| 입력 정제 | `debouncer`, `input_conditioning` | 버튼을 1회 이벤트와 hold 이벤트로 정리함 | 구현됨 |
| 공통 표시 제어 | `common_control` | display 관련 공통 제어를 담당함 | 구현됨 |
| Timer 제어+데이터 | `timer_unit` = `timer_fsm + timer_datapath` | Timer 기능 전체를 묶음 | 구현됨 |
| Timepiece 제어 | `timepiece_fsm` | Timepiece 상태 전이 담당 | 스텁 |
| Timepiece 데이터 | `timepiece_datapath`, `time_set_module` | 실시간 시계와 설정 버스 담당 | 구현 중 |
| 표시 선택 | `display_select` | `Timepiece/Timer`, `12h/24h` 선택 | 구현됨 |
| 표시 출력 | `fnd_controller` | 4자리 FND 표시 | import 사용 |

## 현재 구현 흐름

현재 `main` 구현을 기준으로 보면 데이터 흐름은 아래처럼 읽으면 됨.

1. `btnU`, `btnD`, `btnL`, `btnR` 입력이 들어옴
2. `input_conditioning`이 short/hold 이벤트를 만듦
3. `timer_unit`은 `timer_fsm`과 `timer_datapath`를 묶어서 Timer 값을 만듦
4. `display_select`가 Timer 값 또는 Timepiece 값을 고름
5. `fnd_controller`가 선택된 값을 FND에 표시함

즉 `Timepiece` 구현은 아래 두 블록을 같은 레벨로 채우는 작업으로 보면 됨.

- `timepiece_fsm`
- `timepiece_datapath`

## Timepiece가 들어갈 위치

현재 구조를 기준으로 하면 `Timepiece`는 `Timer Unit`과 대칭적으로 들어가는 것이 가장 자연스러움.

즉 최종적으로는 아래 구조를 목표로 하면 됨.

- `input_conditioning`
- `common_control`
- `timer_unit`
- `timepiece_fsm + timepiece_datapath`
- `display_select`
- `fnd_controller`

특히 `Timepiece`는 `Timer`처럼 wrapper를 둘 수도 있고, 당장은 `fsm + datapath`를 직접 top에 연결해도 됨.

## 현재 top에 대한 주의

`top_stopwatch_watch.v`는 이름 그대로 legacy stopwatch top 성격이 강함.

즉 현재 top은 아래 이유로 최종 구조 기준 문서로 보기 어렵다.

- 이름이 아직 `stopwatch` 기준임
- `control_unit`, `stopwatch_datapath` 흔적이 남아 있음
- `Timepiece`가 최종 반영된 top이 아님

따라서 블록 다이어그램 해석 기준은 `top_stopwatch_watch.v` 자체보다,

- `input_conditioning`
- `timer_unit`
- `display_select`
- `timepiece_datapath`

같은 개별 블록 관계를 중심으로 보는 게 맞음.

## Timepiece 구현 시 참고 포인트

`Timepiece`를 구현할 때는 아래를 `Timer`에서 그대로 가져와 대칭적으로 맞추면 됨.

- 입력 정제는 `input_conditioning` 결과를 그대로 사용하기
- 제어는 `timepiece_fsm`
- 데이터 경로는 `timepiece_datapath`
- 표시 선택은 `display_select`가 담당하기

즉 "Timepiece도 Timer처럼 제어와 데이터 경로를 분리하기"가 현재 문서 기준 핵심임.
