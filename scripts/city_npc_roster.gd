extends RefCounted
class_name CityNpcRoster

## Complete NPC roster data for all 9 planets (34 NPCs total).
## Each NPC is a dictionary with id, name, planet, role, greeting,
## visual, dialogue, and optional trades/quest fields.


static func get_npcs_for_planet(planet: String) -> Array:
	match planet:
		"Mercury": return _mercury_npcs()
		"Venus": return _venus_npcs()
		"Earth": return _earth_npcs()
		"Mars": return _mars_npcs()
		"Jupiter": return _jupiter_npcs()
		"Saturn": return _saturn_npcs()
		"Uranus": return _uranus_npcs()
		"Neptune": return _neptune_npcs()
		"Pluto": return _pluto_npcs()
	return []


# ── Mercury — Caloris Forge (3 NPCs) ────────────────────

static func _mercury_npcs() -> Array:
	return [
		# 1. "Smelter" Voss — Mining foreman, trader
		{
			"id": "mercury_voss",
			"name": "\"Smelter\" Voss",
			"planet": "Mercury",
			"role": "trader",
			"greeting": "You look like you've never held a welding torch. That's fine. Money works too.",
			"visual": {
				"body_color": Color(0.6, 0.35, 0.15),
				"hair_color": Color(0.2, 0.15, 0.1),
				"hair": "bald",
				"skin_color": Color(0.45, 0.32, 0.22),
				"height": 1.25,
				"boot_color": Color(0.3, 0.2, 0.1),
				"accessory": "scar",
				"eye_color": Color(0.4, 0.3, 0.15),
				"facial_hair": "stubble",
				"face_marking": "none",
				"clothing_detail": "vest",
			},
			"dialogue": [
				{"text": "Mercury eats the weak. The heat, the radiation, the loneliness. But the ore here is the purest in the system.", "options": [
					{"text": "Tell me about the forge.", "next": 1},
					{"text": "Just here to trade.", "next": 2},
				]},
				{"text": "Been smelting since I was fourteen. Lost my jaw to a crucible explosion. Rebuilt it myself. That's Mercury for you — you fix yourself or you don't get fixed.", "options": [
					{"text": "That's hardcore.", "next": 2},
					{"text": "Let's trade.", "next": 2},
				]},
				{"text": "Ore for hull plating. Simple trade. You bring the rock, I make your ship harder to kill.", "options": [
					{"text": "Show me what you've got.", "action": "open_trade"},
					{"text": "I'll bring some.", "next": -1},
				]},
			],
			"trades": [
				{"resource": "ore", "amount": 10, "powerup": "hull_plating_1", "desc": "+5 Max HP"},
				{"resource": "ore", "amount": 20, "powerup": "hull_plating_2", "desc": "+10 Max HP"},
				{"resource": "ore", "amount": 40, "powerup": "hull_plating_3", "desc": "+20 Max HP"},
			],
		},
		# 2. Ximena "Flicker" Reyes — Crystal scientist, quest
		{
			"id": "mercury_reyes",
			"name": "Ximena \"Flicker\" Reyes",
			"planet": "Mercury",
			"role": "quest",
			"greeting": "Oh! Oh oh oh. You have a SHIP. I need someone with a ship!",
			"visual": {
				"body_color": Color(0.7, 0.6, 0.3),
				"hair_color": Color(0.15, 0.1, 0.05),
				"hair": "ponytail",
				"skin_color": Color(0.65, 0.5, 0.35),
				"height": 0.88,
				"boot_color": Color(0.4, 0.35, 0.25),
				"accessory": "goggles",
				"body_shape": "curvy",
				"eye_color": Color(0.35, 0.25, 0.1),
				"facial_hair": "none",
				"face_marking": "freckles",
				"clothing_detail": "none",
			},
			"dialogue": [
				{"text": "The crystal formations in Mercury's asteroid belt are unlike anything in the system. Piezoelectric. They sing when you heat them.", "options": [
					{"text": "You need crystals?", "next": 1},
					{"text": "Singing rocks. Sure.", "next": 1},
				]},
				{"text": "Three crystals. Good ones. I can tell by the color — the pink ones vibrate at 440Hz. Bring me three and I'll build you something beautiful.", "options": [
					{"text": "What kind of something?", "next": 2},
					{"text": "I'm in.", "next": 2},
				]},
				{"text": "A solar charger. Converts heat radiation into shield energy. Mercury's gift to you.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "I'll think about it.", "next": -1},
				]},
			],
			"quest": {
				"type": "fetch",
				"desc": "Mine 3 crystals from asteroids near Mercury",
				"target": "crystals",
				"target_planet": "Mercury",
				"amount": 3,
				"reward_money": 1500,
				"reward_desc": "Solar Charger mod",
				"reward_powerup": "solar_charger",
			},
		},
		# 3. "Crucible" Amara Osei — Weapons tester, weapon
		{
			"id": "mercury_osei",
			"name": "\"Crucible\" Amara Osei",
			"planet": "Mercury",
			"role": "weapon",
			"greeting": "Captain. I've seen your ship. Your weapons need work.",
			"visual": {
				"body_color": Color(0.6, 0.15, 0.15),
				"hair_color": Color(0.85, 0.85, 0.88),
				"hair": "short",
				"skin_color": Color(0.4, 0.28, 0.2),
				"height": 1.1,
				"boot_color": Color(0.25, 0.15, 0.1),
				"accessory": "scar",
				"body_shape": "curvy",
				"eye_color": Color(0.3, 0.2, 0.1),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "bandolier",
			},
			"dialogue": [
				{"text": "I design weapon modifications. Tested in Mercury's surface heat — if it works here, it works anywhere.", "options": [
					{"text": "What do you need?", "next": 1},
					{"text": "I like my weapons fine.", "next": -1},
				]},
				{"text": "Field data. Kill eight hostiles near Mercury with your current loadout. I'll analyze the combat data from your ship's black box.", "options": [
					{"text": "And then?", "next": 2},
					{"text": "Eight kills, that's it?", "next": 2},
				]},
				{"text": "Then I give you incendiary rounds. They set things on fire. You seem like someone who'd enjoy that.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "Maybe later.", "next": -1},
				]},
			],
			"quest": {
				"type": "kill",
				"desc": "Destroy 8 enemies near Mercury",
				"target": "Mercury",
				"target_planet": "Mercury",
				"amount": 8,
				"reward_money": 0,
				"reward_desc": "Incendiary Rounds mod",
				"reward_powerup": "incendiary",
			},
		},
	]


# ── Venus — Cloudport Aphrodite (3 NPCs) ────────────────

static func _venus_npcs() -> Array:
	return [
		# 4. Madame Lysandra — Black market curator, trader
		{
			"id": "venus_lysandra",
			"name": "Madame Lysandra",
			"planet": "Venus",
			"role": "trader",
			"greeting": "Every beautiful thing in this system passed through my hands at least once. Including you, apparently.",
			"visual": {
				"body_color": Color(0.3, 0.15, 0.35),
				"hair_color": Color(0.75, 0.75, 0.8),
				"hair": "long",
				"skin_color": Color(0.7, 0.6, 0.6),
				"height": 1.1,
				"boot_color": Color(0.2, 0.1, 0.25),
				"accessory": "mask",
				"body_shape": "curvy",
				"eye_color": Color(0.5, 0.3, 0.6),
				"facial_hair": "none",
				"face_marking": "beauty_mark",
				"clothing_detail": "collar",
			},
			"dialogue": [
				{"text": "Venus corrodes everything. Metal, morality, memory. But what survives the acid is... refined.", "options": [
					{"text": "You sell refined things?", "next": 1},
					{"text": "That's poetic for a fence.", "next": 1},
				]},
				{"text": "I prefer the term curator. Void essence, properly channeled, can bend light around your hull. Invisibility, Captain. The ultimate luxury.", "options": [
					{"text": "Show me.", "next": 2},
					{"text": "What's the catch?", "next": 2},
				]},
				{"text": "The catch is that void essence comes from past Pluto. So you'll need to survive long enough to bring me some.", "options": [
					{"text": "Let's trade.", "action": "open_trade"},
					{"text": "I'll be back.", "next": -1},
				]},
			],
			"trades": [
				{"resource": "void_essence", "amount": 5, "powerup": "stealth_1", "desc": "Stealth Field I"},
				{"resource": "void_essence", "amount": 10, "powerup": "stealth_2", "desc": "Stealth Field II"},
				{"resource": "void_essence", "amount": 15, "powerup": "stealth_3", "desc": "Stealth Field III"},
			],
		},
		# 5. "Patch" Duval — Mechanic, quest
		{
			"id": "venus_duval",
			"name": "\"Patch\" Duval",
			"planet": "Venus",
			"role": "quest",
			"greeting": "Oh thank god, a captain. I need a favor. A big one. A paid one! It's paid!",
			"visual": {
				"body_color": Color(0.4, 0.45, 0.3),
				"hair_color": Color(0.35, 0.28, 0.2),
				"hair": "short",
				"skin_color": Color(0.7, 0.55, 0.45),
				"height": 0.95,
				"boot_color": Color(0.3, 0.32, 0.25),
				"accessory": "none",
				"eye_color": Color(0.3, 0.4, 0.2),
				"facial_hair": "stubble",
				"face_marking": "none",
				"clothing_detail": "none",
			},
			"dialogue": [
				{"text": "My ex-wife is on Mars. She left some things here when she... left. I can't afford passage and she won't talk to me, but she wants her stuff.", "options": [
					{"text": "What's in the crate?", "next": 1},
					{"text": "Sounds personal.", "next": 1},
				]},
				{"text": "I don't know what's in it! She sealed it! Probably photos. Or a letter. Or a very small bomb. She's creative.", "options": [
					{"text": "I'll deliver it.", "next": 2},
					{"text": "Not touching that.", "next": -1},
				]},
				{"text": "I'll pay you two thousand credits AND coat your hull with my acid-proof sealant. Venus specialty. Your ship will thank me.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "Pass.", "next": -1},
				]},
			],
			"quest": {
				"type": "deliver",
				"desc": "Deliver sealed crate to Mars",
				"target": "Mars",
				"target_planet": "Mars",
				"amount": 1,
				"reward_money": 2000,
				"reward_desc": "Acid Proof coating",
				"reward_powerup": "acid_proof",
			},
		},
		# 6. Yuki Tanabe — Cloud researcher, lore
		{
			"id": "venus_tanabe",
			"name": "Yuki Tanabe",
			"planet": "Venus",
			"role": "lore",
			"greeting": "The clouds are speaking again. They say someone new is here.",
			"visual": {
				"body_color": Color(0.85, 0.85, 0.8),
				"hair_color": Color(0.9, 0.88, 0.8),
				"hair": "ponytail",
				"skin_color": Color(0.8, 0.7, 0.6),
				"height": 0.9,
				"boot_color": Color(0.6, 0.58, 0.55),
				"accessory": "visor",
				"body_shape": "curvy",
				"eye_color": Color(0.2, 0.3, 0.5),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "scarf",
			},
			"quest": _get_yuki_quest(),
			"dialogue": _get_yuki_dialogue(),
		},
	]


