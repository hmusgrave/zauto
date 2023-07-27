const std = @import("std");
const testing = std.testing;

// ought to work for scalars/vectors seamlessly
//
// need some sort of comptime graph
//
// inline everything so that the compiler has a chance to
// do something reasonable with small computations -- big compute
// be damned
