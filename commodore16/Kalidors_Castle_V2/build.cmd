@echo off
ca65 bouncy.asm
ca65 utils.asm
ca65 data.asm
ca65 sprite_data.asm
ca65 sprite.asm 
cl65 --obj data.o utils.o sprite_data.o sprite.o bouncy.o -t c16 -o bouncy