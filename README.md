# WiLabVIsim

**_WiLabVIsim_** is a Matlab-based open-source simulator, specifically designed for analyzing radar-to-radar interference in realistic vehicular scenarios, where hundres of moving vehicles are equipped with one or more radars. 

The tool calculates during the simulation the number of potential interferers that each sensor perceives based on its actual positions and the position of the sorrounding vehicles. 
The tool remains agnostic of the signal waveform (e.g., FMCW rather than OFDM) and other radar parameters.

The output includes information concerning the path of potentially interfering signals and the position and speed of the vehicles mounting the source and victim radards.
The output can then be used for the study of interference in realistic scenarios with multiple vehicles and the design and evaluation of methods for interference mitigation.

## Notes
- Matlab version ...
- SUMO version ...

## References
The main reference for the simulator is:

- A. Bazzi, F. Miccoli, Z. Wu, F. Cuccoli, and V. Martinez, "A tool for
  the statistical investigation of the automotive radar interference", in URSI
  Atlantic Radio Science Conference (AT-RASC), IEEE, 2024.

-------------------------------------------------------------
List of main current contributors:
- Francesco Miccoli (francesco.miccoli@wilab.cnit.it)
- Alessandro Bazzi (alessandro.bazzi@unibo.it)

Also contributing or contributed, in alphabetic order:
- Wu Zhuofei, also called Felix
-------------------------------------------------------------
