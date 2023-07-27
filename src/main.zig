const std = @import("std");
const testing = std.testing;

// ought to work for scalars/vectors seamlessly
//
// need some sort of comptime graph
//
// inline everything so that the compiler has a chance to
// do something reasonable with small computations -- big compute
// be damned

pub fn Dual(comptime F: type) type {
    return struct {
        x: F,
        grad: F,

        pub const splat = switch (@typeInfo(F)) {
            .Float => struct {
                pub inline fn _f(z: F) F {
                    return z;
                }
            }._f,
            .Vector => |vec| struct {
                pub inline fn _f(z: vec.child) F {
                    return @splat(vec.len, z);
                }
            }._f,
            else => @compileError("oops: better err: todo"),
        };

        pub inline fn init_with_const(x: F) @This() {
            return .{ .x = x, .grad = splat(0.0) };
        }

        pub inline fn init_with_var(x: F) @This() {
            return .{ .x = x, .grad = splat(1.0) };
        }

        pub inline fn add(self: @This(), other: @This()) @This() {
            return .{ .x = self.x + other.x, .grad = self.grad + other.grad };
        }

        pub inline fn sum(vals: anytype) @This() {
            var rtn: @This() = .{ .x = 0, .grad = 0 };
            inline for (vals) |v| {
                rtn.x += v.x;
                rtn.grad += v.grad;
            }
            return rtn;
        }

        pub inline fn sub(self: @This(), other: @This()) @This() {
            return .{ .x = self.x - other.x, .grad = self.grad - other.grad };
        }

        pub inline fn mul(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x * other.x,
                .grad = self.x * other.grad + self.grad * other.x,
            };
        }

        pub inline fn prod(vals: anytype) @This() {
            var rtn: @This() = .{ .x = 1, .grad = 0 };
            inline for (vals, 0..) |v, i| {
                rtn.x *= v.x;
                inline for (vals, 0..) |w, j| {
                    if (i == j) {
                        rtn.grad *= w.x;
                    } else {
                        rtn.grad *= w.grad;
                    }
                }
            }
            return rtn;
        }

        pub inline fn exp(self: @This()) @This() {
            return .{
                .x = @exp(self.x),
                .grad = @exp(self.x) * self.grad,
            };
        }

        pub inline fn log(self: @This()) @This() {
            return .{
                .x = @log(self.x),
                .grad = self.grad / self.x,
            };
        }

        pub inline fn inv(self: @This()) @This() {
            return .{
                .x = splat(1.0) / self.x,
                .grad = -self.grad / self.x / self.x,
            };
        }
    };
}

test "basic arithmetic" {
    const D = Dual(f32);
    const one_x = D.init_with_var(1.0);
    const one_const = D.init_with_const(1.0);
    const one_squared = one_x.mul(one_x).mul(one_const).add(one_const).sub(one_const);
    try testing.expectEqual(@as(f32, 1.0), one_squared.x);
    try testing.expectEqual(@as(f32, 2.0), one_squared.grad);
}

fn normal_pdf(comptime F: type, x: Dual(F), mu: Dual(F), sigma: Dual(F)) Dual(F) {
    const z = x.sub(mu).mul(sigma.inv());
    const neg_half = Dual(F).init_with_const(Dual(F).splat(-0.5));
    const scalar = Dual(F).init_with_const(Dual(F).splat(1.0 / @sqrt(std.math.tau)));
    const exp = z.mul(z).mul(neg_half).exp();
    return exp.mul(sigma.inv()).mul(scalar);
}

test "erf vector" {
    const D = Dual(@Vector(2, f64));
    const mu = @splat(2, @as(f64, 0.0));
    const sigma = @splat(2, @as(f64, 1.0));
    const x: @Vector(2, f64) = .{ 0.0, 1.0 };
    const prob = normal_pdf(
        @Vector(2, f64),
        D.init_with_var(x),
        D.init_with_const(mu),
        D.init_with_const(sigma),
    );

    try testing.expectApproxEqAbs(@as(f64, 0.398942), prob.x[0], 1e-5);
    try testing.expectApproxEqAbs(@as(f64, 0.241971), prob.x[1], 1e-5);
}
