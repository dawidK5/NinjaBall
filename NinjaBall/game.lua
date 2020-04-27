-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )

local scene = composer.newScene()
local json = require( "json" )
system.activate("multitouch")
-- include Corona's "physics" library
local physics = require( "physics" )
--physics.setDrawMode( "hybrid" )
--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local originX, originY = display.screenOriginX, display.screenOriginY
local isDead = false
--
-- this coordinates table has the folling info for each spike
-- {x-value of left corner, y-value of left corner, rotation(*180degrees), number of spikes on the same height to the right}
--local spikesCoord = { {203, 187, 0, 0}, {187, 490, 1, 1}, {23, 1159, 0, 2} }
--local spikes = {} -- actual spike objects stored here
local objects = {}
local levelMap = "Level1.json"--..composer.getVariable(activeLevel)..".json"
local function compare(a, b)
	return a.gid < b.gid
end
objects = json.decodeFile( system.pathForFile( levelMap, system.ResourceDirectory ) )
table.sort(objects, compare) --sort the table for better register and cache use

-- use gid to know what object to place

local images = {"bumper", "flipper", "shelf", "spring", "spikes"} --order matches 'gid'
local spikesShape = { -70,30, -50,-30, 50,-30, 70,30 }
local options = { {"static", {radius=60, bounce=2}}, {"kinematic", { bounce=2.5, friction=0.3 }},
	{"static", {bounce=0,friction=0.3}}, {"static", { bounce=0.0, friction=0.3 }},
	{"static", { bounce=0, friction=0, isSensor=true } } }




