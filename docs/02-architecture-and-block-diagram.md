# Watch Project Architecture and Block Diagram

## 문서 목적

이 문서는 `Requirement`와 `Function Spec` 사이에서, 시스템이 어떤 블록으로 나뉘는지를 설명하기 위한 문서이다.

현재 `Block Diagram`은 이미 작성이 완료된 상태이므로, 이 문서는 그 다이어그램이 무엇을 의미하는지 텍스트 기준으로 고정하는 역할을 한다.

## 상위 구조

`Watch Project`는 아래 블록으로 나누어 해석한다.

- `Input Conditioning`
- `Common Control Logic`
- `Timepiece FSM`
- `Timer FSM`
- `Timepiece Datapath`
- `Timer Datapath`
- `Display Select Logic`
- `FND Controller`

핵심 원리는 제어부를 하나의 큰 FSM으로 합치지 않고, `공통 제어 로직`, `Timepiece FSM`, `Timer FSM`으로 분리하는 데 있다.

- `공통 제어 로직`은 모드 선택과 공통 입력을 처리한다.
- `Timepiece FSM`은 시계 기능 상태만 담당한다.
- `Timer FSM`은 타이머 기능 상태만 담당한다.
- 각 `Datapath`는 실제 값을 저장하고 갱신한다.
- 마지막으로 `Display Select Logic`과 `FND Controller`가 화면 출력을 담당한다.

## 블록별 역할

| 블록 | 역할 | 주요 입력 | 주요 출력 |
| --- | --- | --- | --- |
| `Input Conditioning` | 스위치와 버튼 입력을 안정화하고 short/hold 이벤트로 정리한다. | `SW`, `Btn`, `clk`, `rst` | clean level, clean tick, `btnR_hold_2s`, `btnU_hold_1p5s`, `btnD_hold_1p5s` |
| `Common Control Logic` | 모드 선택과 공통 입력을 처리하고, 어느 FSM 결과를 활성화할지 결정한다. | `SW0`, `SW15`, `BtnC`, `BtnR short`, clean tick | 공통 제어 신호, reset, display control |
| `Timepiece FSM` | 시계 기능에 대한 상태 전이와 이벤트 처리를 담당한다. | clean tick, `BtnR hold 2s`, `BtnL`, `BtnU short`, `BtnU hold 1.5s`, `BtnD short`, `BtnD hold 1.5s`, current state | `timepiece_state_next`, `edit_action`, `shift_request` |
| `Timer FSM` | 타이머 기능에 대한 상태 전이와 이벤트 처리를 담당한다. | clean tick, `BtnL`, `BtnU`, `BtnD`, current state | `timer_state_next`, `run_toggle_request`, `clear_request`, `direction_toggle_request` |
| `Timepiece Datapath` | 현재 시각과 편집 중인 시각 값을 관리한다. | `clk`, `rst`, `edit_action`, `position_shift` | `timepiece_value` |
| `Timer Datapath` | 타이머 값과 카운트 방향을 관리한다. | `clk`, `rst`, `count_updown`, `run/clear request` | `timer_value` |
| `Display Select Logic` | 현재 모드와 표시 형식에 따라 어느 값을 FND에 보낼지 결정한다. | `sw0`, `display_mode`, `timepiece_value`, `timer_value` | display value |
| `FND Controller` | 선택된 값을 4자리 7-segment 출력으로 변환한다. | display value, `clk`, `rst` | `fnd_com`, `fnd_data` |

## 블록 다이어그램 해석 기준

블록 다이어그램에서는 아래 내용을 분명히 드러내는 것이 좋다.

- `Input Conditioning`과 원시 버튼 입력을 분리할 것
- `Common Control Logic`, `Timepiece FSM`, `Timer FSM`을 분리할 것
- `Timepiece Datapath`와 `Timer Datapath`를 별도 블록으로 둘 것
- `Display Select Logic`이 두 Datapath의 출력을 선택한다는 점을 표시할 것
- `FND Controller`는 출력 전용 블록으로 마지막 단계에 둘 것

## 제어부 분리 기준

제어부는 아래처럼 나누는 것을 기준으로 한다.

| 구분 | 담당 내용 |
| --- | --- |
| `Common Control Logic` | `SW0` 모드 선택, `SW15` 시간 포맷 선택, `BtnR short` 표시 형식 전환, `BtnC` 전체 reset 처리 |
| `Timepiece FSM` | `VIEW`, `SET`, `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS` 상태 처리 |
| `Timer FSM` | `STOP`, `RUN`, `COUNT_UPDOWN`, `COUNT_CLEAR` 상태 처리 |

즉, 공통 제어 로직은 모든 기능이 함께 쓰는 입력을 정리하고, 각 FSM은 자기 기능 상태만 담당하는 구조로 본다.

## 블록 다이어그램 이후 다음 단계

블록 다이어그램이 끝난 다음에는 바로 `State Diagram`으로 넘어가기보다, 먼저 `Function`과 `State`를 분리해서 문서화해야 한다.

이유는 다음과 같다.

- 블록 다이어그램은 구조를 보여준다.
- 기능 표는 버튼과 스위치의 역할을 보여준다.
- 상태도는 각 FSM의 상태 전이만 보여준다.

즉, 상태도를 제대로 그리기 위해서는 먼저 `03-function-spec.md`와 `04-state-spec.md`가 정리되어 있어야 한다.
