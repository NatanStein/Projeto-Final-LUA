local MQTT = require "mqttLoveLibrary" 
local canal = "morse"
local host = "mosquitto.org"
local id = "Natan"
local str=""
local help = ""
local cont = 0
local cont2 = 0
local cont4 = 0
local cont5 = 0
local rep = 0
local y = 534
local caps = false
local disupper = 0
local esp = ""
local mensag = {}
local historico = {}
local Nlogin = ""
local Nlogin2 = ""
local login = true
data=os.date("*t")
dados=io.open("historico.txt")
recupera=dados:read("*a")
dados:close()
function cria_tabela(nome)
  arq=io.open(nome)
  local t = {}
  for line in arq:lines() do
    string.gsub(line,"(.-)>(.-)>",function (chave,carac)
        t[tostring(chave)]=carac
      end 
    )
  end
  arq:close()
  return t
end
function msgrecebida (msg)
  string.gsub(msg,"(.-):(.-):",function (ato,ident)
      if ato == "login" then
        if ident ~= Nlogin then
          Nlogin2=ident
        end
      end
      if ato == "stop" then
        if ident ~= id then
          cor="branco"
          id2=ident
        else
          cor="verde"
        end
        if not(str == "" or str == nil or str == " ") then
          if str:sub(-1) == "\n" then
            str=str:sub(1,-2)
            cont=cont-1
          end
          local data=os.date("*t")
          mensag[#mensag+1]={word=str,cor=cor,h=cont,hora=tostring(data.hour)..":"..tostring(data.min)..":"..tostring(data.sec)}
          str=""
          help=""
          cont=0
          cont5=0
          y=534
        end
      else
        if t[ato] ~= nil  then
          if disupper == 1 then
            disupper = 2
            caps=false
          end
          esp=""
          if t[ato] == "." then
            caps = true
            disupper=1
            esp = " "
          end
          if t[ato] == "," then
            esp = " "
          end
          if t[ato] == "" then
            str=str:sub(1,-2)
          end
          if caps or string.len(str) == 0 or disupper == 2 then
            str=str..string.upper(t[ato])..esp
            if disupper == 2 then
              disupper = 0
            end
          else
            str=str..t[ato]..esp
            if string.len(str) > 47 then
              str = str:sub(1,-2)
            end
          end
          if ident == id then
            help = str
          end
        end
        if string.len(str)%(15+(15*cont5+cont5)) == 0 and string.len(str) >= 15 and cont5 ~= 3 then
          cont5=cont5+1
          if cont5 == 2 then
            y=y-3
          end
          str=str.."\n"
          cont=cont+1
        end
      end
    end
  )  
end
function love.load()
  MQTT.start(host,id,canal,msgrecebida)
  t=cria_tabela("tabela.txt")
  love.window.setMode(1200,576)
  love.graphics.setBackgroundColor(1,1,1) 
  font=love.graphics.newFont(16)
  fundo=love.graphics.newImage("conv.png")
  duaslinha=love.graphics.newImage("2linha.png")
  Tlogin=love.graphics.newImage("login.png")
  dic=love.graphics.newImage("dic.png")
  for i=1,#t do
    cont2=cont2+t[i].h
  end
end
function love.update(dt)
  MQTT.checkMessages()
  if 35+#mensag*60+81 > 500 or 35+7*60+20*cont2 > 500 then
    for i=1,#mensag do
      historico[#historico+1]=mensag[i]
      if mensag[i].cor == "verde" then
        nome=Nlogin
      else
        nome=Nlogin2
      end
      historico[#historico].id=nome
    end
    trash=mensag[#mensag]
    cont2=mensag[#mensag].h
    mensag={}
    mensag[1] = trash
    hist=io.open("historico.txt","w")
    if recupera ~= "" then
      hist:write(recupera)
    end
    if #historico > 7 then
      rep = 1
    end
    hist:write("               <- - - -["..tostring(data.day).."/"..tostring(data.month).."/"..tostring(data.year).."]- - - ->\n")
    for i=1+rep,#historico do
      hist:write(historico[i].id.."-"..historico[i].hora..'-\n"'..historico[i].word..'"\n')
    end
    hist:close()
  end
end
function love.keypressed(key)
  if key == "backspace" then
    if login then
      Nlogin=Nlogin:sub(1,-2)
    end
  end
  if key == "return" then
    if login and Nlogin ~= "" then
      MQTT.sendMessage("login:"..Nlogin..":",canal)
      login = false
    else
      if str ~= "" or str ~= " " or str ~= nil then
        MQTT.sendMessage("stop:"..id..":",canal)
      end
    end
  end
  if key == "capslock" and disupper ~= 1 then
    caps = not caps
  end
  if key == "b" then
    MQTT.sendMessage("1000:"..id..":",canal)
  end
end
function love.textinput(letra)
  if string.len(Nlogin) > 15 then
    letra=""
  end
  if login then
    Nlogin=Nlogin..letra
  end
end
function love.draw()
  if login then
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(font)
    love.graphics.draw(Tlogin,0,0,0,1,1)
    love.graphics.print(Nlogin,430,319)  
  else
    love.graphics.setColor(1,1,1)
    love.graphics.draw(fundo,0,0,0,0.5,0.63)
    love.graphics.draw(dic,624,0,0,0.5,0.5)
    if cont >= 2 and help ~= "" then
      love.graphics.draw(duaslinha,0,505,0,0.5,0.62)
    end
    love.graphics.setFont(font)
    love.graphics.setColor(0.3,0.3,0.3)
    love.graphics.print(Nlogin2,60,20)
    love.graphics.print(help,70,y-cont*6)
    for i,v in ipairs (mensag) do
      if v.cor == "branco" then
        color={1,1,1}
        x=25
      else
        color={0.2,1,0.2}
        x=420
      end
      love.graphics.setColor(color)
      love.graphics.rectangle("fill",x-5,30+i*60+20*cont2,200,30+v.h*20)
      love.graphics.setColor(0,0,0)
      love.graphics.print(v.word,x+5,35+i*60+20*cont2)
    end
  end
end