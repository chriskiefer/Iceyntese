#!/bin/bash

echo "Flash fpga"


if [ -z "$fpga" ]
then
      echo "\$fpga is empty"
      export fpga=0
else
      echo "FPGA:"
      echo $fpga
fi


iceprog -d i:0x0403:0x6010:$fpga build/uart.bin


if [ $fpga == 0 ]
then
  export fpga=1
else
  export fpga=0
fi
