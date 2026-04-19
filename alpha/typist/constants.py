from typist.dsl import Const, Bit, Logic

FOO = Const(100000, signed=True, width=64)
BAR = Const(0, signed=False)

A = Const(3, signed=False)
B = Const(A + 5)
C = Const((A << 2) | 1)
D = Const(-A)
E = Const(~A)

W = Const(13)
addr_t = Bit(W)
mask_t = Logic(8, signed=True)
flag_t = Bit(1)
big_data_t = Bit(67)
