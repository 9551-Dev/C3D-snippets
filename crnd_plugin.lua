return function()
    local crnd = plugin.new("c3d-rendering-plugin")

    local bus = crnd:get_bus()

    bus.autorender           = false
    bus.graphics.auto_resize = false

    local plugin_bus = crnd:get_plugin_bus()
    plugin_bus.output_data = {}

    local current_frame = 0
    function crnd.register_threads()
        local thread_registry = c3d.registry.get_thread_registry()

        thread_registry:set_entry(c3d.registry.entry("render-thread"),function()
            while not plugin_bus.render_frames or not (plugin_bus.render_frames <= current_frame) do
                current_frame = current_frame + 1

                if plugin_bus.render_frames then
                    c3d.generate_frame()
                end
            end

            local data  = plugin_bus.output_data
            data.width  = plugin_bus.dimensions[1]
            data.height = plugin_bus.dimensions[2]

            local file = fs.open(plugin_bus.output_file,"w")
            file.write(textutils.serialize(data))
            file.close()

            c3d.event.quit()
        end)
    end

    function crnd.register_modules()
        local module_registry = c3d.registry.get_module_registry()
        local crnd_module     = module_registry:new_entry("crnd")

        crnd_module:set_entry(c3d.registry.entry("start"),function(w,h,frames_to_render,output)
            c3d.graphics.set_size(w,h)

            plugin_bus.dimensions = {w,h}
            plugin_bus.render_frames = frames_to_render
            plugin_bus.output_file   = output
        end)
    end

    local frm = 0

    function crnd.frame_finished(data,w,h)
        local frame = {}
        for y=1,h do
            local line_data = data[y]
            local line = {}
            for x=1,w do line[x] = ("%x"):format(math.log(line_data[x],2)) end
            frame[y] = table.concat(line,"")
        end
        frm = frm + 1
        plugin_bus.output_data[frm] = frame
    end
    
    crnd:override("screen_render",function(t)
        t.setCursorPos(1,1)
        t.write("Render in progress.. frame: "..current_frame.."/"..plugin_bus.render_frames)
        t.setCursorPos(1,2)
        t.write("- Powered by C3D and CRND")
    end)
    crnd:override("quit",function()
        term.clear()
        term.setCursorPos(1,1)
        term.write("Render finished in "..bus.sys.run_time.."ms")
        term.setCursorPos(1,2)
    end)

    crnd:register()
end
