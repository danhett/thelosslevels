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
	debugmode = false
	nextgame = 'games/3-jou.p8'
	line1 = "it's all over the news."
	line2 = "scour the feeds. find anything."
	success = "it says people are missing.\n\n...and injured, and dead."
	failure = "this is huge...\n\ni need more info."
	col1 = 12
	col2 = 13

	b = 0;
	m = 14;
	f = 0;
	dirup = true;

	flashcurrent = 0
	flashrate = 10
	flashstate = false

	fastflashcurrent = 0
	fastflashrate = 3
	fastflashstate = false

	messagetimer = 0
	messagelimit = 100

	taps = 0
	tapsneeded = 70

	losecount = 0
	losemark = 800

	charpos = 0
	randxpos = 0

	playedendsound = false

	shaking = false
	shakecount = 0
	shakelimit = 10

	doflip = true
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
	checkinputs()

	adjusttaps()

	shake()
end

function _draw()
	cls(0)
	drawbase()
	drawgame()
	checktimeout()
	handlefading()
	handlewinloss()
	flash()
	glitch()
end

function drawbase()
	f+=1

	if f == 3 then
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

	rectfill_p(0,0,128,128,b,9,8)
end

function drawgame()
	-- debug
	if debugmode then
		print(taps, 10, 10, 11)
		print(losecount, 30, 10, 11)
	end

	if not showingmessage then
		print("tap!", 20 + rnd(2), 24, 7)
		print("tap!", 60 + rnd(2), 30, 7)
		print("tap!", 90 + rnd(2), 26, 7)
	end

	-- base
	rectfill_p(0,50,128,80,4,col1,col2)

	-- computers
	if rnd(10) < 1 then
		spr(64, 8, 38, 4, 4)
	else
		spr(68, 8, 38, 4, 4)
	end

	if rnd(10) < 1 then
		spr(64, 40, 42, 4, 4)
	else
		spr(68, 40, 42, 4, 4)
	end

	if rnd(10) < 1 then
		spr(64, 90, 35, 4, 4)
	else
		spr(68, 90, 35, 4, 4)
	end

	-- phones
	if rnd(10) < 1 then
		spr(72, 74, 62, 2, 2)
	else
		spr(74, 74, 62, 2, 2)
	end

	if(charpos < randxpos) charpos+=6
	if(charpos > randxpos) charpos-=6

	-- character
	if fastflashstate and not showingmessage then
		sspr(128, 64, 16, 16, charpos, 48, 50, 50, doflip)
	else
		sspr(128, 80, 16, 16, charpos, 48, 50, 50, doflip)
	end
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
	if state == "playing" then
		if (btnp(4)) then
			resettimeout()
			dotap()
			sfx(4)
		elseif (btnp(5)) then
			resettimeout()
			dotap()
			sfx(5)
		end
	end

	if(btn(0)) resettimeout()
	if(btn(1)) resettimeout()
	if(btn(2)) resettimeout()
	if(btn(3)) resettimeout()
end

function adjusttaps()
	if losecount < losemark then
		losecount+=1
	end

	if losecount == losemark and not showingmessage then
		state="fail"
		shaking = true
	end
end

