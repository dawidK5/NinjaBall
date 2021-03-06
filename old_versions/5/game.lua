-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
system.activate("multitouch")
-- include Corona's "physics" library
local physics = require( "physics" )
-- physics.setDrawMode( "hybrid" )
local tiled = require( "com.ponywolf.ponytiled" )
local json = require( "json" )
--------------------------------------------
physics.start()
-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local originX, originY = display.screenOriginX, display.screenOriginY


local function printTable( t )

    local printTable_cache = {}

    local function sub_printTable( t, indent )

        if ( printTable_cache[tostring(t)] ) then
            print( indent .. "*" .. tostring(t) )
        else
            printTable_cache[tostring(t)] = true
            if ( type( t ) == "table" ) then
                for pos,val in pairs( t ) do
                    if ( type(val) == "table" ) then
                        print( indent .. "[" .. pos .. "] => " .. tostring( t ).. " {" )
                        sub_printTable( val, indent .. string.rep( " ", string.len(pos)+8 ) )
                        print( indent .. string.rep( " ", string.len(pos)+6 ) .. "}" )
                    elseif ( type(val) == "string" ) then
                        print( indent .. "[" .. pos .. '] => "' .. val .. '"' )
                    else
                        print( indent .. "[" .. pos .. "] => " .. tostring(val) )
                    end
                end
            else
                print( indent..tostring(t) )
            end
        end
    end

    if ( type(t) == "table" ) then
        print( tostring(t) .. " {" )
        sub_printTable( t, "  " )
        print( "}" )
    else
        sub_printTable( t, "  " )
    end
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view
	if muted then
		audio.setVolume(0)
	end
	audio.setVolume(0)
		-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.

	physics.pause()
	local levelData = json.decodeFile( system.pathForFile( "Level_One.json", system.ResourceDirectory ) )
	local lvl = tiled.new( levelData, "img" )
	lvl.x, lvl.y = display.screenOriginX, display.screenOriginY
	local background = lvl:findLayer( "background" )
	local gameLayer = lvl:findLayer( "gamelayer")
	print(background)
	background.anchorX = 0
	background.anchorY = 0


	--background:setFillColor( .5 )

	local boundaries = {}

	table.insert(boundaries, display.newLine(  originX-15, originY-15, screenW+15, originY-15 ) ) -- top boundary
	table.insert(boundaries, display.newLine(  originX-15, screenH*0.9, screenW+15, screenH*0.9 ) ) -- bottom boundary
	table.insert(boundaries, display.newLine(  originX-15, originY-15, originX-15, screenH*0.9 ) ) -- left boundary
	table.insert(boundaries, display.newLine(  screenW+15, originY-15, screenW+15, screenH*0.9 ) ) -- right boundary
	for i=#boundaries, 1, -1 do
		physics.addBody( boundaries[i] , "static", {bounce=0} )
	end
	-- [[make a crate (off-screen), position it, and rotate slightly
	--local crate = display.newImageRect( "crate.png", 90, 90 )
	--crate.x, crate.y = 160, -100
	--crate.rotation = 15

	-- add physics to the crate
	--physics.addBody( crate, { density=1.0, friction=0.3, bounce=0.3 } )

	--make ninjaball

	--local ball = display.newImageRect( "protoball.png", 90, 90 )
	--ball.x, ball.y = 160, -100
	--ball.rotation = 0
	local ball = display.newImageRect( "img/ninja_ball.png", 60, 60 )
	ball.x = display.contentCenterX
	ball.y = display.contentCenterY
	local initPosX = display.contentCenterX
	local initPosY = display.contentCenterY
	ball.rotation = 0
	ball.objType = "ball"
	--ball.alpha = 0.8

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

	local midAir = false


	local ground = display.newImageRect( "img/shelf.png", 800, 33)
	ground.x = display.contentCenterX
	ground.y = screenH*0.9 - 16
	ground.objType = "ground"
	physics.addBody( ground, "static" )

	local bumper = lvl:findObject( "bumper" )
	bumper.objType = "bumper"
	audio.setVolume(0.9)
	local bumperSound = audio.loadSound("sound/bumper.wav")
	print(bumper)
	print("---")
	print(lvl:findObject( "spikes" ))
	print(lvl[1])
	printTable(lvl["findObject"])
	local spikes = lvl:findObject( "spikes" )
	print(spikes)
	--spikes.objType = "spikes"

	--spikes.x = 600
	--spikes.y = ground.y-49

	local spikesSensor


	--sceneGroup:insert( background )
	--sceneGroup:insert( ground )
	--sceneGroup:insert( spikes )
	--sceneGroup:insert( bumper )
	lvl:insert( ball )
	sceneGroup:insert( left )
	sceneGroup:insert( right )
	sceneGroup:insert( jump )
	sceneGroup:insert( lvl )


	physics.addBody( bumper, "static", {radius=50, bounce=2} )
	physics.addBody( ball, "dynamic", { radius=30, density=2, bounce=0.3 }, {box={ halfWidth=20, halfHeight=10, x=0, y=40}, isSensor=true } )
	--ball.box.objType = "hitbox"
	--ball.isFixedRotation = true
	ball.sensorOverlaps = 0
	physics.start()
	ball.rotation = 0
	-- temp code

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
        elseif phase == "ended" then
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
		-- print(dx)
		-- print("isdx---")
		-- print(vx)
		-- print("is-vx---")
		if midAir then
			dx = dx / 2
		end
		if ( dx < 0 and vx > -max ) or ( dx > 0 and vx < max ) then
			ball:applyForce( dx or 0, 0, ball.x, ball.y )
		end


	end
	Runtime:addEventListener( "enterFrame", enterFrame )
	--temp code

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
		physics.start()
		transition.to(ball, {time=1000, alpha=1})
	end

	local function death(self, event)

		if event.other.objType == "ball" and event.otherElement == 1 then

			if event.phase == "began" then
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



	--spikes.collision = death
	--spikes:addEventListener( "collision" )

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

		-- Confirm that the colliding elements are the foot sensor and a ground object
		if ( event.selfElement == 2 and event.other.objType == "ground" ) then

			-- Foot sensor has entered (overlapped) a ground object
			if ( event.phase == "began" ) then
				midAir = false
				self.sensorOverlaps = self.sensorOverlaps + 1
			-- Foot sensor has exited a ground object
			elseif ( event.phase == "ended" ) then
				self.sensorOverlaps = self.sensorOverlaps - 1
				midAir = true
			end
		elseif ( event.selfElement == 1 and event.other.objType == "bumper") then
			if ( event.phase == "began" ) then
				audio.play(bumperSound)
			end
		end
	end
	-- Associate collision handler function with character
	ball.collision = sensorCollide
	ball:addEventListener( "collision" )
	jump:addEventListener( "touch", jumpAction )
	left:addEventListener( "touch", movement )
	right:addEventListener( "touch", movement )
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