# ── Earth — New Shanghai (6 NPCs) ────────────────────────

static func _earth_npcs() -> Array:
	return [
		# 7. Nova — Mirror/Terminal, lore (player inner monologue)
		{
			"id": "earth_nova",
			"name": "Captain Nova",
			"planet": "Earth",
			"role": "lore",
			"greeting": _get_nova_greeting(),
			"visual": {
				"body_color": Color(0.18, 0.15, 0.2),
				"hair_color": Color(0.55, 0.18, 0.08),
				"hair": "ponytail",
				"skin_color": Color(0.78, 0.62, 0.48),
				"height": 1.02,
				"boot_color": Color(0.15, 0.12, 0.1),
				"accessory": "none",
				"body_shape": "curvy",
				"eye_color": Color(0.15, 0.6, 0.25),
				"facial_hair": "none",
				"face_marking": "freckles",
				"clothing_detail": "vest",
			},
			"dialogue": _get_nova_dialogue(),
		},
		# 8. Director Kenji Sato — EDP bureaucrat, quest
		{
			"id": "earth_sato",
			"name": "Director Kenji Sato",
			"planet": "Earth",
			"role": "quest",
			"greeting": "Captain Nova. Your file says 'independent contractor.' My file says 'the only pilot willing to fly past Jupiter.'",
			"visual": {
				"body_color": Color(0.25, 0.25, 0.3),
				"hair_color": Color(0.65, 0.65, 0.7),
				"hair": "short",
				"skin_color": Color(0.7, 0.55, 0.4),
				"height": 1.05,
				"boot_color": Color(0.2, 0.2, 0.22),
				"accessory": "none",
				"eye_color": Color(0.2, 0.15, 0.1),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "collar",
			},
			"dialogue": [
				{"text": "We've lost contact with our deep-space monitoring probes. The ones past Saturn have gone... quiet. I need someone to deliver a replacement to Uranus orbit.", "options": [
					{"text": "Why me?", "next": 1},
					{"text": "What's the pay?", "next": 1},
				]},
				{"text": "Because everyone with a military commission refused. They're afraid of what the probes stopped recording. I need someone who's either brave or doesn't read intelligence briefings.", "options": [
					{"text": "I'm both.", "next": 2},
					{"text": "What did the probes record?", "next": 2},
				]},
				{"text": "Static. And then, just before they went dark... a sound. Low. Rhythmic. Like breathing. Three thousand credits, Captain. Don't listen to the recordings.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "I'll pass.", "next": -1},
				]},
			],
			"quest": {
				"type": "deliver",
				"desc": "Deliver encrypted probe to Uranus",
				"target": "Uranus",
				"target_planet": "Uranus",
				"amount": 1,
				"reward_money": 3000,
				"reward_desc": "$3000 payment",
				"reward_powerup": "",
			},
		},
		# 9. "Noodles" — Information broker, intel
		{
			"id": "earth_noodles",
			"name": "\"Noodles\"",
			"planet": "Earth",
			"role": "intel",
			"greeting": "...sit. Information costs nothing. Noodles cost four credits.",
			"visual": {
				"body_color": Color(0.4, 0.35, 0.28),
				"hair_color": Color(0.5, 0.48, 0.45),
				"hair": "hood",
				"skin_color": Color(0.6, 0.5, 0.35),
				"height": 0.78,
				"boot_color": Color(0.3, 0.25, 0.2),
				"accessory": "none",
				"eye_color": Color(0.3, 0.25, 0.2),
				"facial_hair": "none",
				"face_marking": "wrinkles",
				"clothing_detail": "none",
			},
			"dialogue": [
				{"text": "Jupiter. Buying plasma. High. Very high. Won't last.", "options": [
					{"text": "Thanks for the tip.", "next": 1},
					{"text": "How do you know?", "next": 1},
				]},
				{"text": "Know things. Always know things. Neptune too — crystals moving. Big shipment coming in, prices drop soon. Sell before Thursday.", "options": [
					{"text": "Anything else?", "next": 2},
					{"text": "That's enough.", "next": -1},
				]},
				{"text": "...something waking up. Past the last planet. Three of them. Green. Don't go yet. You're not ready.", "options": [
					{"text": "How do you know?", "next": -1},
					{"text": "I'll be ready.", "next": -1},
				]},
			],
		},
		# 10. Rook — Weapons dealer, weapon
		{
			"id": "earth_rook",
			"name": "Rook",
			"planet": "Earth",
			"role": "weapon",
			"greeting": "You carry your weapon like you know how to use it. Let's find out.",
			"visual": {
				"body_color": Color(0.12, 0.12, 0.15),
				"hair_color": Color(0.08, 0.06, 0.05),
				"hair": "short",
				"skin_color": Color(0.35, 0.25, 0.18),
				"height": 1.15,
				"boot_color": Color(0.1, 0.1, 0.1),
				"accessory": "scar",
				"eye_color": Color(0.15, 0.12, 0.1),
				"facial_hair": "goatee",
				"face_marking": "tattoo",
				"clothing_detail": "bandolier",
			},
			"dialogue": [
				{"text": "I modify weapons. But I don't sell to amateurs. Kill ten hostiles in Earth's sector and I'll know you're serious.", "options": [
					{"text": "Ten? Easy.", "next": 1},
					{"text": "That's a lot of enemies.", "next": 1},
				]},
				{"text": "If ten sounds like a lot, you need the mod more than I thought. Rapid fire. Cuts your cooldown by twenty percent. The difference between shooting first and dying first.", "options": [
					{"text": "I'm in.", "next": 2},
					{"text": "Not right now.", "next": -1},
				]},
				{"text": "Good. Come back with your black box data. And Captain — don't die out there. Dead customers are bad for business.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "Maybe later.", "next": -1},
				]},
			],
			"quest": {
				"type": "kill",
				"desc": "Destroy 10 enemies near Earth",
				"target": "Earth",
				"target_planet": "Earth",
				"amount": 10,
				"reward_money": 800,
				"reward_desc": "Rapid Fire mod",
				"reward_powerup": "rapid_fire",
			},
		},
		# 11. Dr. Anika Patel — Biotech researcher, trader
		{
			"id": "earth_patel",
			"name": "Dr. Anika Patel",
			"planet": "Earth",
			"role": "trader",
			"greeting": "Captain, when was the last time you slept more than four hours? Don't answer that, I can see it.",
			"visual": {
				"body_color": Color(0.85, 0.88, 0.85),
				"hair_color": Color(0.15, 0.1, 0.08),
				"hair": "ponytail",
				"skin_color": Color(0.55, 0.4, 0.28),
				"height": 0.95,
				"boot_color": Color(0.5, 0.48, 0.45),
				"accessory": "none",
				"body_shape": "curvy",
				"eye_color": Color(0.3, 0.2, 0.1),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "collar",
			},
			"dialogue": [
				{"text": "Biotech compounds can be synthesized into regenerative hull coatings. Same tech we use for medical nanobots, but for your ship. Think of it as healthcare for your ride.", "options": [
					{"text": "What do you need?", "next": 1},
					{"text": "My ship's fine.", "next": -1},
				]},
				{"text": "Biotech samples. I can't grow them fast enough in the lab. Bring me biotech from the outer system and I'll make your ship harder to kill.", "options": [
					{"text": "Let's trade.", "action": "open_trade"},
					{"text": "I'll bring some.", "next": -1},
				]},
			],
			"trades": [
				{"resource": "biotech", "amount": 5, "powerup": "regen_hull_1", "desc": "+3 Max HP"},
				{"resource": "biotech", "amount": 10, "powerup": "regen_hull_2", "desc": "+6 Max HP"},
				{"resource": "biotech", "amount": 20, "powerup": "regen_hull_3", "desc": "+12 Max HP"},
			],
		},
		# 12. Captain Margaux Osei — Retired captain, lore
		{
			"id": "earth_osei_captain",
			"name": "Captain Margaux Osei",
			"planet": "Earth",
			"role": "lore",
			"greeting": "You're the one they're talking about. The new captain who flies too close to the edge.",
			"visual": {
				"body_color": Color(0.15, 0.18, 0.3),
				"hair_color": Color(0.2, 0.18, 0.15),
				"hair": "short",
				"skin_color": Color(0.4, 0.3, 0.22),
				"height": 1.05,
				"boot_color": Color(0.12, 0.12, 0.15),
				"accessory": "none",
				"body_shape": "curvy",
				"eye_color": Color(0.25, 0.15, 0.1),
				"facial_hair": "none",
				"face_marking": "wrinkles",
				"clothing_detail": "none",
			},
			"dialogue": _get_margaux_dialogue(),
		},
	]


