# Watch Project RTL Schematic Check

## 문서 목적

이 문서는 현재 `main` 구현을 기준으로 RTL schematic에서 무엇을 확인해야 하는지 정리하는 문서임.

즉 이미 구현된 Timer 구조와, 막 구현 중인 Timepiece 구조를 같은 기준으로 비교하기 위한 체크리스트로 보면 됨.

## 현재 구현 기준으로 먼저 봐야 할 것

### 1. `input_conditioning`

아래가 보여야 함.

- 버튼 4개 각각에 대한 `debouncer`
- hold 검출 경로
- `sw0`, `sw15` 전달 경로

즉 입력 정제 블록이 Timer/Timepiece 바깥에서 공통으로 존재해야 함.

### 2. `timer_fsm`

아래 레지스터가 확인되면 정상에 가까움.

- `current_state`
- `next_state`
- `previous_state`
- `updown_state`

즉 Timer 쪽은 현재 구현된 상태 흐름이 schematic에도 그대로 보여야 함.

### 3. `timer_datapath`

아래 구조가 보여야 함.

- `tick_gen_100hz`
- `tick_counter` 4개
- `msec -> sec -> min -> hour` cascade

이게 현재 `main`에서 가장 중요한 기준 구조임.

### 4. `timer_unit`

아래 관계가 보이면 됨.

- `timer_fsm` 출력
- `timer_datapath` 입력
- wrapper로 묶인 구조

즉 `timer_unit`은 구현 기준 레퍼런스 블록으로 보면 됨.

## Timepiece 쪽에서 앞으로 봐야 할 것

Timepiece는 아래 구조가 Timer와 비슷하게 보여야 함.

- `timepiece_fsm`
- `timepiece_datapath`
- `time_set_module`
- `tick_gen_100hz`
- `tick_counter` 4개

즉 schematic에서

- Timer는 이미 이렇게 되어 있는지 확인
- Timepiece는 이 패턴으로 올라가고 있는지 확인

하면 됨.

## display 관련 확인 포인트

현재 `main` 기준으로는 아래 두 블록도 중요함.

- `common_control`
- `display_select`

RTL schematic에서 아래를 확인하면 됨.

- `common_control` 안에 display mode 저장 플롭이 보이는지
- `display_select` 안에 `SW0`, `SW15` 기준 mux 구조가 보이는지

## top 관련 메모

현재 `top_stopwatch_watch`는 legacy stopwatch top 성격이 강함.

따라서 RTL schematic 확인 우선순위는 아래처럼 두는 것이 맞음.

1. `timer_fsm`
2. `timer_datapath`
3. `timer_unit`
4. `input_conditioning`
5. `display_select`
6. `timepiece_datapath`
7. `timepiece_fsm`

즉 top 전체보다, 개별 모듈 구조가 먼저 맞는지 보는 편이 더 중요함.
