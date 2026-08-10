## Cache Performances
### Direct Mapped Cache

L1 hit time        3.00 cyc  (1623 hits)

L1 miss rate       0.0597  (103 misses)

L2 hit latency     5.00 cyc  (15 hits, +2.00 over L1 hit)

L2 local miss rate 0.8544  (88 to mem)

mem latency        8.27 cyc  (+3.27 over L2 hit)

AMAT = 3.00 + 0.0597 * (2.00 + 0.8544 * 3.27) = 3.29 cyc

### Fully Associative Cache
L1 hit time        3.00 cyc  (1661 hits)

L1 miss rate       0.0377  (65 misses)

L2 hit latency     6.00 cyc  (18 hits, +3.00 over L1 hit)

L2 local miss rate 0.7231  (47 to mem)

mem latency        9.45 cyc  (+3.45 over L2 hit)

AMAT = 3.00 + 0.0377 * (3.00 + 0.7231 * 3.45) = 3.21 cyc

### 4 Way Set Associative Cache
L1 hit time        3.00 cyc  (1633 hits)

L1 miss rate       0.0539  (93 misses)

L2 hit latency     6.00 cyc  (21 hits, +3.00 over L1 hit)

L2 local miss rate 0.7742  (72 to mem)

mem latency        9.26 cyc  (+3.26 over L2 hit)

AMAT = 3.00 + 0.0539 * (3.00 + 0.7742 * 3.26) = 3.30 cyc