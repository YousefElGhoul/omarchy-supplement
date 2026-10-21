hl.workspace_rule({
	workspace = "special:mail",
	on_created_empty = "thunderbird",
})

o.bind("SUPER + M", "Toggle Email", hl.dsp.workspace.toggle_special("mail"))

hl.workspace_rule({
	workspace = "special:ai",
	on_created_empty = "chatgpt",
})

o.bind("SUPER + A", "Toggle AI Chat", hl.dsp.workspace.toggle_special("ai"))
o.bind("SUPER + SHIFT + A", "Move window to AI Workspace", hl.dsp.window.move({ workspace = "special:ai" }))

hl.workspace_rule({
	workspace = "special:scratchpad",
	on_created_empty = "omawrite",
})
