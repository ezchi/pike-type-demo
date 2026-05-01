from piketype.dsl import Struct

from alpha.piketype.foo import byte_t

bar_t = (
    Struct()
    .add_member("field1", byte_t)
    .add_member("field2", byte_t)
)
