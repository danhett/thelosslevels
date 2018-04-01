pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- the loss levels
-- dan hett

function _init()
	b = 0;
	m = 16;
	f = 0;
	dirup = true;

	player = {}
	player.sprite = 0
	player.step = 0

	setupglitches()
	setupfader()
end

function _update()
	updatecube()
	checkinputs()
end

function _draw()
	f+=1

	if f == 5 then
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

	rectfill_p(0,0,128,128,b,0,1)
	drawcube()
	drawtitle()
	glitch()

	if(state == "fading") fadedownscene();
end

function setupglitches()
	angle = 0

	glit = {}
	glit.height=128
	glit.width=128
	glit.t=0 -- glitch timer start
end

function setupfader()
	state = "waiting";
	waittime = 0;
	waittotal = 30;
end

function print_c(str, h)
  print(str, 64 - (#str * 2), h)
end

function updatecube()
	angle -= 1
	if angle > 360 then
	 angle = 0
	end
end

function drawcube()
	--rectfill(0,0,127,127,0)
	linecol = 12
	r = 30
	cx = 66
	cy = 116
	stx = {0,0,0,0}
	sty = {0,0,0,0}
	sbx = {0,0,0,0}
	sby = {0,0,0,0}

	i = 0
	while(i < 4) do
		angleoffset = (angle + (i*90)) % 360
		a = angleoffset/360

		ltx = cx + r * cos(a)
		lty = cy + r * sin(a)
		lty = lty * 0.5

		lbx = cx + r * cos(a)
		lby = cy + r * sin(a)
		lby = (lby * 0.6) + 20

		line(lbx,lby,ltx,lty,linecol)

		-- save coordinates

		stx[i] = ltx
		sty[i] = lty
		sbx[i] = lbx
		sby[i] = lby
		i += 1
	end

 	-- connect faces
	line(stx[0],sty[0],stx[1],sty[1],linecol)
	line(stx[1],sty[1],stx[2],sty[2],linecol)
	line(stx[2],sty[2],stx[3],sty[3],linecol)
	line(stx[3],sty[3],stx[0],sty[0],linecol)

	line(sbx[0],sby[0],sbx[1],sby[1],linecol)
	line(sbx[1],sby[1],sbx[2],sby[2],linecol)
	line(sbx[2],sby[2],sbx[3],sby[3],linecol)
	line(sbx[3],sby[3],sbx[0],sby[0],linecol)

	player.step+=1
	if(player.step%7==0) player.sprite += 1

  if player.sprite > 5 then
   player.sprite = 0
  end

	spr(player.sprite * 2, 58, 74, 2, 2)
end

function drawtitle()
	color(7)

	print("the", 10, 5, 2) --the
	--spr(131, 36,6,8,4) -- l o s s
	spr(64, 10, 14, 2, 2)
	spr(66, 40, 14, 2, 2)
	spr(68, 70, 14, 2, 2)
	spr(68, 100, 14, 2, 2)
	print("levels", 90, 34) -- levels

	color(8)
	print_c("press ❎ to begin.", 120)
end

function checkinputs()
	if btn(5) then startgame() end
end

function startgame()
	if state == "waiting" then
		state = "fading"
	end
end

function fadedownscene()
	if waittime < waittotal then
		 waittime+=1
		 rectfill( 0, 0, 127, 3 * waittime, 0 )
		 rectfill( 127, 127, 0, 127 - (3 * waittime), 0 )
	end

	if(waittime == waittotal) load('games/12-flat.p8')
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000ffff00000000000000000000000000000000000000
00000f55f5500000000000ffff0000000000000000000000000000ffff000000000000ffff00000000000ffffff00000000000ffff0000000000000000000000
00000f75f570000000000f55f5500000000000ffff00000000000f55f550000000000f55f550000000000f55f550000000000f55f5500000000000ffff000000
00000ffffff0000000000f75f570000000000f55f550000000000f75f570000000000f75f570000000000ffffff0000000000f75f570000000000f55f5500000
000000ffff00000000000ffffff0000000000f75f570000000000ffffff0000000000ffffff00000000000ffff00000000000ffffff0000000000f75f5700000
0000055555500000000000ffff00000000000ffffff00000000005ffff500000000005ffff5000000000055555500000000000ffff00000000000ffffff00000
00005555555500000000055555500000000005ffff5000000000055555500000000055555555000000005555555500000000055555500000000005ffff500000
00055555555550000000555555550000000055555555000000005555555500000005555555555000000555555555500000005555555500000000555555550000
00055555555550000005555555555000000555555555500000055555555550000005555555555000000555555555500000055555555550000005555555555000
000ff555555ff000000555555555500000055555555550000005555555555000000ff555555ff000000ff555555ff00000055555555550000005555555555000
000ffccccccff000000ff555555ff000000ff555555ff000000ffccccccff000000ffccccccff000000ffccccccff000000ff555555ff000000ff555555ff000
00000ccc0cc00000000ffccccccff000000ffccccccff000000ffccc0ccff00000000ccc0cc0000000000ccc0cc00000000ffccccccff000000ffccccccff000
00000cc00cc0000000000ccc0cc0000000000ccc0cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000ccc0cc0000000000ccc0cc00000
00000cc00cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000cc00cc0000000000cc00cc00000
00000dd000dd000000000dd000dd000000000dd000dd000000000dd000dd000000000dd000dd000000000dd000dd000000000dd000dd000000000dd000dd0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000007777777777000000777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000007777777777000000777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000007700000077000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000007700000077000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000007700000077000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000007700000077000000777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000007700000077000000777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000007700000077000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000007700000077000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000007700000077000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777770000007777777777000000777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777770000007777777777000000777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000088800000088888000000656000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000000000
08808880080800000880000800000558800000000000000000006556666500000000000000000000000000000000000000000000000000000000000000000000
08000088080888000808880800000508800000000000000000005508888800000000000000000000000000000000000000000000000000000000000000000000
08808888080000800800008800000608800000000000000000005608888888000000000000000000000000000000000000000000000000000000000000000000
00808808080888080808888000000508800000000000000000055088808888800000000666600000000000000000000000000000000000000000000000000000
00880008080808080880000800000588800000000000000000050088800088800000055550000000000000000000000000000000000000000000000000000000
00088880088808880088888800066588800000000000000000006088000008880000550888880000000000000000000000000000000000000000000000000000
00000000000000000000000000000588000000000000000000006088000000880050608888888800000000000000000000000000000000000000000000000000
00000000000000000000000000005888000000000555560000000088000000000006088880088880000000000000000000000000000000000000000000000000
00000000000000000000000000065888000000000666000000006088000000000000088800008880000000000000000000000000000000000000000000000000
00000000000000000000000000050880000000005088888800006088000000000060088000000880000000000000000000000000000000000000000000000000
00000000000000000000000000050880000000005088888880006088800000000060088000000000000000000000000000000000000000000000000000000000
00000000000000000000000000050880000000056888000880006608888000000000088800000000000000000000000000000000000000000000000000000000
00000000000000000000000000060880000000556888000880000668888888800000088880000000000000000000000000000000000000000000000000000000
00000000000000000000000000060880000000560880000888000060088888885000008888880000000000000000000000000000000000000000000000000000
00000000000000000000000000060880000000608880006588000000000008880000000088888880000000000000000000000000000000000000000000000000
00000000000000000000000000060880000000608800065088000000000000880000000000088888000000000000000000000000000000000000000000000000
00000000000000000000000000060880000000008800566888000000000556088000000000050888800000000000000000000000000000000000000000000000
00000000000000000000000000050880000000008805668888000000000056088000000000006088880000000000000000000000000000000000000000000000
00000000000000000000000000050880000000068880688880000000000056088000000000006608880000000000000000000000000000000000000000000000
00000000000000000000000000050880000000008888888800000000000056088000000000005600880000000000000000000000000000000000000000000000
00000000000000000000000000050880000000000888888000000000000550088000000006665008880000000000000000000000000000000000000000000000
00000000000000000000000000050880500000000000000000000000055008888000555555550088880000000000000000000000000000000000000000000000
00000000000000000000000000050880500000000000000000000006550088880000066000888888000000000000000000000000000000000000000000000000
00000000000000000000000000050888650000000000000000000655588888800066660088888880000000000000000000000000000000000000000000000000
00000000000000000000000000000888065000000000000000665558888880000008888888880000000000000000000000000000000000000000000000000000
00000000000000000000000000000088866550000000000006555088888000000008888880000000000000000000000000000000000000000000000000000000
00000000000000000000000000000088888880000000000065508888800000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000008888880000000000000088880000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000888800000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000880000000000000000000000000000000000000000000000000000000000000000000000000000
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
