# Watch Project Verilog Implementation Guide

## Top-Level 포트 인터페이스 명세

아래 표는 `Watch Project`의 top-level 모듈 인터페이스를 기준으로 한 권장 명세이다.

기본 가정:

- 보드 입력은 `clk`, `rst`, `SW`, `Btn` 계열로 받는다.
- 출력은 4자리 FND 기준 `fnd_com`, `fnd_data`를 사용하고, 필요하면 `led`를 보조 상태 표시용으로 둔다.
- 실제 프로젝트에서 포트 이름이 다르더라도 방향과 역할은 동일하게 유지하는 것이 좋다.

| 포트명 | 방향 | 권장 형식 | 비트폭 예시 | 설명 |
| --- | --- | --- | --- | --- |
| `clk` | `input` | `wire` | `1bit` | 시스템 하드웨어 클록 입력 |
| `rst` | `input` | `wire` | `1bit` | 전체 시스템 초기화 입력 |
| `sw0` | `input` | `wire` | `1bit` | `Timepiece/Timer` 계열 선택 스위치 |
| `sw15` | `input` | `wire` | `1bit` | `hour_format` 선택 스위치, `0=HOUR_24`, `1=HOUR_12` |
| `btnC` | `input` | `wire` | `1bit` | 전체 리셋 버튼 입력 |
| `btnR` | `input` | `wire` | `1bit` | short press는 `display_mode`, `2초 hold`는 Timepiece FSM의 `VIEW ↔ SET` 제어 입력 |
| `btnL` | `input` | `wire` | `1bit` | `Position Shift` 또는 `Clear` 기능 입력 |
| `btnU` | `input` | `wire` | `1bit` | `Up / Increment` 또는 `UpDown` 기능 입력, Timepiece에서는 short/hold를 구분한다 |
| `btnD` | `input` | `wire` | `1bit` | `Down / Decrement` 또는 `RunStop` 기능 입력, Timepiece에서는 short/hold를 구분한다 |
| `fnd_com` | `output` | `wire` | `4bit` | 4자리 FND 공통 선택 출력 |
| `fnd_data` | `output` | `wire` | `8bit` | FND 세그먼트 데이터 출력 |
| `led` | `output` | `wire` | 구현 의존 | 현재 모드 또는 상태를 보조적으로 표시하는 LED 출력 |

## 순차 상태 및 데이터 기준

상태 정의 자체는 `04-state-spec.md` 문서를 기준으로 하고, 이 문서에서는 실제 RTL에서 어떤 타입으로 두는지가 핵심이다.

| 대상 | 권장 타입 | 비트폭 예시 | 논리 구분 | 해석 방식 | 비고 |
| --- | --- | --- | --- | --- | --- |
| `timepiece_state` | `reg` | `3bit` 이상 | 순차 논리 | FSM 상태 저장 | `VIEW`, `SET`, `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS`를 저장하는 Timepiece FSM 상태 |
| `timer_state` | `reg` | `2bit` 이상 | 순차 논리 | FSM 상태 저장 | `STOP`, `RUN`, `COUNT_UPDOWN`, `COUNT_CLEAR`를 저장하는 Timer FSM 상태 |
| `hour_format` | `reg` | `1bit` | 순차 논리 | 상태 저장 | `HOUR_24 ↔ HOUR_12` 선택 |
| `display_mode` | `reg` | `1bit` | 순차 논리 | 상태 저장 | `DISP_SS_MS ↔ DISP_HH_MM` 표시 선택 |
| `position_shift` | `reg` | `2bit` | 순차 논리 | 상태 저장 | 현재 편집 시간 단위 선택, `SHIFT_MSEC`, `SHIFT_SEC`, `SHIFT_MIN`, `SHIFT_HOUR` 중 하나 |
| `count_updown` | `reg` | `1bit` | 순차 논리 | 상태 저장 | `up ↔ down` 방향 선택 |
| `timepiece_value` | `reg` | 구현 의존 | 순차 논리 | 데이터 저장 | 시계 현재값 또는 편집값 저장 |
| `timer_value` | `reg` | 구현 의존 | 순차 논리 | 데이터 저장 | 타이머 현재값 저장 |

## 조합 논리 기준

