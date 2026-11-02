#define STAMINA_LEVEL_1 /datum/effects/stamina/human/tier1
#define STAMINA_LEVEL_2 /datum/effects/stamina/human/tier2
#define STAMINA_LEVEL_3  /datum/effects/stamina/human/tier3
#define STAMINA_LEVEL_4 /datum/effects/stamina/human/tier4
#define STAMINA_LEVEL_5  /datum/effects/stamina/human/tier5

#define STAMINA_INCREASE_RATE 6

#define STAMINA_REST_PERIOD 3 SECONDS // Seconds before stamina can regen again

// Sprint stamina, spent by running (see /datum/component/sprint)
#define SPRINT_MAX 100
/// Before gear, body and endurance skill modifiers
#define SPRINT_COST_PER_STEP 1
/// Cheapest a running step can get after all modifiers
#define SPRINT_COST_MIN 0.25
/// Per second, while standing still
#define SPRINT_REGEN_RATE 8
#define SPRINT_REGEN_MOVING_MULT 0.6
/// Lying down or sitting
#define SPRINT_REGEN_RESTING_MULT 1.5
/// A step taken this recently counts as still moving for regeneration
#define SPRINT_MOVING_WINDOW 1.5 SECONDS
/// Time after the last running step before sprint stamina starts to regenerate
#define SPRINT_REGEN_DELAY 1.5 SECONDS
/// Needed to switch back to running after running out
#define SPRINT_MIN_TO_RUN 20
/// Must match the sprint0..sprintN icon states in every human HUD style
#define SPRINT_BAR_STEPS 20
/// Tint of the bar while there is too little sprint stamina to start running
#define SPRINT_BAR_WINDED_COLOR "#ff6060"
