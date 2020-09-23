using RedPitayaDAQServer
using PyPlot

rp = RedPitaya("rp-f04972.local")
#rp = RedPitaya("rp-f07083.local")
#rp = RedPitaya("192.168.178.46")

dec = 8
modulus = 4800
base_frequency = 125000000
periods_per_step = 10
samples_per_period = div(modulus, dec)#*periods_per_step
periods_per_frame = 100 # about 0.5 s frame length
frame_period = dec*samples_per_period*periods_per_frame / base_frequency
slow_dac_periods_per_frame = div(periods_per_frame, periods_per_step)

@info samples_per_period, periods_per_frame, slow_dac_periods_per_frame

decimation(rp, dec)
samplesPerPeriod(rp, samples_per_period)
periodsPerFrame(rp, periods_per_frame)
passPDMToFastDAC(rp, true)
slowDACPeriodsPerFrame(rp, slow_dac_periods_per_frame)

numSlowDACChan(rp, 2)
lutA = collect(range(0,0.3,length=slow_dac_periods_per_frame))
lutB = collect(ones(slow_dac_periods_per_frame))

lutEnableDACA = ones(Bool, slow_dac_periods_per_frame)
lutEnableDACA[1:2:end] .= false
lutEnableDACB = ones(Bool, slow_dac_periods_per_frame)
lutEnableDACB[2:2:end] .= false

modeDAC(rp, "STANDARD")
frequencyDAC(rp,1,1, base_frequency / modulus)

freq = frequencyDAC(rp,1,1)
println(" frequency = $(freq)")
jumpSharpnessDAC(rp, 1, 0.01) # controls the sharpness of the jump for the square
signalTypeDAC(rp, 1 , "SQUARE")
phaseDAC(rp, 1, 1, 0.0 ) # Phase has to be given in between 0 and 1
amplitudeDACNext(rp, 1, 1, 0.1) 

ramWriterMode(rp, "TRIGGERED")
triggerMode(rp, "INTERNAL")
masterTrigger(rp, false)
startADC(rp)
masterTrigger(rp, true)

sleep(0.1)


enableDACLUT(rp, collect( cat(lutEnableDACA,lutEnableDACB,dims=2)' ) )

lut = cat(lutA,lutB*0.1,dims=2)'
setSlowDACLUT(rp, collect(lut))


currFr = enableSlowDAC(rp, true, 1, frame_period, 0.5)
uCurrentPeriod = readData(rp, currFr, 1)


sleep(0.5)

lut = cat(lutA,lutB*0.4,dims=2)'
setSlowDACLUT(rp, collect(lut))

currFr = enableSlowDAC(rp, true, 1, frame_period, 0.5)
uCurrentPeriod2 = readData(rp, currFr, 1)

figure(1)
clf()
subplot(2,1,1)
plot(vec(uCurrentPeriod[:,1,:,:]))
plot(vec(uCurrentPeriod[:,2,:,:]))
legend(("Rx1", "Rx2"))
subplot(2,1,2)
plot(vec(uCurrentPeriod2[:,1,:,:]))
plot(vec(uCurrentPeriod2[:,2,:,:]))
legend(("Rx1", "Rx2"))

stopADC(rp)
