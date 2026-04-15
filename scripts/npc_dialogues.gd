class_name NpcDialogues
extends RefCounted

static func configure(npc: CharacterBody2D) -> void:
	match npc.npc_name:
		"Merchant":
			npc.greeting_items = "Well now, let me see\nwhat you've got there..."
			npc.greeting_all = "By the Eastern stars!\nYou carry quite the collection!"
			npc.item_reactions = {
				"Bread": "Bread? The baker's work\nis adequate, I suppose.",
				"Gold Coin": "Ah, gold! Now you have\nmy full attention.",
				"Herb": "Herbs from the healer?\nI could sell those overseas!",
				"Sword": "A fine blade! I have\nsheaths of the finest leather.",
			}
			npc.npc_closing = "Come see me when you're\nready to make a deal!"
			npc.combo_reactions = [
				{"items": ["Gold Coin", "Sword"], "line": "Armed and wealthy!\nI have maps to treasure\nif you're interested..."},
				{"items": ["Bread", "Gold Coin"], "line": "Gold AND provisions?\nYou're well-prepared\nfor a journey!"},
				{"items": ["Herb", "Sword"], "line": "A blade and healing herbs...\nplanning something dangerous?"},
			]
		"Baker":
			npc.greeting_items = "Oh! A customer with\ninteresting things!"
			npc.greeting_all = "My goodness, you've been\nall over the market!"
			npc.item_reactions = {
				"Bread": "I see you found my\nextra loaf! Good taste!",
				"Gold Coin": "Gold! You could buy my\nentire day's baking!",
				"Herb": "Ooh, herbs! I could use\nsome rosemary for my rolls.",
				"Sword": "A sword?! Please don't\nwave that near my flour!",
			}
			npc.npc_closing = "Enjoy the market, and\ndon't skip meals!"
			npc.combo_reactions = [
				{"items": ["Bread", "Herb"], "line": "Bread and herbs together?\nYou're making a fine sandwich!"},
				{"items": ["Bread", "Gold Coin"], "line": "My bread AND gold?\nYou're my favorite customer!"},
				{"items": ["Bread", "Sword"], "line": "A warrior who eats well\nfights well, I always say!"},
			]
		"Blacksmith":
			npc.greeting_items = "Hmm, what's that\nyou've got there?"
			npc.greeting_all = "A full adventurer's pack!\nNow THAT is impressive."
			npc.item_reactions = {
				"Bread": "Bread won't protect you\nin a fight, friend.",
				"Gold Coin": "Gold, eh? I could forge\nyou a proper weapon.",
				"Herb": "Herbs? I burn myself\nso often, those could help!",
				"Sword": "A fine blade! Did you find\nthat in my scrap pile?",
			}
			npc.npc_closing = "Stay sharp out there.\nLiterally."
			npc.combo_reactions = [
				{"items": ["Gold Coin", "Sword"], "line": "Gold AND a sword?\nLet me upgrade that blade\nfor you!"},
				{"items": ["Herb", "Sword"], "line": "Herbs to heal, steel to fight.\nA wise combination!"},
				{"items": ["Bread", "Sword"], "line": "Bread and a blade...\nthe essentials of any quest!"},
			]
		"Herbalist":
			npc.greeting_items = "Ooh, what treasures\ndo you bring me today?"
			npc.greeting_all = "Bread, herbs, gold, steel...\nYou're the most prepared\nperson I've ever met!"
			npc.item_reactions = {
				"Bread": "Bread is medicine for\nthe soul, I always say!",
				"Gold Coin": "Gold can't buy health...\nbut it CAN buy my potions!",
				"Herb": "You found my herb bundle!\nThose are freshly picked.",
				"Sword": "A weapon? I prefer\npeaceful remedies myself.",
			}
			npc.npc_closing = "Nature provides all\nwe truly need!"
			npc.combo_reactions = [
				{"items": ["Gold Coin", "Herb"], "line": "With gold and those herbs,\nI can brew something\ntruly special!"},
				{"items": ["Bread", "Herb"], "line": "Bread and herbs make a\nhealing meal. Very wise!"},
				{"items": ["Herb", "Sword"], "line": "My herbs can mend\nwhat that blade might wound."},
			]
