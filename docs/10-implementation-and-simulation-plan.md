# Watch Project Implementation and Simulation Plan

## 문서 목적

이 문서는 `Watch Project`를 실제로 구현할 때,

- 기존 `stopwatch_watch` 코드에서 재사용할 부분
- 수정해서 가져올 부분
- 새로 구현해야 하는 부분
- `Vivado 2020.2` 기준 RTL / schematic 확인 포인트
- 2인 1조 기준 역할 분담
- 모듈 단위 → 세트 단위 → 종합 테스트 순서

를 한 번에 정리하기 위한 문서이다.

## Git 기준 메모

현재 작업 트리는 로컬 변경이 많아서 바로 `git pull`로 병합하지 않고, `origin/main`을 `fetch`해서 최신 `stopwatch_watch` 코드를 기준으로 참고했다.

이번에 확인한 원격 최신 기준 참고 포인트는 다음과 같다.

- `top_stopwatch_watch.v`에서 `fnd_controller` 파라미터를 명시적으로 연결하도록 수정됨
- `fnd_controller.v`가 더 일반화된 파라미터 구조로 바뀌었고, `always @(*)` 같은 합성 친화적 표현으로 정리됨

즉, 실제 구현 착수 시에는 현재 로컬 작업을 정리한 뒤 병합하되, 설계 판단은 이미 `origin/main` 기준 최신 `stopwatch_watch` 코드를 반영해서 잡아도 된다.

## 참고할 기존 구현 코드

### 직접 참고할 파일

- `activities/korcham/notes/verilog-hdl/HelloVerilog/stopwatch_watch/stopwatch_watch.srcs/sources_1/new/stopwatch_datapath.v`
- `activities/korcham/notes/verilog-hdl/HelloVerilog/stopwatch_watch/stopwatch_watch.srcs/sources_1/new/top_stopwatch_watch.v`
- `activities/korcham/notes/verilog-hdl/HelloVerilog/stopwatch_watch/stopwatch_watch.srcs/sources_1/imports/10000_counter/button_debounce.v`
- `activities/korcham/notes/verilog-hdl/HelloVerilog/stopwatch_watch/stopwatch_watch.srcs/sources_1/imports/10000_counter/fnd_controller.v`
- `activities/korcham/notes/verilog-hdl/HelloVerilog/stopwatch_watch/stopwatch_watch.srcs/sim_1/new/tb_stopwatch_datapath.v`
- `activities/korcham/notes/verilog-hdl/HelloVerilog/source/10000_counter/control_unit.v`

### 이 코드에서 바로 얻는 것

| 기준 파일 | 바로 활용할 핵심 |
| --- | --- |
| `stopwatch_datapath.v` | `msec/sec/min/hour` 체인형 카운터 구조, `tick_counter`, `tick_gen_100hz` |
| `button_debounce.v` | 버튼 동기화, 샘플링 기반 debounce, clean level/tick 출력 |
| `fnd_controller.v` | 4자리 FND 스캔, digit split, 표시 mux, 7-seg 출력 |
| `top_stopwatch_watch.v` | top에서 debounce, control, datapath, display를 묶는 연결 방식 |
| `tb_stopwatch_datapath.v` | 실제 보드 tick 대신 빠른 tick을 강제로 넣는 unit test 방식 |
| `control_unit.v` | FSM을 짧은 상태명으로 두고 출력 제어하는 방식 |

## 변경해서 가져올 부분

기존 `stopwatch_watch`는 `Timer` 중심 구조다. 이번 프로젝트는 `Timepiece + Timer` 구조이므로, 아래 항목은 그대로 복사하지 말고 수정해서 써야 한다.

