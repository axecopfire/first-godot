class_name ScheduleConfig
extends RefCounted

const DEFAULT_MORNING_HOUR := 7
const DEFAULT_EVENING_HOUR := 18

## Hours that trigger the bell and how many times it strikes.
## 1 = dawn, 2 = noon, 3 = evening, 4 = night.
const BELL_SCHEDULE: Dictionary = { 6: 1, 12: 2, 18: 3, 21: 4 }

const DEV_TIME_PRESETS := [
	{"label": "Set Time: Dawn (06:00)", "hour": 6},
	{"label": "Set Time: Morning (09:00)", "hour": 9},
	{"label": "Set Time: Noon (12:00)", "hour": 12},
	{"label": "Set Time: Afternoon (15:00)", "hour": 15},
	{"label": "Set Time: Evening (18:00)", "hour": 18},
	{"label": "Set Time: Night (21:00)", "hour": 21},
	{"label": "Set Time: Midnight (00:00)", "hour": 0},
]

const NPC_WORK_HOURS: Dictionary = {
	"Yusuf": {"morning_hour": 8, "evening_hour": 18},
	"Amina": {"morning_hour": 5, "evening_hour": 18},
	"Samira": {"morning_hour": 7, "evening_hour": 18},
	"Old Hamid": {"morning_hour": 6, "evening_hour": 18},
	"Ibrahim": {"morning_hour": 7, "evening_hour": 18},
	"Tarik": {"morning_hour": 7, "evening_hour": 18},
	"Abbas": {"morning_hour": 5, "evening_hour": 18},
	"Rafiq": {"morning_hour": 8, "evening_hour": 18},
	"Salim": {"morning_hour": 7, "evening_hour": 18},
	"Nura": {"morning_hour": 8, "evening_hour": 18},
	"Capitan Rodrigo": {"morning_hour": 6, "evening_hour": 18},
	"Father Domingo": {"morning_hour": 6, "evening_hour": 18},
	"Zahra": {"morning_hour": 8, "evening_hour": 18},
	"Maestro al-Rashid": {"morning_hour": 7, "evening_hour": 18},
	"Maryam": {"morning_hour": 8, "evening_hour": 18},
	"Qadir": {"morning_hour": 6, "evening_hour": 18},
}

static func get_npc_work_hours(npc_name: String) -> Dictionary:
	var hours: Dictionary = NPC_WORK_HOURS.get(npc_name, {}) as Dictionary
	return {
		"morning_hour": int(hours.get("morning_hour", DEFAULT_MORNING_HOUR)),
		"evening_hour": int(hours.get("evening_hour", DEFAULT_EVENING_HOUR)),
	}
