export setSlowDAC, getSlowADC, slowDACClockDivider, DIO, DIODirection

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


function DIODirection(rp::RedPitaya, pin::Int, val::String)
  if pin < 1 && pin > 8
    error("RP has only 8 digital pins!")
  end

  if val != "IN" && val != "OUT"
    error("value needs to be IN or OUT!")
  end

  send(rp, string("RP:DIO:DIR:PIN$(pin-1) ", val))
  return
end

function DIO(rp::RedPitaya, pin::Int, val::Bool)
  if pin < 1 && pin > 8
    error("RP has only 8 digital pins!")
  end

  DIODirection(rp, pin, "OUT")

  valStr = val ? "ON" : "OFF"
  send(rp, string("RP:DIO:PIN$(pin-1) ", valStr))
  return
end

function DIO(rp::RedPitaya, pin::Int)
  if pin < 1 && pin > 8
    error("RP has only 8 digital pins!")
  end

  DIODirection(rp, pin, "IN")

  return occursin("ON", query(rp,"RP:DIO:PIN$(pin-1)?"))
end