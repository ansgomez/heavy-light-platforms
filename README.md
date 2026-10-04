Heavy-Light Platforms
===

***Vasileios Glykantzis, Andres Gomez, Rehan Ahmed, Lothar Thiele***

***ETH Zurich***

Models, emulation code, experimental results and paper sources for the study of
energy/performance trade-offs in *Heavy-Light* dual-core platforms: a power-hungry
(Heavy) core designed for worst-case PVT conditions and a low-power (Light) core with
reduced design margins. The work derives task-allocation policies that are optimal with
respect to energy and makespan and validates them by emulating heavy-light behavior on a
commercial NXP LPC43xx dual-core (Cortex-M4 + Cortex-M0) platform.

**Status:** research artifact (2016-2017), not maintained.

### Publication

   Glykantzis V, Gomez A, Ahmed R, Thiele L.
   Performance and Energy Trade-Offs in Heavy-Light Platforms.

   TODO: venue/year/DOI. The paper sources in `paper/` use the ASP-DAC 2017 template
   (`paper/ASPDAC.tex`, `paper/ASPDAC.pdf`); confirm whether and where it was published.

### Repository layout

- `code/matlab_model/` - MATLAB models
  - `nxp-matlab_v2.1/` - simulation framework of the heavy-light architecture (allocators, core model, GUI; see its `README.txt`)
  - `Theoretical results/` - `Delta_simulation.m`, `Util_simulation.m` (makespan and energy savings vs. delta / utilization)
  - `Comparison with LPBP/`, `Delta-tasks correlation/` - comparison and correlation experiments
- `code/code_experiments/` - master/slave/single-core C code for the synthetic and real (`flow`, `openshoe`) benchmarks on the LPC43xx
- `code/samples_lpc_project/SequentialMultiprocessing/` - Keil uVision dual-core (CM4/CM0) LPC43xx project
- `experimental_results/` - measured results (Excel workbooks) and plotting scripts for real and synthetic benchmarks
- `paper/` - LaTeX sources, figures and compiled PDF

Note: the repository is ~130 MB, almost entirely due to `.xlsx` measurement files in
`experimental_results/` (~124 MB).

### Third-party code

- NXP LPC43xx example code and Keil startup files (file headers: NXP Semiconductors, Keil/ARM) remain under their original terms.
- `paper/IEEEtran.cls`, `IEEEtran_HOWTO.pdf`, `sig-alternate-05-2015.cls`, `acmcopyright.sty` are publisher templates.

TODO: no license has been chosen yet for the original code in this repository.