| 항목 | 기준 코드 | 왜 수정이 필요한가 | 권장 방향 |
| --- | --- | --- | --- |
| `stopwatch_datapath` | `stopwatch_datapath.v` | 현재는 `Timer` 동작만 담당 | 이름을 `timer_datapath`로 정리하거나 내부를 그대로 재사용하되 상위에서 `Timer` 블록으로 취급 |
| `top_stopwatch_watch` | `top_stopwatch_watch.v` | 현재는 시계 기능이 없음 | `top_watch_project`로 새로 구성 |
| `control_unit` | `source/10000_counter/control_unit.v` | 현재는 `RUN/STOP/CLEAR/DIR` 중심 | `Timepiece FSM`, `Timer FSM`, `Common Control Logic`로 분리 |
| `button_debounce` 사용 방식 | `top_stopwatch_watch.v` | 현재는 clean tick까지만 사용 | `debounce` 뒤에 short/hold 구분 경로 추가 |
| `fnd_controller` 연결 | `origin/main` 기준 `top_stopwatch_watch.v` | 지금 프로젝트는 `Timepiece/Timer`, `HH:MM/SS:MS` 모두 지원 | 최신 parameterized `fnd_controller`를 기준으로 연결 |

## 새로 구현해야 하는 부분

이번 프로젝트에서 핵심적으로 새로 생기는 블록은 아래와 같다.

| 신규 모듈 | 역할 | 비고 |
| --- | --- | --- |
| `common_control_logic` | `SW0`, `SW15`, `BtnC`, `BtnR short` 처리 | 두 FSM에 공통으로 쓰는 제어만 담당 |
| `timepiece_fsm` | `VIEW`, `SET`, `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS` 처리 | 이번 프로젝트 핵심 신규 FSM |
| `timer_fsm` | `STOP`, `RUN`, `COUNT_UPDOWN`, `COUNT_CLEAR` 처리 | 기존 `control_unit` 아이디어를 확장 |
| `timepiece_datapath` | 실제 시계 값 증가 + setting 편집 처리 | 가장 큰 신규 Datapath |
| `button_event_decoder` 또는 `hold_detector` | `BtnR 2초`, `BtnU/BtnD 1.5초` hold 검출 | `button_debounce` 뒤에 붙이는 구조 권장 |
| `display_select_logic` | `Timepiece/Timer`와 `HH:MM/SS:MS` 선택 | top에서 분리하면 검증이 쉬움 |
| `top_watch_project` | 전체 연결 top | bitstream용 최종 모듈 |

## 재사용 / 수정 / 신규 구분 요약

### 재사용 우선

- `button_debounce.v`
- `tick_counter`
- `tick_gen_100hz`
- 최신 `fnd_controller.v`
- `tb_stopwatch_datapath.v`의 fast-tick 검증 아이디어

### 수정 후 재사용

- `stopwatch_datapath.v` → `timer_datapath`
- `control_unit.v` 아이디어 → `timer_fsm`
- `top_stopwatch_watch.v` 연결 방식 → `top_watch_project`

### 완전 신규

- `common_control_logic`
- `timepiece_fsm`
- `timepiece_datapath`
- `button_event_decoder` 또는 `hold_detector`
- `display_select_logic`

## Vivado 2020.2 기준 RTL / Schematic 확인 포인트

이번 프로젝트에서 `Vivado 2020.2` 기준으로 확인할 것은 세 단계로 나누는 것이 좋다.

### 1. Elaborated RTL 확인

`Open Elaborated Design`에서 먼저 본다.

여기서는 다음을 확인한다.

- `common_control_logic`
- `timepiece_fsm`
- `timer_fsm`
- `timepiece_datapath`
- `timer_datapath`
- `display_select_logic`
- `fnd_controller`

가 의도한 계층으로 분리되어 보이는지

즉, 이 단계는 "코드를 쓰자마자 RTL 구조가 설계 문서와 크게 어긋나지 않는가"를 보는 단계다.

### 2. Synthesized Schematic 확인

`Run Synthesis` 후 `Open Synthesized Design`에서 본다.

여기서는 다음을 확인한다.

