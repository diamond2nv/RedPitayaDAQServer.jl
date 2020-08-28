export setSlowDAC, getSlowADC, slowDACClockDivider, DIO

function setSlowDAC(rp::RedPitaya, channel, value)
  command = string("RP:PDM:CHannel", Int64(channel), ":NextValueVolt ", value)
  send(rp, command)
end

function getSlowADC(rp::RedPitaya, channel)
  command = string("RP:XADC:CHannel", Int64(channel), "?")
  query(rp, command, Float64)
end


slowDACClockDivider(rp::RedPitaya) = query(rp,"RP:PDM:ClockDivider?", Int64)
function slowDACClockDivider(rp::RedPitaya, value)
  command = string("RP:PDM:ClockDivider ", Int32(value))
  send(rp, command)
end

function DIO(rp::RedPitaya, pin::Int, val::Bool)
  if pin < 1 && pin > 8
    error("RP has only 8 digital pins!")
  end

  valStr = val ? "ON" : "OFF"
  send(rp, string("RP:DIO:PIN$(pin-1) ", valStr))
end

function DIO(rp::RedPitaya, pin::Int)
  if pin < 1 && pin > 8
    error("RP has only 8 digital pins!")
  end
  return occursin("ON", query(rp,"RP:DIO:PIN$(pin-1)?"))
end