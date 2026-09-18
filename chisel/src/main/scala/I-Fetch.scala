import chisel3._
import chisel3.util._

//configurable levels
class I_cache(initiate_l2: Boolean, initiate_l3: Boolean, I_cache_ways: Int, I_cache_sets: Int, Icache_blocks: Int) extends Module{
    val io = IO(new Bundle{
        val destination = Input(UInt(32.W))
        val instr_code = Output(UInt(32.W))
    })

    val base_instruction_cache = RegInit(Vec(""))
    val stalled_reg_input = RegInit(0.U(32.W))
    val stalled_reg_enable = RegInit(0.U(1.W))
    val completed = RegInit(0.U(32.W))
    val needs_replace_l1 = RegInit(0.U(1.W))
    val replacement_income_l1 = RegInit(0.U(1.W))

    val l1_cache = Module(new Cache(I_cache_ways, I_cache_sets, I_cache_blocks))
    val l2_cache: Option[Cache] = if(initiate_l2) Some(Module(new Cache(16, 4, 512))) else None
    val l3_cache: Option[Cache] = if(initiate_l3) Some(Module(new Cache(32, 4, 512))) else None

    l1_cache.io.w_enable := 0.U
    l1_cache.location := io.destination
    l1_cache.io.stalled_inputloc := stalled_reg_input
    l1_cache.io.stalled_input_w_enable = stalled_reg_engable
    stalled_reg_input := l1_cache.io.stalled_location
    stalled_reg_input := l1_cache.io.stalled_wenable
    needs_replace_l1 := l1_cache.io.needs_replacement

    when (l1_cache.io.completed){
        instr_code := l1_cache.io.data_out
    }

    l2_cache match {
        case (Some(l2_cache)){
            val stalled_l2_reg_input = RegInit(0.U(32.W))
            val stalled_l2_enable = RegInit(0.U(1.W))
            val needs_replace_l2 = RegInit(0.U(1.W))
            val completed_l2 = RegInit(0.U(1.W))
            when(needs_replace_l1){
                replacement_income_l1 := 0.U
                l1_cache.io.replacement_incoming := 1.U
                l2_cache.io.w_enable := 0.U
                l2_cache.io.location := io.destination
                l2_cache.io.stalled_inputloc := stalled_l2_reg_input
                l2_cache.io.stalled_input_wenable := stalled_l2_enable
                
                stalled_l2_reg_input := l2_cache.io.stalled_location
                stalled_l2_enable := l2_cache.io.stalled_wenable
                needs_replace_l2 := l2_cache.io.needs_replacement
                completed_l2 := l2_cache.io.completed

                replacement_income_l1 := completed_l2
            }
        }
    }
}

class Base_I_Cache(I_base_blocks: Int) extends Module{
    val io = IO(new Bundle{
        val lookup_id = Input(UInt(32.W))
        val val_ret = Output(UInt(1.W))
        val returned = Output(UInt(log2Ceil(I_base_blocks).W))
    })
    val offset_bits = log2Ceil(I_base_blocks/8)
    val tag = lookup_id(31, offset_bits)
    val offset = io.lookup_id(offset_bits-1, 0)
    val instr_cache = RegInit(Vec("0hffffffff" >> log2Ceil(I_base_blocks/8), UInt(I_base_blocks.W)))
    returned := instr_cache[tag]
    val_ret := 1.U
}