- `timepiece_state`, `timer_state` 레지스터가 실제로 잡혔는지
- `position_shift`, `count_updown`, `display_mode`, `hour_format`가 저장 레지스터로 보이는지
- hold 검출용 카운터 / 비교기 경로가 생성됐는지
- `timepiece_datapath` 쪽에 ones/tens 편집용 선택 경로가 들어갔는지
- `Display Select Logic`이 FND 쪽과 분리되어 보이는지

즉, 이 단계는 "합성 후에도 FSM과 Datapath 경계가 유지되는가"를 보는 단계다.

### 3. Implemented Design 확인

`Run Implementation` 이후에는 bitstream 직전 최종 연결 확인 정도로만 본다.

이 단계에서 주로 볼 것은 다음이다.

- top이 의도한 핀으로 나가고 있는지
- 불필요하게 큰 논리 경로가 생기지 않았는지
- 최종 bitstream 전 구조가 깨지지 않았는지

이번 프로젝트에서는 기능 검증은 `Behavioral Simulation`이 중심이고, `Implemented Design`은 마지막 sanity check 성격으로 보는 것이 맞다.

## 구현 순서 권장안

이번 프로젝트는 아래 순서가 가장 안정적이다.

1. `button_event_decoder` 또는 `hold_detector`
2. `timer_datapath`
3. `timepiece_datapath`
4. `timer_fsm`
5. `timepiece_fsm`
6. `common_control_logic`
7. `display_select_logic`
8. `top_watch_project`
9. set-level simulation
10. top integration simulation
11. synthesis / bitstream

핵심은 `Datapath`와 `입력 분류`를 먼저 끝내고, 그 위에 FSM을 얹는 것이다.

## Simulation 분해 기준

사용자 요구대로 시뮬레이션은 `모듈 단위 → 세트 단위 → 종합 테스트`로 나누는 것이 맞다.

### 1. 모듈 단위 Unit Simulation

먼저 각 모듈을 단독 검증한다.

| 테스트벤치 | 검증 대상 | 확인할 것 |
| --- | --- | --- |
| `tb_button_debounce.v` | `button_debounce` | bounce 제거, clean tick 1회 생성 |
| `tb_button_event_decoder.v` | `button_event_decoder` | short / hold 구분, `BtnR 2초`, `BtnU/BtnD 1.5초` 검출 |
| `tb_timer_datapath.v` | `timer_datapath` | up/down, clear, carry, wrap 또는 stop 규칙 |
| `tb_timepiece_datapath.v` | `timepiece_datapath` | 실시간 증가, `SHIFT_MSEC/SEC/MIN/HOUR`, ones/tens 편집 |
| `tb_timer_fsm.v` | `timer_fsm` | `STOP/RUN/COUNT_UPDOWN/COUNT_CLEAR` 전이 |
| `tb_timepiece_fsm.v` | `timepiece_fsm` | `VIEW/SET/INDEX_SHIFT/INCREMENT_ONES/INCREMENT_TENS/DECREMENT_ONES/DECREMENT_TENS` 전이 |
| `tb_common_control_logic.v` | `common_control_logic` | `SW0`, `SW15`, `BtnC`, `BtnR short` 처리 |
| `tb_display_select_logic.v` | `display_select_logic` | `Timepiece/Timer`, `HH:MM/SS:MS` 선택 |
| `tb_fnd_controller.v` | `fnd_controller` | digit split, scan, 표시 mux |

### 2. 세트 단위 Set Simulation

그 다음 관련 모듈끼리 묶는다.

| 세트 테스트벤치 | 묶는 모듈 | 목적 |
| --- | --- | --- |
| `tb_timepiece_set.v` | `button_debounce + button_event_decoder + timepiece_fsm + timepiece_datapath` | Timepiece 설정 흐름 전체 검증 |
| `tb_timer_set.v` | `button_debounce + timer_fsm + timer_datapath` | Timer 동작 흐름 전체 검증 |
| `tb_display_set.v` | `display_select_logic + fnd_controller` | 값 선택과 표시 경로 검증 |

