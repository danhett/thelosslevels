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

	nextgame = 'games/13-ash.p8'
	line1 = "his home is empty. sold quickly."
	line2 = "pack a life into boxes."
	success = "everything in its place.\n\nthat place isn't here now."
	failure = "objects, not memories.\n\nleave it all here."
	col1 = 8
	col2 = 9

	palt(0,false)
	palt(10,true)

	player = {}
	player.moving = false
	player.frame = 0
	player.framecount = 0
	player.x = 4
	player.y = 50
	player.step = 0
	player.speed = 2
	player.flip = false
	player.sprite = 0
	player.idlesprite = 32
	player.eyesclosedsprite = 34

	flashcurrent = 0
	flashrate = 10
	flashstate = false

	messagetimer = 0
	messagelimit = 100

	c1ON = 66
	c2ON = 74
	c3ON = 64
	c4ON = 72

	-- 1 2 3 2 2 1 1 4
	c1 = c1ON
	c2 = c2ON
	c3 = c3ON
	c4 = c2ON
	c5 = c2ON
	c6 = c1ON
	c7 = c4ON

	c1OFF = 70
	c2OFF = 78
	c3OFF = 68
	c4OFF = 76

	done1 = false
	done2 = false
	done3 = false
	done4 = false
	done5 = false
	done6 = false
	done7 = false

	yoffset = 200

	box1 = {}
	box1.sprite = 128
	box1.x = 6
	box1.y = 106 + yoffset

	box2 = {}
	box2.sprite = 130
	box2.x = 25
	box2.y = 102 + yoffset

	box3 = {}
	box3.sprite = 132
	box3.x = 42
	box3.y = 101 + yoffset

	box4 = {}
	box4.sprite = 160
	box4.x = 63
	box4.y = 106 + yoffset

	box5 = {}
	box5.sprite = 134
	box5.x = 60
	box5.y = 90 + yoffset

	box6 = {}
	box6.sprite = 138
	box6.x = 95
	box6.y = 92 + yoffset

	losecount = 0
	losemark = 600

	shaking = false
	shakecount = 0
	shakelimit = 10

	playedendsound = false
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
	checklossstate()

	shake()
end

function checklossstate()
	if losecount < losemark then
		losecount+=1
	end

	if losecount == losemark and not showingmessage then
		state="fail"
		shaking = true
	end
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
	rectfill_p(0,0,128,30,16,5,7) -- floor
	rectfill_p(0,30,128,128,14,5,1) -- background

	-- rug
	spr(192, 30, 40, 8, 4)

	-- cupboards
	spr(c1, 2, 2, 2, 4)
	spr(c2, 20, 2, 2, 4)
	spr(c3, 38, 2, 2, 4)
	spr(c4, 56, 2, 2, 4)
	spr(c5, 74, 2, 2, 4)
	spr(c6, 92, 2, 2, 4)
	spr(c7, 110, 2, 2, 4)

	-- boxes
	spr(box1.sprite, box1.x, box1.y, 2, 2)
	spr(box2.sprite, box2.x, box2.y, 2, 2)
	spr(box3.sprite, box3.x, box3.y, 2, 2)
	spr(box4.sprite, box4.x, box4.y, 4, 2)
	spr(box5.sprite, box5.x, box5.y, 4, 2)
	spr(box6.sprite, box6.x, box6.y, 4, 4)

	-- player
	animateplayer()

	if player.moving then
		spr(player.sprite * 2, player.x, player.y, 2, 2, player.flip)
	end

	if not player.moving then
		spr(32, player.x, player.y, 2, 2, player.flip)
	end

	-- debug
	if debug then
		--print(testvar, 10, 10, 11)
	end
end

