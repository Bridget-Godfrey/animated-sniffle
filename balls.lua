-- balls.lua


BALL_RADIUS = 5
BASE_COLOR = {.2, .2, 1}

ALL_BALLS = {}
WAVE_LOCATION = {0, love.graphics.getHeight(), love.graphics.getWidth(), 0}
WAVE_SEGMENTS = 20
WAVE_LIST = {}
WAVE_SPEED = 40
WAVE_SPREAD = 150
COLOR_INTENSITY = 0.7
SIZE_INTENSITY = 1.8
WAVE_RAMP = 91

WAVE_SPEED2 = 40
WAVE_SPREAD2 = 150
COLOR_INTENSITY2 = 0.7
SIZE_INTENSITY2 = 1.8
WAVE_RAMP2 = 91

function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  local distanceA = math.sqrt ( dx * dx + dy * dy )
  dx = x1- love.graphics.getWidth() - x2
  dy = y1 - y2
  local distanceB = math.sqrt ( dx * dx + dy * dy )
  dy = y1 - love.graphics.getHeight() - y2
  local distanceD = math.sqrt ( dx * dx + dy * dy )
  dy = y1 + love.graphics.getHeight() - y2
  local distanceE = math.sqrt ( dx * dx + dy * dy )

  dx = x1+ love.graphics.getWidth() - x2
  dy = y1 - y2
  local distanceC = math.sqrt ( dx * dx + dy * dy )
  dy = y1 + love.graphics.getHeight()  - y2
  local distanceF = math.sqrt ( dx * dx + dy * dy )
  dy = y1 - love.graphics.getHeight()  - y2
  local distanceG = math.sqrt ( dx * dx + dy * dy )


   dx = x1 - x2
  dy = y1- love.graphics.getHeight() - y2
  local distanceH = math.sqrt ( dx * dx + dy * dy )
   dx = x1 - x2
  dy = y1+ love.graphics.getHeight() - y2
  local distanceI = math.sqrt ( dx * dx + dy * dy )

  return math.min(distanceA, distanceB, distanceC , distanceD, distanceE, distanceF, distanceG, distanceH, distanceI)
end


function newBall (x, y)
	local b = {}
	b.x = x or 0
	b.y = y or 0
	b.size = BALL_RADIUS
	b.color = BASE_COLOR

	b.draw = function ()
		love.graphics.setColor(b.color[1], b.color[2], b.color[3])
		love.graphics.circle("fill", b.x, b.y, b.size, 100)

	end
	b.calcDistance = function ()
		local allWaveDists = {}
		for i =	1, table.getn(WAVE_LIST) do
			local d = (-1 *distance( b.x, b.y, WAVE_LIST[i][1], WAVE_LIST[i][2] ) + WAVE_RAMP)*(1/WAVE_SPREAD )
			local sigmoid = 1/(1+ math.exp(d))
			table.insert (allWaveDists, 1-sigmoid)
		end
		local m = allWaveDists[1]
		for i =	2, table.getn(allWaveDists) do
			if m < allWaveDists[i] then 
				m = allWaveDists[i]
			end
		end


		return m
	end
	b.calcDistance2 = function ()
		local allWaveDists = {}
		for i =	1, table.getn(WAVE_LIST) do
			local d = (-1 *distance( b.x, b.y, WAVE_LIST[i][1], WAVE_LIST[i][2] ) + WAVE_RAMP2)*(1/WAVE_SPREAD2 )
			d = d - WAVE_LIST[i][3]
			local sigmoid = 1/(1+ math.exp(d))
			table.insert (allWaveDists, 1-sigmoid)
		end
		local m = allWaveDists[1]
		for i =	2, table.getn(allWaveDists) do
			if m < allWaveDists[i] then 
				m = allWaveDists[i]
			end
		end


		return m
	end
	b.update = function ()
		local addToSize = b.calcDistance()
		b.color = {math.max(0, 0.2 + addToSize*COLOR_INTENSITY), math.max(0, 0.2 + addToSize*COLOR_INTENSITY), 1}
		-- if addToSize >= 0.45 then
		-- 	b.color = {1, 0, 0}
		-- end
		b.size = 1 + addToSize*SIZE_INTENSITY*BALL_RADIUS 
	end

	b.update2 = function ()
		local addToSize = b.calcDistance2()
		b.color = {math.max(0, 0.2 + addToSize*COLOR_INTENSITY2), math.max(0, 0.2 + addToSize*COLOR_INTENSITY2), 1}
		-- if addToSize >= 0.45 then
		-- 	b.color = {1, 0, 0}
		-- end
		b.size = 1 + addToSize*SIZE_INTENSITY2*BALL_RADIUS 
	end
	return b
