import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("***********_____STARTING COCOTB SIMULATION_____***********")
    
    # ------------------------------------------------------------------------
    # 1. Configuración del Reloj
    # ------------------------------------------------------------------------
    CLK_PRD = 20  # Período del reloj de 20ns configurado en tu inicio
    clock = Clock(dut.clk, CLK_PRD, unit="ns")
    cocotb.start_soon(clock.start())

    # ------------------------------------------------------------------------
    # 2. Inicialización de Señales (Primer bloque initial de Verilog)
    # ------------------------------------------------------------------------
    dut.rst_n.value = 0
    dut.i_sel_mux_0.value = 0
    dut.i_sel_mux_1.value = 0
    dut.i_n_inv.value = 0
    dut.i_enable.value = 0
    dut.i_tx_ready.value = 0
    dut.i_op_mode.value = 0

    # Espera inicial: 4 ciclos completos + desfase de 0.8 del período
    await ClockCycles(dut.clk, 4)
    await Timer(int(0.8 * CLK_PRD), units="ns")
    dut.rst_n.value = 1

    # ------------------------------------------------------------------------
    # 3. Flujo Secuencial de Estímulos (Segundo bloque initial de Verilog)
    # ------------------------------------------------------------------------
    
    # --- Bloque de Prueba 1 ---
    await ClockCycles(dut.clk, 6)
    await Timer(int(0.8 * CLK_PRD), units="ns")
    dut.i_sel_mux_0.value = 0
    dut.i_sel_mux_1.value = 1
    dut.i_n_inv.value = 0

    await ClockCycles(dut.clk, 4)
    dut.i_enable.value = 1
    
    await ClockCycles(dut.clk, 4)
    dut.i_tx_ready.value = 1
    
    await ClockCycles(dut.clk, 200)
    
    # --- Bloque de Prueba 2 (Reset y Cambio de Desafío) ---
    dut.rst_n.value = 0
    dut.i_enable.value = 0
    
    await ClockCycles(dut.clk, 4)
    dut.rst_n.value = 1
    dut.i_sel_mux_0.value = 0
    dut.i_sel_mux_1.value = 2
    dut.i_n_inv.value = 4
    
    await ClockCycles(dut.clk, 4)
    dut.i_enable.value = 1
    
    await ClockCycles(dut.clk, 200)
    
    # --- Bloque de Prueba 3 ---
    dut.rst_n.value = 0
    dut.i_enable.value = 0
    
    await ClockCycles(dut.clk, 4)
    dut.rst_n.value = 1
    dut.i_sel_mux_0.value = 3
    dut.i_sel_mux_1.value = 2
    dut.i_n_inv.value = 0
    
    await ClockCycles(dut.clk, 4)
    dut.i_enable.value = 1
    
    await ClockCycles(dut.clk, 200)
    
    # --- Bloque de Prueba 4 (Inyección de op_mode) ---
    dut.rst_n.value = 0
    dut.i_enable.value = 0
    
    await ClockCycles(dut.clk, 4)
    dut.rst_n.value = 1
    dut.i_sel_mux_0.value = 3
    dut.i_sel_mux_1.value = 2
    dut.i_n_inv.value = 0
    
    await ClockCycles(dut.clk, 4)
    dut.i_enable.value = 1
    
    await ClockCycles(dut.clk, 20)
    dut.i_op_mode.value = 1
    
    await ClockCycles(dut.clk, 20)
    
    dut._log.info("***********_____SIMULATION COMPLETED_____***********")
