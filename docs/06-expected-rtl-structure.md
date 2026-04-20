# Watch Project Expected RTL Structure

## 문서 목적

이 문서는 실제 툴이 생성하는 `RTL Schematic`을 보기 전에, 설계자가 예상하는 `RTL 구조`를 미리 정리하기 위한 문서이다.

즉, 이 문서는 구현 결과물이 아니라 `예상 회로도 설명서`에 해당한다.

## 문서 위치

이 문서는 `State Diagram` 다음, `Verilog 구현 가이드` 이전에 둔다.

그 이유는 다음과 같다.

- 상태 정의가 끝나야 어떤 레지스터와 제어 경로가 필요한지 보인다.
- 코드 구현 전에 예상 구조를 정리해야 실제 RTL schematic과 비교하기 쉽다.

## 예상 상위 RTL 구조

예상 RTL 구조는 아래처럼 해석한다.

- `Input Conditioning`
- `Common Control Logic`
- `Timepiece FSM`
- `Timer FSM`
- `Timepiece Datapath`
- `Timer Datapath`
- `Display Select Logic`
- `FND Controller`

즉, 블록 다이어그램보다 한 단계 더 내려와서, FSM과 Datapath가 실제 레지스터/선택 경로 관점에서 어떻게 연결될지를 예상하는 문서다.

## 예상 레지스터와 제어 경로

| 구분 | 예상 항목 | 역할 |
| --- | --- | --- |
| FSM 상태 레지스터 | `timepiece_state`, `timer_state` | 각 FSM의 현재 상태 저장 |
| 저장 레지스터 | `hour_format`, `display_mode`, `position_shift`, `count_updown` | 모드와 선택값 유지 |
| 데이터 레지스터 | `timepiece_value`, `timer_value` | 실제 시각/타이머 값 저장 |
| duration detect 경로 | `btnR_hold_2s`, `btnU_hold_1p5s`, `btnD_hold_1p5s` | hold 입력을 short 입력과 구분해 FSM으로 전달 |
| 제어 경로 | `edit_action`, `shift_request`, `clear_request`, `run_toggle_request` | 버튼 입력을 Datapath 동작으로 연결 |
| 선택 경로 | `display_select` 계열 | 현재 표시할 값 선택 |

## Timepiece 쪽 예상 RTL 해석

Timepiece 쪽은 아래 흐름으로 예상한다.

1. `timepiece_state`가 현재 상태를 저장
2. `btnR_hold_2s`가 `VIEW ↔ SET` 진입 조건으로 사용
3. `position_shift`가 어느 시간 단위를 수정할지 저장
4. `btnU/btnD`의 short/hold 구분이 `edit_action`에 반영
5. `timepiece_value`가 선택 단위와 ones/tens 제어 기준으로 갱신

즉 `SET` 상태와 `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS` 상태가 Timepiece Datapath를 제어하는 구조를 예상한다.

## Timer 쪽 예상 RTL 해석

Timer 쪽은 아래 흐름으로 예상한다.

1. `timer_state`가 현재 상태를 저장
2. `count_updown`이 카운트 방향을 저장
3. 내부 tick이 들어오면 `RUN` 상태에서만 `timer_value`를 갱신
4. `COUNT_CLEAR` 상태에서는 `timer_value`를 초기화

즉 `STOP`, `RUN`, `COUNT_UPDOWN`, `COUNT_CLEAR` 상태가 Timer Datapath를 제어하는 구조를 예상한다.

## Timepiece 편집 경로에서 예상할 것

Timepiece 편집 경로는 기존 한 자리수 편집보다 조금 더 구체적으로 보일 가능성이 크다.

- `position_shift`는 `SHIFT_MSEC`, `SHIFT_SEC`, `SHIFT_MIN`, `SHIFT_HOUR` 중 하나를 저장한다.
- `edit_action`은 `EDIT_INC_ONES`, `EDIT_INC_TENS`, `EDIT_DEC_ONES`, `EDIT_DEC_TENS`처럼 short/hold 구분이 들어간다.
- Datapath 안에는 현재 선택 단위의 `ones` 또는 `tens` 위치를 계산하는 선택 경로가 추가될 수 있다.
- `BtnL` 입력은 `INDEX_SHIFT` 상태를 통해 단위 선택 레지스터만 바꾸고, 실제 값 변경은 하지 않는다.

## 예상 구조에서 확인할 포인트

예상 RTL 구조를 그릴 때는 아래를 확인한다.

- FSM 상태 레지스터와 Datapath 레지스터가 분리되어 있는가
- `Timepiece FSM`과 `Timer FSM`이 독립적으로 보이는가
- `Common Control Logic`이 공통 입력만 담당하는가
- `Display Select Logic`이 출력 선택만 담당하는가
- `FND Controller`가 출력 드라이버 역할만 하는가

## 다음 단계와의 연결

이 문서 다음에는 `07-verilog-implementation-guide.md`에서 실제 RTL 코드 작성 기준을 정리한다.

그 뒤에는 `08-rtl-schematic-check.md`에서 실제 툴이 만든 RTL schematic에서 무엇을 확인할지 정리한다.
