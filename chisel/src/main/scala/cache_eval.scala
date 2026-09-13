import chisel3._
import chisel3.simulator.EphemeralSimulator._

case class CacheConfig(numWays: Int, numSets: Int, blockSize: Int)

case class EvalResult(hits: Int, misses: Int, totalCycles: Int, numAccesses: Int) {
    def hitRate: Double = hits.toDouble / numAccesses
    def avgCyclesPerAccess: Double = totalCycles.toDouble / numAccesses
}

object CacheEval extends App {
    import reg_refills.State._
    val missLatencyCycles = 20

    def runTrace(config: CacheConfig, trace: Seq[(Long, Boolean)]): EvalResult = {
        var hits = 0
        var misses = 0
        var cycles = 0

        simulate(new Cache(config.numWays, config.numSets, config.blockSize)) { dut =>
            dut.io.w_enable.poke(0.U)
            dut.io.data_in.poke(0.U)
            dut.io.location.poke(0.U)
            dut.io.stalled_inputloc.poke(0.U)
            dut.io.stalled_input_wenable.poke(0.U)
            dut.io.replacement_incoming.poke(0.U)

            for ((addr, isWrite) <- trace) {
                dut.io.location.poke(addr.U)
                dut.io.w_enable.poke((if (isWrite) 1 else 0).U)
                dut.clock.step(1)
                cycles += 1

                if (dut.io.state.peekValue().asBigInt == sNot_Hit_Valid.litValue) {
                    misses += 1
                    for (_ <- 0 until missLatencyCycles) {
                        dut.clock.step(1)
                        cycles += 1
                    }

                    dut.io.replacement_incoming.poke(1.U)
                    dut.clock.step(1)
                    cycles += 1
                    dut.io.replacement_incoming.poke(0.U)

                    while (dut.io.state.peekValue().asBigInt != sSearch.litValue) {
                        dut.clock.step(1)
                        cycles += 1
                    }
                } else {
                    hits += 1
                    dut.clock.step(1)
                    cycles += 1
                }
            }
        }

        EvalResult(hits, misses, cycles, trace.size)
    }

    val traceGen = new Trace_Generator
    val trace = traceGen.generate_trace(numTraces = 2000, generationRange = 14)

    val configs = Seq(
        CacheConfig(numWays = 2, numSets = 8, blockSize = 512),
        CacheConfig(numWays = 4, numSets = 8, blockSize = 512),
        CacheConfig(numWays = 8, numSets = 8, blockSize = 512),
        CacheConfig(numWays = 4, numSets = 16, blockSize = 512),
        CacheConfig(numWays = 2, numSets = 16, blockSize = 512),

    )

    for (config <- configs) {
        val result = runTrace(config, trace)
        println(
            f"ways=${config.numWays}%2d sets=${config.numSets}%2d block=${config.blockSize}%4d  " +
            f"hits=${result.hits}%5d misses=${result.misses}%5d hitRate=${result.hitRate * 100}%5.2f%%  " +
            f"avgCyclesPerAccess=${result.avgCyclesPerAccess}%.2f"
        )
    }
}
