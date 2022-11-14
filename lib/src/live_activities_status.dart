/// LiveActivitiesState
/// * [active] : The Live Activity is active, visible to the user, and can receive content updates.
/// * [ended] : The Live Activity is visible, but the user, app, or system ended it, and it won't update its content anymore.
/// * [dismissed] : The Live Activity ended and is no longer visible because the user or the system removed it.
/// * [unknown]
enum LiveActivitiesState { active, ended, dismissed, unknown }
