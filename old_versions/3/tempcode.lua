-- my old code and the character movement 
	local function setVelZero (event)
		local vx, vy = ball:getLinearVelocity()
		vx = math.round(vx)
		if cirBreaker == 0 then
			timer.cancel(event.source)
		end
		if (vx > 3 and cirBreaker == 1) then
			print("work1")
			ball:setLinearVelocity( vx-3, vy )
		
		elseif (vx < -3 and cirBreaker == 1) then
			ball:setLinearVelocity(vx+3, vy)
			print("work2")
		elseif (cirBreaker == 1) then
			print("work3")
			ball:setLinearVelocity(0, vy)
			timer.cancel(event.source)
		end
	end
	
	local function accelerate (eventt)
		local vx, vy = ball:getLinearVelocity()
		vx = math.round(vx)
		if (vx > 1000 or vx < -1000) then
			timer.cancel(eventt.source)
		
		else
			ball:setLinearVelocity(vx*1.8, vy)
			-- timer.cancel(event.source)
		end
		-- if (cirBreaker == 1) then
			-- timer.cancel(event.source)
		-- end
		
		-- ball:setLinearVelocity(vx-10, vy)
		print("acc")
	
		print(vx)
		
	end
	
local function leftAction( event )
		local evPhase = event.phase
		if ( evPhase == "began" ) then
			local vx, vy = ball:getLinearVelocity()
			print(vx)
			cirBreaker = 0
			ball:applyAngularImpulse( -10 )
			ball:applyLinearImpulse( -20, nil, ball.x, ball.y)
			evPhase = event.phase
			print(evPhase)
			timer.performWithDelay(0, accelerate(eventt), 0)
		elseif ( event.phase == "ended" ) then
			cirBreaker = 1
			timer.performWithDelay(100, setVelZero, 0)
			
		end
	end
	
	
	local function rightAction( event )
		if ( event.phase == "began" ) then
			vx, vy = ball:getLinearVelocity()
			print(vx)
			cirBreaker = 0
			ball:applyAngularImpulse( 10 )
			ball:applyLinearImpulse( 20, nil, ball.x, ball.y)
			timer.performWithDelay(100, accelerate(eventt), 0)
		elseif ( event.phase == "ended" ) then
			cirBreaker = 1
			timer.performWithDelay(100, setVelZero, 0)
			
		end
	end


-- Keyboard control
    local max, acceleration, left, right, flip = 375, 5000, 0, 0, 0
    local lastEvent = {}
    local function key( event )
        local phase = event.phase
        local name = event.keyName
        if ( phase == lastEvent.phase ) and ( name == lastEvent.keyName ) then return false end  -- Filter repeating keys
        if phase == "began" then
            if "left" == name or "a" == name then
                left = -acceleration
                flip = -0.133
            end
            if "right" == name or "d" == name then
                right = acceleration
                flip = 0.133
            elseif "space" == name or "buttonA" == name or "button1" == name then
                instance:jump()
            end
            if not ( left == 0 and right == 0 ) and not instance.jumping then
                instance:setSequence( "walk" )
                instance:play()
            end
        elseif phase == "ended" then
            if "left" == name or "a" == name then left = 0 end
            if "right" == name or "d" == name then right = 0 end
            if left == 0 and right == 0 and not instance.jumping then
                instance:setSequence("idle")
            end
        end
        lastEvent = event
    end
	local function enterFrame()
		-- Do this every frame
		local vx, vy = ball:getLinearVelocity()
		local dx = left + right
		if instance.jumping then dx = dx / 4 end
		if ( dx < 0 and vx > -max ) or ( dx > 0 and vx < max ) then
			instance:applyForce( dx or 0, 0, instance.x, instance.y )
		end
		-- Turn around
		
	end
	
    function instance:jump()
        if not self.jumping then
            self:applyLinearImpulse( 0, -550 )
            instance:setSequence( "jump" )
            self.jumping = true
        end
    end