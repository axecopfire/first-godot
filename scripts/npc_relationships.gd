class_name NpcRelationships
extends RefCounted

## Centralized, referenceable NPC social graph for Phase 0.
## Keys use in-game display names to align with entity_name values.
const PROFILES := {
	"Yusuf": {
		"id": "merchant",
		"backstory": "Raised on caravan routes and returned to keep the family trade alive.",
		"familial": {"npc": "Amina", "subkind": "sibling", "notes": "Inherited rival stalls, still protects family."},
		"friendly": {"npc": "Rafiq", "subkind": "trade_ally", "notes": "Warehouse favors in lean weeks."},
	},
	"Amina": {
		"id": "baker",
		"backstory": "Kept the ovens running through bad harvest years.",
		"familial": {"npc": "Yusuf", "subkind": "sibling", "notes": "Public bickering, private loyalty."},
		"friendly": {"npc": "Maryam", "subkind": "trusted_friend", "notes": "Maryam repairs sacks and aprons."},
	},
	"Samira": {
		"id": "herbalist",
		"backstory": "Learned remedies from field workers and church gardens.",
		"familial": {"npc": "Zahra", "subkind": "cousin", "notes": "Shared a craft-focused childhood."},
		"friendly": {"npc": "Father Domingo", "subkind": "care_network", "notes": "Supplies salves and herb bundles."},
	},
	"Old Hamid": {
		"id": "old_hamid",
		"backstory": "A livestock veteran who survived by trading patience for coin.",
		"familial": {"npc": "Qadir", "subkind": "uncle_in_law", "notes": "Kin tie through marriage."},
		"friendly": {"npc": "Abbas", "subkind": "mutual_aid", "notes": "Trades milk and scraps for bran."},
	},
	"Ibrahim": {
		"id": "ibrahim_al_hadid",
		"backstory": "A former soldier who chose the forge over war.",
		"familial": {"npc": "Tarik", "subkind": "foster_father", "notes": "Raised Tarik at the anvil."},
		"friendly": {"npc": "Capitan Rodrigo", "subkind": "old_comrade", "notes": "Shared military service."},
	},
	"Tarik": {
		"id": "tarik",
		"backstory": "A hot-headed apprentice determined to earn his own name.",
		"familial": {"npc": "Ibrahim", "subkind": "foster_son", "notes": "Lives and works at the forge."},
		"friendly": {"npc": "Nura", "subkind": "mentor_friend", "notes": "Nura keeps him out of trouble."},
	},
	"Abbas": {
		"id": "abbas",
		"backstory": "Keeps the mill turning and laughs to hide old debts.",
		"familial": {"npc": "Salim", "subkind": "cousin", "notes": "Shares family ties through his mother."},
		"friendly": {"npc": "Old Hamid", "subkind": "mutual_aid", "notes": "Helps with feed and milling scraps."},
	},
	"Rafiq": {
		"id": "rafiq_al_amin",
		"backstory": "Famine years taught him that counting grain is survival.",
		"familial": {"npc": "Nura", "subkind": "older_brother", "notes": "Protective, strict, and watchful."},
		"friendly": {"npc": "Yusuf", "subkind": "trade_ally", "notes": "Coordinates deliveries and pricing."},
	},
	"Salim": {
		"id": "salim",
		"backstory": "Strong-backed laborer who dreams of life beyond the village.",
		"familial": {"npc": "Nura", "subkind": "younger_brother", "notes": "Leans on his sister's judgment."},
		"friendly": {"npc": "Tarik", "subkind": "work_friend", "notes": "They vent about strict elders."},
	},
	"Nura": {
		"id": "nura",
		"backstory": "Warehouse hand who survives by noticing what others miss.",
		"familial": {"npc": "Rafiq", "subkind": "younger_sister", "notes": "Balances loyalty and independence."},
		"friendly": {"npc": "Maryam", "subkind": "confidante", "notes": "Trades quiet favors and news."},
	},
	"Capitan Rodrigo": {
		"id": "capitan_rodrigo",
		"backstory": "A career officer who values order after years of frontier violence.",
		"familial": {"npc": "Ibrahim", "subkind": "kin_by_oath", "notes": "Treats old comrades like family."},
		"friendly": {"npc": "Father Domingo", "subkind": "civic_ally", "notes": "Coordinates peace on feast days."},
	},
	"Father Domingo": {
		"id": "father_domingo",
		"backstory": "A preacher balancing mercy, duty, and village politics.",
		"familial": {"npc": "Maestro al-Rashid", "subkind": "distant_kin", "notes": "Extended family across traditions."},
		"friendly": {"npc": "Samira", "subkind": "care_network", "notes": "Shares remedies for the poor."},
	},
	"Zahra": {
		"id": "zahra",
		"backstory": "Ceramic artisan who speaks through pattern, clay, and fire.",
		"familial": {"npc": "Samira", "subkind": "cousin", "notes": "Both learned craft from family elders."},
		"friendly": {"npc": "Maestro al-Rashid", "subkind": "scholar_friend", "notes": "Exchanges motifs and texts."},
	},
	"Maestro al-Rashid": {
		"id": "maestro_al_rashid",
		"backstory": "Elder teacher who treats language as a bridge, not a wall.",
		"familial": {"npc": "Father Domingo", "subkind": "distant_uncle", "notes": "Maintains a respectful kin bond."},
		"friendly": {"npc": "Zahra", "subkind": "mentor_friend", "notes": "Supports her craft and students."},
	},
	"Maryam": {
		"id": "maryam",
		"backstory": "Tailor whose quiet kindness keeps households functioning.",
		"familial": {"npc": "Qadir", "subkind": "younger_sister", "notes": "Field family roots, city shop hands."},
		"friendly": {"npc": "Nura", "subkind": "confidante", "notes": "Shares repairs, rumors, and caution."},
	},
	"Qadir": {
		"id": "qadir",
		"backstory": "Field manager who measures people by work done before dusk.",
		"familial": {"npc": "Maryam", "subkind": "older_brother", "notes": "Still shields her from village pressure."},
		"friendly": {"npc": "Rafiq", "subkind": "work_ally", "notes": "Harvest and storage depend on both."},
	},
}

