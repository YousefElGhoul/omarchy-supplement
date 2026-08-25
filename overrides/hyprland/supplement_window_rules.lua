hl.window_rule({
	name = "keepass-unlock",
	match = {
		class = "^(org.keepassxc.KeePassXC)$",
		title = "Unlock Database - KeePassXC",
	},
	float = true,
})

hl.window_rule({
	name = "prism-launcher-main",
	match = {
		class = "^(org.prismlauncher.PrismLauncher)$",
		title = "^(Prism Launcher( \\d+(\\.\\d+)*)?)$",
	},
	float = true,
})

hl.window_rule({
	name = "prism-launcher-popups",
	match = {
		title = "^(.+ - Prism Launcher( \\d+(\\.\\d+)*)?)$",
	},
	float = true,
})

hl.window_rule({
	name = "claude-ai-move",
	match = {
		class = "^(claude-desktop)$",
	},
	workspace = "special:ai",
})

hl.window_rule({
	name = "thunderbird-move",
	match = {
		class = "^(org.mozilla.Thunderbird)$",
	},
	workspace = "special:mail silent",
})

hl.window_rule({
	name = "thunderbird-no-activate",
	match = {
		class = "^(org.mozilla.Thunderbird)$",
	},
	suppress_event = "activatefocus",
})

hl.window_rule({
	name = "omawrite-move",
	match = {
		class = "^(omawrite)$",
	},
	workspace = "special:scratchpad",
})
