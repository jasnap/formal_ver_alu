# formal_ver_alu
Formal verification of an ALU

The ALU should be able to do the following:
1. Add two 8-bit numbers
2. Add two 16-bit numbers
3. Do two adding of two 8-bit numbers
4. Subtract two 8-bit numbers
5. Subtract two 16-bit numbers
6. Do two subtractions of two 8-bit numbers
7. Multiply two 8-bit numbers

The bigger part of the datapath should be used for every of the required operations/
Using + and - for numbers wider than 8 bits is not allowed. The ALU should use the
AXI Stream protocol. The first thing that is being sent should be the operation, and
after it the numbers. The result should be sent using another AXI Stream outside of 
the model.
	
