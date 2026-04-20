# Timepiecer
Verilog Watch Project: Timepiece and Timer

## Project Layout

- Main project HDL: `Timepiecer.srcs/sources_1/new/`
- Imported reference HDL: `Timepiecer.srcs/sources_1/imports/stopwatch_watch/`
- Simulation sources: `Timepiecer.srcs/sim_1/new/`
- Vivado project: `Timepiecer.xpr`

## Docs

Design/report docs are managed in Vault.

- `~/git/Vault/activities/korcham/notes/verilog-hdl/reports/watch-project-timepiece-timer/`

## Vivado Tcl

You can recreate a local timepiecer reference project with Tcl:

```tcl
source vivado/create_timepiecer_project.tcl
```

The script creates a local project under `.vivado/timepiecer_reference/` so the
tracked repo files stay clean.

## Local Helper

Build a `.bit` from source on macOS without the GUI run manager.
This helper does a full resynthesis + implementation inside the Vivado Docker container:

```bash
./vivado/build_and_program_basys3.sh --build-only
```

Program Basys3 from macOS:

```bash
openFPGALoader -b basys3 ./Timepiecer.runs/impl_1/timepiecer_nonproject.bit
```

Or do both in one step:

```bash
./vivado/build_and_program_basys3.sh
```
