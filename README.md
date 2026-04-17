# Timerpiece
Verilog Watch Project: Timepiece and Timer

## Stopwatch Reference Import

The repo includes the stopwatch reference HDL listed in
`docs/10-implementation-and-simulation-plan.md`, plus a checked-in Vivado
project file for the stopwatch reference flow.

Imported files live under:

- `Timerpiece.srcs/sources_1/new/`
- `Timerpiece.srcs/sources_1/imports/10000_counter/`
- `Timerpiece.srcs/sources_1/imports/stopwatch_watch/`
- `Timerpiece.srcs/sim_1/imports/new/`
- `Timerpiece.srcs/sim_1/new/`

You can open the checked-in project directly:

- `Timerpiece.xpr`

Or recreate the stopwatch reference project with Tcl:

```tcl
source vivado/create_stopwatch_reference_project.tcl
```

The script creates a local project under `.vivado/stopwatch_reference/` so the
tracked repo files stay clean.
