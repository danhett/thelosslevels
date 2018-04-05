pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- the loss levels
-- dan hett

function _init()
	sfx(0)

	setupgameparts()
	setuptimeout()
	setupglitches()
	setupfader()
end

function setupgameparts()
	debug = false

	nextgame = 'games/12-flat.p8'
	line1 = "strangers approach relentlessly."
	line2 = "sorry for your loss, man."
	success = "everyone means well...\n\nbut it's too much."
	failure = "everyone means well...\n\nbut there's no escaping it."
	col1 = 13
	col2 = 12

	player = {}
	player.moving = false
	player.frame = 0
	player.framecount = 0
	player.x = 4
	player.y = 106
	player.step = 0
	player.speed = 3
	player.flip = false
	player.sprite = 0
	player.idlesprite = 32
	player.eyesclosedsprite = 34

	p1 = {}
	p1.sprite = 128
	p1.x = 90
	p1.y = 10
	p1.step = 0
	p1.flip = false
	p1.speed = 1

	p2 = {}
	p2.sprite = 160
	p2.x = 90
	p2.y = 50
	p2.step = 0
	p2.flip = false
	p2.speed = 0.7

	p3 = {}
	p3.sprite = 192
	p3.x = 90
	p3.y = 90
	p3.step = 0
	p3.flip = false
	p3.speed = 0.6

	flashcurrent = 0
	flashrate = 10
	flashstate = false

	messagetimer = 0
	messagelimit = 100

	wincount = 0
	wintarget = 400

	shaking = false
	shakecount = 0
	shakelimit = 10

	playedendsound = false
end

function setuptimeout()
	tcurrent = 0
	tmax = 60 * 10 -- reset timeout to return to the main menu
end

function setupfader()
	state = "waiting" -- or fadingdown or playing
	waittime = 0
	waittotal = 40
	fadedelay = 0
	fadelimit = 150

	ypos = -20
end

function setupglitches()
	glit = {}
	glit.height=128
	glit.width=128
	glit.t=0
end

function _update()
	if(state=="playing") checkinputs()

	wincount+=1
	if wincount >= wintarget then
		if state == "playing" then
			state = "success"
		end
	end

	shake()
end

function _draw()
	cls(0)
	drawgame()
	checktimeout()
	handlewinloss()
	handlefading()
	checkcollisions()
	flash()
	glitch()
end


function drawgame()
	-- terrain
	map(0, 0, 0, 0, 128, 128)

	-- enemies (always moving so just draw)
	animateenemies()
	spr(p1.sprite, p1.x, p1.y, 2, 2, p1.flip)
	spr(p2.sprite, p2.x, p2.y, 2, 2, p2.flip)
	spr(p3.sprite, p3.x, p3.y, 2, 2, p3.flip)

	-- player
	animateplayer()

	if player.moving then
		spr(player.sprite * 2, player.x, player.y, 2, 2, player.flip)
	end

	if not player.moving then
		spr(32, player.x, player.y, 2, 2, player.flip)
	end

	if debug then
		print(player.y, 10, 10, 2)
	end
end

function animateplayer()
	if player.moving then
		player.step+=1

		if(player.step%2==0) player.sprite += 1

	  if player.sprite > 7 then
	   player.sprite = 0
	  end
	end
end