### 3. 종합 Integration Simulation

마지막에는 top 전체를 본다.

| 테스트벤치 | 대상 | 목적 |
| --- | --- | --- |
| `tb_top_watch_project.v` | `top_watch_project` | 모드 전환, setting 진입, unit shift, ones/tens 편집, timer run/stop, clear, display 전환 전체 검증 |

## 2인 1조 역할 분담 권장안

시간이 충분하면 "내가 구현한 모듈은 상대가 unit test를 쓰는 구조"가 가장 깔끔하다.

하지만 지금처럼 시간이 부족하면 아래 방식이 더 현실적이다.

- `unit` 단계에서는 각자 자기 모듈을 구현하고, 자기 모듈 testbench도 직접 작성한다.
- `set` 이상 통합 단계에서만 상대 영역을 1개씩 검증한다.
- 마지막 `top integration`은 공동 작성으로 간다.

즉, 이번 프로젝트는 `self unit test + limited peer integration test` 구조로 가는 것을 권장한다.

### 역할 분담안

| 사람 | 구현 담당 | 자기 검증 담당 |
| --- | --- | --- |
| 김연우(`mumallaeng`) | `timepiece_fsm`, `timepiece_datapath` | 위 2개 모듈의 unit simulation |
| 이영현(`younghyun0702`) | `button_event_decoder`, `common_control_logic`, `timer_fsm`, `timer_datapath`, `display_select_logic`, `top_watch_project` | 위 모듈들의 unit simulation |

### unit test 권장 분배

시간이 부족하므로 `unit test`는 자기 구현 모듈을 자기가 바로 검증하는 구조로 간다.

| 사람 | 작성할 testbench |
| --- | --- |
| 김연우(`mumallaeng`) | `tb_timepiece_fsm.v`, `tb_timepiece_datapath.v` |
| 이영현(`younghyun0702`) | `tb_button_event_decoder.v`, `tb_common_control_logic.v`, `tb_timer_fsm.v`, `tb_timer_datapath.v`, `tb_display_select_logic.v`, `tb_top_smoke.v` 또는 `top_watch_project` 단위 기본 test |

### set 단위 통합 시뮬 분배

`unit`을 묶는 첫 통합 단계는 각자 자기 영역을 먼저 책임지는 방식으로 나누는 것이 가장 빠르다.

| 사람 | 작성할 세트 테스트 | 목적 |
| --- | --- | --- |
| 김연우(`mumallaeng`) | `tb_timepiece_set.v` | `button_event_decoder + timepiece_fsm + timepiece_datapath` 통합 검증 |
| 이영현(`younghyun0702`) | `tb_timer_set.v` | `button_debounce + timer_fsm + timer_datapath` 통합 검증 |

추가로 표시 경로는 한 사람이 전담하는 편이 낫다.

| 사람 | 작성할 표시 통합 테스트 | 목적 |
| --- | --- | --- |
| 이영현(`younghyun0702`) | `tb_display_set.v` | `display_select_logic + fnd_controller` 검증 |

### 상대 검증은 1인당 1개만 하는 권장안

서로의 것을 직접 테스트하는 건 `1인당 1개`만 하기로 하면 아래 배분이 가장 공정하다.

| 사람 | 상대 영역에서 맡을 테스트 1개 | 이유 |
| --- | --- | --- |
| 김연우(`mumallaeng`) | `tb_timer_set_peer.v` 또는 `tb_timer_set.v` 보강 | 이영현이 만든 `timer_fsm + timer_datapath` 통합이 실제로 잘 묶였는지 확인 |
| 이영현(`younghyun0702`) | `tb_timepiece_set_peer.v` 또는 `tb_timepiece_set.v` 보강 | 김연우가 만든 `timepiece_fsm + timepiece_datapath` 통합이 실제로 잘 묶였는지 확인 |

