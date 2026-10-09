<!---

This file is used to generate your project datasheet. Please fill in
the information below and delete any unused sections.

You can also include images in this folder and reference them in the
markdown. Each image must be less than 512 kb in size, and the
combined size of all images must be less than 1 MB.

-->

## How it works

Placeholder Tiny Tapeout top for the Frome Road / omnichip CMOS5L entry.
`uo_out` is currently `ui_in + uio_in` so the sim and GDS flows have a known
oracle. This will be replaced by a hardwired UART TX, then a reprogrammable
bit-bang core (see the repo README and GitHub issues).

## How to test

```bash
./scripts/setup-sim.sh
source .venv/bin/activate
cd test && make
python -m cocotb_tools.check_results results.xml
```

## External hardware

None for the placeholder. The programmable design will expect an SPI host
on the Tiny Tapeout demo board's microcontroller.