-- copy paste lol (no time, omg)
function animateenemies()
	if state=="playing" then
		-- one
		p1.step+=1
		if(p1.step%3==0) p1.sprite += 2
	  if p1.sprite > 135 then
	   p1.sprite = 128
	  end
		if p1.x < player.x then
			p1.x += p1.speed
			p1.flip = false
		end
		if p1.x > player.x then
			p1.x -= p1.speed
			p1.flip = true
		end
		if(p1.y < player.y) p1.y += p1.speed
		if(p1.y > player.y) p1.y -= p1.speed

		-- two
		p2.step+=1
		if(p2.step%3==0) p2.sprite += 2
	  if p2.sprite > 167 then
	   p2.sprite = 160
	  end
		if p2.x < player.x then
			p2.x += p2.speed
			p2.flip = false
		end
		if p2.x > player.x then
			p2.x -= p2.speed
			p2.flip = true
		end
		if(p2.y < player.y) p2.y += p2.speed
		if(p2.y > player.y) p2.y -= p2.speed

		-- three
		p3.step+=1
		if(p3.step%4==0) p3.sprite += 2
	  if p3.sprite > 199 then
	   p3.sprite = 192
	  end
		if p3.x < player.x then
			p3.x += p3.speed
			p3.flip = false
		end
		if p3.x > player.x then
			p3.x -= p3.speed
			p3.flip = true
		end
		if(p3.y < player.y) p3.y += p3.speed
		if(p3.y > player.y) p3.y -= p3.speed

		if dst(player, p1) > 0 and dst(player, p1) < 6 then
			state = "fail"
			shaking = true
		end
	end
end

function checkcollisions()

end

function dst(p0, p1)
 local dx = p0.x - p1.x
 local dy = p0.y - p1.y

 return sqrt(dx*dx+dy*dy)
end

function outline(s,x,y,c1,c2)
	for i=0,2 do
	 for j=0,2 do
	  if not(i==1 and j==1) then
	   print(s,x+i,y+j,c1)
	  end
	 end
	end
	print(s,x+1,y+1,c2)
end

function checkinputs()
	player.moving = false

	if btn(0) and player.x > 0 then
		resettimeout()
		player.x-=player.speed
		player.flip = true;
		player.moving = true
	end

	if btn(1) and player.x < 112 then
		resettimeout()
		player.x+=player.speed
		player.flip = false
		player.moving = true
	end

	if btn(2) and player.y > 0 then
		resettimeout()
		player.y-=player.speed
		player.moving = true
	end

	if btn(3) and player.y < 110 then
		resettimeout()
		player.y+=player.speed
		player.moving = true
	end

	if(btn(4)) resettimeout()
	if(btn(5)) resettimeout()

	if not player.moving then
    player.sprite = 0
  end
end

function resettimeout()
	tcurrent = 0
end

function checktimeout()
	if tcurrent < tmax then tcurrent+=1 end

	if tcurrent == tmax then
		load('losslevels.p8')
	end
end

function handlefading()
	if state == "waiting" then
		if fadedelay < fadelimit then
			fadedelay+=1
		end

		if fadedelay == fadelimit then
			state = "fadingup"
		end

		drawmessage()
	end

	if state == "fadingup" then
		waittime+=1

		if waittime < waittotal  then
			rectfill( 0, 0, 127, 127 - (3 * waittime), 0 )
			rectfill( 127, 127, 0, 3 * waittime, 0 )
			drawmessage()
			ypos += 4
		end
	end

	if waittime == waittotal then
		if state == "fadingup" then
			state = "playing"
			waittime = 0
		end

		if state == "fadingdown" then
			load(nextgame)
		end
	end

	if state == "fadingdown" then
		waittime+=1
		rectfill( 0, 0, 127, 3 * waittime, 0 )
		rectfill( 127, 127, 0, 127 - (3 * waittime), 0 )
	end
end

function handlewinloss()
	if state == "success" then
		outline(success,4,6,0,11)
		showingmessage = true
		player.moving = false

		if playedendsound == false then
			sfx(2)
			playedendsound = true
		end
	end

	if state == "fail" then
		outline(failure,4,6,0,8)
		showingmessage = true
		player.moving = false

		if playedendsound == false then
			sfx(3)
			playedendsound = true
		end
	end

	if showingmessage then
		messagetimer+=1
		if(messagetimer >= messagelimit) state = "fadingdown"
	end
end

function drawmessage()
	-- draw shutters
	rectfill( 0, 0, 127, 127 - (3 * waittime), 0 )
	rectfill( 127, 127, 0, 3 * waittime, 0 )

	-- draw text
	if(ypos < 50) then ypos+= 4 end

	if flashstate then
		outline(line1,0,ypos,0,col1)
		outline(line2,0,ypos+10,0,col2)
	else
		outline(line1,0,ypos,1,col1)
		outline(line2,0,ypos+10,1,col2)
	end
