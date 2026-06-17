# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    data_to_send = [0, 1, 0, 0, 1, 1, 0, 1] 
    # Set the clock period to 20 ns
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    current_value = dut.ui_in.value.integer
    dut._log.info("Test project behavior")
    # 4. Activate control signals
    dut.ui_in[0].value = 1  # valid_in = 1
    dut.ui_in[1].value = 1  # sop_in = 1 (Start of Packet on the first bit)
    
    # 5. Serial transmission loop
    for i in range(len(data_to_send)):
        # Assign the single bit to ui_in[3] (data_in) without touching the other pins
        dut.ui_in[3].value = data_to_send[i]
        
        # Wait for the clock edge so the chip samples the bit
        await RisingEdge(dut.clk)
        
        # Turn off sop_in after the very first bit
        if i == 0:
            dut.ui_in[1].value = 0 # sop_in = 0

     # 6. End of Packet signal
    dut.ui_in[2].value = 1  # eop_in = 1 (End of Packet)
    await RisingEdge(dut.clk)
    
    # Clean up signals
    dut.ui_in[0].value = 0  # valid_in = 0
    dut.ui_in[2].value = 0  # eop_in = 0
    dut.ui_in[3].value = 0  # data_in = 0
    
    # Wait some cycles to see the decoder output
    for _ in range(30):
        await RisingEdge(dut.clk)

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
