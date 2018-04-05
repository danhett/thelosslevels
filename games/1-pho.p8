pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- the loss levels
-- dan hett

function _init()
	setupgameparts()
	setuptimeout()
	setupglitches()
	setupfader()

	sfx(0)
end

function setupgameparts()
	nextgame = 'games/2-nws.p8'
	line1 = "hundreds of messages..."
	line2 = "an explosion? an accident?"
	success = "a bomb.\n\n...he's missing."
	failure = "no idea, but...\n\nhe's missing."
	col1 = 8
	col2 = 9

	b = 0;
	m = 15;
	f = 0;
	dirup = true;

	hand = {}
	hand.x = 6
	hand.y = 30
	hand.speed = 3
	hand.frame = 0

	flashcurrent = 0
	flashrate = 10
	flashstate = false

	messagetimer = 0
	messagelimit = 100

	xpos = 700

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
	fadelimit = 100

	ypos = -20
end

function setupglitches()
	glit = {}
	glit.height=128
	glit.width=128
	glit.t=0
end

function _update()
	checkinputs()

	shake()
end

function _draw()
	cls(0)
	drawbase()
	drawgame()
	checktimeout()
	handlefading()
	handlewinloss()
	glitch()
	flash()
end

function drawbase()
	f+=1

	if f == 4 then
		if dirup then
			b+=1
		end

		if not dirup then
			b-=1
		end

		f = 1
	end

	if dirup then
		if b == m then dirup = false end;
	end

	if not dirup then
		if b == 1 then dirup = true end;
	end

	--rectfill_p(0,0,128,128,b,0,5)
	rectfill_p(0,0,128,128,b,14,12)
end


function drawgame()
	if(xpos > 0) xpos-=4

	-- phone
	palt(0,false)
	palt(6,true)
	rectfill_p(xpos+40,14,xpos+110,120,10,0,5)
	rectfill_p(xpos+42,16,xpos+108,100,15,0,7)

	-- dummy buttons
	rectfill_p(xpos+44,20,xpos+106,34,0,0,col2)
	rectfill_p(xpos+44,40,xpos+106,54,0,0,col2)
	rectfill_p(xpos+44,80,xpos+106,94,0,0,col2)

	-- live button
	if flashstate and not showingmessage then
		rectfill_p(xpos+44,60,xpos+106,74,16,0,col2)
	else
		rectfill_p(xpos+44,60,xpos+106,74,16,0,11)
	end

	-- text
	print("??! !?!?? !!??!\n! ?!!? ?!!!...?", xpos + 46, 22, 7)
	print("!! -? !??? !..!\n..??? !! ?!! ?!", xpos + 46, 42, 7)
	print("???! ...!? ?!! \n?!?!! ?!! !??! ", xpos + 46, 62, 7) -- live
	print("......??!! !!?!\n!??! !! ??! ?!?", xpos + 46, 82, 7)

	-- hand
	spr(hand.frame, hand.x, hand.y, 3, 4)

	-- debug
	--print(hand.y, 10, 10, 11)
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
	if (btn(1)) hand.x += hand.speed
	if (btn(0)) hand.x -= hand.speed
	if (btn(2)) hand.y -= hand.speed
	if (btn(3)) hand.y += hand.speed

	if (btn(4)) then
		dotap()
	elseif (btn(5)) then
		dotap()
	else
		hand.frame = 0
	end
end

function dotap()
	if state == "playing" then
		hand.frame = 4

		resettimeout()

		if not showingmessage then
			if hand.x > 32 and hand.x < 104
			and hand.y > 58 and hand.y < 72 then
				state = "success"
			else
				state = "fail"
				shaking = true
			end
		end
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

		if playedendsound == false then
			sfx(2)
			playedendsound = true
		end
	end

	if state == "fail" then
		outline(failure,4,6,0,8)
		showingmessage = true

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

