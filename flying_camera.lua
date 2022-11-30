local function get_look_vector(yaw,pitch)
    return c3d.vector.new(
        math.sin(yaw)*math.cos(pitch),
        math.sin(pitch),
        math.cos(yaw)*math.cos(pitch)
    ):normalize()
end

local function get_move_vector(yaw)
    return c3d.vector.new(
        math.sin(yaw),
        0,
        math.cos(yaw)
    ):normalize()
end

function c3d.postrender(term)
    term.setCursorPos(1,1)
    term.write("FPS: "..c3d.timer.getFPS())
end

local cam = c3d.vector.new(0,0,2)
local pitch,yaw = 0,0
local pitch_lim = {-89,89}
local no_height_vec = c3d.vector.new(1,0,1)

function c3d.update(dt)
    local sens_vector   = c3d.vector.new(10*dt,10*dt,10*dt)

    if c3d.keyboard.is_down("left") then yaw = yaw - 100*dt end
    if c3d.keyboard.is_down("right") then yaw = yaw + 100*dt end
    if c3d.keyboard.is_down("up") then
        local new_pitch = pitch + 100*dt
        if new_pitch < pitch_lim[2] then pitch = new_pitch end
    end
    if c3d.keyboard.is_down("down") then
        local new_pitch = pitch - 100*dt
        if new_pitch > pitch_lim[1] then pitch = new_pitch end
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
