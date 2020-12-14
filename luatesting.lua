-- simple squaring function
function sqrt(x)
    return x * x
end

-- simple max function
function max(x, y)
    if x > y then
        return x
    end
    return y
end

local position = {0, -5, 0}
local startingPosition = {1, 1, 0} -- the starting position of the mining turtle

function returnFromMiningTunnel(corridor)
	while position[2] ~= startingPosition[2] do
		printArray(position)
		position[2] = position[2] + 1
	end
end

function makeStaircase()
    	local X = 4
    	local Y = 4
    	local x = 0
	    local y = 0
	    local dx = 0
	    local dy = -1
        for j = 0, sqrt(max(X, Y)) do
            if (-X/2 < x and x <= X/2) and (-Y/2 < y and y <= Y/2) then
            	print("forward")
            end
            if x == y or (x < 0 and x == -y) or (x > 0 and x == 1-y) then
            	print("turn left")
                tempX = dx
                dx = -dy
                dy = tempX
            end
            x = x + dx
            y = y + dy
        end
end


local position = {3, 2, 3}  -- x, y, z
local leftPosition = {0, 0, 0}  -- x, y, z position turtle left when going back to origin or chunk reloads
-- dont need a area-matrix since I can simply go back to the origin by reducing my position to {0, 0, 0} and saving the starting position beforehand
 function backToOrigin(origin)
 	if equal(origin, leftPosition) then 
 		leftPosition = position
 		printArray(leftPosition)
 	end
 	local x, y, z = position[1], position[2], position[3] 
 	print(x, y, z)
 	for i = 1, z do position[3] = position[3] - 1 end
 	print(position[1], position[2], position[3] )
 	for i = 1, y do position[2] = position[2] - 1 end
	print(position[1], position[2], position[3] )
 	for i = 1, x do position[1] = position[1] - 1 end
 	print(position[1], position[2], position[3] )
 end

local orientation = {0, -1}  -- x, y between -1 and 1

-- changes the position value according to the orientation after the turtle moved forward
function changePositionValue()
 	if orientation[1] ~= 0 then 
 		position[1] = position[1] + orientation[1]
 	else
 		position[2] = position[2] + orientation[2]
 	end
 	printArray(position)
end

 function equal(arr1, arr2)
 	local isEqual = true
 	if #arr1 == #arr2 then
 		for i = 1, #arr1 do
 			if arr1[i] ~= arr2[i] then
 				return false
 			end
 		end
 		return true
 	else
 		return false
 	end
 end

 function printArray(arr)
	text = "{"
	for i = 1, #arr do 
		if i == 1 then text = text..tostring(arr[i])
		else
			text = text..", "..tostring(arr[i])
		end
	end
	text = text.."}"
	print(text) 
 end


local orientation = {0,1}

function changeOrientationTurnLeft()
	if orientation[1] ~= 0 then
		if orientation[1] == 1 then
			orientation[1], orientation[2] = orientation[0] - 1, orientation[2] - 1
		else
			orientation[1], orientation[2] = orientation[0] + 1, orientation[2] + 1
		end
	else
		if orientation[2] == 1 then
			orientation[1], orientation[2] = orientation[1] + 1, orientation[2] - 1
		else
			orientation[1], orientation[2] = orientation[1] - 1, orientation[2] + 1
		end
	end
end

-- function to absolute a value
function abs(value)
	if value < 0 then
		return value * -1
	else
		return value
	end
end

function matrix2D(dimensions)
	
end

-- checks if a value is contained in the array
 function contains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

-- subtract array from another array
function subtractArrays(arr1, arr2)
	local result = {0, 0, 0}
	for i = 1, #arr1 do
		result[i] = arr1[i] - arr2[i]
	end
	return result
end

a = {0, 1}
b = {0, -1}

print(equal(a, b))