function dst(p0, p1)
 local dx = p0.x - p1.x
 local dy = p0.y - p1.y

 return sqrt(dx*dx+dy*dy)
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
66666666666666666666666666666666666666666666666666666666666666660000000000000000000000000000000000000000000000000000000000000000
66666666666600666666666666666666666666666666666666666666666666660000000000000000000000000000000000000000000000000000000000000000
66666666666077066666666666666666666666666666666666666666666666660000000000000000000000000000000000000000000000000000000000000000
66666666660700706666666666666666666666666666666666666666666666660000000000000000000000000000000000000000000000000000000000000000
66666666660700706666666666666666666666666666006666666666666666660000000000000000000000000000000000000000000000000000000000000000
66666666660700706666666666666666666666666660770666666666666666660000000000000000000000000000000000000000000000000000000000000000
66666666660700700666666666666666666666666607007066666666666666660000000000000000000000000000000000000000000000000000000000000000
66666666660700777000666666666666666666666607007006666666666666660000000000000000000000000000000000000000000000000000000000000000
66666666660700700777006666666666666666666607007770006666666666660000000000000000000000000000000000000000000000000000000000000000
66666666660700700700770666666666666666666607007007770066666666660000000000000000000000000000000000000000000000000000000000000000
66666600000700700700707066666666666666666607007007007706666666660000000000000000000000000000000000000000000000000000000000000000
66666077770700700700700706666666666666000007007007007070666666660000000000000000000000000000000000000000000000000000000000000000
66666070007700000700700706666666666660777707007007007007066666660000000000000000000000000000000000000000000000000000000000000000
66666070000700000000700706666666666660700077000007007007066666660000000000000000000000000000000000000000000000000000000000000000
66666070000000000000000706666666666660700007000000007007066666660000000000000000000000000000000000000000000000000000000000000000
66666607000000000000000706666666666660700000000000000007066666660000000000000000000000000000000000000000000000000000000000000000
66666660700000000000000706666666666666070000000000000007066666660000000000000000000000000000000000000000000000000000000000000000
66666660700000000000000706666666666666607000000000000007066666660000000000000000000000000000000000000000000000000000000000000000
66666660770000000000000706666666666666607000000000000007066666660000000000000000000000000000000000000000000000000000000000000000
66666666070000000000007066666666666666607700000000000007066666660000000000000000000000000000000000000000000000000000000000000000
66666666070000000000007066666666666666660700000000000070666666660000000000000000000000000000000000000000000000000000000000000000
66666666607000000000007066666666666666660700000000000070666666660000000000000000000000000000000000000000000000000000000000000000
66666666607000000000007066666666666666666070000000000070666666660000000000000000000000000000000000000000000000000000000000000000
66666666607000000000070666666666666666666070000000000070666666660000000000000000000000000000000000000000000000000000000000000000
66666666607000000000070666666666666666666070000000000706666666660000000000000000000000000000000000000000000000000000000000000000
66666666607000000000070666666666666666666070000000000706666666660000000000000000000000000000000000000000000000000000000000000000
66666666607000000000070666666666666666666070000000000706666666660000000000000000000000000000000000000000000000000000000000000000
66666666607777777777770666666666666666666070000000000706666666660000000000000000000000000000000000000000000000000000000000000000
66666666660000000000006666666666666666666077777777777706666666660000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666666666666600000000000066666666660000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666666666666666666666666666666666660000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666666666666666666666666666666666660000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300002c5502b5502a550295502855027550265502555024550235502255021550205501e5501d5501b5501a550195501855017550165501455012550105500c55008550055500255001550015500155001550
000800020855006540015000f5000f500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0005000004050080500b0500f0501205017050190501d0502205025050270502705027050230001d0001c0001c0001c0000000000000000000000000000000000000000000000000000000000000000000000000
010500002805025050220501f0501a0501705013050100500e0500b0500a050080500805007050070500705007050070500705000000000000000000000000000000000000000000000000000000000000000000
