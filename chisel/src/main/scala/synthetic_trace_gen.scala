import scala.util.Random

class Trace_Generator {
    def generate_trace(numTraces: Int, generationRange: Int): Seq[(Long, Boolean)] = {
        val rand = new Random()
        val mask = (1L << generationRange) - 1
        Seq.fill(numTraces) {
            val addr = rand.nextLong() & mask
            val isWrite = rand.nextBoolean()
            (addr, isWrite)
        }
    }
}