즉, 상대 검증은 `unit`이 아니라 `set` 단계에서 한 번씩만 수행한다.

### 서로의 것을 합치는 경계에서의 테스트

사용자 말대로 가장 의미 있는 상호 검증 지점은 "서로의 모듈이 합쳐지는 부분"이다.

이번 프로젝트에서는 그 경계를 두 군데로 볼 수 있다.

| 경계 | 추천 테스트 | 담당 |
| --- | --- | --- |
| `Timepiece/Timer` 결과가 `Display Select Logic`으로 모이는 지점 | `tb_display_merge.v` 또는 `tb_top_watch_project.v` 일부 시나리오 | 이영현 주도, 김연우 확인 |
| 전체 top에서 버튼 입력과 두 FSM 결과가 함께 동작하는 지점 | `tb_top_watch_project.v` | 공동 |

따라서 상대 테스트를 억지로 unit까지 내릴 필요는 없고, 실제로는 `set 1개 + top 공동`이면 충분하다.

### 최종 top integration 분담

최종 `tb_top_watch_project.v`는 공동 작성으로 가되, 시나리오를 반씩 나누는 것이 가장 공정하다.

| 사람 | top integration에서 맡을 시나리오 |
| --- | --- |
| 김연우(`mumallaeng`) | `Timepiece` 중심 시나리오: `SET 진입`, `SHIFT_MSEC/SEC/MIN/HOUR`, short/hold 편집, `HH:MM ↔ SS:MS` 전환 |
| 이영현(`younghyun0702`) | `Timer` 중심 시나리오: `RUN/STOP`, `COUNT_UP/DOWN`, `CLEAR`, `Timepiece ↔ Timer` 모드 전환 |

그리고 마지막 waveform review는 둘이 같이 본다.

이 구조의 장점은 다음과 같다.

- 두 사람 모두 구현과 검증을 한다.
- unit 단계에서 속도가 빠르다.
- 상대 검증은 통합 경계에서만 수행하므로 시간이 덜 든다.
- 최종적으로는 서로의 블록이 합쳐지는 지점에서 한 번씩 검증하게 된다.

## 구현 파일 권장 목록

### source

- `button_event_decoder.v`
- `common_control_logic.v`
- `timepiece_fsm.v`
- `timepiece_datapath.v`
- `timer_fsm.v`
- `timer_datapath.v`
- `display_select_logic.v`
- `top_watch_project.v`

### simulation

- `tb_button_event_decoder.v`
- `tb_common_control_logic.v`
- `tb_timepiece_fsm.v`
- `tb_timepiece_datapath.v`
- `tb_timer_fsm.v`
- `tb_timer_datapath.v`
- `tb_display_select_logic.v`
- `tb_fnd_controller.v`
- `tb_timepiece_set.v`
- `tb_timer_set.v`
- `tb_top_watch_project.v`

## 최종 권장 판단

이번 프로젝트는 아래처럼 정리하면 가장 깔끔하다.

- `button_debounce`, `tick_counter`, `tick_gen_100hz`, 최신 `fnd_controller`는 최대한 재사용
- `Timer` 쪽은 기존 `stopwatch_datapath`를 기반으로 수정
- `Timepiece` 쪽은 신규 설계
- 입력 처리에서 `debounce`와 `hold detect`를 분리
- 검증은 `unit → set → top integration` 순서 고정
- `Vivado 2020.2`에서는 `Open Elaborated Design`과 `Open Synthesized Design`을 단계별로 구분해서 확인

즉, 구현 난이도를 균등하게 나누려면 한 사람은 `입력 + Timepiece`, 다른 한 사람은 `Timer + Display + Top`을 맡고, 검증은 서로 반대로 맡는 방식이 가장 공정하다.
