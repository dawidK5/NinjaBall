-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local widget = require("widget")
local scene = composer.newScene()
local json = require( "json" )
system.activate("multitouch")	-- our game supports multitouch
local physics = require( "physics" )
physics.setDrawMode( "hybrid" )
--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY
local originX, originY = display.screenOriginX, display.screenOriginY
local firstSpawnPos = {{screenW/5, screenH*0.1},{screenW/5, screenH*0.1},{screenW/5, screenH*0.08},{screenW/5, screenH*0.1}}
--local firstSpawnPos = { {screenW/5, screenH*0.1}, {screenW/15, screenH*0.81}, {screenW/15, screenH*0.81}, {screenW*0.75, screenH*0.78} }
local secondSpawnPos = { {halfW, screenH*0.4}, {halfW, screenH*0.43}, {halfW, screenH*0.46}, {halfW, screenH/5} }
local pauseParams = { isModal = true, effect = "fade", time = 500, params = {sampleVar = "my sample variable"}}
local isDead = false
local muted = composer.getVariable( "muted" )
local levelTransitionSound = audio.loadSound("sound/leveltrans.wav")
local ball, left, right, jump, movement, jumpAction
local vx, vy
local isReloading = false

--local isJumping
--
-- this coordinates table has the folling info for each spike
-- {x-value of left corner, y-value of left corner, rotation(*180degrees), number of spikes on the same height to the right}
--local spikesCoord = { {203, 187, 0, 0}, {187, 490, 1, 1}, {23, 1159, 0, 2} }
--local spikes = {} -- actual spike objects stored here

local objects = {}
local levelNum = tonumber( composer.getVariable( "levelToLoad" ) )
local levelMap = "levels/Level"..levelNum..".json"
local function compare(a, b)
	return a.gid < b.gid
end
objects = json.decodeFile( system.pathForFile( levelMap, system.ResourceDirectory ) )
table.sort(objects, compare) --sort the table

-- use gid to know what object to place

local images = {"bumper", "flipper", "shelf", "spring", "spikes"} --order matches 'gid'
local spikesShape = { -70,30, -50,-30, 50,-30, 70,30 }
local myoptions = { {"static", {radius=60, bounce=2}}, {"kinematic", { bounce=2, friction=0.3 }},
	{"static", {bounce=0,friction=0.3}}, {"static", { bounce=0.0, friction=0.3 }},
	{"static", { bounce=0, friction=0, isSensor=true } } }
myoptions[1][2].radius = (objects[1].height)/2