function animateplayer()
	if player.moving then
		player.step+=1

		if(player.step%2==0) player.sprite += 1

	  if player.sprite > 7 then
	   player.sprite = 0
	  end

		resettimeout()
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
		player.x-=player.speed
		player.flip = true;
		player.moving = true
	end

	if btn(1) and player.x < 112 then
		player.x+=player.speed
		player.flip = false
		player.moving = true
	end

	if btn(2) and player.y > 24 then
		player.y-=player.speed
		player.moving = true
	end

	if btn(3) and player.y < 70 then
		player.y+=player.speed
		player.moving = true
	end

	if btnp(4) then
		checkdoors()
	end

	if btnp(5) then
		checkdoors()
	end

	if not player.moving then
    player.sprite = 0
  end
end

function checkdoors()
	-- 1 2 3 2 2 1 4

	if player.y < 30 then
		if player.x >= 0 and player.x < 24 and not done1 then
			c1 = c1OFF
			done1 = true
			box1.y -= yoffset
			checkboxes()
		end
		if player.x >= 16 and player.x < 42 and not done2 then
			c2 = c2OFF
			done2 = true
			box2.y -= yoffset
			checkboxes()
		end
		if player.x >= 34 and player.x < 60 and not done3 then
			c3 = c3OFF
			done3 = true
			box3.y -= yoffset
			checkboxes()
		end
		if player.x >= 52 and player.x < 78 and not done4 then
			c4 = c2OFF
			done4 = true
			box4.y -= yoffset
			checkboxes()
		end
		if player.x >= 74 and player.x < 96 and not done5 then
			c5 = c2OFF
			done5 = true
			box5.y -= yoffset
			checkboxes()
		end
		if player.x >= 88 and player.x < 110 and not done6 then
			c6 = c1OFF
			done6 = true
			box6.y -= yoffset
			checkboxes()
		end
		if player.x >= 106 and player.x < 131 and not done7 then
			c7 = c4OFF
			done7 = true
			checkboxes()
		end
	end
end

