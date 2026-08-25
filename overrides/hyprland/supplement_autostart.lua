function o.silent_exec_on_start(command)
	hl.on("hyprland.start", function()
		hl.exec_cmd(o.launch(command))
	end)
end

function o.silent_launch_on_start(command)
	o.silent_exec_on_start(o.launch(command))
end

o.silent_launch_on_start("thunderbird")
