/datum/paygrade/upp
	name = "UPP Paygrade"
	pay_multiplier = 0.1 //lol. lmao
	default_faction = FACTION_UPP


//UPP Enlisted

/datum/paygrade/upp/ue1
	paygrade = PAY_SHORT_UE1
	name = "Private"
	prefix = "Pvt."
	rank_pin = /obj/item/clothing/accessory/ranks/upp/ue1
	
/datum/paygrade/upp/ue2
	paygrade = PAY_SHORT_UE2
	name = "Senior Private"
	prefix = "SrPvt."
	rank_pin = /obj/item/clothing/accessory/ranks/upp/ue2
	pay_multiplier = 0.3
	
/datum/paygrade/upp/ue3
	paygrade = PAY_SHORT_UE3
	name = "Junior Sergeant"
	prefix = "JrSgt."
	rank_pin = /obj/item/clothing/accessory/ranks/upp/ue3
	pay_multiplier = 0.5
	
/datum/paygrade/upp/ue4
	paygrade = PAY_SHORT_UE4
	name = "Sergeant"
	prefix = "Sgt."
	rank_pin = /obj/item/clothing/accessory/ranks/upp/ue4
	pay_multiplier = 0.7
	
/datum/paygrade/upp/ue5
	paygrade = PAY_SHORT_UE5
	name = "Senior Sergeant"
	prefix = "SrSgt."
	rank_pin = /obj/item/clothing/accessory/ranks/upp/ue5
	pay_multiplier = 0.9
	
/datum/paygrade/upp/ue6
	paygrade = PAY_SHORT_UE6
	name = "Sergeant Major"
	prefix = "SgtMaj."
	rank_pin = /obj/item/clothing/accessory/ranks/upp/ue6
	pay_multiplier = 1

//UPP Commandos
/datum/paygrade/upp/uk1
	paygrade = "UK1"
	name = "Junior Kommando"
	prefix = "JKdo."
	pay_multiplier = 1.5

/datum/paygrade/upp/uk2
	paygrade = "UK2"
	name = "2nd Kommando"
	prefix = "2ndKdo."
	pay_multiplier = 2
	officer_grade = GRADE_OFFICER

/datum/paygrade/upp/uk3
	paygrade = "UK3"
	name = "1st Kommando"
	prefix = "1stKdo."
	pay_multiplier = 2.5
	officer_grade = GRADE_OFFICER

//UPP Officers
/datum/paygrade/upp/uo1
	paygrade = PAY_SHORT_UO1
	name = "Junior Lieutenant"
	prefix = "Jr. Lt."
	rank_pin = /obj/item/clothing/accessory/ranks/upp/uo1
	pay_multiplier = 1.25
	officer_grade = GRADE_OFFICER

/datum/paygrade/upp/uo2
	paygrade = PAY_SHORT_UO2
	name = "Senior Lieutenant"
	prefix = "Sr. LT."
	rank_pin = /obj/item/clothing/accessory/ranks/upp/uo2
	pay_multiplier = 1.5
	officer_grade = GRADE_OFFICER

/datum/paygrade/upp/uo3
	paygrade = PAY_SHORT_UO3
	name = "Captain"
	prefix = "Cpt."
	pay_multiplier = 2
	officer_grade = GRADE_OFFICER

/datum/paygrade/upp/uo4
	paygrade = PAY_SHORT_UO4
	name = "Major"
	prefix = "Mjr."
	pay_multiplier = 2.5
	officer_grade = GRADE_OFFICER

/datum/paygrade/upp/uo4p
	paygrade = PAY_SHORT_UO4P
	name = "Political Commissar"
	prefix = "Pol."
	pay_multiplier = 5
	officer_grade = GRADE_OFFICER

/datum/paygrade/upp/uo5
	paygrade = PAY_SHORT_UO5
	name = "Lieutenant Colonel"
	prefix = "Lt. Col."
	pay_multiplier = 3
	officer_grade = GRADE_OFFICER

/datum/paygrade/upp/uo6
	paygrade = PAY_SHORT_UO6
	name = "Colonel"
	prefix = "Col."
	pay_multiplier = 4
	officer_grade = GRADE_OFFICER

/datum/paygrade/upp/uo7
	paygrade = PAY_SHORT_UO7
	name = "Major General"
	prefix = "Maj. Gen."
	pay_multiplier = 5
	officer_grade = GRADE_FLAG

/datum/paygrade/upp/uo8
	paygrade = PAY_SHORT_UO8
	name = "Lieutenant General"
	prefix = "Lt. Gen."
	pay_multiplier = 6
	officer_grade = GRADE_FLAG

/datum/paygrade/upp/uo9
	paygrade = PAY_SHORT_UO9
	name = "Army General"
	prefix = "Gen."
	pay_multiplier = 7
	officer_grade = GRADE_FLAG

//UPP Colonists

/datum/paygrade/upp/militsiya
	paygrade = PAY_SHORT_UC1
	name = "Militsioner"
	prefix = "Milit."
	pay_multiplier = 0.3
