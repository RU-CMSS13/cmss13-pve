#define HALO_CPL_VARIANT "Corporal"
#define HALO_LCPL_VARIANT "Lance Corporal"
#define HALO_PFC_VARIANT "Private First Class"
#define HALO_PVT_VARIANT "Private"

#define USCM_RTO_LCPL_VARIANT "Lance Corporal"
#define USCM_RTO_PFC_VARIANT "Private First Class"

/datum/job/marine/standard/ai/rto/handle_job_options(option)
	gear_preset = initial(gear_preset)
	if(option == USCM_RTO_PFC_VARIANT)
		gear_preset = gear_preset_quaternary
	if(option == USCM_RTO_LCPL_VARIANT)
		gear_preset = gear_preset_secondary

/datum/job/marine/standard/ai/rto/halo/unsc/handle_job_options(option)
	gear_preset = initial(gear_preset)
	if(option == HALO_PFC_VARIANT)
		gear_preset = gear_preset_secondary

/datum/job/marine/standard/ai/rto/halo/odst/handle_job_options(option)
	gear_preset = initial(gear_preset)
	if(option == HALO_PFC_VARIANT)
		gear_preset = gear_preset_secondary

/datum/job/marine/standard/ai/halo/odst/handle_job_options(option)
	gear_preset = initial(gear_preset)
	if(option == HALO_PFC_VARIANT)
		gear_preset = gear_preset_secondary

/datum/job/marine/medic/ai/halo/unsc/handle_job_options(option)
	gear_preset = initial(gear_preset)
	if(option == HALO_PVT_VARIANT)
		gear_preset = gear_preset_quaternary
	if(option == HALO_PFC_VARIANT)
		gear_preset = gear_preset_tertiary
	if(option == HALO_LCPL_VARIANT)
		gear_preset = gear_preset_secondary

#undef USCM_RTO_LCPL_VARIANT
#undef USCM_RTO_PFC_VARIANT

/datum/job/marine/medic/ai/halo/odst/handle_job_options(option)
	gear_preset = initial(gear_preset)
	if(option == HALO_PVT_VARIANT)
		gear_preset = gear_preset_quaternary
	if(option == HALO_PFC_VARIANT)
		gear_preset = gear_preset_tertiary
	if(option == HALO_LCPL_VARIANT)
		gear_preset = gear_preset_secondary
