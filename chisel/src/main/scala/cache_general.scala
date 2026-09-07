import chisel3._
import chisel3.util._

//hard requirement block size must be multiple of 8 to at least support byte addressable indexing and accesses

class Cache(int num_ways, int num_sets, int block_size) extends Module{
    val io = IO(new Bundle{
        val clk = Input(Clock())
        val rst_n = Input(UInt(1.W))
        val w_enable = Input(UInt(1.W))
        val data_in = Input(UInt(512.W))
        val location = Input(UInt(32.W))
        val replacement_finished = Input(UInt(1.W))
        val next_state = Input(UInt(2.W))
        val state_out = Output(UInt(2.W))
        val dirty_out = Output(UInt(512.W))
        val data_out = Output(UInt(32.W))
        val needs_replacement = Output(UInt(1.W))
        val replacement_finished = Output(Uint(1.W))
    })
    val offset_bits = log2Ceil(block_size/8)
    val offset = io.location(offset_bits-1, 0)
    val indexbits = log2Ceil(num_sets)
    val tagWidth = 32 - indexbits - offset_bits
    val infoArray = Reg(Vec(num_sets, Vec(ways, UInt(block_size.W))))
    val tagArray   = Reg(Vec(numSets, Vec(ways, UInt(tagWidth.W))))
    val validBits  = RegInit(VecInit(Seq.fill(numSets)(VecInit(Seq.fill(ways)(false.B)))))
    val dirtyBits  = RegInit(VecInit(Seq.fill(numSets)(VecInit(Seq.fill(ways)(false.B)))))
    val state_register = RegInit(0.U(2.W))
    val states = RegInit(0.U(2.W))
    val tag = io.location(31, offset_bits+indexbits)
    val index = io.location(offset_bits+indexbits-1, offset_bits)
    val replacement_indicator = RegInit(0.U(1.W))
    val ways_in_set = tagArray(indexbits)
    val hit_in_tag = Vecinit(ways_in_set(_===tag))
    val hit_in_way = hit_in_tag.reduce(_ || _)
    val hit = OHToUInt(hit_in_way)
    val dataout = RegInit(0.U(32.W))
    switch (io.next_state){
        is("b00".U){
            when(tagArray(indexbits)(hit) === tag && validBits(indexbits)(hit) === 1){
                state_out := 1.U
                replacement_indicator := 0.U
            }Otherwise{
                state_out := 2.U
                replacement_indicator := 1.U
            }
        }
        is("b01".U){
            when(w_enable === 1.U){
                tagArray(index)(hit) := tag
                validBits(index)(hit) := 1.U
                dirtyBits(index)(hit) := 1.U
                infoArray(index)(hit) := io.data_in
            }
            state_register := 0.U
            dataout := infoArray(index)(hit)(offset >> )
            
        }
    }
}
