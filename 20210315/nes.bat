X F_Reset.asm
L -C F_Reset -X
COPY F_Reset.TSK F_Reset.BIN
@del F_Reset.tsk
@del F_Reset.obj
cmb Romfile
cmb Testnes
COPY testnes.bin Testnes.nes
