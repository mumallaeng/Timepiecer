# Watch Project Overview

## 문서 목적

이 폴더는 `Watch Project`의 설계 문서를 단계별로 정리한 작업 공간이다.

이번 구조의 핵심은 아래 세 가지를 분리하는 것이다.

- `Requirement`: 사용자가 무엇을 할 수 있어야 하는가
- `Function`: 각 버튼과 스위치가 어떤 기능을 수행하는가
- `State`: 시스템이 무엇을 기억해야 하며 어떤 상태 전이를 갖는가

특히 `State Diagram`을 그릴 때는 기능 표만으로는 부족하므로, `State Specification` 문서를 별도로 둔다.

## 프로젝트 개요

- 프로젝트명: `Watch Project`
- 핵심 기능: `Timepiece + Timer`
- 표시 형식: `HH:MM`, `SS:MS`
- 대상 보드: `Digilent Basys 3`
- 설계 구조: `Input Conditioning`, `Control Unit`, `Datapath`, `FND Controller`

핵심 동작 전제는 다음과 같다.

- 스위치는 `Down = 0`, `Up = 1`로 해석한다.
- 버튼 입력은 `0 ↔ 1`로 동작한다.
- 모든 제어 상태의 기본값은 `0 (OFF)`를 기준으로 한다.
- `Timepiece`는 현재 표시 모드와 무관하게 백그라운드에서 계속 동작해야 한다.

## 명명 기준

`Clock`은 코드에서 하드웨어 클록 신호 `clk`와 쉽게 혼동되므로, 기능 명칭은 아래처럼 분리한다.

- 프로젝트명: `Watch Project`
- 시계 기능명: `Timepiece`
- 스톱워치 기능명: `Timer`

코드 명칭도 이 기준을 따른다.

- `clk`: 하드웨어 클록 신호
- `timepiece_value`: 시계 값
- `timer_value`: 타이머 값
- `timepiece_state`: `VIEW`, `SET`, `INDEX_SHIFT`, `INCREMENT_ONES`, `INCREMENT_TENS`, `DECREMENT_ONES`, `DECREMENT_TENS`
- `timer_state`: `STOP`, `RUN`, `COUNT_UPDOWN`, `COUNT_CLEAR`
- `position_shift`: `SHIFT_MSEC`, `SHIFT_SEC`, `SHIFT_MIN`, `SHIFT_HOUR`
- `count_updown`: `COUNT_UP`, `COUNT_DOWN`
- `is_timepiece_mode`, `is_timer_mode`: 현재 어느 FSM 출력이 활성인지 나타내는 모드 플래그

## 문서 흐름

이 설계 문서는 아래 순서로 읽는 것을 기준으로 한다.

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

이 순서를 따르는 이유는 다음과 같다.

- 요구사항을 먼저 고정한다.
- 그 요구사항이 어떤 구조로 구현되는지 블록 단위로 본다.
- 사용자 관점 기능을 정리한다.
- 기능과 별개로 시스템이 기억해야 하는 상태를 정리한다.
- 그 상태를 기준으로 상태도를 그린다.
- 상태 정의를 바탕으로 예상 RTL 구조를 먼저 정리한다.
- 구현 규칙을 정리한 뒤 실제 RTL Schematic 확인 항목으로 이어진다.
- 남은 설계 결정과 실제 구현/시뮬 계획은 보조 문서로 따로 관리한다.
