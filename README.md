# GOMOKU-FPGA

Please refer to the walk through slides [here](https://tingfengx.github.io/GOMOKU-FPGA/slides/walk_through_slides.pdf) for implementation details and output behavior.

## Repository Road Map
```
GOMOKU-FPGA/
├── DE1_SoC.qsf
├── README.md
├── adapters
│   ├── Altera_UP_PS2_Command_Out.v
│   ├── Altera_UP_PS2_Data_In.v
│   ├── PS2_Controller.v
│   ├── PS2_Keyboard_Controller.v
│   ├── qmegawiz_errors_log.txt
│   ├── vga_adapter.bsf
│   ├── vga_adapter.v
│   ├── vga_address_translator.v
│   ├── vga_controller.v
│   ├── vga_pll.cnx
│   ├── vga_pll.cnxerr
│   ├── vga_pll.qip
│   └── vga_pll.v
├── gomoku.v
├── img
│   ├── gomoku_start.bmp
│   ├── image.colour.mif
│   └── image.mono.mif
├── slides
│   ├── color_fsm.png
│   ├── gameplay.jpeg
│   ├── keyboard.png
│   ├── place_go.png
│   ├── screen_fsm.png
│   ├── start.jpeg
│   ├── walk_through_slides.pdf
│   └── walk_through_slides.tex
└── utils
    └── bmp2mif
        ├── a.out
        ├── bmp2mif.c
        ├── bmp2mif.exe
        ├── bmp2mif.ncb
        ├── bmp2mif.o
        ├── bmp2mif.sln
        ├── bmp2mif.suo
        ├── bmp2mif.vcproj
        ├── gomoku_start.bmp
        ├── image.colour.mif
        └── image.mono.mif
```

## Requirements
- FPGA board: DE1_SoC board with Cyclone V, ```5CSEMA5F31C6```
- Compiled on Altera Quartus Prime 18.1