end

function rectfill_p(x0,y0,x1,y1,p,c0,c1)
 fill_pattern(p)
 col=color_pattern(c0,c1)
 rectfill(x0,y0,x1,y1,col)
end

function fill_pattern(n)
 t={
 0b1111111111111111,
 0b1111111111110111,
 0b1111110111110111,
 0b1111110111110101,
 0b1111010111110101,
 0b1111010110110101,
 0b1110010110110101,
 0b1110010110100101,
 0b1010010110100101,
 0b1010010110100001,
 0b1010010010100001,
 0b1010010010100000,
 0b1010000010100000,
 0b1010000000100000,
 0b1000000000100000,
 0b1000000000000000,
 0b0000000000000000}
 if n<0 then n=0
 elseif n>16 then n=16 end
 fillp(t[n+1])
end

function color_pattern(c0,c1)
 t={0,1,2,3,4,5,6,7,8,9,
 "a","b","c","d","e","f"}
 return "0x"..t[c0+1]..t[c1+1]
end

function flash()
	flashcurrent+=1

	if flashcurrent > flashrate then
		flashstate = true
	else
		flashstate = false
	end

	if flashcurrent == flashrate * 2 then
		flashcurrent = 0
	end
end

function glitch()
	if g_on == true then -- on boolean is mangaged by the timer
		local t={7,6,10} -- create array of three colors
		local c=rnd(3) -- generate a random number between 1 and 3, we'll use this in a bit
		c=flr(c) -- make sure our random number is an integer and not a float
		for i=0, 5, 4 do -- the outer loop generates the vertical glitch dots
			local gl_height = rnd(glit.height)
			for h=0, 100, 2 do -- the inner loop creates longer horizontal lines
				pset(rnd(glit.width), gl_height, t[c]) -- write the random pixels to the screen and randomize the colors from the previously generated random number against out color array
			end
		end
	end

	-- animation timeline that turns the static on and off
	if glit.t>30 and glit.t < 50 then
		g_on=true
	elseif glit.t>70 and glit.t < 80 then
		g_on=true
	elseif glit.t>120 then
		glit.t = 0

	else
		g_on=false

	end
	glit.t+=1

	o1 = flr(rnd(0x1f00)) + 0x6040
 o2 = o1 + flr(rnd(0x4)-0x2)
 len = flr(rnd(0x40))

 memcpy(o1,o2,len)
end

function shake(reset) -- shake the screen
	camera(0,0) -- reset to 0,0 before each shake so we don't drift

	if shaking then
		if(shakecount < shakelimit) shakecount+=1
		if(shakecount == shakelimit) shaking = false
		if not reset then -- if the param is true, don't shake, just reset the screen to default
			camera(flr(rnd(3)-3),flr(rnd(3)-3)) -- define shake power here (-5 to shake equally in all directions)
		end
	end
