#define RUV_MODE_MANUAL "manual"
#define RUV_MODE_AUTO "auto"

#define RUV_ORDER_HOLD "hold"
#define RUV_ORDER_FOLLOW "follow"
#define RUV_ORDER_ATTACK "attack"
#define RUV_ORDER_INTERACT "interact"

/// Charge drained every second while the drone has power, whether it is used or not
#define RUV_IDLE_DRAIN 0.5
#define RUV_STEP_COST 1
/// Charge used by one trigger pull of the sentry module, the whole burst included
#define RUV_SHOT_COST 2
/// Charge used by one swing, grab or button press of the arm module
#define RUV_ARM_COST 3

#define RUV_MOVE_DELAY 3
#define RUV_PULL_SLOWDOWN 2
/// How close a following drone stays to whoever it follows
#define RUV_FOLLOW_DISTANCE 2
#define RUV_PATH_RANGE 30
/// Added to the move delay of whoever carries the RUV in hand
#define RUV_CARRY_SLOWDOWN 3

#define TRAIT_SOURCE_RUV_ARM "ruv_arm"
