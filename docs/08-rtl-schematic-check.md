# Watch Project RTL Schematic Check

## 문서 목적

이 문서는 코드 구현 후 Vivado 등에서 확인하게 되는 실제 `RTL Schematic`에서 무엇을 점검할지 정리하기 위한 문서이다.

즉, 이 문서는 상태도나 예상 구조와 실제 툴 결과가 일치하는지 확인하는 체크 문서다.

## 확인 목적

RTL Schematic을 보는 목적은 아래와 같다.

- FSM과 Datapath 분리가 의도대로 되었는지 확인
- 저장 레지스터와 조합 경로가 예상과 맞는지 확인
- 불필요하게 복잡한 경로가 생기지 않았는지 확인
- 모드 선택과 출력 선택 구조가 설계 의도와 맞는지 확인

## 확인 대상

| 확인 항목 | 기대 구조 |
| --- | --- |
| `Timepiece FSM` | `VIEW`, `SET`, `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS` 상태 흐름이 반영되어야 한다 |
| `Timer FSM` | `STOP`, `RUN`, `COUNT_UPDOWN`, `COUNT_CLEAR` 상태 흐름이 반영되어야 한다 |
| 저장 레지스터 | `hour_format`, `display_mode`, `position_shift`, `count_updown`가 별도 저장값으로 보여야 한다 |
| 데이터 경로 | `timepiece_value`, `timer_value`가 별도 Datapath로 분리되어야 한다 |
| duration detect 경로 | `btnR_hold_2s`, `btnU_hold_1p5s`, `btnD_hold_1p5s`가 분리되어 보이거나 이에 해당하는 카운터/비교기 경로가 보여야 한다 |
| 출력 선택 | `Display Select Logic` 이후에 `FND Controller`가 연결되어야 한다 |

## RTL Schematic에서 특히 볼 것

| 영역 | 확인 포인트 |
| --- | --- |
| FSM 영역 | 상태 레지스터가 실제로 분리되어 보이는가 |
| 입력 정제 영역 | debounce와 hold-time 검출 경로가 서로 구분되어 보이는가 |
| Datapath 영역 | 값 저장 레지스터와 연산 경로가 분리되어 보이는가 |
| MUX/선택 경로 | 모드 선택과 표시 선택이 예상대로 MUX 형태로 보이는가 |
| 출력 영역 | `FND Controller`가 마지막 단계에 위치하는가 |

## 예상 구조와 비교 기준

실제 RTL schematic은 반드시 `06-expected-rtl-structure.md`와 비교해서 본다.

비교 항목:

1. 블록 수가 예상과 크게 다르지 않은가
2. FSM과 Datapath의 경계가 유지되는가
3. 공통 제어와 출력 제어가 섞이지 않았는가
4. 저장 레지스터와 조합 경로가 명확히 구분되는가

## 문서 활용 방식

이 문서는 실제 RTL schematic 캡처를 붙이기 전의 기준 문서로 사용한다.

나중에 구현이 끝나면 아래를 추가하면 된다.

- RTL schematic 캡처 이미지
- 캡처에서 강조할 블록 표시
- 예상 구조와 실제 구조 비교 코멘트
