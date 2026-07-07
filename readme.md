## Cache Performances
### Direct Mapped Cache
512B cold (L1 miss / L2 hit) avg 3.11 cyc (min 3, max 5, n=128)

512B warm (L1 hit) avg 3.00 cyc (min 3, max 3, n=128)

next 512B (L1 miss / L2 hit) avg 3.12 cyc (min 3, max 5, n=128)

upper 1KB (L1 miss / L2 miss) avg 3.31 cyc (min 3, max 8, n=256) / fetch from base mem

upper 1KB warm (L1 hit) avg 3.00 cyc (min 3, max 3, n=256)

thrash 0x000/0x400 (all miss) avg 8.00 cyc (n=32) / no fetch from anywhere

Calculated AMAT: 3.12 cyc