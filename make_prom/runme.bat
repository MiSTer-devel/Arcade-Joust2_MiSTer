copy /B cpu_2732_ic9_rom3_rev2.4d    + cpu_2732_ic10_rom4_rev2.4f joust2_prog2.bin
copy /B cpu_2732_ic26_rom19_rev1.10j + cpu_2732_ic24_rom17_rev1.10h + cpu_2732_ic22_rom15_rev1.9j + cpu_2732_ic20_rom13_rev1.9h joust2_bank_a.bin
copy /B cpu_2732_ic25_rom18_rev1.10i + cpu_2732_ic23_rom16_rev1.10g + cpu_2732_ic21_rom14_rev1.9i + cpu_2732_ic19_rom12_rev1.9g joust2_bank_b.bin
copy /B cpu_2732_ic18_rom11_rev1.8j  + cpu_2732_ic16_rom9_rev2.8h   + cpu_2732_ic14_rom7_rev2.6j  + cpu_2732_ic12_rom5_rev2.6h joust2_bank_c.bin
copy /B cpu_2732_ic17_rom10_rev1.8i  + cpu_2732_ic15_rom8_rev1.8g   + cpu_2732_ic13_rom6_rev2.6i  joust2_bank_d.bin

make_vhdl_prom cpu_2732_ic55_rom2_rev1.4c joust2_prog1.vhd
make_vhdl_prom joust2_prog2.bin joust2_prog2.vhd
make_vhdl_prom joust2_bank_a.bin joust2_bank_a.vhd
make_vhdl_prom joust2_bank_b.bin joust2_bank_b.vhd
make_vhdl_prom joust2_bank_c.bin joust2_bank_c.vhd
make_vhdl_prom joust2_bank_d.bin joust2_bank_d.vhd

make_vhdl_prom cpu_2764_ic8_rom1_rev1.0f    joust2_sound.vhd
make_vhdl_prom vid_27128_ic57_rom20_rev1.8f joust2_graph1.vhd
make_vhdl_prom vid_27128_ic58_rom21_rev1.9f joust2_graph2.vhd
make_vhdl_prom vid_27128_ic41_rom22_rev1.9d joust2_graph3.vhd

make_vhdl_prom vid_82s147a_ic60_a-5282-10292.12f joust2_decoder.vhd
