-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require( "physics" )
--physics.setDrawMode( "hybrid" )
--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()


	local background = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH )
	background.anchorX = 0 
	background.anchorY = 0
	background:setFillColor( .5 )
	
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
	local ball = display.newImageRect( "ninja_ball.png", 90, 90 )
	ball.x = display.contentCenterX
	ball.y = display.contentCenterY
	ball.rotation = 0
	--ball.alpha = 0.8
	
	--places buttons
	local left = display.newRect(display.screenOriginX, display.screenOriginY + screenH*0.9, screenW/3, screenH/10 )
	left.anchorX = 0 
	left.anchorY = 0
	left:setFillColor( 1 )
	
	local right = display.newRect(display.screenOriginX + screenW/3, display.screenOriginY + screenH*0.9, screenW/3, screenH/10 )
	right.anchorX = 0 
	right.anchorY = 0
	right:setFillColor( .9 )
	
	local jump = display.newRect(display.screenOriginX + screenW*2/3, display.screenOriginY + screenH*0.9, screenW/3, screenH/10 )
	jump.anchorX = 0 
	jump.anchorY = 0
	jump:setFillColor( .8 )
	
	
	
	local ground = display.newImageRect( "button.png", 800, 50)
	ground.x = display.contentCenterX
	ground.y = display.contentHeight-250
	ground.objType = "ground"
	physics.addBody( ground, "static", { bounce=0.2, friction=0.3 } )
	
	
	
	sceneGroup:insert( background )
	sceneGroup:insert( ground )
	sceneGroup:insert( ball )
	sceneGroup:insert( left )
	sceneGroup:insert( right )
	sceneGroup:insert( jump )
	-- add physics to the crate
	physics.addBody( ball, "dynamic", { radius=45, density=1.0, bounce=0.5}, {box={ halfWidth=30, halfHeight=10, x=0, y=60 }, isSensor=true } )
	ball.isFixedRotation = true
	ball.sensorOverlaps = 0
	physics.start()
	ball.rotation = 0
	
	local cirBreaker = 0
	
	local function jumpAction( event )
		
		if ( event.phase == "began" and ball.sensorOverlaps > 0 ) then
			-- Jump procedure here
			local vx, vy = ball:getLinearVelocity()
			ball:setLinearVelocity( vx, vy )
			ball:applyLinearImpulse( nil, -175, ball.x, ball.y )
		end
	end
	
	local count = 0
	local function rotateLeft()
		if (cirBreaker == 0) then
			count = count+1
			ball:applyLinearImpulse( -2, nil, ball.x, ball.y )
			transition.to( ball, { rotation=-360, time=2000, transition=easing.inOutCubic})
			print("done " .. count .. " times")
		else
			count = 0
		end
	end
	
	-- 1 means break the repeater loop
	local repeater		
	local function leftAction( eventt )	
		if ( eventt.phase == "began" ) then
			cirBreaker = 0
			local vx, vy = ball:getLinearVelocity()
			ball:setLinearVelocity( vx, vy )
			ball:applyAngularImpulse( -50 )
			if ( eventt.phase == "began" or eventt.phase == "moved" ) then
				repeater = timer.performWithDelay(200, rotateLeft, 0)
			end
					
		elseif ( eventt.phase == "ended" ) then
			cirBreaker = 1
			--ball.angularVelocity = 0
			--ball:setLinearVelocity(vx, vy)
			
		end
	end
	
	
	local function rightAction( event )
		if ( event.phase == "began" ) then
			local vx, vy = ball:getLinearVelocity()
			print(vx)
			--tempRot = ball.rotation
			ball:setLinearVelocity( vx+5, vy )
			ball:applyAngularImpulse( 50 )
			--transition.to( ball, { rotation=tempRot +25, time=300, transition=easing.inOutCubic })
			ball:applyLinearImpulse( 20, nil, ball.x, ball.y )
		elseif ( event.phase == "ended" ) then
			--ball:setLinearVelocity(0,0)
		end
	end

	local function sensorCollide( self, event )

		-- Confirm that the colliding elements are the foot sensor and a ground object
		if ( event.selfElement == 2 and event.other.objType == "ground" ) then

			-- Foot sensor has entered (overlapped) a ground object
			if ( event.phase == "began" ) then
				self.sensorOverlaps = self.sensorOverlaps + 1
			-- Foot sensor has exited a ground object
			elseif ( event.phase == "ended" ) then
				self.sensorOverlaps = self.sensorOverlaps - 1
			end
		end
	end
	-- Associate collision handler function with character
	ball.collision = sensorCollide
	ball:addEventListener( "collision" )
	jump:addEventListener( "touch", jumpAction )
	left:addEventListener( "touch", leftAction )
	right:addEventListener( "touch", rightAction )
	local function gameLoop ()
		if (ball.x > screenW or ball.x < 0) then
			ball:setLinearVelocity(0, 0)
			ball.angularVelocity = 0
			ball.rotation = 0
			ball.x = 1
		end
	end
	gameTimer = timer.performWithDelay(300, gameLoop, 0)
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