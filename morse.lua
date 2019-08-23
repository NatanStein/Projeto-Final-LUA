-- Projeto Final de INF1031
-- Alunos: Natan Steinbruch (1910877) e Paulo Vítor Libório (1910896)
-- Prof.: Waldemar Celes Filho

local msgr = require ("mqttNodeMCULibrary");

local srlongo = 2;
local slcurto = 1;

gpio.mode(srlongo, gpio.INT, gpio.PULLUP);
gpio.mode(slcurto, gpio.INT, gpio.PULLUP);

local timerbounce = tmr.create();
local timerend = tmr.create();
local sequence = "";
local idlove = "Natan"
local id = idlove.."Node"
local canal = "morse"
local host = "mosquitto.org"

function clickCurto(level, time)
  if(gpio.read(srlongo) == gpio.LOW) then
    gpio.trig(srlongo);
    sequence=sequence:sub(1,-2)
    msgr.sendMessage(sequence..":"..idlove..":",canal);
    print("mensagem enviada!");
    sequence = "";
    gpio.trig(slcurto);
    timerbounce:alarm(200, tmr.ALARM_SINGLE, reestablishBoth);
  else
    timerend:stop();
    sequence = sequence.."0";
    tmr.delay(100)
    print(sequence);
    gpio.trig(slcurto);
    timerbounce:alarm(200, tmr.ALARM_SINGLE, reestablishLeft);
  end
end

function clickLongo(level, time)
  if(gpio.read(slcurto) == gpio.LOW) then
    gpio.trig(slcurto);
     sequence=sequence:sub(1,-2)
    msgr.sendMessage(sequence..":"..idlove..":",canal);
    print("mensagem enviada!");
    sequence = "";
    gpio.trig(srlongo);
    timerbounce:alarm(200, tmr.ALARM_SINGLE, reestablishBoth);
  else
    timerend:stop();
    sequence = sequence.."1";
    tmr.delay(100)
    print(sequence);
    gpio.trig(srlongo);
    timerbounce:alarm(200, tmr.ALARM_SINGLE, reestablishRight);
  end
end

-- Função para restabelecer o click do switch curto
function reestablishLeft()
  gpio.trig(slcurto, "down", clickCurto);
end

-- Função para restabelecer o click do switch longo
function reestablishRight()
  gpio.trig(srlongo, "down", clickLongo);
end

-- Função para restabelecer o click dos dois switchs
function reestablishBoth()
  gpio.trig(srlongo,"down",clickLongo);
  gpio.trig(slcurto,"down",clickCurto);
end

function mensagemRecebida(msg)
end
reestablishBoth();
msgr.start(host,id,canal,mensagemRecebida);