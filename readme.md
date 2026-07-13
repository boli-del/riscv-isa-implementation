## Cache Performances
### Direct Mapped Cache
512B cold (L1 miss / L2 hit) avg 3.11 cyc (min 3, max 5, n=128)

512B warm (L1 hit) avg 3.00 cyc (min 3, max 3, n=128)

next 512B (L1 miss / L2 hit) avg 3.12 cyc (min 3, max 5, n=128)

upper 1KB (L1 miss / L2 miss) avg 3.31 cyc (min 3, max 8, n=256) / fetch from base mem

upper 1KB warm (L1 hit) avg 3.00 cyc (min 3, max 3, n=256)

thrash 0x000/0x400 (all miss) avg 8.00 cyc (n=32) / no fetch from anywhere

Calculated AMAT: 3.12 cyc

### Fully Associative Cache
512B cold  (L1 miss / L2 hit)      avg 3.16 cyc  (min 3, max 6, n=128)

512B warm  (L1 hit)                avg 3.00 cyc  (min 3, max 3, n=128)

next 512B  (L1 miss / L2 hit)      avg 3.19 cyc  (min 3, max 6, n=128)

upper 1KB  (L1 miss / L2 miss)     avg 3.38 cyc  (min 3, max 9, n=256)

upper 1KB warm (L1 hit)            avg 3.00 cyc  (min 3, max 3, n=256)

alternating between 0x000/0x400 (FA: hits)   avg 3.38 cyc  (n=32)   (testing associativity)

refill 512B                        avg 3.33 cyc  (min 3, max 9, n=128)

Calculated AMAT: 3.16 cyc
