import chisel3._
import chisel3.util._
import java.util.ResourceBundle
import java.util.ResourceBundle
import java.util.ResourceBundle

//hard requirement block size must be multiple of 8 to at least support byte addressable indexing and accesses
Object reg_refills{
    Object State extends ChiselEnum{
        val sSearch, sHit_and_return, sNot_Hit_Valid, sWrite_return, sReplace, sComplete_Stalled
    }
}

class Find_LRU(int num_ways, int num_sets, int block_size) extends Module{
    val io = IO(new Bundle{
        val usefulness = Input(Vec(num_sets, Vec(num_ways, Vec(log2Ceil(block_size/8), UInt(log2Ceil(block_size/8).W)))))
        val input_sets = Input(UInt(log2Ceil(num_sets).W))
        val input_ways = Input(UInt(log2Ceil(num_ways).W))
        val max_usefulness = Output(UInt(log2Ceil(block_size).W))
    })
    val curr_largest = UInt(0.U, log2Ceil(block_size/8).W)
    val curr_largest_idx = UInt(0.U, log2Ceil(block_size/8).W)
    for(i <- 0 until block_size){
        when(usefulness(input_sets)(input_ways)(i) > curr_largest){
            curr_largest := usefulness(input_sets)(input_ways)(i)
            curr_largest_idx := i.U
        }
    }
    max_usefulness := curr_largest_idx
}

class Update_Usefulness(int num_ways, int num_sets, int block_size) extends Module{
    val io = IO(new Bundle{
        val usefulness = Input(Vec(num_sets, Vec(num_ways, Vec(log2Ceil(block_size/8), UInt(log2Ceil(block_size/8).W)))))
        val input_sets = Input(UInt(log2Ceil(num_sets).W))
        val input_ways = Input(UInt(log2Ceil(num_ways).W))
        val input_recently_updated = Input(UInt(log2Ceil(block_size/8).W))
        val updated_usefulness_arr = Output(Vec(num_sets, Vec(num_ways, Vec(log2Ceil(block_size/8), UInt(log2Ceil(block_size/8).W)))))
    })
    val curr_largest = UInt(0.U, log2Ceil(block_size/8).W)
    val curr_largest_idx = UInt(0.U, log2Ceil(block_size/8).W)
    for(i <- 0 until block_size){
        when(i.U != input_recently_updated){
            updated_usefulness_arr(input_sets)(input_ways)(i) := usefulness(input_sets)(input_ways)(i)
        }
    }
}

class Cache(int num_ways, int num_sets, int block_size) extends Module{
    import reg_refills.State
    import reg_refills.State._
    import Find_LRU
    import Update_Usefulness
    val io = IO(new Bundle{
        val clk = Input(Clock())
        val rst_n = Input(UInt(1.W))
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
        val stalled_location = Input(UInt(32.W))
        val stalled_wenable = Input(UInt(1.W))
        val stalled = Input(UInt(1.W))
    })

    //necessary predefinitions for lengths and tags and preliminaries that will be needed
    val offset_bits = log2Ceil(block_size/8)
    val offset = io.location(offset_bits-1, 0)
    val indexbits = log2Ceil(num_sets)
    val tagWidth = 32 - indexbits - offset_bits
    val usefulness = Reg(Vec(num_sets, Vec(num_ways, Vec(offset_bits, UInt(offset_bits.W)))))
    val infoArray = Reg(Vec(num_sets, Vec(num_ways, UInt(block_size.W))))
    val tagArray   = Reg(Vec(numSets, Vec(num_ways, UInt(tagWidth.W))))
    val validBits  = RegInit(VecInit(Seq.fill(numSets)(VecInit(Seq.fill(ways)(false.B)))))
    val dirtyBits  = RegInit(VecInit(Seq.fill(numSets)(VecInit(Seq.fill(ways)(false.B)))))
    val tag = io.location(31, offset_bits+indexbits)
    val index = io.location(offset_bits+indexbits-1, offset_bits)
    val replacement_indicator = RegInit(0.U(1.W))
    val ways_in_set = tagArray(indexbits)
    val hit_in_tag = Vecinit(ways_in_set(_===tag))
    val hit_in_way = hit_in_tag.reduce(_ || _)
    val hit = OHToUInt(hit_in_way)

    //register definition
    val state = RegInit(sSearch)
    val dataout = RegInit(0.U(32.W))

    io.state := state

    switch (state){
        is(sSearch){
            when(tagArray(indexbits)(hit) === tag && validBits(indexbits)(hit) === 1){
                when(w_enable){
                    state:= sWrite_return
                }Otherwise{
                    state := sHit_and_return
                    replacement_indicator := 0.U
                }
            }Otherwise{
                state := sNot_Hit_Valid
                replacement_indicator := 1.U
            }
        }
        is(sHit_and_return){
            state_register := 0.U
            dataout := infoArray(index)(hit)(((offset + 1) << 3), (offset << 3))
            replacement_indicator := 0.U
            state := sSearch
        }
        is(sNot_Hit_Valid){
            replacement_indicator := 1.U
            stalled_location := location
            stalled := 1.U
            when(replacement_incoming){
                replacement_indicator := 0.U
                state := sReplace
            }
        }
        is(sReplace){
            //indicates it was an invalid problem:
            when(tagArray(indexbits)(hit) === tag){
                tagArray(indexbits)(hit) := data_in
                validBits(indexbits)(hit) := 1.U
                usefulness(indexbits)(hit) := 0.U
                state := sComplete_Stalled
            }OtherWise{
                
            }
        }
    }
}