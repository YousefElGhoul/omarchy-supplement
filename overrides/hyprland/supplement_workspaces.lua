hl.workspace_rule({
	workspace = "special:mail",
	on_created_empty = "thunderbird",
})

o.bind("SUPER + M", "Toggle Email", hl.dsp.workspace.toggle_special("mail"))

hl.workspace_rule({
	workspace = "special:ai",
	on_created_empty = "claude-desktop",
})

o.bind("SUPER + A", "Toggle AI Chat", hl.dsp.workspace.toggle_special("ai"))
