\# Pipelined Tensor Processing Slice \& Verification Suite



A 3-stage pipelined 4-lane vector dot-product engine implemented in SystemVerilog, modeling GPU Tensor Core microarchitectures for INT8 matrix multiplication workloads.



\## Microarchitecture

\- \*\*Stage 1 (Multiply)\*\*: 4 parallel signed INT8 multipliers ($A\_i \\times B\_i$) producing 16-bit intermediate products with input pipeline registers.

\- \*\*Stage 2 (Adder Tree)\*\*: 18-bit balanced adder tree summing the 4 products without bit truncation.

\- \*\*Stage 3 (Accumulate \& Saturate)\*\*: 19-bit accumulator adding staged 16-bit bias $C$, followed by two's complement saturation logic clamped to `\[-32768, 32767]` (`0x7FFF` / `0x8000`), driving `overflow` and `valid\_out`.

\- \*\*Throughput\*\*: 3-cycle latency with continuous 1-result-per-cycle streaming throughput.



\## Verification

\- Automated regression suite using an independent Python golden reference model.

\- Testbench streams 1,008 vectors via file I/O (`inputs.hex` / `expected.hex`).

\- Stimulus driven on `negedge clk` to guarantee stable setup-time margins for the DUT sampling on `posedge clk`.

\- \*\*Result\*\*: 1,008 / 1,008 tests passed with 0 mismatches.



\## Waveform

!\[Simulation Waveform](waveform.png)



\## Running Simulation

```bash

\# Generate vectors

python verify.py



\# Compile and simulate with Icarus Verilog

iverilog -g2012 -o sim.vvp dot\_product.sv tb\_dot\_product.sv

vvp sim.vvp



\# View trace

gtkwave dump.vcd