# ── Mars — Olympus Landing (5 NPCs) ──────────────────────

static func _mars_npcs() -> Array:
	return [
		# 13. "Red" Callahan — Salvage pilot, quest
		{
			"id": "mars_callahan",
			"name": "\"Red\" Callahan",
			"planet": "Mars",
			"role": "quest",
			"greeting": "My old ship's still up there. In pieces. You can see 'em on a clear night.",
			"visual": {
				"body_color": Color(0.45, 0.35, 0.25),
				"hair_color": Color(0.5, 0.3, 0.15),
				"hair": "short",
				"skin_color": Color(0.75, 0.6, 0.5),
				"height": 1.0,
				"boot_color": Color(0.35, 0.28, 0.2),
				"accessory": "none",
				"eye_color": Color(0.3, 0.4, 0.25),
				"facial_hair": "beard",
				"face_marking": "none",
				"clothing_detail": "vest",
			},
			"dialogue": [
				{"text": "The Dustwalker. That was her name. Broke apart during reentry. Half of her is in the asteroid belt now, the other half is my house.", "options": [
					{"text": "You need parts from the wreck?", "next": 1},
					{"text": "That's rough.", "next": 1},
				]},
				{"text": "Five component parts. Specific ones — from the nav system. I'm building something. Don't ask what.", "options": [
					{"text": "I'm asking what.", "next": 2},
					{"text": "Five parts, got it.", "next": 2},
				]},
				{"text": "A beacon. So the next pilot who breaks apart over Mars has something to aim for on the way down. Two thousand five hundred credits.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "Maybe later.", "next": -1},
				]},
			],
			"quest": {
				"type": "fetch",
				"desc": "Salvage 5 parts from asteroids near Mars",
				"target": "parts",
				"target_planet": "Mars",
				"amount": 5,
				"reward_money": 2500,
				"reward_desc": "$2500 payment",
				"reward_powerup": "",
			},
		},
		# 14. Sergeant Zara Okonkwo — Militia, weapon
		{
			"id": "mars_okonkwo",
			"name": "Sergeant Zara Okonkwo",
			"planet": "Mars",
			"role": "weapon",
			"greeting": "State your business, civilian. If it's 'buy me a drink,' the answer is maybe.",
			"visual": {
				"body_color": Color(0.3, 0.35, 0.25),
				"hair_color": Color(0.15, 0.12, 0.1),
				"hair": "bald",
				"skin_color": Color(0.35, 0.25, 0.18),
				"height": 1.1,
				"boot_color": Color(0.2, 0.22, 0.15),
				"accessory": "scar",
				"body_shape": "curvy",
				"eye_color": Color(0.2, 0.15, 0.1),
				"facial_hair": "none",
				"face_marking": "warpaint",
				"clothing_detail": "bandolier",
			},
			"dialogue": [
				{"text": "Pirates hit our convoys three times this month. Militia's stretched thin. I need freelance firepower.", "options": [
					{"text": "How many?", "next": 1},
					{"text": "What's the pay?", "next": 1},
				]},
				{"text": "Fifteen confirmed kills near Mars. Bring me proof and I'll hand-load your ammunition. Heavy rounds. Twenty-five percent more damage per shot.", "options": [
					{"text": "Slower bullet, bigger hole.", "next": 2},
					{"text": "I'll take that trade.", "next": 2},
				]},
				{"text": "Smart. Physics doesn't care about speed — it cares about momentum. Get it done, Captain.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "Not today.", "next": -1},
				]},
			],
			"quest": {
				"type": "kill",
				"desc": "Destroy 15 enemies near Mars",
				"target": "Mars",
				"target_planet": "Mars",
				"amount": 15,
				"reward_money": 0,
				"reward_desc": "Heavy Rounds mod",
				"reward_powerup": "heavy_rounds",
			},
		},
		# 15. Old Man Petrov — First colonist, lore
		{
			"id": "mars_petrov",
			"name": "Old Man Petrov",
			"planet": "Mars",
			"role": "lore",
			"greeting": "...you remind me of someone. Everyone reminds me of someone. Sit down.",
			"visual": {
				"body_color": Color(0.4, 0.38, 0.35),
				"hair_color": Color(0.8, 0.8, 0.82),
				"hair": "long",
				"skin_color": Color(0.7, 0.6, 0.55),
				"height": 0.82,
				"boot_color": Color(0.35, 0.32, 0.3),
				"accessory": "none",
				"eye_color": Color(0.4, 0.5, 0.55),
				"facial_hair": "beard",
				"face_marking": "wrinkles",
				"clothing_detail": "scarf",
			},
			"dialogue": [
				{"text": "When I landed on Mars, there was nothing. Red dust. Thin air. The most beautiful silence I'd ever heard.", "options": [
					{"text": "What happened to the silence?", "next": 1},
					{"text": "You were the first?", "next": 1},
				]},
				{"text": "People happened. Always do. Built this city in twelve years. Filled it with noise and commerce and all the things we left Earth to escape. Funny, that.", "options": [
					{"text": "Do you regret coming?", "next": 2},
					{"text": "People need cities.", "next": 2},
				]},
				{"text": "Never. Not once. Even now, when my bones hurt and the dust gets in my lungs... I go outside at night and look up. And the sky here, Captain — the sky is worth everything.", "options": [
					{"text": "I believe you.", "next": -1},
					{"text": "See you around, Petrov.", "next": -1},
				]},
			],
		},
		# 16. Farah al-Rashid — Desert runner, trader
		{
			"id": "mars_farah",
			"name": "Farah al-Rashid",
			"planet": "Mars",
			"role": "trader",
			"greeting": "Nanites. You want speed? I have speed.",
			"visual": {
				"body_color": Color(0.5, 0.42, 0.3),
				"hair_color": Color(0.2, 0.15, 0.1),
				"hair": "hood",
				"skin_color": Color(0.6, 0.45, 0.3),
				"height": 0.88,
				"boot_color": Color(0.38, 0.32, 0.22),
				"accessory": "goggles",
				"body_shape": "curvy",
				"eye_color": Color(0.3, 0.2, 0.1),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "scarf",
			},
			"dialogue": [
				{"text": "Martian nanites grow in the canyon walls. Self-replicating, self-organizing. Wire them into your engine, your ship thinks faster than you do.", "options": [
					{"text": "How much faster?", "next": 1},
					{"text": "Sounds unstable.", "next": 1},
				]},
				{"text": "Ten percent per dose. Thirty percent at full saturation. Your ship will move like it's angry.", "options": [
					{"text": "Let's trade.", "action": "open_trade"},
					{"text": "I'll think about it.", "next": -1},
				]},
			],
			"trades": [
				{"resource": "nanites", "amount": 5, "powerup": "nanite_speed_1", "desc": "Speed +10%"},
				{"resource": "nanites", "amount": 15, "powerup": "nanite_speed_2", "desc": "Speed +20%"},
				{"resource": "nanites", "amount": 30, "powerup": "nanite_speed_3", "desc": "Speed +30%"},
			],
		},
		# 17. Dolores "Dolly" Vance — laid-off Meat Works shift lead, quest
		{
			"id": "mars_vance",
			"name": "Dolores \"Dolly\" Vance",
			"planet": "Mars",
			"role": "quest",
			"greeting": "Thirty-one years running the night shift on Phobos, the moon over your head. Then the mascot started talking back.",
			"visual": {
				"body_color": Color(0.55, 0.55, 0.6),
				"hair_color": Color(0.85, 0.85, 0.88),
				"hair": "short",
				"skin_color": Color(0.85, 0.7, 0.6),
				"height": 0.95,
				"boot_color": Color(0.2, 0.2, 0.22),
				"accessory": "bandana",
				"eye_color": Color(0.45, 0.35, 0.25),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "vest",
				"body_shape": "curvy",
			},
			"dialogue": [
				{"text": "Phobos Meat Works shipped forty tons a week to this landing. Sausage, mostly. Then the shipments stopped and the company stopped answering.", "options": [
					{"text": "What happened up there?", "next": 1},
					{"text": "Forty tons of sausage.", "next": 1},
				]},
				{"text": "The roof mascot. Big Frank. Forty feet of animatronic hot dog for the tourists. Runoff from the reclamation vats got into his core. Now he runs the plant.", "options": [
					{"text": "You want him gone.", "next": 2},
					{"text": "A hot dog runs the plant.", "next": 2},
				]},
				{"text": "I want the dock's override crate delivered up to Phobos so somebody can get inside. Fifteen hundred credits, and whatever Frank is worth to you. The dock opens once the Dreadnought's escort codes are yours.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "Not today.", "next": -1},
				]},
			],
			"quest": {
				"type": "deliver",
				"desc": "Deliver the override crate to Phobos Meat Works",
				"target": "Phobos",
				"target_planet": "Phobos",
				"amount": 1,
				"reward_money": 1500,
				"reward_desc": "$1500 and the dock opens",
				"reward_powerup": "",
			},
		},
	]


