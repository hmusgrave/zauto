# zauto

very very very basic automatic differentiation

## Purpose

I need to solve some nonsense involving integrating log(erf(...)) and solving for the parameters based on a target. The math involved is simple, but probably not solvable in closed form and definitely not cheap in paper/chalk. I'd prefer to comptime evaluate that nonsense in Zig rather than copy-pasta magic from Python or whatever.

## Installation

Zig has a package manager!!! Do something like the following.

```zig
// build.zig.zon
.{
    .name = "foo",
    .version = "0.0.0",

    .dependencies = .{
        .zauto = .{
            .url = "https://github.com/hmusgrave/zauto/archive/refs/tags/0.0.0.tar.gz",
            .hash = "122032ce63f83b093452dac8487bff9f26e2f9f2f14f6f69e81bad1c41343bec5fdd",
        },
    },
}
```

```zig
// build.zig
const zauto_pkg = b.dependency("zauto", .{
    .target = target,
    .optimize = optimize,
});
const zauto_mod = zauto_pkg.module("zauto");
exe.addModule("zauto", zauto_mod);
unit_tests.addModule("zauto", zauto_mod);
```

## Other

Feel free to use this library for something. It's the most basic of (scalar) dual number implementations. Read the source to figure out how to use it. Vectors also work seamlessly as a computational shorthand, but keep in mind that the whole library assumes single variable calculus and does nothing special for partial derivatives. Message/email me instead if you're determined and lazy (SLA 0-10 weeks, usually 1-3 days). Please fork if you have significant feature requests or don't have much time for small requests.
