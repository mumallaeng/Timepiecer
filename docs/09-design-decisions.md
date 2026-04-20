# Watch Project Design Decisions

## 문서 목적

이 문서는 현재 `main` 구현을 기준으로 이미 굳은 결정과, `Timepiece` 구현 전에 아직 정해야 하는 결정을 나누어 적는 문서임.

## 현재 구현 기준으로 사실상 고정된 것

| 항목 | 현재 기준 |
| --- | --- |
| 입력 정제 방식 | `debouncer -> input_conditioning` 구조 사용 |
| Timer 제어 분리 | `timer_fsm + timer_datapath + timer_unit` 구조 사용 |
| Timer 상태명 | `STOP`, `RUN`, `UPDOWN`, `CLEAR` |
| Timer 복귀 방식 | `previous_state`를 저장하고 `UPDOWN`, `CLEAR` 후 복귀 |
| 표시 선택 구조 | `display_select`가 `SW0`, `SW15`를 기준으로 선택 |
| 공통 display 저장 | `common_control`이 display mode 저장 담당 |

## Timepiece 구현 전에 맞춰야 하는 것

| 항목 | 현재 권장 방향 |
| --- | --- |
| Timepiece 구조 | `timepiece_fsm + timepiece_datapath + time_set_module`로 Timer와 대칭 맞추기 |
| Timepiece 상태명 | `VIEW`, `SET`, `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS` |
| 설정 버스 | `o_set_time[23:0]` 사용 |
| 실시간 버스 | `o_timepiece_vault[23:0]` 사용 |
| 편집 단위 저장 | `time_set_module` 내부 `set_index`로 유지 |
| hold 처리 | `BtnU/BtnD hold 1.5s`는 FSM 또는 event decoding 쪽에서 구분 후 datapath로 전달 |

## 현재 main 기준 주의할 점

아래는 "이미 구현되어 있으나 최종 문서 기준으로는 다시 볼 필요가 있는 부분"임.

| 항목 | 메모 |
| --- | --- |
| `common_control` | 현재는 `i_btnR_hold` 기반 display mode 토글 구조임 |
| `display_select` | 현재 `SW15` 처리 방식은 추후 검토 필요 |
| `top_stopwatch_watch` | 최종 watch top이라기보다 legacy stopwatch top 성격이 강함 |
| `timepiece_fsm` | 아직 스텁이라 문서 기준으로 새로 채워야 함 |

## 결론

현재 구현 기준으로는

- Timer 쪽은 구조 레퍼런스
- Timepiece 쪽은 구현 대상

으로 보는 것이 가장 자연스러움.

즉 앞으로의 핵심 결정은 "Timepiece를 Timer 구조와 얼마나 대칭적으로 맞출 것인가"에 있음.