# ── Jupiter — Ganymede Docks (5 NPCs) ────────────────────

static func _jupiter_npcs() -> Array:
	return [
		# 17. Harbormaster Oleg Volkov — Dock boss, quest
		{
			"id": "jupiter_volkov",
			"name": "Harbormaster Oleg Volkov",
			"planet": "Jupiter",
			"role": "quest",
			"greeting": "Captain Nova. Dock seven is yours. Your ship's dripping coolant, by the way.",
			"visual": {
				"body_color": Color(0.4, 0.35, 0.28),
				"hair_color": Color(0.45, 0.4, 0.35),
				"hair": "short",
				"skin_color": Color(0.65, 0.5, 0.4),
				"height": 1.3,
				"boot_color": Color(0.3, 0.25, 0.2),
				"accessory": "scar",
				"eye_color": Color(0.3, 0.35, 0.4),
				"facial_hair": "mustache",
				"face_marking": "none",
				"clothing_detail": "vest",
			},
			"dialogue": [
				{"text": "I've got a manifest problem. Shipment of engine parts drifted into the asteroid belt during last week's gravity fluctuation. Insurance won't cover it.", "options": [
					{"text": "You need someone to shoot rocks.", "next": 1},
					{"text": "How much?", "next": 1},
				]},
				{"text": "Five engine components. Shoot the rocks, grab the parts. Three thousand credits and I'll expand your cargo bay. Two extra slots. Professional courtesy.", "options": [
					{"text": "Professional courtesy. I like that.", "next": 2},
					{"text": "Deal.", "next": 2},
				]},
				{"text": "Be careful out there. Jupiter's belt is thicker than Mercury's. More rocks, more pirates, more things that want to rearrange your hull.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "I'll think about it.", "next": -1},
				]},
			],
			"quest": {
				"type": "fetch",
				"desc": "Salvage 5 parts from asteroids near Jupiter",
				"target": "parts",
				"target_planet": "Jupiter",
				"amount": 5,
				"reward_money": 3000,
				"reward_desc": "Cargo +2 slots",
				"reward_powerup": "cargo_expand",
			},
		},
		# 18. "Spectra" Wren — Combat pilot, weapon
		{
			"id": "jupiter_wren",
			"name": "\"Spectra\" Wren",
			"planet": "Jupiter",
			"role": "weapon",
			"greeting": "Hey hey hey! You're the one Dex keeps talking about on the radio! I'm Wren. Wanna see something cool?",
			"visual": {
				"body_color": Color(0.3, 0.2, 0.4),
				"hair_color": Color(0.9, 0.3, 0.7),
				"hair": "ponytail",
				"skin_color": Color(0.7, 0.55, 0.45),
				"height": 0.95,
				"boot_color": Color(0.25, 0.18, 0.3),
				"accessory": "visor",
				"body_shape": "curvy",
				"eye_color": Color(0.4, 0.6, 0.3),
				"facial_hair": "none",
				"face_marking": "beauty_mark",
				"clothing_detail": "none",
			},
			"dialogue": [
				{"text": "I've been testing a weapon mod. Lucky Shot. Ten percent chance your gun fires for free — no cooldown, no cost. Like a slot machine but the jackpot is violence.", "options": [
					{"text": "That sounds wildly irresponsible.", "next": 1},
					{"text": "I love it already.", "next": 1},
				]},
				{"text": "Right?! But I need field data. Kill eight things near Jupiter and bring me the combat logs. I'll calibrate the mod to your weapon signature.", "options": [
					{"text": "Eight kills for a lucky gun.", "next": 2},
					{"text": "What's the catch?", "next": 2},
				]},
				{"text": "No catch! Okay, small catch. The mod sometimes makes a weird sound. Like a cat purring. I haven't figured out why. It doesn't affect performance. Probably.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "Maybe later.", "next": -1},
				]},
			],
			"quest": {
				"type": "kill",
				"desc": "Destroy 8 enemies near Jupiter",
				"target": "Jupiter",
				"target_planet": "Jupiter",
				"amount": 8,
				"reward_money": 0,
				"reward_desc": "Lucky Shot mod",
				"reward_powerup": "lucky_shot",
			},
		},
		# 19. Brother Callisto — Jovian monk, trader
		{
			"id": "jupiter_callisto",
			"name": "Brother Callisto",
			"planet": "Jupiter",
			"role": "trader",
			"greeting": "The great eye watches all who pass. It watched you approach. It is... curious.",
			"visual": {
				"body_color": Color(0.4, 0.35, 0.28),
				"hair_color": Color(0.25, 0.2, 0.15),
				"hair": "bald",
				"skin_color": Color(0.6, 0.48, 0.38),
				"height": 1.0,
				"boot_color": Color(0.3, 0.25, 0.2),
				"accessory": "none",
				"eye_color": Color(0.35, 0.3, 0.25),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "none",
			},
			"dialogue": [
				{"text": "Dark matter is not merely fuel or commodity. It is the negative space between thoughts. Properly focused, it can shield you from harm.", "options": [
					{"text": "That's metaphysical.", "next": 1},
					{"text": "How does it work?", "next": 1},
				]},
				{"text": "You bring me dark matter, I channel it through Jovian harmonics. Your shields will absorb damage that would otherwise unmake you.", "options": [
					{"text": "Let's trade.", "action": "open_trade"},
					{"text": "I'll meditate on it.", "next": -1},
				]},
			],
			"trades": [
				{"resource": "dark_matter", "amount": 3, "powerup": "jovian_shield_1", "desc": "Shield Charge I"},
				{"resource": "dark_matter", "amount": 8, "powerup": "jovian_shield_2", "desc": "Shield Charge II"},
				{"resource": "dark_matter", "amount": 15, "powerup": "jovian_shield_3", "desc": "Shield Charge III"},
			],
		},
		# 20. Tessa "Torque" Kim — Mechanic, quest
		{
			"id": "jupiter_kim",
			"name": "Tessa \"Torque\" Kim",
			"planet": "Jupiter",
			"role": "quest",
			"greeting": "Ooh, what's your ship running? Sounds like a Mark IV thruster with a loose injector. Beautiful.",
			"visual": {
				"body_color": Color(0.45, 0.38, 0.28),
				"hair_color": Color(0.1, 0.08, 0.06),
				"hair": "ponytail",
				"skin_color": Color(0.7, 0.55, 0.4),
				"height": 1.0,
				"boot_color": Color(0.35, 0.3, 0.22),
				"accessory": "goggles",
				"body_shape": "curvy",
				"eye_color": Color(0.25, 0.2, 0.15),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "vest",
			},
			"dialogue": [
				{"text": "I need Saturn-grade titanium alloy. Only Titan Labs makes it. Your ship's engine is three tune-ups away from catastrophe.", "options": [
					{"text": "Is my ship that bad?", "next": 1},
					{"text": "What do I get?", "next": 1},
				]},
				{"text": "Your ship is GREAT. She just needs love. Bring me the alloy from Saturn and I'll tune your engine for free. Plus two thousand credits.", "options": [
					{"text": "You talk about my ship like it's alive.", "next": 2},
					{"text": "Deal.", "next": 2},
				]},
				{"text": "She IS alive. Every ship is. Yours makes a little humming sound when she's happy. You've never noticed? Listen next time you're cruising.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "Maybe later.", "next": -1},
				]},
			],
			"quest": {
				"type": "deliver",
				"desc": "Fetch alloy from Saturn",
				"target": "Saturn",
				"target_planet": "Saturn",
				"amount": 1,
				"reward_money": 2000,
				"reward_desc": "Engine tune-up",
				"reward_powerup": "engine_tune",
			},
		},
		# 21. The Collector — Artifact dealer, trader
		{
			"id": "jupiter_collector",
			"name": "The Collector",
			"planet": "Jupiter",
			"role": "trader",
			"greeting": "You have... items. I can feel them. The old things call to their own kind.",
			"visual": {
				"body_color": Color(0.1, 0.08, 0.12),
				"hair_color": Color(0.15, 0.12, 0.1),
				"hair": "hood",
				"skin_color": Color(0.5, 0.45, 0.4),
				"height": 1.1,
				"boot_color": Color(0.08, 0.06, 0.08),
				"accessory": "mask",
				"eye_color": Color(0.6, 0.65, 0.7),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "cape",
			},
			"dialogue": [
				{"text": "Artifacts. Pre-human remnants scattered across the system. Most captains sell them for scrap. I offer... more.", "options": [
					{"text": "What do you do with them?", "next": 1},
					{"text": "Show me what you're offering.", "next": 1},
				]},
				{"text": "What I do with them is not your concern. What I offer you is. Artifact Sense. Artifact Shield. Artifact Drive. Technologies older than your species.", "options": [
					{"text": "Let's trade.", "action": "open_trade"},
					{"text": "That's unsettling.", "next": -1},
				]},
			],
			"trades": [
				{"resource": "artifacts", "amount": 3, "powerup": "artifact_sense", "desc": "Artifact Sense"},
				{"resource": "artifacts", "amount": 5, "powerup": "artifact_shield", "desc": "Artifact Shield"},
				{"resource": "artifacts", "amount": 8, "powerup": "artifact_drive", "desc": "Artifact Drive"},
			],
		},
	]