| 대상 | 권장 타입 | 비트폭 예시 | 논리 구분 | 해석 방식 | 비고 |
| --- | --- | --- | --- | --- | --- |
| `timepiece_state_next` | `reg` | `3bit` 이상 | 조합 논리 | next-state 계산 | Timepiece FSM 상태 전이 계산용 |
| `timer_state_next` | `reg` | `2bit` 이상 | 조합 논리 | next-state 계산 | Timer FSM 상태 전이 계산용 |
| `hour_format_next` | `reg` | `1bit` | 조합 논리 | next-state 계산 | 필요 시 형식 선택 반영용 |
| `display_mode_next` | `reg` | `1bit` | 조합 논리 | next-state 계산 | short `BtnR` 반영용 |
| `position_shift_next` | `reg` | `2bit` | 조합 논리 | next-state 계산 | `Position Shift` 요청 결과를 반영한 다음 시간 단위 값 |
| `count_updown_next` | `reg` | `1bit` | 조합 논리 | next-state 계산 | `UpDown` 반영용 |
| `timepiece_value_next` | `reg` | 구현 의존 | 조합 논리 | next-data 계산 | 현재 선택 단위의 ones/tens 편집 결과를 계산한 다음 값 |
| `timer_value_next` | `reg` | 구현 의존 | 조합 논리 | next-data 계산 | tick 또는 clear 결과를 계산한 다음 값 |
| 버튼 debounce 결과 | `wire` | `1bit` | 조합 논리 | 입력 정제 | 버튼별 clean tick 또는 level 신호 |
| `btnR_hold_2s` | `wire` | `1bit` | 조합 논리 | duration detect | `BtnR`가 2초 이상 유지되었을 때 1회 이벤트 |
| `btnU_hold_1p5s` | `wire` | `1bit` | 조합 논리 | duration detect | `BtnU`가 1.5초 이상 유지되었을 때 1회 이벤트 |
| `btnD_hold_1p5s` | `wire` | `1bit` | 조합 논리 | duration detect | `BtnD`가 1.5초 이상 유지되었을 때 1회 이벤트 |
| `is_timepiece_mode`, `is_timer_mode` | `wire` | `1bit` | 조합 논리 | Moore형 파생 플래그 | 현재 출력 또는 동작 기준이 어느 FSM 계열인지 판단하는 플래그 |
| `is_setting_state`, `is_timer_running` | `wire` | `1bit` | 조합 논리 | Moore형 파생 플래그 | `timepiece_state`, `timer_state`만 보고 판단하는 상태 플래그 |
| `display_toggle_request` | `wire` | `1bit` | 조합 논리 | Mealy형 이벤트 | short `BtnR tick`과 현재 상태를 함께 보고 생성하는 표시 전환 요청 |
| `timepiece_set_toggle_request` | `wire` | `1bit` | 조합 논리 | Mealy형 이벤트 | `btnR_hold_2s`와 `timepiece_state`를 함께 보고 생성하는 설정 진입/복귀 요청 |
| `shift_request` | `wire` | `1bit` | 조합 논리 | Mealy형 이벤트 | `timepiece_state`와 `BtnL tick`을 함께 보고 생성하는 `Position Shift` 요청 |
| `clear_request` | `wire` | `1bit` | 조합 논리 | Mealy형 이벤트 | `timer_state`와 `BtnL tick`을 함께 보고 생성하는 타이머 clear 요청 |
| `direction_toggle_request` | `wire` | `1bit` | 조합 논리 | Mealy형 이벤트 | `timer_state`와 `BtnU tick`을 함께 보고 생성하는 방향 전환 요청 |
| `run_toggle_request` | `wire` | `1bit` | 조합 논리 | Mealy형 이벤트 | `timer_state`와 `BtnD tick`을 함께 보고 생성하는 run/stop 전환 요청 |
| `edit_action` | `wire` | `3bit` 또는 enum 대체 폭 | 조합 논리 | Mealy형 이벤트 | `EDIT_INC_ONES`, `EDIT_INC_TENS`, `EDIT_DEC_ONES`, `EDIT_DEC_TENS`처럼 short/hold를 구분하는 편집 요청 |
| 표시용 선택 신호 | `wire` 또는 `reg` | 구현 의존 | 조합 논리 | Moore형 출력 선택 | FND에 어떤 값을 내보낼지 결정하는 경로 |
| 모듈 출력 포트 | `wire` | 구현 의존 | 조합 논리 | 출력 전달 | `fnd_com`, `fnd_data`, `led` 등 외부 연결선 |

## 상수 이름 기준

상태 이름과 선택값은 코드 안에서 아래와 같은 명명 규칙으로 맞추는 것이 좋다.

| 대상 | 값 이름 예시 |
| --- | --- |
| `timepiece_state` | `VIEW`, `SET`, `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS` |
| `timer_state` | `STOP`, `RUN`, `COUNT_UPDOWN`, `COUNT_CLEAR` |
| `hour_format` | `HOUR_24`, `HOUR_12` |
| `display_mode` | `DISP_SS_MS`, `DISP_HH_MM` |
| `position_shift` | `SHIFT_MSEC`, `SHIFT_SEC`, `SHIFT_MIN`, `SHIFT_HOUR` |
| `count_updown` | `COUNT_UP`, `COUNT_DOWN` |
| `edit_action` | `EDIT_IDLE`, `EDIT_INC_ONES`, `EDIT_INC_TENS`, `EDIT_DEC_ONES`, `EDIT_DEC_TENS` |

## Latch 방지 규칙

Latch가 생기지 않게 하려면 다음 규칙을 지켜야 한다.

1. 저장되는 상태값과 데이터값은 모두 레지스터에 모으고, 클록 기준으로만 갱신한다.
2. 조합 경로에서 계산되는 모든 `*_next`, `*_request`, `edit_action`은 기본값이 항상 정해져 있어야 한다.
3. Moore형 파생 플래그와 Mealy형 이벤트 제어를 섞어 쓰더라도 분기 누락 없이 닫힌 구조로 정리한다.
4. `position_shift`는 시간 단위 선택만 담당하고, 실제 ones/tens 증감 동작은 `edit_action`이 별도로 결정하도록 분리한다.
5. `BtnR hold 2s`, `BtnU hold 1.5s`, `BtnD hold 1.5s`는 short 이벤트와 중복 처리되지 않도록 우선순위를 명확히 둔다.
6. `position_shift`처럼 순환하는 선택값은 `Position Shift` 버튼 동작이 `SHIFT_MSEC → SHIFT_SEC → SHIFT_MIN → SHIFT_HOUR` 순으로 한 바퀴 돌도록 설계한다.

핵심 요약:

- FSM 상태/보조 저장 상태/데이터: `reg`
- next-state / next-data 계산: 조합 논리용 `reg`
- 버튼 입력, debounce 출력, 파생 플래그, 이벤트 제어: `wire`
- Moore형 해석: `timepiece_state`, `timer_state`만으로 결정
- Mealy형 해석: 현재 상태와 버튼 tick을 함께 사용
