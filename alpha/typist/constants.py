from typist.dsl import Const, Bit, Logic, Struct

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

header_t = (
    Struct()
    .add_member("addr", addr_t)
    .add_member("enable", flag_t)
    .add_member("data", big_data_t)
)

packet_t = (
    Struct()
    .add_member("header", header_t)
    .add_member("mode", Logic(2))
    .add_member("error_code", Bit(3))
    .add_member("data1", Logic(32))
    .add_member("data2", Logic(32))
)