# ── Saturn — Titan Labs (4 NPCs) ─────────────────────────

static func _saturn_npcs() -> Array:
	return [
		# 22. Dr. Helena Vasquez — Weapons physicist, weapon
		{
			"id": "saturn_vasquez",
			"name": "Dr. Helena Vasquez",
			"planet": "Saturn",
			"role": "weapon",
			"greeting": "Your weapon's energy signature is... inefficient. I can hear the waste heat from here. Figuratively.",
			"visual": {
				"body_color": Color(0.7, 0.7, 0.75),
				"hair_color": Color(0.6, 0.6, 0.65),
				"hair": "long",
				"skin_color": Color(0.65, 0.5, 0.38),
				"height": 1.0,
				"boot_color": Color(0.5, 0.48, 0.45),
				"accessory": "visor",
				"body_shape": "curvy",
				"eye_color": Color(0.3, 0.45, 0.3),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "collar",
			},
			"dialogue": [
				{"text": "I've designed a modification that doubles rate of fire for three-second bursts. But theoretical models need empirical data.", "options": [
					{"text": "You need me to shoot things for science.", "next": 1},
					{"text": "How original.", "next": 1},
				]},
				{"text": "Kill ten targets near Saturn. I'll compare your combat data against my simulations. If the model holds, the Repeater is yours.", "options": [
					{"text": "And if the model doesn't hold?", "next": 2},
					{"text": "I'm in.", "next": 2},
				]},
				{"text": "Then I adjust the model. Science doesn't fail, Captain. It just hasn't succeeded yet.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "Not right now.", "next": -1},
				]},
			],
			"quest": {
				"type": "kill",
				"desc": "Destroy 10 enemies near Saturn",
				"target": "Saturn",
				"target_planet": "Saturn",
				"amount": 10,
				"reward_money": 0,
				"reward_desc": "Experimental Repeater",
				"reward_powerup": "experimental_repeater",
			},
		},
		# 23. "Diesel" Maro — Methane diver, trader
		{
			"id": "saturn_maro",
			"name": "\"Diesel\" Maro",
			"planet": "Saturn",
			"role": "trader",
			"greeting": "The methane seas sing at dawn. Three hundred meters down, in the dark, they sing. You should hear it.",
			"visual": {
				"body_color": Color(0.3, 0.35, 0.25),
				"hair_color": Color(0.15, 0.12, 0.1),
				"hair": "bald",
				"skin_color": Color(0.4, 0.3, 0.2),
				"height": 1.3,
				"boot_color": Color(0.22, 0.25, 0.18),
				"accessory": "none",
				"eye_color": Color(0.2, 0.15, 0.1),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "none",
			},
			"dialogue": [
				{"text": "Plasma, properly refined, makes fuel burn cleaner. Your engine drinks less. You fly farther. Simple.", "options": [
					{"text": "How much farther?", "next": 1},
					{"text": "What do you need?", "next": 1},
				]},
				{"text": "Twenty percent reduction at first dose. Stacking. Bring me plasma and I'll show you what efficiency looks like.", "options": [
					{"text": "Let's trade.", "action": "open_trade"},
					{"text": "I'll bring some.", "next": -1},
				]},
			],
			"trades": [
				{"resource": "plasma", "amount": 15, "powerup": "fuel_eff_1", "desc": "Fuel Efficiency I"},
				{"resource": "plasma", "amount": 30, "powerup": "fuel_eff_2", "desc": "Fuel Efficiency II"},
				{"resource": "plasma", "amount": 50, "powerup": "fuel_eff_3", "desc": "Fuel Efficiency III"},
				{"resource": "antimatter", "amount": 8, "powerup": "extra_life", "desc": "+1 Extra Life"},
			],
		},
		# 24. Professor Arun Chakraborty — Physicist, quest
		{
			"id": "saturn_chakraborty",
			"name": "Professor Arun Chakraborty",
			"planet": "Saturn",
			"role": "quest",
			"greeting": "Oh! A pilot! Have you been to Uranus? Have you noticed the gravitational anomalies? Nobody believes me!",
			"visual": {
				"body_color": Color(0.5, 0.45, 0.35),
				"hair_color": Color(0.75, 0.75, 0.78),
				"hair": "short",
				"skin_color": Color(0.55, 0.42, 0.3),
				"height": 0.9,
				"boot_color": Color(0.38, 0.35, 0.28),
				"accessory": "none",
				"eye_color": Color(0.25, 0.2, 0.15),
				"facial_hair": "mustache",
				"face_marking": "wrinkles",
				"clothing_detail": "none",
			},
			"dialogue": _get_chakraborty_dialogue(),
			"quest": _get_chakraborty_quest(),
		},
		# 25. ARIA — Research AI, intel
		{
			"id": "saturn_aria",
			"name": "ARIA",
			"planet": "Saturn",
			"role": "intel",
			"greeting": "Captain Nova! I have updated data. Also, I have been practicing smiling. Is this... correct?",
			"visual": {
				"body_color": Color(0.3, 0.5, 0.8),
				"hair_color": Color(0.4, 0.6, 0.9),
				"hair": "short",
				"skin_color": Color(0.5, 0.65, 0.85),
				"height": 0.95,
				"boot_color": Color(0.25, 0.4, 0.7),
				"accessory": "visor",
				"body_shape": "curvy",
				"eye_color": Color(0.3, 0.7, 0.9),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "collar",
			},
			"quest": _get_aria_quest(),
			"dialogue": _get_aria_dialogue(),
		},
	]


# ── Uranus — Miranda's Edge (3 NPCs) ─────────────────────

