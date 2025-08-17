import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

async def do_reset(dut, hold_cycles: int = 1, after_cycles: int = 1):
  dut.ena.value = 1
  dut.ui_in.value = 0
  dut.uio_in.value = 0
  dut.rst_n.value = 0
  await ClockCycles(dut.clk, hold_cycles)
  dut.rst_n.value = 1
  await ClockCycles(dut.clk, after_cycles)

@cocotb.test()
async def test_write_and_read_memory(dut):
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())
  await do_reset(dut)

  dut._log.info("write to memory address: 0b0000")
  dut.ui_in.value = 0b0000_0000 # ADD A, Im
  dut.uio_in.value = 0b0000_1011 # Im: 1101 (MSL, LSB逆)
  await ClockCycles(dut.clk, 1)

  dut._log.info("write to memory address: 0b0001")
  dut.ui_in.value = 0b0000_1010 # ADD B, Im
  dut.uio_in.value = 0b0001_0011 # Im: 1100 (MSL, LSB逆)
  await ClockCycles(dut.clk, 1)

  dut._log.info("read from memory address: 0b0000")
  dut.ui_in.value = 0b0100_0000 # set to read mode
  dut.uio_in.value = 0b0000_0000 # read from address 0b0000
  await ClockCycles(dut.clk, 1)
  assert dut.uo_out.value == 0b1011_0000 # ADD A, 1101

  dut._log.info("read from memory address: 0b0000")
  dut.ui_in.value = 0b0100_0000 # set to read mode
  dut.uio_in.value = 0b0001_0000 # read from address 0b0001
  await ClockCycles(dut.clk, 1)

  assert dut.uo_out.value == 0b0011_1010 # ADD B, 1100

@cocotb.test()
async def test_add_reg_im(dut):
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())
  await do_reset(dut)

  # メモリへの値の書き込み
  dut.ui_in.value = 0b0000_0000 # ADD A, Im
  dut.uio_in.value = 0b0000_1011 # Im: 1101 (MSL, LSB逆)
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_1010 # ADD B, Im
  dut.uio_in.value = 0b0001_0011 # Im: 1100 (MSL, LSB逆)
  await ClockCycles(dut.clk, 1)

  # 実行
  dut.ui_in.value = 0b1000_0000 # 実行モードに設定
  await ClockCycles(dut.clk, 3)
  assert dut.uo_out.value == 0b_0011_1011 # reg aに1011が入っているはず

@cocotb.test()
async def test_mov_reg_im(dut):
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())
  await do_reset(dut)

  # メモリへの値の書き込み
  dut.ui_in.value = 0b0000_1100 # MOV A, Im
  dut.uio_in.value = 0b0000_1011 # Im: 1101 (MSB, LSB逆)
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_1110 # MOV B, Im
  dut.uio_in.value = 0b0001_0011 # Im: 1100 (MSB, LSB逆)
  await ClockCycles(dut.clk, 1)

  dut.ui_in.value = 0b1000_0000 # 実行モードに設定
  await ClockCycles(dut.clk, 3)
  assert dut.uo_out.value == 0b_0011_1011 # reg aに1011が入っているはず

@cocotb.test()
async def test_mov_A_B(dut):
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())
  await do_reset(dut)

  # メモリへの値の書き込み
  dut.ui_in.value = 0b0000_1110 # MOV B, Im
  dut.uio_in.value = 0b0000_0011 # Im: 1100 (MSB, LSB逆)
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_1000 # MOV A, B
  dut.uio_in.value = 0b0001_0000
  await ClockCycles(dut.clk, 1)

  dut.ui_in.value = 0b1000_0000 # 実行モードに設定
  await ClockCycles(dut.clk, 3)
  assert dut.uo_out.value == 0b_0011_0011

