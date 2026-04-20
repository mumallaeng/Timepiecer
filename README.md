# Timerpiece
Verilog Watch Project: Timepiece and Timer

## Project Layout

- Main project HDL: `Timerpiece.srcs/sources_1/new/`
- Imported reference HDL: `Timerpiece.srcs/sources_1/imports/stopwatch_watch/`
- Simulation sources: `Timerpiece.srcs/sim_1/new/`
- Vivado project: `Timerpiece.xpr`

## Docs

Design/report docs are managed in Vault.

- `~/git/Vault/activities/korcham/notes/verilog-hdl/reports/watch-project-timepiece-timer/`

## Vivado Tcl

You can recreate a local timerpiece reference project with Tcl:

```tcl
source vivado/create_timerpiece_project.tcl
```

The script creates a local project under `.vivado/timerpiece_reference/` so the
tracked repo files stay clean.