function checkboxes()
	-- quicker than faffing around with key repeats, fight me
	if done1 and done2 and done3 and
		 done4 and done5 and done6 and done7 then
		state = 'success'
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
		outline(success,4,100,0,11)
		showingmessage = true

		if playedendsound == false then
			sfx(2)
			playedendsound = true
		end
	end

	if state == "fail" then
		outline(failure,4,100,0,8)
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
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaffffaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaffffaaaaaa
aaaaaaffffaaaaaaaaaaaaaaaaaaaaaaaaaaaaffffaaaaaaaaaaafff55faaaaaaaaaaaffffaaaaaaaaaaaaaaaaaaaaaaaaaaaaffffaaaaaaaaaaaff55f5aaaaa
aaaaafff55faaaaaaaaaaaffffaaaaaaaaaaaffff55aaaaaaaaaafff75faaaaaaaaaafff55faaaaaaaaaaaffffaaaaaaaaaaaff55f5aaaaaaaaaaff75f5aaaaa
aaaaafff75faaaaaaaaaaffff55aaaaaaaaaaffff75aaaaaaaaaaffffffaaaaaaaaaafff75faaaaaaaaaaff55f5aaaaaaaaaaff75f5aaaaaaaaaaffffffaaaaa
aaaaaffffffaaaaaaaaaaffff75aaaaaaaaaaffffffaaaaaaaaaaaffffaaaaaaaaaaaffffffaaaaaaaaaaff75f5aaaaaaaaaaffffffaaaaaaaaaaaffffaaaaaa
aaaaaaffffaaaaaaaaaaaffffffaaaaaaaaaaaffffaaaaaaaaaaaaccccaaaaaaaaaaaaffffaaaaaaaaaaaffffffaaaaaaaaaaaffffaaaaaaaaaaaaccccaaaaaa
aaaaaaccccaaaaaaaaaaaaffffaaaaaaaaaaaaccccaaaaaaaaaaaacccccaaaaaaaaaaaccccaaaaaaaaaaaaffffaaaaaaaaaaaaccccaaaaaaaaaaaacccccaaaaa
aaaaaacccccaaaaaaaaaaaccccaaaaaaaaaaaccccccaaaaaaaaaaacccccaaaaaaaaaaacccccaaaaaaaaaaaccccaaaaaaaaaaaacccccaaaaaaaaaaacccccaaaaa
aaaaaacccccaaaaaaaaaaccccccaaaaaaaaaaccccccaaaaaaaaaaacccccaaaaaaaaaacccccccaaaaaaaaacccccccaaaaaaaaacccccccaaaaaaaaaccccccfaaaa
aaaaaacccccaaaaaaaaaaccccccaaaaaaaaaafccccffaaaaaaaaaaacffcaaaaaaaaaaffccccffaaaaaaacccccccccaaaaaaaaffccccffaaaaaaaacffcccfaaaa
aaaaaacccffaaaaaaaaaafccccffaaaaaaaaaffcccffaaaaaaaaaa66ff6aaaaaaaaaaffccccffaaaaaaaffcccccffaaaaaaaaffccccffaaaaaaaaaff6666aaaa
aaaaaa666ff6aaaaaaaaaa6666ffaaaaaaaaaaa666aaaaaaaaaaaa67666aaaaaaaaaaa66666aaaaaaaaaffcccccffaaaaaaaaaaa666aaaaaaaaaaa666666aaaa
aaaaaa6666666aaaaaaa7666666aaaaaaaaaa76666aaaaaaaaaaaa6766aaaaaaaaaaaa666666aaaaaaaaaa66666aaaaaaaaaaaa6666aaaaaaaaaaa66a766aaaa
aaaaa666aa666aaaaaaa7666a66aaaaaaaaaa7666aaaaaaaaaaaaa67aaaaaaaaaaaaa666aa66aaaaaaaa766aa66aaaaaaaaaaa7666aaaaaaaaaaa666a7aaaaaa
aaaa666aaaa77aaaaaaa7aaaa66aaaaaaaaaa7a66aaaaaaaaaaaaa66aaaaaaaaaaaaa66aaaa77aaaaaaa76aaa66aaaaaaaaaaa7a66aaaaaaaaaaa66aaaaaaaaa
aaaa77aaaaaaaaaaaaaaaaaaaa77aaaaaaaaaaaa77aaaaaaaaaaaaa77aaaaaaaaaaaa77aaaaaaaaaaaaaaaaaaa77aaaaaaaaaaaaa77aaaaaaaaaaa77aaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaffffaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaffffaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaf55f55aaaaaaaaaaaffffaaaaaaaaaaaaaaaaaaaaaaaaaaaaffffaaaaaaaaaaaaffffaaaaaaaaaaaf55f55aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaf75f57aaaaaaaaaaf55f55aaaaaaaaaaaffffaaaaaaaaaaaf55f55aaaaaaaaaaf55f55aaaaaaaaaaf75f57aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaffffffaaaaaaaaaaf75f57aaaaaaaaaaf55f55aaaaaaaaaaf75f57aaaaaaaaaaf75f57aaaaaaaaaaffffffaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaffffaaaaaaaaaaaffffffaaaaaaaaaaf75f57aaaaaaaaaaffffffaaaaaaaaaaffffffaaaaaaaaaaaffffaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaccccccaaaaaaaaaaaffffaaaaaaaaaaaffffffaaaaaaaaaacffffcaaaaaaaaaacffffcaaaaaaaaaaccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaccccccccaaaaaaaaaccccccaaaaaaaaaacffffcaaaaaaaaaaccccccaaaaaaaaaccccccccaaaaaaaaccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaccccccccccaaaaaaaccccccccaaaaaaaaccccccccaaaaaaaaccccccccaaaaaaaccccccccccaaaaaaccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaccccccccccaaaaaaccccccccccaaaaaaccccccccccaaaaaaccccccccccaaaaaaccccccccccaaaaaaccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaffccccccffaaaaaaccccccccccaaaaaaccccccccccaaaaaaccccccccccaaaaaaffccccccffaaaaaaffccccccffaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaff666666ffaaaaaaffccccccffaaaaaaffccccccffaaaaaaff666666ffaaaaaaff666666ffaaaaaaff666666ffaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaa666a66aaaaaaaaff666666ffaaaaaaff666666ffaaaaaaff666a66ffaaaaaaaa666a66aaaaaaaaaa666a66aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaa66aa66aaaaaaaaaa666a66aaaaaaaaaa666a66aaaaaaaaaa66aa66aaaaaaaaaa66aa66aaaaaaaaaa66aa66aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaa66aa66aaaaaaaaaa66aa66aaaaaaaaaa66aa66aaaaaaaaaa66aa66aaaaaaaaaa66aa66aaaaaaaaaa66aa66aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaa77aaa77aaaaaaaaa77aaa77aaaaaaaaa77aaa77aaaaaaaaa77aaa77aaaaaaaaa77aaa77aaaaaaaaa77aaa77aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
222222222222222a222222222222222a222222222222222a222222222222222a555555555555555a555555555555555a555555555555555a555555555555555a
2eeeeeeeeeeeeeee2eeeeeeeeeeeeeee2eeeeeeeeeeeeeee2eeeeeeeeeeeeeee5444444444444444544444444444444454444444444444445444444444444444
2e222222e222222e2e222222e222222e2e2222222222022e2e2222222220222e5400000040000004540000004000000454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eee22e22eee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404440040044404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e0000000000022e2e2222222220222e5404444040444404540444404044440454000000000005545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222202e2e2222222220222e5404444040444404540444404044440454555555555550545455555555505554
2e222222e222222e2e2eeee2e2eeee2e2e2222222222220e2e2222222220222e5400000040000004540444404044440454555555555555045455555555505554
0eeeeeeeeeeeeeee2e2eeee2e2eeee2e2eeeeeeeeeeeeeee2e2222222220222e5444444444444444540444404044440404444444444444445455555555505554
22222222222222202e2eeee2e2eeee2e22222222222222222e2222222220222e5555555555555555540444404044440455555555555555505455555555505554
2eeeeeeeeeeeeeee2e2eee22e22eee2e2eeeeeeeeeeeeeee2e2222222220222e5444444444444444540444004004440454444444444444445455555555505554
2e222222e222222e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5400000040000004540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eee22e22eee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404440040044404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e2222222220222e5404444040444404540444404044440454555555555505545455555555505554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222022e2e0000000000222e5404444040444404540444404044440454555555555505545400000000005554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e0000000000022e2e2222222222022e5404444040444404540444404044440454000000000005545455555555550554
2e2eeee2e2eeee2e2e2eeee2e2eeee2e2e2222222222202e2e2222222222202e5404444040444404540444404044440454555555555550545455555555555054
2e222222e222222e2e222222e222222e2e2222222222220e2e2222222222220e5400000040000004540000004000000454555555555555045455555555555504
aeeeeeeeeeeeeeeeaeeeeeeeeeeeeeeeaeeeeeeeeeeeeeeeaeeeeeeeeeeeeeeea444444444444444a444444444444444a444444444444444a444444444444444
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
9999999999999aaa9999999999999aaa9999999999999aaa99999999999999999999999999999aaa99999999999999999999999999999aaaaaaaaaaaaaaaaaaa
94444454454444aa94454444544444aa94444444444444aa944444444445444544444444444444aa944444444454454445444444444444aaaaaaaaaaaaaaaaaa
94444454454444aa94454444544444aa94444444444444aa944444444445444544444444444444aa944444444454454445444444444444aaaaaaaaaaaaaaaaaa
94444454454444aa94455555544444aa94444444444444aa944444444445444544444444444444aa944444444454454445444444444444aaaaaaaaaaaaaaaaaa
94444455554444aa94444444444444aa94445444555544aa944445555545555544455444444544aa944444444454454445444444444444aaaaaaaaaaaaaaaaaa
94444444444444aa94444455554444aa94455544455444aa944455444544444444444444444444aa944444444454454445444444444444aaaaaaaaaaaaaaaaaa
94444444444444aa94444444444444aa94545454444444aa944444444454444444554444455444aa944444444454454445444444444444aaaaaaaaaaaaaaaaaa
94444444444444aa94444555555544aa94445444455554aa944444444544444444444444444444aa944444444455554445444444444444aaaaaaaaaaaaaaaaaa
94444444444444aa94454544444444aa94445444444444aa944444455444444444555555444444aa944444444444454554444444444444aaaaaaaaaaaaaaaaaa
94444444444444aa94454555555544aa94445445555554aa944444455444444444444444444444aa944444444444455544444444444444aaaaaaaaaaaaaaaaaa
94444555444444aa94454444444444aa94445444444444aa944444445444444444444444445444aa944444444444444444444444444444aaaaaaaaaaaaaaaaaa
94444545444444aa94454555555444aa94445445545544aa944444444444444444444444444444aa944455544444444444444444444444aaaaaaaaaaaaaaaaaa
94444545554444aa94454444444444aa94445444444444aa944444444544444444444444444444aa944454544444444444444444444444aaaaaaaaaaaaaaaaaa
94444545454444aa94444555554544aa94444445555554aa944444444444444444444444444444aa944454544444444444444444444444aaaaaaaaaaaaaaaaaa
a4444545454444aaa4444444444444aaa4444444444444aaa44444444444444444444444444444aa944455544444445555554454555444aaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944444444444444444444444444444aaaaaaaaaaaaaaaaaa
99999999999999999999999999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944455544444444455555555544444aaaaaaaaaaaaaaaaaa
944444444445445445444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944454544444444444444444444444aaaaaaaaaaaaaaaaaa
944444444445445445444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944455544444444444444444555544aaaaaaaaaaaaaaaaaa
944444444445445445444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944454444444444444445555544444aaaaaaaaaaaaaaaaaa
944444444445445445444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944444444444445555444444444444aaaaaaaaaaaaaaaaaa
944444444445445445444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944444444444445445444444444444aaaaaaaaaaaaaaaaaa
944444444445445555444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944444444444445445444444444444aaaaaaaaaaaaaaaaaa
944444444445445444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944444444444445445555444444444aaaaaaaaaaaaaaaaaa
944444444445545444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944444444444555445445544444444aaaaaaaaaaaaaaaaaa
944444444444555444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944444444444545445444544444444aaaaaaaaaaaaaaaaaa
944444444444444444444444444555aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944444444444545445444544444444aaaaaaaaaaaaaaaaaa
944444444444444444444444455544aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944444444444545445444544444444aaaaaaaaaaaaaaaaaa
944444444444444444444444454444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa944444444444545445444544444444aaaaaaaaaaaaaaaaaa
944444444444444444444444445444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa44444444444545445444544444444aaaaaaaaaaaaaaaaaa
a44444444444444444444444445444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a222222222222222222222222222222222222222222222222222222222222222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a8882288222222222222222222222222222222222222222222222222288228aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a82222822222222222222222822222222222222222222222222222222282222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa8222222222222222222222222222222222222222222222222222222222888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aa222222222222222222222222222222222222222222222222822222222228aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a8882282222282222222222222222222222222222222222222222222228222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
222222222222222222222222222222222222822222222222222222222222288aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa8222222222222222222222222222222222222222222222222222222822222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aa88228222222222222222222222222222222222222222222222222222222888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a2222222222222222222222222222222222222222222222222222222222228aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a88822222222222222222222222282222222222222222222222222222282222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a222228222222222222222222222222222222222222222222222222222222888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a88822222222222222222222222222222222222222222222222222222222222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa2222222222222222222222222222222222222222282222222222222822888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a8882282222222222222222222222222222222222222222222222222222228aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aa2222222222222222222222222222222222222222222222222222222222222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa8222222222222222222222222222222222222222222222222222222822888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aa882282222222222222222222222222222222222222222222222222222222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a2222222222222222222222222222222222222222222222222222222222228aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a888228222222228222222222222222222222222222222222222222222822222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa8222222222222222222222222222222222222222222222222222222222888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa222822222222222222222822222222222222222222222222822222282222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaa822882222222222222222222222222222282222222222222222222882288aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a222222222222222222222222222222222222222222222222222222222222222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
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
