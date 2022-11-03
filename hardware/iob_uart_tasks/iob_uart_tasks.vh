//
// TASKS TO CONTROL THE TESTBENCH UART
//

`include "iob_uart_swreg_def.vh"

task uart_init;
   begin
      // pulse reset uart
      iob_write(`UART_SOFTRESET_ADDR, 1, `UART_SOFTRESET_W);
      iob_write(`UART_SOFTRESET_ADDR, 0, `UART_SOFTRESET_W);

      // config uart div factor
      iob_write(`UART_DIV_ADDR, `FREQ/`BAUD, `UART_DIV_W);

      // enable uart for receiving
      iob_write(`UART_RXEN_ADDR, 1, `UART_RXEN_W);
      iob_write(`UART_TXEN_ADDR, 1, `UART_TXEN_W);
   end
endtask