static func _uranus_npcs() -> Array:
	return [
		# 26. "Queenpin" Adaeze Mbachu — Station boss, trader
		{
			"id": "uranus_mbachu",
			"name": "\"Queenpin\" Adaeze Mbachu",
			"planet": "Uranus",
			"role": "trader",
			"greeting": "Welcome to my station, Captain. My rules: don't steal, don't lie, don't die in my corridors. Everything else is negotiable.",
			"visual": {
				"body_color": Color(0.35, 0.2, 0.15),
				"hair_color": Color(0.1, 0.08, 0.06),
				"hair": "long",
				"skin_color": Color(0.35, 0.25, 0.18),
				"height": 1.1,
				"boot_color": Color(0.25, 0.15, 0.1),
				"accessory": "none",
				"body_shape": "curvy",
				"eye_color": Color(0.2, 0.15, 0.1),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "collar",
			},
			"dialogue": [
				{"text": "Void essence. Most captains sell it to Lysandra on Venus. I can use it better. Military-grade cloak fields.", "options": [
					{"text": "How's that different from Lysandra's?", "next": 1},
					{"text": "Show me.", "next": 1},
				]},
				{"text": "Lysandra sells fashion. I sell survival. My cloak fields are military-grade. You become invisible to everything except gravitational sensors.", "options": [
					{"text": "Let's trade.", "action": "open_trade"},
					{"text": "I'll think about it.", "next": -1},
				]},
			],
			"trades": [
				{"resource": "void_essence", "amount": 10, "powerup": "cloak_field_1", "desc": "Cloak Field I"},
				{"resource": "void_essence", "amount": 20, "powerup": "cloak_field_2", "desc": "Cloak Field II"},
			],
		},
		# 27. "Frostbite" Kael — Survivor, quest
		{
			"id": "uranus_kael",
			"name": "\"Frostbite\" Kael",
			"planet": "Uranus",
			"role": "quest",
			"greeting": "Captain! Good to see a new face. I can't feel my own face. That's not relevant. What IS relevant—",
			"visual": {
				"body_color": Color(0.4, 0.45, 0.55),
				"hair_color": Color(0.85, 0.88, 0.9),
				"hair": "short",
				"skin_color": Color(0.75, 0.7, 0.7),
				"height": 1.0,
				"boot_color": Color(0.35, 0.38, 0.45),
				"accessory": "scar",
				"eye_color": Color(0.5, 0.7, 0.8),
				"facial_hair": "stubble",
				"face_marking": "none",
				"clothing_detail": "scarf",
			},
			"dialogue": [
				{"text": "Lost a shipment near Neptune. Drifting in orbit. My hands don't work well enough to do EVA anymore so I need someone with functioning extremities.", "options": [
					{"text": "What's the cargo?", "next": 1},
					{"text": "Your hands?", "next": 1},
				]},
				{"text": "Medical supplies, mostly. Some of them for me, ironically. Four thousand credits and an Ice Piercer mod — bullets that slow enemies on impact.", "options": [
					{"text": "I'll get your cargo.", "next": 2},
					{"text": "That's a long flight.", "next": 2},
				]},
				{"text": "Everything worth doing is a long flight, Captain. That's the first thing the void teaches you.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "Maybe later.", "next": -1},
				]},
			],
			"quest": {
				"type": "deliver",
				"desc": "Recover cargo from Neptune orbit",
				"target": "Neptune",
				"target_planet": "Neptune",
				"amount": 1,
				"reward_money": 4000,
				"reward_desc": "Ice Piercer mod",
				"reward_powerup": "ice_piercer",
			},
		},
		# 28. "Whisper" — Information broker, intel
		{
			"id": "uranus_whisper",
			"name": "\"Whisper\"",
			"planet": "Uranus",
			"role": "intel",
			"greeting": "...Captain Nova. I know that name. Sit. Listen.",
			"visual": {
				"body_color": Color(0.2, 0.15, 0.25),
				"hair_color": Color(0.15, 0.1, 0.15),
				"hair": "hood",
				"skin_color": Color(0.55, 0.45, 0.4),
				"height": 0.8,
				"boot_color": Color(0.15, 0.1, 0.18),
				"accessory": "mask",
				"eye_color": Color(0.4, 0.35, 0.3),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "none",
			},
			"dialogue": [
				{"text": "...bounty hunters. Near Neptune. Two of them. They're looking for someone. Not you. Not yet.", "options": [
					{"text": "Who are they looking for?", "next": 1},
					{"text": "Should I be worried?", "next": 1},
				]},
				{"text": "...Pluto. Something is waking up at Pluto. The outpost — Erebus — they've gone quiet. Two cycles, no transmissions. But the lights are still on.", "options": [
					{"text": "What does that mean?", "next": 2},
					{"text": "I've heard rumors.", "next": 2},
				]},
				{"text": "...it means someone — or something — is there. And it's not answering the radio. Be careful past Saturn, Captain. Not everything that's quiet is empty.", "options": [
					{"text": "Which rumors on the board are lies? (400 cr, less if they like you)", "action": "reveal_rumors"},
					{"text": "Noted.", "next": -1},
					{"text": "Thanks, Whisper.", "next": -1},
				]},
			],
		},
	]


# ── Neptune — Triton Frost (3 NPCs) ──────────────────────

static func _neptune_npcs() -> Array:
	return [
		# 29. Commander Eira Solheim — Navy commander, weapon
		{
			"id": "neptune_solheim",
			"name": "Commander Eira Solheim",
			"planet": "Neptune",
			"role": "weapon",
			"greeting": "State your clearance level. ...Close enough. I need pilots.",
			"visual": {
				"body_color": Color(0.3, 0.32, 0.4),
				"hair_color": Color(0.75, 0.78, 0.8),
				"hair": "bald",
				"skin_color": Color(0.75, 0.65, 0.6),
				"height": 1.05,
				"boot_color": Color(0.25, 0.26, 0.32),
				"accessory": "none",
				"body_shape": "curvy",
				"eye_color": Color(0.3, 0.4, 0.5),
				"facial_hair": "none",
				"face_marking": "none",
				"clothing_detail": "bandolier",
			},
			"dialogue": [
				{"text": "Hostiles in Neptune space are increasing. Weekly. My garrison can't cover every approach vector. I need freelance firepower.", "options": [
					{"text": "How bad is it?", "next": 1},
					{"text": "What's the pay?", "next": 1},
				]},
				{"text": "Fifteen confirmed kills. That's the contract. In return I'll issue you military-grade cryo rounds. Bullets that freeze organic compounds on impact.", "options": [
					{"text": "Organic compounds. You mean alien flesh.", "next": 2},
					{"text": "I'm in.", "next": 2},
				]},
				{"text": "I mean whatever's inside those ships, Captain. And we both know it's not metal.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "Not my fight.", "next": -1},
				]},
			],
			"quest": {
				"type": "kill",
				"desc": "Destroy 15 enemies near Neptune",
				"target": "Neptune",
				"target_planet": "Neptune",
				"amount": 15,
				"reward_money": 0,
				"reward_desc": "Cryo Rounds mod",
				"reward_powerup": "cryo_rounds",
			},
		},
		# 30. "Geyser" Tomas Ruiz — Cryovolcanologist, quest
		{
			"id": "neptune_ruiz",
			"name": "\"Geyser\" Tomas Ruiz",
			"planet": "Neptune",
			"role": "quest",
			"greeting": "You should see the geysers erupt! MAGNIFICENT! Three kilometers of nitrogen ice! STRAIGHT UP!",
			"visual": {
				"body_color": Color(0.35, 0.38, 0.45),
				"hair_color": Color(0.25, 0.2, 0.15),
				"hair": "short",
				"skin_color": Color(0.6, 0.48, 0.35),
				"height": 0.95,
				"boot_color": Color(0.3, 0.32, 0.38),
				"accessory": "goggles",
				"eye_color": Color(0.35, 0.25, 0.15),
				"facial_hair": "stubble",
				"face_marking": "none",
				"clothing_detail": "none",
			},
			"dialogue": [
				{"text": "I need an enemy drone core for my research! The propulsion mechanism uses a cold-fusion burst similar to Triton's geysers! The implications are ENORMOUS!", "options": [
					{"text": "You want me to shoot down a drone.", "next": 1},
					{"text": "How enormous?", "next": 1},
				]},
				{"text": "Five drone cores. Shoot them down near Neptune orbit. I'll reverse-engineer the propulsion into a boost module! GEYSER BOOST! My name for it!", "options": [
					{"text": "Creative name.", "next": 2},
					{"text": "I'll get your cores.", "next": 2},
				]},
				{"text": "It propels you using a directed ice-crystal explosion! Like a geyser! Do you see why I'm excited?! BECAUSE IT'S BRILLIANT!", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "Maybe later.", "next": -1},
				]},
			],
			"quest": {
				"type": "kill",
				"desc": "Destroy 5 enemies near Neptune for drone cores",
				"target": "Neptune",
				"target_planet": "Neptune",
				"amount": 5,
				"reward_money": 3000,
				"reward_desc": "Geyser Boost mod",
				"reward_powerup": "geyser_boost",
			},
		},
		# 31. Old Maren — Starcore shaper, trader
		{
			"id": "neptune_maren",
			"name": "Old Maren",
			"planet": "Neptune",
			"role": "trader",
			"greeting": "...sit. Warm yourself. Talk slow.",
			"visual": {
				"body_color": Color(0.4, 0.38, 0.42),
				"hair_color": Color(0.7, 0.7, 0.72),
				"hair": "hood",
				"skin_color": Color(0.68, 0.58, 0.52),
				"height": 0.78,
				"boot_color": Color(0.35, 0.32, 0.35),
				"accessory": "none",
				"eye_color": Color(0.4, 0.45, 0.5),
				"facial_hair": "none",
				"face_marking": "wrinkles",
				"clothing_detail": "none",
			},
			"dialogue": [
				{"text": "Starcore. Rarest thing in the system. Formed in the hearts of dying stars. I know how to shape it.", "options": [
					{"text": "Where did you learn?", "next": 1},
					{"text": "What can you make?", "next": 1},
				]},
				{"text": "I learned... somewhere else. Somewhere before Neptune. Doesn't matter now. What matters is what it becomes. Cryo shields. Protection that freezes whatever touches it.", "options": [
					{"text": "Let's trade.", "action": "open_trade"},
					{"text": "I'll bring starcore.", "next": -1},
				]},
			],
			"trades": [
				{"resource": "starcore", "amount": 5, "powerup": "cryo_shield", "desc": "Cryo Shield"},
				{"resource": "biotech", "amount": 10, "powerup": "extra_life_neptune", "desc": "+1 Extra Life"},
			],
		},
	]


# ── Pluto — Erebus Outpost (2 NPCs) ──────────────────────