function scene:create( event )

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view
		-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.

	--composer.removeScene( "game" )
	physics.start()
	physics.pause()

	local background = display.newImageRect( "img/background.jpg", screenW, screenH*0.9 )
	--local i =1
	background.anchorX = 0
	background.anchorY = 0
	sceneGroup:insert( background )
	print(levelNum)
	ball = display.newImageRect( "img/ninja_ball.png", 60, 60 )
	ball.x = firstSpawnPos[levelNum][1]
	ball.y = firstSpawnPos[levelNum][2]
	ball.rotation = 0
	ball.objType = "ball"
	local function showPauseOverlay()
		physics.pause()
		audio.pause()

		composer.showOverlay( "pause", pauseParams )
	end


	physics.addBody( ball, "dynamic", { radius=30, density=2, bounce=0.3 }, {box={ halfWidth=20, halfHeight=10, x=0, y=40}, isSensor=true } )
	ball:setLinearVelocity(0, 0)
	local pauseBtn = widget.newButton{ defaultFile="img/pause.png",
				width = 80,
				height = 160,
				onRelease = showPauseOverlay }
	pauseBtn.x = screenW*0.9
	pauseBtn.y = screenH*0.05

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
		physics.addBody(objects[i], myoptions[ temp[1] ][1], myoptions[ temp[1] ][2])

		sceneGroup:insert(objects[i])
	end

	local boundaries = {}
	table.insert(boundaries, display.newLine(  originX-15, originY-45, screenW+15, originY-45 ) ) -- top boundary
	table.insert(boundaries, display.newLine(  originX-15, screenH*0.9, screenW+15, screenH*0.9 ) ) -- bottom boundary
	table.insert(boundaries, display.newLine(  originX-15, originY-45, originX-15, screenH*0.9 ) ) -- left boundary
	table.insert(boundaries, display.newLine(  screenW+15, originY-45, screenW+15, screenH*0.9 ) ) -- right boundary
	for i=#boundaries, 1, -1 do
		physics.addBody( boundaries[i] , "static", {bounce=0} )
	end


	print("usable height")
	print(screenH*0.9)



	--places buttons
	left = display.newImageRect( "img/left.png", screenW/3, screenH/10 )
	left.x = originX
	left.y = originY + screenH*0.9
	left.anchorX = 0
	left.anchorY = 0
	left.objType = "left"
	print(left.objType)

	right = display.newImageRect( "img/right.png", screenW/3, screenH/10 )
	right.x = originX + screenW/3
	right.y = originY + screenH*0.9
	right.anchorX = 0
	right.anchorY = 0
	right.objType = "right"

	jump = display.newImageRect( "img/jump.png", screenW/3, screenH/10 )
	jump.x = originX + screenW*2/3
	jump.y = originY + screenH*0.9
	jump.anchorX = 0
	jump.anchorY = 0
	jump.objType = "jump"
	local midAir = true


	local bumperSound = audio.loadSound("sound/bumper.wav")
	sceneGroup:insert( pauseBtn )
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
				local tx = event.x
				print(tx)
				print(screenW/3)
        if ( phase == lastEvent.phase ) and ( name == lastEvent.target.objType ) then
					return false
				end -- cancel same buttons pressed
        if (phase == "began") then
					moving = true
            if ("left" == name ) then
                leftM = -acceleration
            end
            if ("right" == name ) then
                rightM = acceleration
            end
				elseif phase=="moved" then
					if ("left" == name and (event.x > (screenW/3) or event.y < (screenH*0.9)) ) then
						leftM = 0
						--print("left to 0")
					end
					if ("right" == name and ( event.x < screenW/3 or event.x > screenW*0.6666 or event.y < screenH*0.9) ) then
						rightM = 0
					end
        elseif phase == "ended" then
            if ("left" == name) then
							leftM = 0
						end
            if ("right" == name) then
							rightM = 0
						end
        end
				print(phase)
				print(leftM)
				print(rightM)
        lastEvent = event
    end
		local function enterFrame()
			-- game loop
			if isReloading then
				Runtime:removeEventListener("enterFrame", enterFrame)
			else
				vx, vy = ball:getLinearVelocity()
				local dx = math.round(leftM + rightM)
				if midAir then
					dx = dx / 1
				end
				if ( dx < 0 and vx > -max ) or ( dx > 0 and vx < max ) then
						ball:applyForce( dx or 0, 0, ball.x, ball.y )
				end
				if ( dx > -0.5 and dx < 0.5) then
					--print("slow")
					ball:applyForce( -(vx/5) or 0, 0, ball.x, ball.y )
				end
			end
		end



	local function restoreBall()
		physics.removeBody(ball)
		physics.addBody( ball, "dynamic", { radius=30, density=2, bounce=0.3}, {box={ halfWidth=20, halfHeight=10, x=0, y=40}, isSensor=true } )
		if ball.y < screenH/2 then
			if levelNum==4 and ball.y > screenH/5 then
				ball.x = firstSpawnPos[levelNum][1]
				ball.y = firstSpawnPos[levelNum][2]
			else
				ball.x = secondSpawnPos[levelNum][1]
				ball.y = secondSpawnPos[levelNum][2]
			end
		else
			ball.x = firstSpawnPos[levelNum][1]
			ball.y = firstSpawnPos[levelNum][2]
		end
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

	function jumpAction( event )
		midAir = true
		local vx, vy = ball:getLinearVelocity()
		if ( event.phase == "began" and ball.sensorOverlaps > 0 and vy > -50) then
			-- local cirBreaker = 0
			ball:setLinearVelocity( vx, vy )
			ball:applyLinearImpulse( nil, -60, ball.x, ball.y )
		end
	end

	function sensorCollide( self, event )
		--Confirm that the colliding elements are the foot sensor and a shelf object
		if ( event.selfElement == 2 and event.other.objType == "shelf" ) then
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
                transition.to( event.other, { rotation=-45, time=300, transition=easing.inOutCubic } )
            elseif ( event.phase == "ended" ) then
                transition.to( event.other, { rotation=45, time=300, transition=easing.inOutCubic } )
								self.sensorOverlaps = self.sensorOverlaps - 1
            end
		elseif  (event.selfElement == 2 and event.other.objType == "spring") then

			if ( event.phase == "began" and (isReloading==false)) then
				audio.play(levelTransitionSound)
				ball:setLinearVelocity( vx, vy )
				--physics.removeBody(boundaries[1])
				ball:applyLinearImpulse( nil, -150, ball.x, ball.y )

				display.remove( boundaries[1] )
				boundaries[1] = nil
				levelNum = levelNum+1
				composer.setVariable( "levelToLoad", levelNum )
				isReloading = true
				composer.gotoScene( "callback" )
				--physics.stop()
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
function scene:resumeGame()
	muted = composer.getVariable( "muted" )
	if not muted then
		audio.resume()
	end
	physics.start()
end

function scene:hide( event )
	local sceneGroup = self.view

	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)

	--	physics.pause()
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
	Runtime:removeEventListener("enterFrame", enterFrame)

	local function destRest()
		ball.collision=nil
		--jump:removeEventListener( "touch", jumpAction )
		--left:removeEventListener( "touch", movement )
		--right:removeEventListener( "touch", movement )
		ind = 1
		while ( ind <= #objects) do --c is object count
			if (objects[ind].objType=="spikes") then
				objects[ind]:removeEventListener( "collision", death )
			end
			ind=ind+1
		end
	  physics.pause()
		print("loading level".. tostring( levelNum ))
		for a=#objects, 1, -1 do
			physics.removeBody( objects[a] )
			objects[a]:removeSelf()
			objects[a]=nil
		end
		physics.removeBody(ball)
		objects=nil
		ball=nil
		if pauseBtn then
			pauseBtn:removeSelf()	-- widgets must be manually removed
			pauseBtn = nil
		end

		package.loaded[physics] = nil
		physics = nil
end
timer.performWithDelay( 400, destRest() )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
--scene:addEventListener( "resumeGame", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
