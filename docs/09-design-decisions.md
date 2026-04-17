# Watch Project Design Decisions

## 구현 전 결정 항목

아래 항목은 구현 전에 반드시 문서로 유지해야 하는 부분이다.

현재는 이 표 자체를 설계 기준으로 고정하고, 실제 구현 시 선택이 필요한 항목은 코드 착수 전에 명확히 확정한다.

| 항목 | 확인 내용 | 현재 고정 기준 |
| --- | --- | --- |
| Reset 초기값 | 리셋 시 어떤 상태와 값으로 돌아가는지 | `timepiece_state=VIEW`, `timer_state=STOP`, `hour_format=HOUR_24`, `display_mode=DISP_HH_MM`, `position_shift=SHIFT_MSEC`, `count_updown=COUNT_UP`, `timepiece_value=12:00`, `timer_value=00:00`, 조합 기본값은 `edit_action=EDIT_IDLE`로 둔다 |
| Timepiece 설정 진입 조건 | 언제 `SET`으로 들어가는지 | `BtnR hold 2s`로만 `VIEW ↔ SET` 전이를 허용한다 |
| Timepiece 편집 단위 이동 | `BtnL`이 어떤 순서로 이동하는지 | `SHIFT_MSEC → SHIFT_SEC → SHIFT_MIN → SHIFT_HOUR → SHIFT_MSEC` 순으로 순환한다 |
| Timepiece short/hold 편집 규칙 | `BtnU`, `BtnD` short/hold를 어떻게 구분하는지 | short는 1의 자리, `1.5초 hold`는 10의 자리 변경으로 고정한다 |
| Timer가 0에 도달했을 때 동작 | `0 유지`, `자동 정지`, `랩어라운드` 중 무엇인지 | `0 유지` 또는 `0 유지 + stop` 중 하나를 명시적으로 고정 |
| `BtnL Clear`를 RUN 중에 눌렀을 때 | 클리어 후 계속 RUN인지, STOP인지 | 둘 중 하나를 문서로 확정 |
| 12-hour format의 `AM/PM` 처리 | 표시 여부와 내부 저장 여부 | 표시하지 않더라도 내부 상태 보유 여부를 정해야 함 |
| Time Setting ON일 때 시간 동작 | 편집 중에도 Timepiece가 계속 흐르는지 | 실시간 카운터와 편집값을 분리하는 구조 권장 |

## 고정한 상태 이름 기준

기존의 `CLOCK`, `STOPWATCH` 계열 이름 대신 아래 기준을 사용한다.

- `CLOCK_VIEW` → `VIEW`
- `CLOCK_SET` → `SET`
- `SW_STOP` → `STOP`
- `SW_RUN` → `RUN`
- `clock_value` → `timepiece_value`
- `stopwatch_value` → `timer_value`
- `watch_mode` → 저장 상태로 두지 않고 `sw0` 또는 `is_timepiece_mode`, `is_timer_mode`로 해석
- `time_setting` → 저장 상태로 두지 않고 `SET` 또는 `is_setting_state`로 해석
- `run_state` → 저장 상태로 두지 않고 `STOP`, `RUN` 또는 `is_timer_running`으로 해석

이 이름 기준은 `clk`와의 혼동을 줄이기 위한 고정 명명 규칙으로 사용한다.

## 문서 흐름 내 위치

이 문서는 `Requirement`, `Architecture`, `Function`, `State`, `State Diagram`이 정리된 이후에 읽는 것을 기준으로 한다.

즉, 이 문서는 기능과 상태를 새로 정의하는 문서가 아니라, 구현 전에 선택을 고정해야 하는 남은 설계 결정을 정리하는 문서다.