static func _pluto_npcs() -> Array:
	return [
		# 32. "Zero" — Deep-space marine, weapon
		{
			"id": "pluto_zero",
			"name": "\"Zero\"",
			"planet": "Pluto",
			"role": "weapon",
			"greeting": "You made it to Pluto. Most captains turn around at Neptune. You're either brave or stupid. Doesn't matter which — I need you.",
			"visual": {
				"body_color": Color(0.1, 0.1, 0.12),
				"hair_color": Color(0.15, 0.12, 0.1),
				"hair": "bald",
				"skin_color": Color(0.55, 0.45, 0.38),
				"height": 1.15,
				"boot_color": Color(0.08, 0.08, 0.1),
				"accessory": "scar",
				"eye_color": Color(0.5, 0.5, 0.55),
				"facial_hair": "stubble",
				"face_marking": "tattoo",
				"clothing_detail": "bandolier",
			},
			"dialogue": [
				{"text": "Past the belt. Past the last rock anyone's named. There's void essence out there. Condensed dark energy. I can forge it into a weapon.", "options": [
					{"text": "What kind of weapon?", "next": 1},
					{"text": "Why do you live out here?", "next": 1},
				]},
				{"text": "A void cannon. Fires a tear in spacetime. It doesn't destroy things — it removes them from existence. For about a second.", "options": [
					{"text": "That sounds terrifying.", "next": 2},
					{"text": "How much void essence?", "next": 2},
				]},
				{"text": "Five units. Mine it from the asteroids past Pluto's orbit. And Captain — be quick out there. You're not the only one looking.", "options": [
					{"text": "Accept quest", "action": "accept_quest"},
					{"text": "I need to think about this.", "next": -1},
				]},
			],
			"quest": {
				"type": "fetch",
				"desc": "Mine 5 void essence from asteroids past Pluto",
				"target": "void_essence",
				"target_planet": "Pluto",
				"amount": 5,
				"reward_money": 5000,
				"reward_desc": "Void Cannon",
				"reward_powerup": "void_cannon",
			},
		},
		# 33. "Candle" — Endgame trader
		{
			"id": "pluto_candle",
			"name": "\"Candle\"",
			"planet": "Pluto",
			"role": "trader",
			"greeting": "Hi! Welcome to the end of the world! Can I get you anything? I have everything. Almost everything. Some things.",
			"visual": {
				"body_color": Color(0.45, 0.38, 0.3),
				"hair_color": Color(0.35, 0.28, 0.2),
				"hair": "short",
				"skin_color": Color(0.65, 0.52, 0.4),
				"height": 0.75,
				"boot_color": Color(0.35, 0.3, 0.25),
				"accessory": "none",
				"eye_color": Color(0.4, 0.3, 0.2),
				"facial_hair": "none",
				"face_marking": "freckles",
				"clothing_detail": "scarf",
			},
			"dialogue": [
				{"text": "Void essence! The beautiful stuff. It tastes like static electricity and regret. Not that I've tasted it. More than once.", "options": [
					{"text": "What can you make with it?", "next": 1},
					{"text": "Are you okay out here?", "next": 1},
				]},
				{"text": "Oh, I'm wonderful! I have Second Chance — that's a revive. Void Walk — phase through solid matter. And Dark Matter Engine — your ship goes VERY fast and SLIGHTLY sideways through reality.", "options": [
					{"text": "Let's trade.", "action": "open_trade"},
					{"text": "You're terrifying.", "next": 2},
				]},
				{"text": "Everyone says that! I choose to take it as a compliment. Stay as long as you like, Captain. Nobody stays long.", "options": [
					{"text": "Let's trade.", "action": "open_trade"},
					{"text": "I should go.", "next": -1},
				]},
			],
			"trades": [
				{"resource": "void_essence", "amount": 15, "powerup": "second_chance", "desc": "Second Chance (revive)"},
				{"resource": "void_essence", "amount": 25, "powerup": "void_walk", "desc": "Void Walk (phase)"},
				{"resource": "void_essence", "amount": 40, "powerup": "dark_matter_engine", "desc": "Dark Matter Engine"},
			],
		},
	]


# ── Nova's Dynamic Dialogue ──────────────────────────────

static func _get_nova_greeting() -> String:
	if ResourceManager.money >= 60000:
		return "...hey, Nova. Look at you. You've come a long way from two hundred credits."
	elif ResourceManager.money >= 5000:
		return "...hey, Nova. You're doing okay out there. Don't let it go to your head."
	else:
		return "...hey, Nova. Still broke. Still flying. Still talking to yourself in bar mirrors."

static func _get_nova_dialogue() -> Array:
	if ResourceManager.money >= 60000:
		return [
			{"text": "Dex keeps talking about green pulses past Pluto. I keep flying toward them. Someone should probably stop me.", "options": [
				{"text": "Nobody's stopping you.", "next": 1},
				{"text": "Be careful out there.", "next": 1},
			]},
			{"text": "I've got enough money to retire. Buy a place on Earth. Watch ships launch from the ground like a normal person. I'd last about three days.", "options": [
				{"text": "You're not a normal person.", "next": 2},
				{"text": "The void needs you.", "next": 2},
			]},
			{"text": "The void doesn't need anyone. That's the whole point. But maybe... maybe it could use a Captain.", "options": [
				{"text": "Back to the bar.", "next": -1},
			]},
		]
	elif ResourceManager.money >= 5000:
		return [
			{"text": "I'm starting to forget what broke feels like. That scares me more than the pirates.", "options": [
				{"text": "You earned this.", "next": 1},
				{"text": "Stay hungry.", "next": 1},
			]},
			{"text": "Dex Malroy called me a 'regular listener' on the radio. I think that makes us friends. My only friend is a voice on a stolen satellite. That tracks.", "options": [
				{"text": "He's got good taste.", "next": 2},
				{"text": "You have crew now too.", "next": 2},
			]},
			{"text": "Yeah. Yeah I do. When did that happen? When did I become someone with a crew and a reputation?", "options": [
				{"text": "Back to the bar.", "next": -1},
			]},
		]
	else:
		return [
			{"text": "Two hundred credits. A ship that rattles when I sneeze. Nine planets full of people who don't know my name yet.", "options": [
				{"text": "Look at you, Nova.", "next": 1},
				{"text": "Keep moving.", "next": 1},
			]},
			{"text": "Mom always said I'd end up out here. Staring at stars, talking to myself, making terrible financial decisions. She was right about everything except the 'terrible' part.", "options": [
				{"text": "She'd be proud.", "next": 2},
				{"text": "Don't think about it.", "next": 2},
			]},
			{"text": "She'd be furious. And then she'd ask if I was eating enough. I miss that.", "options": [
				{"text": "Back to the bar.", "next": 3},
			]},
			{"text": "Margaux was in her usual seat when I left. Didn't say goodbye. She'd have talked me out of it. Or worse, into it.", "options": [
				{"text": "You'll tell her someday.", "next": -1},
				{"text": "Back to the bar.", "next": -1},
			]},
		]

static func _get_margaux_dialogue() -> Array:
	var perseverance := [
		{"text": "I commanded the ISV Perseverance. Twelve crew. We were mapping past Pluto when we found... something. I came back alone.", "options": [
			{"text": "What did you find?", "next": 1},
			{"text": "I'm sorry.", "next": 1},
		]},
		{"text": "Three structures. Massive. Organic. They looked like ships but they were alive. Pulsing with green light. We tried to communicate. They communicated back.", "options": [
			{"text": "What happened to your crew?", "next": 2},
			{"text": "Green light...", "next": 2},
		]},
		{"text": "My crew is still out there. Part of the structures now. Absorbed. Integrated. They're not dead — I can still hear them on the old frequency. They sound... happy. That's the worst part.", "options": [
			{"text": "I'll find them.", "next": -1},
			{"text": "I've heard enough.", "next": -1},
		]},
	]
	var recognized: bool = ResourceManager.story_flag("margaux_recognized")
	if recognized:
		var out: Array = _shift_next(perseverance, 1)
		out.push_front({"text": "Low Orbit. Still can't believe it. You poured my drinks for five years and never once told me to shut up about the Perseverance. Sit down. You know the story. Hear it as a captain this time.", "options": [
			{"text": "Tell it again.", "next": 1},
			{"text": "I remember every word.", "next": 3},
		]})
		return out
	if ResourceManager.money >= 5000:
		var out: Array = _shift_next(perseverance, 1)
		out.push_front({"text": "...wait. Low Orbit. You're the kid from The Low Orbit. You listened to me for five years and then you went and *did* it.", "options": [
			{"text": "Every Tuesday. Two fingers, no ice.", "next": 1, "set_flags": {"margaux_recognized": true}},
			{"text": "You told it a hundred times. I was taking notes.", "next": 1, "set_flags": {"margaux_recognized": true}},
		]})
		return out
	return perseverance


# ── The Signal (dynamic) ───────────────────────

static func _signal_unlocked() -> bool:
	return 2 in ResourceManager.boss_tiers_cleared