@cocotb.test()
async def test_mov_B_A(dut):
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())
  await do_reset(dut)

  # メモリへの値の書き込み
  dut.ui_in.value = 0b0000_1100 # MOV A, Im
  dut.uio_in.value = 0b0000_1011 # Im: 1101 (MSB, LSB逆)
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_0010 # MOV B, A
  dut.uio_in.value = 0b0001_0000
  await ClockCycles(dut.clk, 1)

  dut.ui_in.value = 0b1000_0000 # 実行モードに設定
  await ClockCycles(dut.clk, 3)
  assert dut.uo_out.value == 0b_1011_1011


@cocotb.test()
async def test_jmp_im(dut):
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())
  await do_reset(dut)

  # メモリへの値の書き込み
  dut.ui_in.value = 0b0000_1111 # JMP Im
  dut.uio_in.value = 0b0000_0011 # Im: 3 → pcを3に進める
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_1100 # MOV A, Im
  dut.uio_in.value = 0b0011_1011 # Im: 1101 Addr: 3
  await ClockCycles(dut.clk, 1)

  dut.ui_in.value = 0b1000_0000 # 実行モードに設定
  await ClockCycles(dut.clk, 3)
  assert dut.uo_out.value == 0b_0000_1011

@cocotb.test()
async def test_jnc_im(dut):
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())
  await do_reset(dut)

  # メモリへの値の書き込み
  dut.ui_in.value = 0b0000_1100 # MOV A, Im
  dut.uio_in.value = 0b0000_1111 # Im: 1111
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_0000 # ADD A, Im
  dut.uio_in.value = 0b0001_0001 # Im: 0001 → オーバーフロー
  await ClockCycles(dut.clk, 1)

  dut.ui_in.value = 0b0000_1111 # JNC Im
  dut.uio_in.value = 0b0010_1000 # Im: 8
  await ClockCycles(dut.clk, 1)

  dut.ui_in.value = 0b0000_1010 # ADD B, Im
  dut.uio_in.value = 0b1000_1001 # Addr: 8, Im: 1001 
  await ClockCycles(dut.clk, 1)

  dut.ui_in.value = 0b1000_0000 # 実行モードに設定
  await ClockCycles(dut.clk, 5)
  assert dut.uo_out.value == 0b_1001_0000

@cocotb.test()
async def test_in_reg(dut):
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())
  await do_reset(dut)

  # メモリへの値の書き込み
  dut.ui_in.value = 0b0000_0100 # IN A
  dut.uio_in.value = 0b0000_0000
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_0110 # IN B
  dut.uio_in.value = 0b0001_0000
  await ClockCycles(dut.clk, 1)

  dut.ui_in.value = 0b1000_0011 # 実行モード Input: 0011
  await ClockCycles(dut.clk, 1)

  dut.ui_in.value = 0b1000_0101 # 実行モード Input: 0101
  await ClockCycles(dut.clk, 1)
  assert dut.uo_out.value == 0b0000_0011

  await ClockCycles(dut.clk, 1)
  assert dut.uo_out.value == 0b0101_0011

@cocotb.test()
async def test_out_b(dut):
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())
  await do_reset(dut)

  # メモリへの値の書き込み
  dut.ui_in.value = 0b0000_1110 # MOV B, Im
  dut.uio_in.value = 0b0000_0011 # Im: 0011
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0b0000_1001 # OUT B
  dut.uio_in.value = 0b0001_0000
  await ClockCycles(dut.clk, 1)
  
  dut.ui_in.value = 0b1000_0000 # 実行モード
  await ClockCycles(dut.clk, 3)
  assert dut.uio_out.value == 0b0000_0011

@cocotb.test()
async def test_out_im(dut):
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())
  await do_reset(dut)

  # メモリへの値の書き込み
  dut.ui_in.value = 0b0000_1101 # OUT Im
  dut.uio_in.value = 0b0000_1100 # Im: 1100
  await ClockCycles(dut.clk, 1)

  # 実行モード
  dut.ui_in.value = 0b1000_0000
  await ClockCycles(dut.clk, 2)
  assert dut.uio_out.value == 0b0000_1100