function scene:create( event )

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	if muted then
		audio.setVolume(0)
	end
		-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()

	local background = display.newImageRect( "img/background.jpg", screenW, screenH*0.9 )
	--local i =1
	background.anchorX = 0
	background.anchorY = 0
	sceneGroup:insert( background )

	local ball = display.newImageRect( "img/ninja_ball.png", 60, 60 )
	ball.x = display.contentCenterX
	ball.y = 250
	local initPosX = display.contentCenterX
	local initPosY = display.contentCenterY
	ball.rotation = 0
	ball.objType = "ball"

	physics.addBody( ball, "dynamic", { radius=30, density=2, bounce=0.3 }, {box={ halfWidth=20, halfHeight=10, x=0, y=40}, isSensor=true } )
	ball:setLinearVelocity(0, 0)


	local temp={}
	for i=#objects, 1, -1 do
		temp = { objects[i].gid, objects[i].width, objects[i].height, objects[i].x, objects[i].y, objects[i].rotation }
		if temp[1] ~= 5 then
			objects[i] = display.newImageRect( "img/"..images[temp[1]]..".png", temp[2], temp[3])
		else
			objects[i] = display.newPolygon( temp[4], temp[5], spikesShape)
			objects[i].fill={type="image", filename="img/spikes.png"}
		end
		objects[i].x = temp[4] + (temp[2] / 2) -- x,y offset lua uses different coordinates
		objects[i].y = temp[5] - (temp[3] / 2)-- (temp[2] / 2)
		objects[i].objType = images[ temp[1] ]

		if temp[6] == -90 then
			objects[i].x = temp[4] - (temp[3] / 2)
			objects[i].y = temp[5] - ((temp[2] / 2) + (temp[3] / 2)) + (temp[3] / 2)
		end
		objects[i].rotation = temp[6]
		physics.addBody(objects[i], options[ temp[1] ][1], options[ temp[1] ][2])

		sceneGroup:insert(objects[i])
	end

	local boundaries = {}
	table.insert(boundaries, display.newLine(  originX-15, originY-15, screenW+15, originY-15 ) ) -- top boundary
	table.insert(boundaries, display.newLine(  originX-15, screenH*0.9, screenW+15, screenH*0.9 ) ) -- bottom boundary
	table.insert(boundaries, display.newLine(  originX-15, originY-15, originX-15, screenH*0.9 ) ) -- left boundary
	table.insert(boundaries, display.newLine(  screenW+15, originY-15, screenW+15, screenH*0.9 ) ) -- right boundary
	for i=#boundaries, 1, -1 do
		physics.addBody( boundaries[i] , "static", {bounce=0} )
	end


	print("usable height")
	print(screenH*0.9)



	--places buttons
	local left = display.newImageRect( "img/left.png", screenW/3, screenH/10 )
	left.x = originX
	left.y = originY + screenH*0.9
	left.anchorX = 0
	left.anchorY = 0
	--left:setFillColor( 1 )
	left.objType = "left"

	local right = display.newImageRect( "img/right.png", screenW/3, screenH/10 )
	right.x = originX + screenW/3
	right.y = originY + screenH*0.9
	right.anchorX = 0
	right.anchorY = 0
	--right:setFillColor( .8 )
	right.objType = "right"

	local jump = display.newImageRect( "img/jump.png", screenW/3, screenH/10 )
	jump.x = originX + screenW*2/3
	jump.y = originY + screenH*0.9
	jump.anchorX = 0
	jump.anchorY = 0
	--jump:setFillColor( .6 )

	local midAir = true

	audio.setVolume(0.9)
	local bumperSound = audio.loadSound("sound/bumper.wav")

	sceneGroup:insert( ball )
	sceneGroup:insert( left )
	sceneGroup:insert( right )
	sceneGroup:insert( jump )


	--ball.box.objType = "hitbox"
	--ball.isFixedRotation = true
	ball.sensorOverlaps = 0
	physics.start()

	local max, acceleration, leftM, rightM = 360, 120, 0, 0
    local lastEvent = {}
    local function movement ( event )
        local phase = event.phase
        local name = event.target.objType
        if ( phase == lastEvent.phase ) and ( name == lastEvent.target.objType ) then
					return false
				end
		-- cancel same buttons pressed
        if (phase == "began") then
            if "left" == name then
                leftM = -acceleration
            end
            if "right" == name then
                rightM = acceleration
            end
        elseif phase == "ended" or phase=="moved" then
            if ("left" == name )then
							leftM = 0
						end
            if "right" == name then
							rightM = 0
						end
        end
        lastEvent = event
    end
		local function enterFrame()
			-- game loop
			local vx, vy = ball:getLinearVelocity()
			local dx = math.round(leftM + rightM)
			if midAir then
				dx = dx / 2
			end
			if ( dx > -1 and dx < 1) then
        ball:applyForce( -(vx/5) or 0, 0, ball.x, ball.y )
      end
			if ( dx < 0 and vx > -max ) or ( dx > 0 and vx < max ) then--and (not isDead) then
				ball:applyForce( dx or 0, 0, ball.x, ball.y )
			end
		end



	local function restoreBall()
		physics.removeBody(ball)
		physics.addBody( ball, "dynamic", { radius=30, density=2, bounce=0.3}, {box={ halfWidth=20, halfHeight=10, x=0, y=40}, isSensor=true } )
		ball.x = initPosX
		ball.y = initPosY
		ball:setLinearVelocity(0, 0)
		vx=0
		vy=0
		ball.rotation = 0
		ball.angularVelocity=0
		midAir = true
		ball.sensorOverlaps = 0
		physics.start()
		transition.to(ball, {time=1000, alpha=1})
	end

	local function death(self, event)
		if event.other.objType == "ball" and event.otherElement == 1 then
			if event.phase == "began" then
				print("dying")
				isDead=true
				vx=0
				vy=0
				ball.angularVelocity=0
				ball.sensorOverlaps = 0
				transition.to( ball, {time=1500, alpha=0})
				physics.pause()
				timer.performWithDelay(1500, restoreBall)
			end
		end
	end

	local ind = 1
	while ( ind <= #objects) do --c is object count
		if (objects[ind].objType=="spikes") then
			objects[ind].collision = death
			objects[ind]:addEventListener( "collision" )
		end
		ind=ind+1
	end
	local cirBreaker = 0

	local function jumpAction( event )
		if ( event.phase == "began" and ball.sensorOverlaps > 0 ) then
			midAir = true
			local vx, vy = ball:getLinearVelocity()
			-- local cirBreaker = 0
			ball:setLinearVelocity( vx, vy )
			ball:applyLinearImpulse( nil, -50, ball.x, ball.y )
		end
	end

	local function sensorCollide( self, event )
		--Confirm that the colliding elements are the foot sensor and a shelf object
		if ( event.selfElement == 2 and event.other.objType ~= "flipper") then
			-- Foot sensor has entered (overlapped) a shelf object
			if ( event.phase == "began" ) then
				midAir = false
				self.sensorOverlaps = self.sensorOverlaps + 1
			-- Foot sensor has exited a shelf object
			elseif ( event.phase == "ended" ) then
				self.sensorOverlaps = self.sensorOverlaps - 1
				midAir = true
			end
		elseif ( event.selfElement == 1 and event.other.objType == "bumper") then
			if ( event.phase == "began" ) then
				audio.play(bumperSound)
			end
		elseif  (event.selfElement == 2 and event.other.objType == "flipper") then
            if ( event.phase == "began" ) then
								self.sensorOverlaps = self.sensorOverlaps + 1
                transition.to( event.other, { rotation=-45, time=100, transition=easing.inOutCubic } )
            elseif ( event.phase == "ended" ) then
                transition.to( event.other, { rotation=45, time=100, transition=easing.inOutCubic } )
								self.sensorOverlaps = self.sensorOverlaps - 1
            end
		elseif  (event.selfElement == 2 and event.other.objType == "spring") then
			if ( event.phase == "began" ) then
				ball:setLinearVelocity( vx, vy )
				physics.removeBody(boundaries[1])
				ball:applyLinearImpulse( nil, -200, ball.x, ball.y )
				display.remove( boundaries[1] )
				boundaries[1] = nil
			elseif ( event.phase == "ended" ) then
			end
    end
	end
	-- Associate collision handler function with character
	ball.collision = sensorCollide


	ball:addEventListener( "collision" )
	jump:addEventListener( "touch", jumpAction )
	left:addEventListener( "touch", movement )
	right:addEventListener( "touch", movement )
	Runtime:addEventListener( "enterFrame", enterFrame )

end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then

		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.

		physics.start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view

	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end

end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	objects:removeSelf()
	objects=nil
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
