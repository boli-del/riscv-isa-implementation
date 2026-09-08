import chisel3._
import chisel3.util._

//hard requirement block size must be multiple of 8 to at least support byte addressable indexing and accesses
object reg_refills{
    object State extends ChiselEnum{
        val sSearch, sHit_and_return, sNot_Hit_Valid, sWrite_return, sReplace, sComplete_Stalled = Value
    }
}

class Find_LRU(numWays: Int, numSets: Int, blockSize: Int) extends Module{
    val io = IO(new Bundle{
        val usefulness = Input(Vec(numSets, Vec(numWays, UInt(log2Ceil(numWays).W))))
        val input_sets = Input(UInt(log2Ceil(numSets).W))
        val max_usefulness = Output(UInt(log2Ceil(numWays).W))
    })
    // searches every way within the selected set for the one with the highest
    // usefulness value (i.e. the least-recently-used entry), returning its index
    val waysInSet = io.usefulness(io.input_sets)
    val indexed = waysInSet.zipWithIndex.map { case (u, i) => (u, i.U(log2Ceil(numWays).W)) }
    val lruPair = indexed.reduce { (a, b) =>
        (Mux(a._1 >= b._1, a._1, b._1), Mux(a._1 >= b._1, a._2, b._2))
    }
    io.max_usefulness := lruPair._2
}

class Update_Usefulness(numWays: Int, numSets: Int, blockSize: Int) extends Module{
    val io = IO(new Bundle{
        val usefulness = Input(Vec(numSets, Vec(numWays, UInt(log2Ceil(numWays).W))))
        val input_sets = Input(UInt(log2Ceil(numSets).W))
        val input_recently_updated = Input(UInt(log2Ceil(numWays).W))
        val updated_usefulness_arr = Output(Vec(numWays, UInt(log2Ceil(numWays).W)))
    })
    // ages every way in the set whose usefulness is behind the promoted way's,
    // and resets the promoted way itself to 0 (most-recently-used)
    val waysInSet = io.usefulness(io.input_sets)
    val promotedUsefulness = waysInSet(io.input_recently_updated)
    for (i <- 0 until numWays) {
        when(i.U === io.input_recently_updated) {
            io.updated_usefulness_arr(i) := 0.U
        }.elsewhen(waysInSet(i) < promotedUsefulness) {
            io.updated_usefulness_arr(i) := waysInSet(i) + 1.U
        }.otherwise {
            io.updated_usefulness_arr(i) := waysInSet(i)
        }
    }
}

class Cache(numWays: Int, numSets: Int, blockSize: Int) extends Module{
    import reg_refills.State
    import reg_refills.State._
    val io = IO(new Bundle{
        val w_enable = Input(UInt(1.W))
        val data_in = Input(UInt(512.W))
        val location = Input(UInt(32.W))
        val stalled_inputloc = Input(UInt(32.W))
        val stalled_input_wenable = Input(UInt(1.W))
        val replacement_incoming = Input(UInt(1.W))
        val state = Output(State())
        val dirty_out = Output(UInt(512.W))
        val data_out = Output(UInt(32.W))
        val needs_replacement = Output(UInt(1.W))
        val stalled_location = Output(UInt(32.W))
        val stalled_wenable = Input(UInt(1.W))
        val stalled = Output(UInt(1.W))
    })

    //necessary predefinitions for lengths and tags and preliminaries that will be needed
    val offset_bits = log2Ceil(blockSize/8)
    val offset = io.location(offset_bits-1, 0)
    val indexbits = log2Ceil(numSets)
    val tagWidth = 32 - indexbits - offset_bits
    val usefulness = Reg(Vec(numSets, Vec(numWays, UInt(log2Ceil(numWays).W))))
    val infoArray = Reg(Vec(numSets, Vec(numWays, UInt(blockSize.W))))
    val tagArray   = Reg(Vec(numSets, Vec(numWays, UInt(tagWidth.W))))
    val validBits  = RegInit(VecInit(Seq.fill(numSets)(VecInit(Seq.fill(numWays)(false.B)))))
    val dirtyBits  = RegInit(VecInit(Seq.fill(numSets)(VecInit(Seq.fill(numWays)(false.B)))))
    val tag = io.location(31, offset_bits+indexbits)
    val index = io.location(offset_bits+indexbits-1, offset_bits)
    val replacement_indicator = RegInit(0.U(1.W))
    val ways_in_set = tagArray(index)
    val hit_per_way = VecInit(ways_in_set.map(_ === tag))
    val hit_found = hit_per_way.reduce(_ || _)
    val hit = OHToUInt(hit_per_way)

    //register definition
    val state = RegInit(sSearch)
    val dataout = RegInit(0.U(32.W))
    val stalledLocationReg = RegInit(0.U(32.W))
    val stalledReg = RegInit(0.U(1.W))

    io.state := state
    io.stalled_location := stalledLocationReg
    io.stalled := stalledReg
    io.data_out := dataout
    io.dirty_out := 0.U
    io.needs_replacement := 0.U

    switch (state){
        is(sSearch){
            when(hit_found && validBits(index)(hit) === true.B){
                when(io.w_enable === 1.U){
                    state := sWrite_return
                }.otherwise{
                    state := sHit_and_return
                    replacement_indicator := 0.U
                }
            }.otherwise{
                state := sNot_Hit_Valid
                replacement_indicator := 1.U
            }
        }
        is(sHit_and_return){
            val wordsInLine = infoArray(index)(hit).asTypeOf(Vec(blockSize/32, UInt(32.W)))
            dataout := wordsInLine(offset(offset_bits-1, 2))
            replacement_indicator := 0.U
            state := sSearch
        }
        is(sWrite_return){
            tagArray(index)(hit) := tag
            validBits(index)(hit) := true.B
            dirtyBits(index)(hit) := true.B
            infoArray(index)(hit) := io.data_in
            state := sSearch
        }
        is(sNot_Hit_Valid){
            replacement_indicator := 1.U
            stalledLocationReg := io.location
            stalledReg := 1.U
            when(io.replacement_incoming === 1.U){
                replacement_indicator := 0.U
                state := sReplace
            }
        }
        is(sReplace){
            //indicates the tag matched but the entry was invalid (not a true miss)
            when(hit_found){
                tagArray(index)(hit) := tag
                validBits(index)(hit) := true.B
                usefulness(index)(hit) := 0.U
                state := sComplete_Stalled
            }.otherwise{
                val findLru = Module(new Find_LRU(numWays, numSets, blockSize))
                findLru.io.usefulness := usefulness
                findLru.io.input_sets := index
                val replaceWay = findLru.io.max_usefulness

                val updateUsefulness = Module(new Update_Usefulness(numWays, numSets, blockSize))
                updateUsefulness.io.usefulness := usefulness
                updateUsefulness.io.input_sets := index
                updateUsefulness.io.input_recently_updated := replaceWay
                usefulness(index) := updateUsefulness.io.updated_usefulness_arr

                tagArray(index)(replaceWay) := tag
                validBits(index)(replaceWay) := true.B
                state := sComplete_Stalled
            }
        }
        is(sComplete_Stalled){
            stalledReg := 0.U
            state := sSearch
        }
    }
}