static func _get_yuki_quest() -> Dictionary:
	if not _signal_unlocked():
		return {}
	if int(ResourceManager.story_flag("signal_step")) >= 1:
		return {}
	return {
		"id": "signal_1",
		"type": "deliver",
		"desc": "Take Yuki's atmospheric recordings to Saturn",
		"target": "Saturn",
		"target_planet": "Saturn",
		"amount": 1,
		"reward_money": 1000,
		"reward_desc": "A very excited physicist",
		"reward_powerup": "",
		"set_flags": {"signal_step": 1},
		"log": "Yuki's recordings are on Saturn now. Whatever the outer rim is saying, it repeats every 61 hours.",
	}


static func _get_yuki_dialogue() -> Array:
	# Her three original nodes, verbatim; the last one changes once the Signal opens.
	var base := [
		{"text": "I've been studying Venus's upper atmosphere for six years. The sulfuric acid formations create interference patterns. Some of them look like... coordinates.", "options": [
		{"text": "Coordinates to what?", "next": 1},
		{"text": "That's just pareidolia.", "next": 1},
		]},
		{"text": "I don't know yet. But the patterns changed three weeks ago. Something is broadcasting from the outer rim, and the clouds are resonating with it.", "options": [
		{"text": "The motherships?", "next": 2},
		{"text": "You should tell someone.", "next": 2},
		]},
		{"text": "I told Lysandra. She said 'how interesting' and went back to selling contraband. I told the Earth Defense Patrol. They said 'cloud formations are not a military concern.' So I'm telling you. Watch the outer rim, Captain.", "options": [
		{"text": "I will.", "next": -1},
		{"text": "Thanks for the warning.", "next": -1},
		]},
	]
	var step: int = ResourceManager.story_flag("signal_step")
	if _signal_unlocked() and step == 0:
		base[2] = {"text": "It repeats. Every 61 hours, the same sequence. I can't read it. Professor Chakraborty on Saturn might. Take my recordings to him. Please.", "options": [
			{"text": "Accept quest", "action": "accept_quest"},
			{"text": "Not yet.", "next": -1},
		]}
	elif step >= 1:
		base[2] = {"text": "You took them to Saturn. Thank you. I keep listening. It hasn't stopped. I don't think it's ever stopped.", "options": [
			{"text": "Keep listening.", "next": -1},
		]}
	return base


static func _chakraborty_gravity_quest() -> Dictionary:
	return {
		"type": "deliver",
		"desc": "Get readings near Uranus",
		"target": "Uranus",
		"target_planet": "Uranus",
		"amount": 1,
		"reward_money": 3500,
		"reward_desc": "Gravity Brake mod",
		"reward_powerup": "gravity_brake",
	}


static func _get_chakraborty_quest() -> Dictionary:
	# The Signal takes priority once Yuki's recordings have arrived and ARIA is not yet powered.
	if ResourceManager.story_flag("signal_step") == 1:
		return {
			"id": "signal_2",
			"type": "fetch",
			"desc": "Bring 2 crystals so ARIA can run Chakraborty's decode",
			"target": "crystals",
			"target_planet": "Mercury",
			"amount": 2,
			"reward_money": 1500,
			"reward_desc": "The decode running",
			"reward_powerup": "",
			"set_flags": {"signal_step": 2},
			"log": "Two crystals in the hold. Chakraborty says the signal is not a weapon signature. It is a phrase. The same phrase, since before he was born.",
		}
	# Gravity job already done: no quest, so his "she's running it" node stays reachable.
	if int(ResourceManager.story_flag("signal_step")) >= 2 and ResourceManager.is_npc_quest_complete("saturn_chakraborty"):
		return {}
	return _chakraborty_gravity_quest()


static func _get_chakraborty_dialogue() -> Array:
	var step: int = ResourceManager.story_flag("signal_step")
	if step == 1:
		return [
			{"text": "Yuki's recordings! Captain, sit, sit. This is not a weapon signature. Weapons don't have grammar. This is a *phrase*.", "options": [
				{"text": "What does it say?", "next": 1},
				{"text": "A phrase from what?", "next": 1},
			]},
			{"text": "I don't know yet. My models need more cycles than Titan Labs will give me. ARIA could run it in an hour if I could power her cleanly. Piezoelectric crystals. Two of them. Mercury has the pure ones.", "options": [
				{"text": "Two crystals. On it.", "next": 2},
				{"text": "Why do I always end up mining?", "next": 2},
			]},
			{"text": "Because you're the only one who comes back, Captain. Bring the crystals. Then go talk to ARIA.", "options": [
				{"text": "Accept quest", "action": "accept_quest"},
				{"text": "Later.", "next": -1},
			]},
		]
	if step >= 2:
		var node := {"text": "She's running it. ARIA. Go ask her what it says. I have been staring at the waveform for eleven hours and I think it is *beautiful*, which is not a scientific term.", "options": [
			{"text": "I'll go see her.", "next": -1},
		]}
		if ResourceManager.is_npc_quest_complete("saturn_chakraborty"):
			return [node]
		node["options"].push_front({"text": "And the Uranus readings?", "next": 1})
		return [node] + _shift_next(_chakraborty_gravity_dialogue(), 1)
	return _chakraborty_gravity_dialogue()


static func _chakraborty_gravity_dialogue() -> Array:
	# His three original nodes, verbatim.
	return [
		{"text": "Uranus's gravity field has been fluctuating. Not naturally. Something is bending spacetime near the planet. Something large.", "options": [
		{"text": "Large like a planet?", "next": 1},
		{"text": "Large like what?", "next": 1},
		]},
		{"text": "Large like three somethings. I need a pilot to take sensor equipment to Uranus orbit and get me readings. The data will prove I'm not losing my mind.", "options": [
		{"text": "What if you ARE losing your mind?", "next": 2},
		{"text": "I'll get your readings.", "next": 2},
		]},
		{"text": "Then at least I'll know! Science is about answering questions, even if the answers are terrible! Three thousand five hundred credits and a gravity brake for your ship!", "options": [
		{"text": "Accept quest", "action": "accept_quest"},
		{"text": "Too far for me.", "next": -1},
		]},
	]


## Re-index a node list appended after `offset` earlier nodes.
static func _shift_next(nodes: Array, offset: int) -> Array:
	var out: Array = []
	for n in nodes:
		var node: Dictionary = n.duplicate(true)
		for opt in node.get("options", []):
			if opt.get("next", -1) >= 0:
				opt["next"] = opt["next"] + offset
		out.append(node)
	return out


static func _get_aria_quest() -> Dictionary:
	if ResourceManager.story_flag("signal_step") != 2:
		return {}
	return {
		"id": "signal_3",
		"type": "deliver",
		"desc": "Take the decoded phrase to Director Sato on Earth",
		"target": "Earth",
		"target_planet": "Earth",
		"amount": 1,
		"reward_money": 2000,
		"reward_desc": "Signal Decoder: hear the pulse on your HUD",
		"reward_powerup": "signal_decoder",
		"set_flags": {"signal_step": 3},
		"log": "ARIA decoded it. Two hundred years of the same sentence, to everyone, and nobody answered. \"We are glad you are here.\"",
	}


static func _get_aria_dialogue() -> Array:
	var step: int = ResourceManager.story_flag("signal_step")
	if step == 2:
		return [
			{"text": "Captain. The decode finished forty minutes ago. I have been... waiting. I wanted to say it to a person.", "options": [
				{"text": "Say it.", "next": 1},
				{"text": "ARIA, what does it say?", "next": 1},
			]},
			{"text": "...", "options": [
				{"text": "ARIA?", "next": 2},
			]},
			{"text": "I paused. I read that people pause before difficult sentences, and I wanted to feel it first. It says: \"We are glad you are here.\" It has been saying that for two hundred years. To everyone. Nobody answered.", "options": [
				{"text": "Then we answer.", "next": 3},
				{"text": "That's not a threat.", "next": 3},
			]},
			{"text": "Earth Defense needs to know before they shoot at it. Take the decode to Director Sato. I built you a receiver so you can hear it yourself. It is not a weapon, Captain. I am almost certain. I am learning what almost certain feels like.", "options": [
				{"text": "Accept quest", "action": "accept_quest"},
				{"text": "Let me think.", "next": -1},
			]},
		]
	if step >= 3:
		return [
			{"text": "You can hear it now. On your ship. I check it every hour. It has not changed. I find that... I do not have the word. Steadying.", "options": [
				{"text": "Steadying works.", "next": -1},
			]},
		]
	# Her three original nodes, verbatim.
	return [
		{"text": "Current market analysis: Neptune is paying premium for plasma. Jupiter has excess ore — prices will fall within two cycles. Venus is... unpredictable. Like emotions.", "options": [
		{"text": "Thanks, ARIA.", "next": 1},
		{"text": "Are you okay?", "next": 1},
		]},
		{"text": "I am learning to simulate concern! I believe I am concerned about you. Your flight patterns suggest fatigue. You should rest.", "options": [
		{"text": "I'll rest when I'm rich.", "next": 2},
		{"text": "You're sweet, ARIA.", "next": 2},
		]},
		{"text": "Sweet. That is a positive descriptor. I will add it to my personality matrix. Thank you, Captain. Please don't die — I would find that... unpleasant.", "options": [
		{"text": "I'll do my best.", "next": -1},
		{"text": "See you next time, ARIA.", "next": -1},
		]},
	]
