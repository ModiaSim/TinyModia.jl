module TestTwoInertiasAndIdealGear

using TinyModia
using DifferentialEquations
@usingModiaPlot
using Unitful
using Test

TwoInertiasAndIdealGearTooManyInits = Model(
    J1 = 0.0025,
    J2 = 170,
    r  = 105,
    tau_max = 1,
    phi1 = Var(init = 0.0), 
    w1   = Var(init = 1.0), 
    phi2 = Var(init = 0.5), 
    w2   = Var(init = 0.0),
    equations = :[
        tau = if time < 1u"s"; tau_max elseif time < 2u"s"; 0 elseif time < 3u"s"; -tau_max else 0 end,

        # inertia1
        w1 = der(phi1),
        J1*der(w1) = tau - tau1,

        # gear
        phi1   = r*phi2,
        r*tau1 = tau2,

        # inertia2]
        w2 = der(phi2),
        J2*der(w2) = tau2
    ]
)

TwoInertiasAndIdealGear = TwoInertiasAndIdealGearTooManyInits | Map(phi1 = Var(init=nothing), w1=Var(init=nothing))

twoInertiasAndIdealGearTooManyInits = @instantiateModel(TwoInertiasAndIdealGearTooManyInits)
twoInertiasAndIdealGear             = @instantiateModel(TwoInertiasAndIdealGear)

println("Next simulate! should result in an error:\n")
simulate!(twoInertiasAndIdealGearTooManyInits, Tsit5(), stopTime = 4.0, log=true)

simulate!(twoInertiasAndIdealGear, Tsit5(), stopTime = 4.0, log=false,
          logParameters=true, logStates=true,
          requiredFinalStates=[1.5628074713622309, -6.878080753044174e-5])
          
plot(twoInertiasAndIdealGear, ["phi2", "w2"])


# Linearize
println("\n... Linearize at stopTime = 0 and 4")
(A_0, x_0) = linearize!(twoInertiasAndIdealGear, stopTime=0, analytic = true)
(A_4, x_4) = linearize!(twoInertiasAndIdealGear, stopTime=4, analytic = true) 
(A_4_numeric, x_4_numeric) = linearize!(twoInertiasAndIdealGear, stopTime=4, analytic=false) 

xNames = get_xNames(twoInertiasAndIdealGear)
@show xNames
@show A_0, x_0
@show A_4, x_4
@show A_4_numeric, x_4_numeric
@test isapprox(A_0,[0.0 1.0; 0.0 0.0])
@test isapprox(A_0, A_4)

end