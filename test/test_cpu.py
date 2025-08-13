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
  await ClockCycles(dut.clk, 1)

  dut._log.info("Test project behavior")

  # Test
  # ADD A, Im (Op:0000, Im:1010)
  dut._log.info("add A, Im")
  dut.ui_in.value = 0b0101_0000
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_0000
  await ClockCycles(dut.clk, 1) # NOPで出力が立ち上がるのを待ってからassert
  assert dut.uo_out.value == 0b0000_0101

  # ADD B, Im (Op:0101, Im:1010)
  dut._log.info("add B, Im")
  dut.ui_in.value = 0b0101_1010
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_0000
  await ClockCycles(dut.clk, 1) # NOPで出力が立ち上がるのを待ってからassert
  assert dut.uo_out.value == 0b0101_0101

  # Reset
  dut._log.info("Reset")
  dut.ena.value = 1
  dut.ui_in.value = 0
  dut.uio_in.value = 0
  dut.rst_n.value = 0
  await ClockCycles(dut.clk, 1)
  dut.rst_n.value = 1
  await ClockCycles(dut.clk, 1)

  # MOV A, Im (Op: 0011, Im: 1111)
  dut._log.info("mov A, Im")
  dut.ui_in.value = 0b1111_1100
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_0000
  await ClockCycles(dut.clk, 1)
  assert dut.uo_out.value == 0b0000_1111

  # MOV B, Im (Op: 0111, Im: 1001)
  dut._log.info("mov B, Im")
  dut.ui_in.value = 0b1001_1110
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_0000
  await ClockCycles(dut.clk, 1)
  assert dut.uo_out.value == 0b1001_1111

  # MOV A, B (Op: 0001, Im: any)
  dut._log.info("mov A, B")
  dut.ui_in.value = 0b0000_1000
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_0000
  await ClockCycles(dut.clk, 1)
  assert dut.uo_out.value == 0b1001_1001

  # MOV A, Im (Op: 0011, Im: 0000)
  dut._log.info("mov A, Im")
  dut.ui_in.value = 0b0000_1100
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_0000
  await ClockCycles(dut.clk, 1)
  assert dut.uo_out.value == 0b1001_0000

  # MOV B, A (Op: 0100, Im: any)
  dut._log.info("mov B, A")
  dut.ui_in.value = 0b0000_0010
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_0000
  await ClockCycles(dut.clk, 1)
  assert dut.uo_out.value == 0b0000_0000

  dut._log.info("Test finished")

