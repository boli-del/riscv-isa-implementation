import chisel3._
import chisel3.util._

class I_cache(initiate_l2: Boolean, initiate_l3: Boolean) extends Module{
    val io = IO(new Bundle{
        val destination = Input(UInt(32.W))
        val instr_code = Output(UInt(32.W))
    })
    val base_instruction_cache = RegInit(Vec(""))
    val stalled_reg_input = RegInit(0.U(32.W))
    val stalled_reg_enable = RegInit(0.U(1.W))
    val completed = RegInit(0.U(32.W))
    val dirty_l1 = RegInit(0.U(1.W))
    val l1_cache = Module(new Cache(8, 4, 512))
    val l2_cache: Option[Cache] = if(initiate_l2) Some(Module(new Cache(16, 4, 512))) else None
    val l3_cache: Option[Cache] = if(initiate_l3) Some(Module(new Cache(32, 4, 512))) else None
    l1_cache.io.w_enable := 0.U
    l1_cache.location := io.destination
    l1_cache.io.stalled_inputloc := stalled_reg_input
    l1_cache.io.stalled_input_w_enable = stalled_reg_engable
    stalled_reg_input := l1_cache.io.stalled_location
    stalled_reg_input := l1_cache.io.stalled_wenable
    when (l1_cache.io.completed){
        instr_code := l1_cache.io.data_out
    }
    case (Some(l2_cache)){
        when(dirty_l1){
            l1_cache.io.replacement_incoming := 1.U
            l2_cache.io.w_enable := 0.U
            l2_cache.io.location := io.destination
            l2_cache.io.
        }
    }
}

class Base_I_Cache extends Module{
    val io = IO(new Bundle{
        val lookup_i
    })
}