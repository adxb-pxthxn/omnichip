# Getting omnichip running on your machine

I want the day-to-day loop to feel like ordinary software work: edit Verilog, run a test, look at a waveform. Hardening to GDS is a separate, heavier path. You do not need the PDK, Docker, or LibreLane to write RTL or firmware. You need those when you care about area and timing.

If you have used the Tiny Tapeout template before, this is that template, pointed at the Jane Street **CMOS5L** shuttle (`ihp-sg13cmos5l`) instead of the default IHP SG13G2 flow. The stock `ttihp-verilog-template` still wires `ttihp26b` / `ihp-sg13g2`. Do not copy those tags into this repo.

## Two readings of the same repo

| Path | What it is for | What you need |
|---|---|---|
| **Sim** | RTL, cocotb, assembler, golden model | Python 3.11+, Icarus Verilog, a venv |
| **Harden** | GDS, STA, precheck | Sim tools + Docker + CMOS5L PDK + LibreLane |

Treat sim as the compiler and unit tests. Treat harden as a release build you run when the design has something new worth measuring. CI runs both; your laptop only has to run sim until you are chasing utilization or slack.

## Sim path (do this first)

### Option A — Dev Container (recommended)

VS Code / Cursor with the Dev Containers extension, and Docker.

1. Clone the repo and open the folder.
2. Reopen in Container. The image installs Icarus, Verilator, cocotb, verible, LibreLane, and the `ihp-sg13cmos5l` branch of `tt-support-tools`.
3. In the container terminal:

```bash
cd test
make
python -m cocotb_tools.check_results results.xml
```

The first build of the image is slow. Later opens reuse the layer cache.

### Option B — Bare metal

macOS or Linux. From the repo root:

```bash
./scripts/setup-sim.sh
source .venv/bin/activate
./scripts/check-env.sh
cd test && make
python -m cocotb_tools.check_results results.xml
```

`setup-sim.sh` will refuse to continue if `iverilog` is missing:

- macOS: `brew install icarus-verilog`
- Ubuntu / Debian: `sudo apt-get install -y iverilog`

Waveforms land in `test/tb.fst`. Surfer or gtkwave both work. I use Surfer the same way I used it on the Jane Street reverse-engineering puzzle: open the FST, find the pins you care about, ignore the rest until a test fails.

### What "green" means

`make` in `test/` running the placeholder top (`tt_um_omnichip`) and `check_results` exiting 0. That is the smoke test for the environment, not the chip. The next real design step is issue #10: a hardwired UART TX through the same flow to GDS.

## Harden path (when you need a die)

Local hardening matches what GitHub Actions runs with `TinyTapeout/tt-gds-action@ihp-cmos5l`.

```bash
./scripts/setup-harden.sh
export PDK_ROOT="$HOME/ttsetup/pdk"
export PDK=ihp-sg13cmos5l
source "$HOME/ttsetup/venv/bin/activate"

./tt/tt_tool.py --create-user-config --ihp
./tt/tt_tool.py --harden --ihp
```

Notes that bit me (or other teams) already:

- **Tools branch is `ihp-sg13cmos5l`**, not `main`, and not a typo of `ihp-cmos5l`. The GDS *action* tag is `@ihp-cmos5l`; the support-tools *git branch* is `ihp-sg13cmos5l`.
- **PDK pin** is IHP-Open-PDK `2bbec755dc67ca3db0261c3d6163e15735d66710`. `scripts/install-pdk-cmos5l.sh` fetches exactly that. Do not "upgrade" it casually or your numbers stop matching CI.
- **LibreLane** is pinned to `3.1.0.dev3` to match the action default. Same rule.
- First PDK clone is large. Later runs reuse `$PDK_ROOT`.
- Outputs go under `runs/`. Those artifacts are gitignored on purpose.

You can skip local harden entirely and push; the `gds` workflow will build on `ubuntu-24.04`. Local harden is for shorter iteration when you are staring at utilization or a slow-corner path.

## Repo layout

```
src/                 Verilog (tt_um_omnichip is the Tiny Tapeout top)
test/                cocotb + Icarus Makefile
docs/                setup (this file), datasheet stub (info.md)
scripts/             setup-sim, setup-harden, install-pdk, check-env
.github/workflows/   test, gds, docs, fpga — all on @ihp-cmos5l
.devcontainer/       CMOS5L-oriented Tiny Tapeout container
info.yaml            6x4 tiles, 50 MHz, top_module, pin names
```

Firmware, assembler, and the golden model are not here yet. When they land they should grow next to `test/`, not as a second unrelated tree.

## CI

| Workflow | Trigger | What it proves |
|---|---|---|
| `test` | every push | Icarus + cocotb |
| `gds` | every push | LibreLane harden, precheck, gate-level test, viewer |
| `docs` | every push | Tiny Tapeout datasheet build |
| `fpga` | manual only | ICE40 bitstream for the ASIC sim board |

If `test` is red, do not look at GDS logs. If `test` is green and `gds` is red, that is a physical or config problem, not a cocotb flake.

## Common failures

**`iverilog: command not found`**  
Sim setup did not see Icarus. Install it system-wide; the venv cannot provide it.

**`ensurepip is not available` / `python3 -m venv` fails**  
On Debian/Ubuntu: `sudo apt-get install -y python3-venv`, then remove a half-created `.venv` and rerun `./scripts/setup-sim.sh`.

**`make` succeeds but `check_results` fails**  
cocotb's Makefile exit code is not enough. Always run `python -m cocotb_tools.check_results results.xml`, the same way CI does.

**Dev Container builds against SG13G2**  
You opened the wrong template, or an old image. Confirm `.devcontainer/Dockerfile` has `PDK=ihp-sg13cmos5l` and `TT_SUPPORT_TOOLS_BRANCH=ihp-sg13cmos5l`, then rebuild the container with no cache.

**Local harden cannot find the PDK**  
`echo $PDK_ROOT $PDK` should print something like `/home/you/ttsetup/pdk ihp-sg13cmos5l`, and `$PDK_ROOT/ihp-sg13cmos5l/SOURCES` should mention `2bbec755…`.

**GitHub `gds` still says `ttihp26b`**  
That is the stock IHP template. This repo's workflows must say `@ihp-cmos5l` and `pdk: ihp-sg13cmos5l`. If you see `ttihp26b`, someone re-copied the wrong YAML.

## Closing

The mental model I want for collaborators is the same one that worked on the Sky130 puzzle: treat the RTL like a program, Icarus like the runtime, Surfer like a debugger, and the GDS flow like a release pipeline you only run when the program is worth shipping. Get `cd test && make` green on your machine before you touch pinmux, host SPI, or the instruction set.

If setup is still broken after `./scripts/check-env.sh`, open an issue with the script output and your OS. Do not silently invent a third toolchain.
