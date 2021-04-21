module TestSimpleStateEvents

using TinyModia
using DifferentialEquations
using ModiaPlot


SimpleStateEvents = Model(
    fmax = 1.5,
    m    = 1.0,
    k    = 1.0,
    d    = 0.1,
    s    = Var(init = 2.0),
    v    = Var(init = 0.0),
    equations = :[
        sPos = positive(instantiatedModel, 1, s, "s", _leq_mode)
        f = sPos ? 0.0 : fmax
        v = der(s)
        m*der(v) + d*v + k*s = f
    ]
)

model = @instantiateModel(SimpleStateEvents, logCode=true)

simulate!(model, Tsit5(), stopTime = 10, nz=1, log=true, logEvents=true)   # requiredFinalStates = [-0.3617373025974107]

plot(model, ["s", "v", "sPos", "f"])

end