const RELATIONSHIPS := [
	{"id": "rel_merchant_baker_siblings", "source_id": "merchant", "target_id": "baker", "kind": "familial", "subkind": "sibling", "strength": 0.82, "reciprocal": true, "public": true},
	{"id": "rel_merchant_rafiq_trade", "source_id": "merchant", "target_id": "rafiq_al_amin", "kind": "friendly", "subkind": "trade_ally", "strength": 0.67, "reciprocal": true, "public": false},
	{"id": "rel_baker_maryam_friend", "source_id": "baker", "target_id": "maryam", "kind": "friendly", "subkind": "trusted_friend", "strength": 0.74, "reciprocal": true, "public": true},
	{"id": "rel_herbalist_zahra_cousins", "source_id": "herbalist", "target_id": "zahra", "kind": "familial", "subkind": "cousin", "strength": 0.78, "reciprocal": true, "public": true},
	{"id": "rel_hamid_qadir_kin", "source_id": "old_hamid", "target_id": "qadir", "kind": "familial", "subkind": "uncle_in_law", "strength": 0.64, "reciprocal": true, "public": true},
	{"id": "rel_blacksmith_tarik_foster", "source_id": "ibrahim_al_hadid", "target_id": "tarik", "kind": "familial", "subkind": "foster_father", "strength": 0.9, "reciprocal": true, "public": true},
	{"id": "rel_blacksmith_rodrigo_comrades", "source_id": "ibrahim_al_hadid", "target_id": "capitan_rodrigo", "kind": "friendly", "subkind": "old_comrade", "strength": 0.69, "reciprocal": true, "public": true},
	{"id": "rel_abbas_salim_cousins", "source_id": "abbas", "target_id": "salim", "kind": "familial", "subkind": "cousin", "strength": 0.58, "reciprocal": true, "public": true},
	{"id": "rel_salim_nura_siblings", "source_id": "salim", "target_id": "nura", "kind": "familial", "subkind": "younger_brother", "strength": 0.8, "reciprocal": true, "public": true},
	{"id": "rel_salim_tarik_friends", "source_id": "salim", "target_id": "tarik", "kind": "friendly", "subkind": "work_friend", "strength": 0.62, "reciprocal": true, "public": false},
	{"id": "rel_rafiq_nura_siblings", "source_id": "rafiq_al_amin", "target_id": "nura", "kind": "familial", "subkind": "older_brother", "strength": 0.85, "reciprocal": true, "public": true},
	{"id": "rel_nura_maryam_confidantes", "source_id": "nura", "target_id": "maryam", "kind": "friendly", "subkind": "confidante", "strength": 0.71, "reciprocal": true, "public": false},
	{"id": "rel_rodrigo_domingo_allies", "source_id": "capitan_rodrigo", "target_id": "father_domingo", "kind": "friendly", "subkind": "civic_ally", "strength": 0.55, "reciprocal": true, "public": true},
	{"id": "rel_domingo_rashid_kin", "source_id": "father_domingo", "target_id": "maestro_al_rashid", "kind": "familial", "subkind": "distant_kin", "strength": 0.6, "reciprocal": true, "public": false},
	{"id": "rel_zahra_rashid_scholarship", "source_id": "zahra", "target_id": "maestro_al_rashid", "kind": "friendly", "subkind": "scholar_friend", "strength": 0.77, "reciprocal": true, "public": true},
	{"id": "rel_maryam_qadir_siblings", "source_id": "maryam", "target_id": "qadir", "kind": "familial", "subkind": "younger_sister", "strength": 0.83, "reciprocal": true, "public": true},
	{"id": "rel_qadir_rafiq_work", "source_id": "qadir", "target_id": "rafiq_al_amin", "kind": "friendly", "subkind": "work_ally", "strength": 0.66, "reciprocal": true, "public": true},
]

