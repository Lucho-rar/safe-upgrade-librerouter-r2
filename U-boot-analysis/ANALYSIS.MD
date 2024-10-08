# Analyzing librerouter init
# Librerouter v1
## First section
```bash
LR-U-Boot v1.1.0-0-g4527b031 (Jan 11 2019 - 01:42:10) ###Version

LibreRouter-1.0 # hardware model
DRAM: # dram init
sri
Scorpion 1.0
ath_ddr_initial_config(195): (32bit) ddr2 init # ddr2 ram init
tap = 0x00000003 # calibration values ?
Tap (low, high) = (0x4, 0x1e) 
Tap values = (0x11, 0x11, 0x11, 0x11)
128 MB #128 MB RAM
Top of RAM usable for U-Boot at: 88000000 # memory reserves
Reserving 202k for U-Boot at: 87fcc000
Reserving 192k for malloc() at: 87f9c000
Reserving 44 Bytes for Board Info at: 87f9bfd4
Reserving 36 Bytes for Global Data at: 87f9bfb0
Reserving 128k for boot params() at: 87f7bfb0
Stack Pointer at: 87f7bf98 # STACK 
Now running in RAM - U-Boot at: 87fcc000 # Run U-Boot in reservated value
Flash Manuf Id 0xef, DeviceId0 0x40, DeviceId1 0x18 # flash data
flash size 16MB, sector count = 256
Flash: 16 MB  # flash 16MB
In:    serial #in/out errors in serial data?
Out:   serial
Err:   serial
Net:   ath_gmac_enet_initialize... #config network
athrs_sgmii_res_cal: cal value = 0xe
Fetching MAC Address from 0x87fed5d8 # MAC address
Fetching MAC Address from 0x87fed5d8
ath_gmac_enet_initialize: reset mask:c02200
Scorpion  ----> S17 PHY *
Vlan config... ##config vlan
s17 phy0 register value 0x00004140
TEST: FINAL REG VAL after TX Calibration - 0x46000000
TEST: FINAL XMII VAL after RX Calibration - 0x56000000
TEST: FINAL ETH_CFG VAL after RX Calibration - 0x00000001
athrs17_reg_init: complete
: cfg1 0x80000000 cfg2 0x7335
eth0: a8:40:41:1f:73:aa
eth0 up #up ethernet 0 
athrs17_reg_init_wan done
SGMII in forced mode
athr_gmac_sgmii_setup SGMII done
: cfg1 0x800c0000 cfg2 0x7214
eth1: a8:40:41:1f:73:ab
eth1 up #up ethernet 1
eth0, eth1
Setting 0x18116290 to 0x2448214f
Hit any key to stop autoboot:  0
ath>
```

## Second section
```bash
0x56000000
TEST: FINAL ETH_CFG VAL after RX Calibration - 0x00000001
athrs17_reg_init: complete
: cfg1 0x80000000 cfg2 0x7335
eth0: a8:40:41:1f:73:aa
eth0 up
athrs17_reg_init_wan done
SGMII in forced mode
athr_gmac_sgmii_setup SGMII done
: cfg1 0x800c0000 cfg2 0x7214
eth1: a8:40:41:1f:73:ab
eth1 up
eth0, eth1
Setting 0x18116290 to 0x2448214f
Hit any key to stop autoboot:  0
ath> boot
## Error: "preboot" not defined
booting part 2
## Booting image at 9f810000 ...
   Image Name:   MIPS LibreRouterOs Linux-6.1.89
   Created:      2024-05-05  15:22:26 UTC
   Image Type:   MIPS Linux Kernel Image (lzma compressed)
   Data Size:    2451076 Bytes =  2.3 MB
   Load Address: 80060000
   Entry Point:  80060000
   Verifying Checksum at 0x9f810040 ...OK
   Uncompressing Kernel Image ... OK
No initrd
## Transferring control to Linux (at address 80060000) ...
## Giving linux memsize in bytes, 134217728

Starting kernel ...

[    0.000000] Linux version 6.1.89 (jjorge@pluma) (mips-openwrt-linux-musl-gcc (OpenWrt GCC 13.2.0 r0-49a64c9) 13.2.0, GNU ld (GNU Binutils) 2.42) #0 Sun May  5 15:22:26 2024 Init messages
[    0.000000] printk: bootconsole [early0] enabled
[    0.000000] CPU0 revision is: 00019750 (MIPS 74Kc) # hardware info
[    0.000000] MIPS: machine is LibreRouter v1
[    0.000000] SoC: Qualcomm Atheros QCA9558 ver 1 rev 0
[    0.000000] User-defined physical RAM map overwrite
[    0.000000] Initrd not found or empty - disabling initrd
[    0.000000] Primary instruction cache 64kB, VIPT, 4-way, linesize 32 bytes. ##cache 
[    0.000000] Primary data cache 32kB, 4-way, VIPT, cache aliases, linesize 32 bytes
[    0.000000] Zone ranges: #rangos de memoria
[    0.000000]   Normal   [mem 0x0000000000000000-0x0000000007ffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000000000-0x0000000007ffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x0000000007ffffff]
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 32480
[    0.000000] Kernel command line: console=ttyS0,115200 board=LIBREROUTERV1 mtdparts=spi0.0:256k(u-boot),64k(u-boot-env),7936k(fw1),7936k(firmware),128k(res),64k(art) mem=128M rootfstype=squashfs,jffs2 # CL kernel
[    0.000000] Unknown kernel command line parameters "board=LIBREROUTERV1", will be passed to user space.
[    0.000000] Dentry cache hash table entries: 16384 (order: 4, 65536 bytes, linear)
[    0.000000] Inode-cache hash table entries: 8192 (order: 3, 32768 bytes, linear)
[    0.000000] Writing ErrCtl register=00000000
[    0.000000] Readback ErrCtl register=00000000
[    0.000000] mem auto-init: stack:off, heap alloc:off, heap free:off
[    0.000000] Memory: 120376K/131072K available (5940K kernel code, 599K rwdata, 1376K rodata, 1228K init, 209K bss, 10696K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] NR_IRQS: 51
[    0.000000] CPU clock: 720.000 MHz
[    0.000000] clocksource: MIPS: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 5309056796 ns
[    0.000001] sched_clock: 32 bits at 360MHz, resolution 2ns, wraps every 5965232126ns
[    0.008324] Calibrating delay loop... 358.80 BogoMIPS (lpj=1794048)
[    0.075008] pid_max: default: 32768 minimum: 301
[    0.080814] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes, linear)
[    0.088604] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes, linear)
[    0.099318] cblist_init_generic: Setting adjustable number of callback queues.
[    0.107043] cblist_init_generic: Setting shift to 0 and lim to 1.
[    0.117226] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
[    0.127728] futex hash table entries: 256 (order: -1, 3072 bytes, linear)
[    0.135114] pinctrl core: initialized pinctrl subsystem
[    0.142170] NET: Registered PF_NETLINK/PF_ROUTE protocol family
[    0.162814] clocksource: Switched to clocksource MIPS
[    0.169569] NET: Registered PF_INET protocol family
[    0.175062] IP idents hash table entries: 2048 (order: 2, 16384 bytes, linear)
[    0.18
```