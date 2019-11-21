# GOMOKU-FPGA
## Repository Road Map
``````
GOMOKU-FPGA
|gomoku.v
|DE1_SoC.qsf
|-utils
|  |-bmp2mif
|  |-andgates
|-adapters
|  |-Altera_UP_PS2_Command_Out.v
|  |-Altera_UP_PS2_Data_In.v
|  |-PS2_Controller.v
|  |-PS2_Keyboard_Controller.v
|  |-vga_adapter.bsf
|  |-vga_adapter.v
|  |-vga_address_translator.v
|  |-vga_controller.v
|  |-vga_pll.v
|-slides
|  |-walk_through_slides.tex
|  |-walk_through_slides.pdf
``````

## Requirements
- FPGA board: DE1_SoC board with Cyclone V, ```5CSEMA5F31C6```
- Compiled on Altera Quartus Prime 18.1