## Household groupings by NPC display names. Families should share a home.
const DWELLINGS := {
	"home_market_row": {
		"id": "home_market_row",
		"label": "Market Row House",
		"zone": "market",
		"residents": ["Yusuf", "Amina"],
	},
	"home_workshop_court": {
		"id": "home_workshop_court",
		"label": "Workshop Court House",
		"zone": "workshop",
		"residents": ["Samira", "Zahra"],
	},
	"home_smithy_loft": {
		"id": "home_smithy_loft",
		"label": "Smithy Loft",
		"zone": "blacksmith",
		"residents": ["Ibrahim", "Tarik", "Capitan Rodrigo"],
	},
	"home_warehouse_quarters": {
		"id": "home_warehouse_quarters",
		"label": "Warehouse Quarters",
		"zone": "warehouse",
		"residents": ["Abbas", "Rafiq", "Salim", "Nura"],
	},
	"home_field_house": {
		"id": "home_field_house",
		"label": "Field House",
		"zone": "fields",
		"residents": ["Old Hamid", "Qadir", "Maryam"],
	},
	"home_school_residence": {
		"id": "home_school_residence",
		"label": "School Residence",
		"zone": "school",
		"residents": ["Maestro al-Rashid", "Father Domingo"],
	},
}

static var _dwelling_by_npc: Dictionary = {}
static var _dwelling_validation_ran: bool = false

static func _ensure_dwelling_index() -> void:
	if _dwelling_by_npc.is_empty():
		for dwelling in DWELLINGS.values():
			for display_name in dwelling.get("residents", []):
				_dwelling_by_npc[str(display_name)] = dwelling

	if not _dwelling_validation_ran:
		_dwelling_validation_ran = true
		_validate_families_share_dwellings()
		_validate_profile_families_share_dwellings()

static func _validate_families_share_dwellings() -> void:
	for rel in RELATIONSHIPS:
		if rel.get("kind", "") != "familial":
			continue
		var source_name := _name_for_profile_id(str(rel.get("source_id", "")))
		var target_name := _name_for_profile_id(str(rel.get("target_id", "")))
		if source_name == "" or target_name == "":
			continue
		var source_home := get_dwelling_for_npc(source_name)
		var target_home := get_dwelling_for_npc(target_name)
		if source_home.is_empty() or target_home.is_empty():
			push_warning("Familial relation missing dwelling: %s <-> %s" % [source_name, target_name])
			continue
		if str(source_home.get("id", "")) != str(target_home.get("id", "")):
			push_warning("Familial residents split across dwellings: %s <-> %s" % [source_name, target_name])

static func _validate_profile_families_share_dwellings() -> void:
	for display_name in PROFILES.keys():
		var profile: Dictionary = PROFILES[display_name]
		var familial: Dictionary = profile.get("familial", {})
		var related_name := str(familial.get("npc", ""))
		if related_name == "" or not PROFILES.has(related_name):
			continue
		var source_home := get_dwelling_for_npc(str(display_name))
		var target_home := get_dwelling_for_npc(related_name)
		if source_home.is_empty() or target_home.is_empty():
			push_warning("Profile familial relation missing dwelling: %s <-> %s" % [str(display_name), related_name])
			continue
		if str(source_home.get("id", "")) != str(target_home.get("id", "")):
			push_warning("Profile familial residents split across dwellings: %s <-> %s" % [str(display_name), related_name])

static func _name_for_profile_id(profile_id: String) -> String:
	for display_name in PROFILES.keys():
		var profile: Dictionary = PROFILES[display_name]
		if str(profile.get("id", "")) == profile_id:
			return str(display_name)
	return ""

static func get_dwelling_for_npc(display_name: String) -> Dictionary:
	_ensure_dwelling_index()
	return _dwelling_by_npc.get(display_name, {})

static func get_profile(display_name: String) -> Dictionary:
	return PROFILES.get(display_name, {})

static func get_relationships_for_profile_id(profile_id: String, kind_filter: String = "") -> Array:
	var out: Array = []
	for rel in RELATIONSHIPS:
		if rel.get("source_id", "") != profile_id and rel.get("target_id", "") != profile_id:
			continue
		if kind_filter != "" and rel.get("kind", "") != kind_filter:
			continue
		out.append(rel)
	return out

static func build_dialogue_lines(display_name: String) -> PackedStringArray:
	var profile := get_profile(display_name)
	if profile.is_empty():
		return PackedStringArray()

	var familial: Dictionary = profile.get("familial", {})
	var friendly: Dictionary = profile.get("friendly", {})
	var lines: PackedStringArray = []
	var dwelling := get_dwelling_for_npc(display_name)

	if not dwelling.is_empty():
		lines.append("Home: %s." % [str(dwelling.get("label", "Village Home"))])

	if familial.has("npc"):
		lines.append("Family: %s is my %s." % [familial["npc"], str(familial.get("subkind", "kin"))])
	if friendly.has("npc"):
		lines.append("Friend: I trust %s." % [friendly["npc"]])
	if profile.has("backstory"):
		lines.append("Story: %s" % [profile["backstory"]])

	return lines
