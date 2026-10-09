# omnichip

One chip, many protocols.

Frome Road's entry for Jane Street's [protocol emulator ASIC competition](https://blog.janestreet.com/protocol-emulator-asic-competition/). IHP 130 nm **CMOS5L** through Tiny Tapeout, 6×4 tiles, open source (Apache-2.0).

The chip is meant to be a small reprogrammable CPU for bit-banged protocols: UART, SPI, and I2C first; the rest only if the die and the calendar allow it. There is a longer design note in the project store; this README is for getting the repo running.

## Get running

```bash
git clone https://github.com/adxb-pxthxn/omnichip.git
cd omnichip
./scripts/setup-sim.sh
source .venv/bin/activate
cd test && make
python -m cocotb_tools.check_results results.xml
```

Or open the folder in VS Code / Cursor and **Reopen in Container**. Same tests, heavier first build.

Full setup, harden path, and CMOS5L footguns: **[docs/setup.md](docs/setup.md)**.

## Status

The tree is the Tiny Tapeout CMOS5L flow with a placeholder top (`tt_um_omnichip`) so sim and GDS CI have something to chew on. Next hardware milestone is [issue #10](https://github.com/adxb-pxthxn/omnichip/issues/10): hardwired UART TX through to GDS, then make it programmable.

## Layout

| Path | Role |
|---|---|
| `src/` | Verilog |
| `test/` | cocotb + Icarus |
| `docs/setup.md` | how we develop |
| `scripts/` | sim / harden / PDK helpers |
| `.github/workflows/` | `test`, `gds`, `docs` on `@ihp-cmos5l` |
| `info.yaml` | tiles, clock, pin names, top module |

## Links

- [Contest post](https://blog.janestreet.com/protocol-emulator-asic-competition/)
- [Tiny Tapeout](https://tinytapeout.com)
- [Local hardening guide](https://www.tinytapeout.com/guides/local-hardening/) (generic; we pin CMOS5L in this repo)
- [Adib's site](https://adibpathan.vercel.app/)
