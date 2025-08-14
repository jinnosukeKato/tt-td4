import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
  dut._log.info("Start")

  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())

  # Reset
  dut._log.info("Reset")
  dut.ena.value = 1
  dut.ui_in.value = 0
  dut.uio_in.value = 0
  dut.rst_n.value = 0
  await ClockCycles(dut.clk, 1)
  dut.rst_n.value = 1
  await ClockCycles(dut.clk, 1)

  dut._log.info("Test project behavior")

  # Test
  # メモリへの値の書き込みと読み込み
  dut._log.info("Write value(0101 0000) to mem addr: 0000")
  dut.ui_in.value = 0b1000_0000
  dut.uio_in.value = 0b0000_0101
  await ClockCycles(dut.clk, 1)
  dut._log.info("Read value from mem addr: 0000")
  dut.ui_in.value = 0b1100_0000
  await ClockCycles(dut.clk, 1)

  dut.ui_in.value = 0b0000_0000
  await ClockCycles(dut.clk, 1)
  assert dut.uo_out.value == 0b0101_0000

  dut._log.info("Test finished")

