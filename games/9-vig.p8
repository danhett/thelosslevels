pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- the loss levels
-- dan hett

function _init()
	setupgameparts()
	setuptimeout()
	setupglitches()
	setupfader()
end

function setupgameparts()
	nextgame = 'games/10-arn.p8'
	line1 = "thousands gather at a vigil."
	line2 = "there are songs, tears, noise"
	success = "this is a success message"
	failure = "this is a failure message"
	col1 = 14
	col2 = 15

	flashcurrent = 0
	flashrate = 10
	flashstate = false
end

function setuptimeout()
	tcurrent = 0
	tmax = 60 * 60 -- reset timeout to return to the main menu
end

function setupfader()
	state = "waiting" -- or fadingdown or playing
	waittime = 0
	waittotal = 40
	fadedelay = 0

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
end

function _draw()
	cls(0)
	drawgame()
	checkcollisions()
	checktimeout()
	handlefading()
	flash()
	glitch()
end


function drawgame()
	rectfill_p(0,0,128,128,1,0,1) -- background
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
		if fadedelay < 200 then
			fadedelay+=1
		end

		if fadedelay == 200 then
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