function dotap()
	if state == "playing" then
		taps+=1

		if taps % 3 == 0 and not showingmessage then
			randxpos = rnd(80)
		end

		if randxpos < 30 then
			doflip = true
		else
			doflip = false
		end

		if(taps == tapsneeded) state="success"
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


	fastflashcurrent+=1

	if fastflashcurrent > fastflashrate then
		fastflashstate = true
	else
		fastflashstate = false
	end

	if fastflashcurrent == fastflashrate * 2 then
		fastflashcurrent = 0
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
000000ffff00000000000ffffff00000000000ffff0000000000005555000000000000ffff00000000000ffffff00000000000ffff0000000000005555000000
0000005555000000000000ffff000000000000555500000000000055555000000000005555000000000000ffff00000000000055550000000000005555500000
00000055555000000000005555000000000005555550000000000055555000000000005555500000000000555500000000000055555000000000005555500000
000000555550000000000555555000000000055555500000000000555550000000000555555500000000055555550000000005555555000000000555555f0000
0000005555500000000005555550000000000f5555ff000000000005ff50000000000ff5555ff000000055555555500000000ff5555ff000000005ff555f0000
000000555ff0000000000f5555ff000000000ff555ff0000000000ccffc0000000000ff5555ff0000000ff55555ff00000000ff5555ff000000000ffcccc0000
000000cccffc0000000000ccccff00000000000ccc000000000000c5ccc00000000000ccccc000000000ff55555ff00000000000ccc00000000000cccccc0000
000000ccccccc00000005cccccc00000000005cccc000000000000c5cc000000000000cccccc0000000000ccccc000000000000cccc00000000000cc05cc0000
00000ccc00ccc00000005ccc0cc00000000005ccc0000000000000c50000000000000ccc00cc000000005cc00cc000000000005ccc00000000000ccc05000000
0000ccc000055000000050000cc000000000050cc0000000000000cc0000000000000cc00005500000005c000cc0000000000050cc00000000000cc000000000
00005500000000000000000000550000000000005500000000000005500000000000055000000000000000000055000000000000055000000000005500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000ffff00000000000000000000000000000000000000
00000f55f5500000000000ffff0000000000000000000000000000ffff000000000000ffff00000000000f55f550000000000000000000000000000000000000
00000f75f570000000000f55f5500000000000ffff00000000000f55f550000000000f55f550000000000f75f570000000000000000000000000000000000000
00000ffffff0000000000f75f570000000000f55f550000000000f75f570000000000f75f570000000000ffffff0000000000000000000000000000000000000
000000ffff00000000000ffffff0000000000f75f570000000000ffffff0000000000ffffff00000000000ffff00000000000000000000000000000000000000
0000055555500000000000ffff00000000000ffffff00000000005ffff500000000005ffff500000000005555550000000000000000000000000000000000000
00005555555500000000055555500000000005ffff50000000000555555000000000555555550000000055555555000000000000000000000000000000000000
00055555555550000000555555550000000055555555000000005555555500000005555555555000000555555555500000000000000000000000000000000000
00055555555550000005555555555000000555555555500000055555555550000005555555555000000555555555500000000000000000000000000000000000
000ff555555ff000000555555555500000055555555550000005555555555000000ff555555ff000000ff555555ff00000000000000000000000000000000000
000ffccccccff000000ff555555ff000000ff555555ff000000ffccccccff000000ffccccccff000000ffccccccff00000000000000000000000000000000000
00000ccc0cc00000000ffccccccff000000ffccccccff000000ffccc0ccff00000000ccc0cc0000000000ccc0cc0000000000000000000000000000000000000
00000cc00cc0000000000ccc0cc0000000000ccc0cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000000000000000000000000000000
00000cc00cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000000000000000000000000000000
00000dd000dd000000000dd000dd000000000dd000dd000000000dd000dd000000000dd000dd000000000dd000dd000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000006666666600000000666666660000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000066555555550000006655555555000000000000000000000000000000000000
00006666666666666666666666660000000066666666666666666666666600000065511111155000006551111115500000000000000000000000000000000000
000065555555555555555555555550000000655555555555555555555555500000651a1aa1a1500000651aaa1aa1500000000000000000000000000000000000
00006555555555555555555555555000000065555555555555555555555550000065111111115000006511111111500000000000000000000000000000000000
000065511111111111111111111580000000655111111111111111111115800000651a1aaaa1500000651a1a1aa1500000000000000000000000000000000000
00006551777777777117117777155000000065517777771777717171771550000065111111115000006511111111500000000000000000000000000000000000
000065511111111111111111111550000000655111111111111111111115500000651aaa1aa1500000651a1aaaa1500000000000000000000000000000000000
00006551717177777171777717155000000065517171777771717777771550000065111111115000006511111111500000000000000000000000000000000000
000065511111111111111111111550000000655111111111111111111115500000651aa1a1a1500000651aa1a1a1500000000000000000000000000000000000
00006551777777777777771717155000000065517777777771717717171550000065111111115000006511111111500000000000000000000000000000000000
000065511111111111111111111550000000655111111111111111111115500000651aaa1aa1500000651aa1aaa1500000000000000000000000000000000000
00006551777777771717777777155000000065517177771777777717771550000065111111115000006511111111500000000000000000000000000000000000
00006551111111111111111111155000000065511111111111111111111550000065511111155000006551111115500000000000000000000000000000000000
00006551717177777717177777155000000065517717171171777777171550000005555555555000000555555555500000000000000000000000000000000000
00006551111111111111111111155000000065511111111111111111111550000000555555550000000055555555000000000000000000000000000000000000
00006551777777177177777177155000000065517171777777177771771550000000000000000000000000000000000000000000000000000000000000000000
00006555555555555555555555555000000065555555555555555555555550000000000000000000000000000000000000000000000000000000000000000000
00006555555555555555555555555000000065555555555555555555555550000000000000000000000000000000000000000000000000000000000000000000
00065555555555555555555555555000000655555555555555555555555550000000000000000000000000000000000000000000000000000000000000000000
00065555555555555555555555555000000655555555555555555555555550000000000000000000000000000000000000000000000000000000000000000000
00065557657657657657657657655500000655576576576576576576576555000000000000000000000000000000000000000000000000000000000000000000
00065556656656656656656656655500000655566566566566566566566555000000000000000000000000000000000000000000000000000000000000000000
00065555555555555555555555555500000655555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000
00655765765765765765765765765500006557657657657657657657657655000000000000000000000000000000000000000000000000000000000000000000
00655665665665665665665665665550006556656656656656656656656655500000000000000000000000000000000000000000000000000000000000000000
06555555555555555555555555555550065555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000
06557657657657657657657657657650065576576576576576576576576576500000000000000000000000000000000000000000000000000000000000000000
65556656656656656656656656656655655566566566566566566566566566550000000000000000000000000000000000000000000000000000000000000000
65555555555555555555555555555555655555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
65555555555555555555555555555555655555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
05555555555555555555555555555555055555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ffff00f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000880088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000ff00ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000fff0fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000f6666660f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000880088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000ff00ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000fff0fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000500002805025050220501f0501a0501705013050100500e0500b0500a050080500805007050070500705007050070500705000000000000000000000000000000000000000000000000000000000000000000
00050000075502350037500325003b5003a5003950035500325002c50028500265000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000700000855000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
