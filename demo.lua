local place_positions = {
    {0,0,1},
    {0,0,1},
    {1,0,0},
    {1,0,0},
    {0,-1,0},
    {0,-1,0},
    {0,0,-1},
    {0,0,-1},
    {-1,0,0},
    {-1,0,0},
    {0,1,0},
    {0,1,0},
}

--[[function c3d.screen_render(term,w,h,buffer)
    _G.term.setGraphicsMode(1)
    _G.term.drawPixels(1,1,buffer)
end]]


local blocks = {
    c3d.graphics.load_texture("cct.ppm"),
    c3d.graphics.load_texture("dirt.ppm"),
    c3d.graphics.load_texture("lantern.ppm"),
    c3d.graphics.load_texture("stone.ppm")
}

local names = {"computer","dirt","lantern","stone"}

local res = 1

local place = blocks[1]

local m = peripheral.wrap("left")

function c3d.load()
    --c3d.graphics.autoresize(false)
    --c3d.graphics.set_size(term.getSize(1))
    c3d.graphics.set_bg(colors.cyan)
    c3d.sys.fps_limit(60)
    
    local x,y = 0,0
    local c = c3d.geometry.cube_simple():add_param("texture",blocks[2])

    c.x,c.y,c.z = x,0,y

    function c.new(object,index)
        local offset = place_positions[index]

        local new_x,new_y,new_z = offset[1]+object.x,offset[2]+object.y,offset[3]+object.z

        local new = object:clone():reposition(new_x,new_y,new_z)

        new.x = new_x
        new.y = new_y
        new.z = new_z

        new.texture = blocks[res]
    end

    c:push():set_geometry_shader(function(tri,index)
        if index == 13 then function tri.fs()
            return colors.red
        end end
        return tri
    end):reposition(x,0,y)
end

local function get_look_vector(yaw,pitch)
    return c3d.vector.new(
        -math.sin(yaw)*math.cos(pitch),
        math.sin(pitch),
        -math.cos(yaw)*math.cos(pitch)
    ):normalize()
end

local function get_move_vector(yaw)
    return c3d.vector.new(
        -math.sin(yaw),
        0,
        -math.cos(yaw)
    ):normalize()
end

--[[function c3d.postrender()
    m.clear()
    m.setCursorPos(1,1)
    local i = 0
    for k,v in pairs(c3d.graphics.get_stats()) do
        i = i + 1
        m.setCursorPos(1,i)
        m.write(k..": "..v)
    end
end]]

function c3d.postrender(term)
    term.setCursorPos(1,1)
    term.write("selected block: "..names[res])
end

local cam = c3d.vector.new(0,0,2)
local pitch,yaw = 0,0

local pitch_lim = {-89,89}

local no_height_vec = c3d.vector.new(1,0,1)

local fpslim = 30

function c3d.update(dt)
    --[[local fps = c3d.timer.getFPS()
    local diff = fpslim/fps
    if diff > 1 or diff < 0.7 then
        c3d.graphics.set_pixel_size(diff)
    end]]
    

    local sens_vector   = c3d.vector.new(5*dt,5*dt,5*dt)

    if c3d.keyboard.is_down("left") then yaw = yaw - 100*dt end
    if c3d.keyboard.is_down("right") then yaw = yaw + 100*dt end
    if c3d.keyboard.is_down("up") then
        local new_pitch = pitch - 100*dt
        if new_pitch > pitch_lim[1] then pitch = new_pitch end
    end
    if c3d.keyboard.is_down("down") then
        local new_pitch = pitch + 100*dt
        if new_pitch < pitch_lim[2] then pitch = new_pitch end
    end

    local move_vector = get_move_vector(math.rad(yaw))

    if c3d.keyboard.is_down("w") then cam = cam + move_vector*sens_vector end
    if c3d.keyboard.is_down("s") then cam = cam +- move_vector*sens_vector end
    if c3d.keyboard.is_down("d") then
        local look_vector_right = get_move_vector(math.rad(yaw+90))
        cam = cam + look_vector_right*sens_vector*no_height_vec
    end
    if c3d.keyboard.is_down("a") then
        local look_vector_left = get_move_vector(math.rad(yaw-90))
        cam = cam + look_vector_left*sens_vector*no_height_vec
    end

    if c3d.keyboard.is_down("leftShift") then cam = cam + c3d.vector.new(0,0.5,0)*sens_vector end
    if c3d.keyboard.is_down("leftCtrl") then cam = cam - c3d.vector.new(0,0.5,0)*sens_vector end

    local look_vector = get_look_vector(math.rad(yaw),math.rad(pitch))
    local lp = cam+look_vector

    c3d.camera.lookat(cam[1],cam[2],cam[3],lp[1],lp[2],lp[3])
end

function c3d.mousepressed(x,y,btn)
    --local t = c3d.interact.get_triangle_pixel(x,y)
    local t = c3d.interact.get_triangle(x,y)
    if t and btn == 1 and t.object.new then
        t.object:new(t.index)
    elseif t and btn == 2 and t.object.new then
        t.object:remove()
    end
end

--[[function c3d.quit()
    term.setCursorPos(1,1)
    local i = 0
    for k,v in pairs(c3d.graphics.get_stats()) do
        i = i + 1
        term.setCursorPos(1,i)
        term.write(k..": "..v)
    end
    c3d.exit()
    return true
end]]

--[[function c3d.resize(w,h)
    c3d.graphics.set_size(w,h)
end]]

function c3d.wheelmoved(x,y)
    local new_res = res + y
    if new_res > #blocks then new_res = 1 end
    if res < 1 then new_res = #blocks end
    res = new_res
end
