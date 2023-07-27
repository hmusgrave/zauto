# zauto

very very very basic automatic differentiation

## Purpose

I need to solve some nonsense involving integrating log(erf(...)) and solving for the parameters based on a target. The math involved is simple, but probably not solvable in closed form and definitely not cheap in paper/chalk. I'd prefer to comptime evaluate that nonsense in Zig rather than copy-pasta magic from Python or whatever.

## Other

Feel free to use this library for something. It's the most basic of (scalar) dual number implementations. Read the source to figure out how to use it. Vectors also work seamlessly as a computational shorthand, but keep in mind that the whole library assumes single variable calculus and does nothing special for partial derivatives. Message/email me instead if you're determined and lazy (SLA 0-10 weeks, usually 1-3 days). Please fork if you have significant feature requests or don't have much time for small requests.