end
__gfx__
000000000000000000000000000000000000000000000000000000ffff000000000000000000000000000000000000000000000000000000000000ffff000000
000000ffff0000000000000000000000000000ffff00000000000fff55f00000000000ffff0000000000000000000000000000ffff00000000000ff55f500000
00000fff55f00000000000ffff00000000000ffff550000000000fff75f0000000000fff55f00000000000ffff00000000000ff55f50000000000ff75f500000
00000fff75f0000000000ffff550000000000ffff750000000000ffffff0000000000fff75f0000000000ff55f50000000000ff75f50000000000ffffff00000
00000ffffff0000000000ffff750000000000ffffff00000000000ffff00000000000ffffff0000000000ff75f50000000000ffffff00000000000ffff000000
000000ffff00000000000ffffff00000000000ffff0000000000008888000000000000ffff00000000000ffffff00000000000ffff0000000000008888000000
0000008888000000000000ffff000000000000888800000000000088888000000000008888000000000000ffff00000000000088880000000000008888800000
00000088888000000000008888000000000008888880000000000088888000000000008888800000000000888800000000000088888000000000008888800000
000000888880000000000888888000000000088888800000000000888880000000000888888800000000088888880000000008888888000000000888888f0000
0000008888800000000008888880000000000f8888ff000000000008ff80000000000ff8888ff000000088888888800000000ff8888ff000000008ff888f0000
000000888ff0000000000f8888ff000000000ff888ff0000000000ccffc0000000000ff8888ff0000000ff88888ff00000000ff8888ff000000000ffcccc0000
000000cccffc0000000000ccccff00000000000ccc000000000000c7ccc00000000000ccccc000000000ff88888ff00000000000ccc00000000000cccccc0000
000000ccccccc00000007cccccc00000000007cccc000000000000c7cc000000000000cccccc0000000000ccccc000000000000cccc00000000000cc07cc0000
00000ccc00ccc00000007ccc0cc00000000007ccc0000000000000c70000000000000ccc00cc000000007cc00cc000000000007ccc00000000000ccc07000000
0000ccc000077000000070000cc000000000070cc0000000000000cc0000000000000cc00007700000007c000cc0000000000070cc00000000000cc000000000
00007700000000000000000000770000000000007700000000000007700000000000077000000000000000000077000000000000077000000000007700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000ffff00000000000000000000000000000000000000
00000f55f5500000000000ffff0000000000000000000000000000ffff000000000000ffff00000000000f55f550000000000000000000000000000000000000
00000f75f570000000000f55f5500000000000ffff00000000000f55f550000000000f55f550000000000f75f570000000000000000000000000000000000000
00000ffffff0000000000f75f570000000000f55f550000000000f75f570000000000f75f570000000000ffffff0000000000000000000000000000000000000
000000ffff00000000000ffffff0000000000f75f570000000000ffffff0000000000ffffff00000000000ffff00000000000000000000000000000000000000
0000088888800000000000ffff00000000000ffffff00000000008ffff800000000008ffff800000000008888880000000000000000000000000000000000000
00008888888800000000088888800000000008ffff80000000000888888000000000888888880000000088888888000000000000000000000000000000000000
00088888888880000000888888880000000088888888000000008888888800000008888888888000000888888888800000000000000000000000000000000000
00088888888880000008888888888000000888888888800000088888888880000008888888888000000888888888800000000000000000000000000000000000
000ff888888ff000000888888888800000088888888880000008888888888000000ff888888ff000000ff888888ff00000000000000000000000000000000000
000ffccccccff000000ff888888ff000000ff888888ff000000ffccccccff000000ffccccccff000000ffccccccff00000000000000000000000000000000000
00000ccc0cc00000000ffccccccff000000ffccccccff000000ffccc0ccff00000000ccc0cc0000000000ccc0cc0000000000000000000000000000000000000
00000cc00cc0000000000ccc0cc0000000000ccc0cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000000000000000000000000000000
00000cc00cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000000000000000000000000000000
000007700077000000000dd000dd000000000dd000dd000000000dd000dd000000000dd000dd000000000dd000dd000000000000000000000000000000000000
33333333333333333333333bb3333333333333733333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333b33b33333333333333333333333333337a73333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333333333333333333333b333333733333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333b3333333333333333333333b3333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333b33333333333333333333733333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
b3333333333333333333333337a73333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333b33333333333b333333733333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333333333333333333333333333333b3333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
34333343333333433343334334333433333333433433333300000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444333333443444444444444443333333444433333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333434433333333333344333333433433333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333433433333333333343333333433433333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333433433333333333343333333433433333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333433433333333333343333333444433333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333444433333333333344444444433444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333433433333333333343343334333343334300000000000000000000000000000000000000000000000000000000000000000000000000000000
34333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
34333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
34333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
34333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
34333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44333333444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
34333333343333430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000044444000000000000000000000000000000000000000000000000000000000004444000000
0000004444400000000000000000000000000044444000000000044ffff000000000004444400000000000000000000000000044440000000000044ffff00000
0000044ffff0000000000044444000000000044ffff0000000000ffffff000000000044ffff0000000000044440000000000044ffff0000000000ffffff00000
00000ffffff000000000044ffff0000000000ffffff0000000000ffffff0000000000ffffff000000000044ffff0000000000ffffff0000000000ffffff00000
00000ffffff0000000000ffffff0000000000ffffff00000000000ffff00000000000ffffff0000000000ffffff0000000000ffffff00000000000ffff000000
000000ffff00000000000ffffff00000000000ffff0000000000006666000000000000ffff00000000000ffffff00000000000ffff0000000000006666000000
0000006666000000000000ffff000000000000666600000000000066666000000000006666000000000000ffff00000000000066660000000000006666600000
00000066666000000000006666000000000006666660000000000066666000000000006666600000000000666600000000000066666000000000006666600000
000000666660000000000666666000000000066666600000000000666660000000000666666600000000066666660000000006666666000000000666666f0000
0000006666600000000006666660000000000f6666ff000000000006ff60000000000ff6666ff000000066666666600000000ff6666ff000000006ff666f0000
000000666ff0000000000f6666ff000000000ff666ff000000000011ff10000000000ff6666ff0000000ff66666ff00000000ff6666ff000000000ff11110000
000000111ff100000000001111ff00000000000111000000000000171110000000000011111000000000ff66666ff00000000000111000000000001111110000
00000011111110000000711111100000000007111100000000000017110000000000001111110000000000111110000000000001111000000000001107110000
00000111001110000000711101100000000007111000000000000017000000000000011100110000000071100110000000000071110000000000011107000000
00001110000770000000700001100000000007011000000000000011000000000000011000077000000071000110000000000070110000000000011000000000
00007700000000000000000000770000000000007700000000000007700000000000077000000000000000000077000000000000077000000000007700000000
000000000000000000000000000000000000000000000000000000aaaaa00000000000000000000000000000000000000000000000000000000000aaaa000000
000000aaaaa000000000000000000000000000aaaaa0000000000aaffff00000000000aaaaa000000000000000000000000000aaaa00000000000aaffff00000
00000aaffff00000000000aaaaa0000000000aaffff0000000000afffff0000000000aaffff00000000000aaaa00000000000aaffff0000000000afffff00000
00000afffff0000000000aaffff0000000000afffff0000000000afffff0000000000afffff0000000000aaffff0000000000afffff0000000000afffff00000
00000afffff0000000000afffff0000000000afffff0000000000affff00000000000afffff0000000000afffff0000000000afffff0000000000affff000000
00000affff00000000000afffff0000000000affff00000000000a222200000000000affff00000000000afffff0000000000affff00000000000a2222000000
00000a222200000000000affff00000000000a222200000000000a222220000000000a222200000000000affff00000000000a222200000000000a2222200000
00000a222220000000000a222200000000000a2222200000000000222220000000000a222220000000000a22220000000000aa22222000000000002222200000
000000222220000000000a22222000000000022222200000000000222220000000000222222200000000aa2222220000000002222222000000000222222f0000
0000002222200000000002222220000000000f2222ff000000000002ff20000000000ff2222ff000000022222222200000000ff2222ff000000002ff222f0000
000000222ff0000000000f2222ff000000000ff222ff0000000000eeffe0000000000ff2222ff0000000ff22222ff00000000ff2222ff000000000ffeeee0000
000000eeeffe0000000000eeeeff00000000000eee000000000000e8eee00000000000eeeee000000000ff22222ff00000000000eee00000000000eeeeee0000
000000eeeeeee00000008eeeeee00000000008eeee000000000000e8ee000000000000eeeeee0000000000eeeee000000000000eeee00000000000ee08ee0000
00000eee00eee00000008eee0ee00000000008eee0000000000000e80000000000000eee00ee000000008ee00ee000000000008eee00000000000eee08000000
0000eee000088000000080000ee000000000080ee0000000000000ee0000000000000ee00008800000008e000ee0000000000080ee00000000000ee000000000
00008800000000000000000000880000000000008800000000000008800000000000088000000000000000000088000000000000088000000000008800000000
00000000000000000000000000000000000000000000000000000055555000000000000000000000000000000000000000000000000000000000005555000000
00000055555000000000000000000000000000555550000000000554444000000000005555500000000000000000000000000055550000000000055444400000
00000554444000000000005555500000000005544440000000000444444000000000055444400000000000555500000000000554444000000000044444400000
00000444444000000000055444400000000004444440000000000444444000000000044444400000000005544440000000000444444000000000044444400000
00000444444000000000044444400000000004444440000000000044440000000000044444400000000004444440000000000444444000000000004444000000
00000044440000000000044444400000000000444400000000000077770000000000004444000000000004444440000000000044440000000000007777000000
00000077770000000000004444000000000000777700000000000077777000000000007777000000000000444400000000000077770000000000007777700000
00000077777000000000007777000000000007777770000000000077777000000000007777700000000000777700000000000077777000000000007777700000
00000077777000000000077777700000000007777770000000000077777000000000077777770000000007777777000000000777777700000000077777740000
00000077777000000000077777700000000004777744000000000007447000000000044777744000000077777777700000000447777440000000074477740000
000000777440000000000477774400000000044777440000000000cc44c0000000000447777440000000447777744000000004477774400000000044cccc0000
000000ccc44c0000000000cccc4400000000000ccc000000000000c1ccc00000000000ccccc00000000044777774400000000000ccc00000000000cccccc0000
000000ccccccc00000001cccccc00000000001cccc000000000000c1cc000000000000cccccc0000000000ccccc000000000000cccc00000000000cc01cc0000
00000ccc00ccc00000001ccc0cc00000000001ccc0000000000000c10000000000000ccc00cc000000001cc00cc000000000001ccc00000000000ccc01000000
0000ccc000011000000010000cc000000000010cc0000000000000cc0000000000000cc00001100000001c000cc0000000000010cc00000000000cc000000000
00001100000000000000000000110000000000001100000000000001100000000000011000000000000000000011000000000000011000000000001100000000
__map__
5250505050505050505050505050505350505050505050505050505050505053460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6040434545454545424545454545455145454545454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454543454245454545445145454545454543454545454145454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454345454545454545454242455145454545454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454544454545454545454545435145454145454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454245454545454545454545455145454545454545454545454545434551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045424545454545424445454545455145454545454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045414545454145454545454145415145454545454445454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454541454545454541455145454545454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045404545454545454545454545455145454545454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6040444545454545454545454545455145454545454545454045454045454051460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545444545454541454545455145454545454045454544454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454545454545454545455145454145454545424545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6044454545454545454545454545455140454545454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6043444545454545434545454545405145454145454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5561616161616161616161616161615445454545454545454545454245454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454545454545454545434545454545454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545414545454545414545454545454544454545404545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454545454545454545454545454545454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454545454545454545454545454545454545454545404545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454545454545454545454545454545454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454345414545454545454545454545454045404545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454545454543454545454545454545454545454545454045454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454545454545454545454545454545454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454545454545454545454545454045454545454545454445454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045404545454245454545454545454545454545454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454545454545454245434545454545454545454545454545454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454542454545454545454545454045454545454545454540454551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454540454545404545454545454545454545454545434245454545404551460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454545454545454545454545454545454045454545454545404051460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6045454545454545454543454545454545454545454545454545454545454051460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5561616161616161616161616161616161616161616161616161616161616154460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300002c5502b5502a550295502855027550265502555024550235502255021550205501e5501d5501b5501a550195501855017550165501455012550105500c55008550055500255001550015500155001550
000800020855006540015000f5000f500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0005000004050080500b0500f0501205017050190501d0502205025050270502705027050230001d0001c0001c0001c0000000000000000000000000000000000000000000000000000000000000000000000000
010500002805025050220501f0501a0501705013050100500e0500b0500a050080500805007050070500705007050070500705000000000000000000000000000000000000000000000000000000000000000000
