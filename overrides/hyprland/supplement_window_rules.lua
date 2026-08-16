hl.window_rule({
	name = "keepass-unlock",
	match = {
		class = "^(org.keepassxc.KeePassXC)$",
		title = "Unlock Database - KeePassXC",
	},
	float = true,
})

hl.window_rule({
	name = "prism-launcher-loader",
	match = {
		class = "^(org.prismlauncher.PrismLauncher)$",
	},
	size = {
		1400,
		800,
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