end



balls = {}
balls.lst = {}
function createBalls ()
	for j = 1, love.graphics.getHeight()+ BALL_RADIUS*5 , BALL_RADIUS*5 do
		for i = 1, love.graphics.getWidth()+ BALL_RADIUS*5 , BALL_RADIUS*5 do
			table.insert(balls.lst, newBall (i, j))
		end 
	end
end




balls.update = function (dt)
	for i = 1, table.getn(WAVE_LIST) do
		local a = WAVE_LIST[i][1] + dt*WAVE_SPEED
		a = a%love.graphics.getWidth()
		local b = WAVE_LIST[i][2] - dt*WAVE_SPEED
		b = b%love.graphics.getHeight()
		-- local a = xDist * (i/WAVE_SEGMENTS)
		-- local b = yDist * (i/WAVE_SEGMENTS)
		WAVE_LIST[i]=  {a, b}
	end
	
	-- WAVE_LOCATION = {a, b}
	for i = 1, table.getn(balls.lst) do
		balls.lst[i].update()
	end
end

balls.update2 = function (dt)
	for i = 1, table.getn(WAVE_LIST) do
		
		if WAVE_LIST[i][3] <=  0 then
			WAVE_LIST[i][4] = -WAVE_LIST[i][4]
			WAVE_LIST[i][3] = 0
		elseif WAVE_LIST[i][3] <= 10 then
			WAVE_LIST[i][4] = -WAVE_LIST[i][4]
			WAVE_LIST[i][3] = 10
		end

		WAVE_LIST[i][3] = WAVE_LIST[i][3] + WAVE_LIST[i][4]*dt

		-- a = a%love.graphics.getWidth()
		-- local b = WAVE_LIST[i][2] - dt*WAVE_SPEED
		-- b = b%love.graphics.getHeight()
		-- WAVE_LIST[i]=  {a, b}
	end
	
	-- WAVE_LOCATION = {a, b}
	for i = 1, table.getn(balls.lst) do
		balls.lst[i].update2()
	end
end

balls.draw = function ()
	for i = 1, table.getn(balls.lst) do
			balls.lst[i].draw()
		end

end

balls.start = function ()
	createBalls()
	-- WAVE_SEGMENTS = {}
	WAVE_LIST = {} 
	local waveA = {WAVE_LOCATION[1], WAVE_LOCATION[2]}
	local waveB = {WAVE_LOCATION[3], WAVE_LOCATION[4]}
	local xDist = waveA[1] + waveB[1]
	local yDist = waveA[2] + waveB[2]
	for i = 1, WAVE_SEGMENTS do
		local a = xDist * (i/WAVE_SEGMENTS)
		local b = yDist * (i/WAVE_SEGMENTS)
		table.insert(WAVE_LIST, {a, b})
	end
	love.draw = balls.draw
	love.update = function (dt)
		balls.update(dt)
	end
end

balls.start2 = function ()
	createBalls()
	-- WAVE_SEGMENTS = {}
	WAVE_LIST = {{0, love.graphics.getHeight(), 5, WAVE_SPEED2},
				 {0, 0, 5, WAVE_SPEED2},
				 {love.graphics.getWidth(), 0, 5, WAVE_SPEED2},
				 {love.graphics.getWidth(), love.graphics.getHeight(), 5, WAVE_SPEED2}} 
	
	love.draw = balls.draw
	love.update = function (dt)
		balls.update2(dt)
	end
end


love.keypressed = function(k)
	if k == "=" then
		if (love.keyboard.isDown("lshift")) then
			WAVE_SPREAD = WAVE_SPREAD + 2
		else
			WAVE_RAMP = WAVE_RAMP + 1
		end
	end
	if k == "-" then
		if (love.keyboard.isDown("lshift")) then
			WAVE_SPREAD = WAVE_SPREAD - 2
		else
			WAVE_RAMP = WAVE_RAMP - 1
		end

	end
	if k == "q" then print(WAVE_RAMP, WAVE_SPREAD) end

end