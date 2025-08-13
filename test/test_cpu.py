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
  await ClockCycles(dut.clk, 10)
  dut.rst_n.value = 1

  dut._log.info("Test project behavior")

  # Test
  # ADD A, Im (Op:0000, Im:1010)
  dut.ui_in.value = 0b0101_0000 
  await ClockCycles(dut.clk, 2)
  assert dut.uo_out.value == 0b0000_0101

  # TODO!!! 1サイクルで計算が回り切っていない
  # ADD B, Im (Op:0101, Im:1010)
  dut.ui_in.value = 0b0101_1010
  await ClockCycles(dut.clk, 2)
  assert dut.uo_out.value == 0b0101_1010
