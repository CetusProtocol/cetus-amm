module cetus_amm::amm_config {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::event;

    struct GlobalPauseStatus has key {
        id: UID,
        pause: bool,
    }

    struct SetPauseEvent has copy, drop {
        sender: address,
        status: bool
    }

    public fun new_global_pause_status(ctx: &mut TxContext): GlobalPauseStatus {
        GlobalPauseStatus {
            id: object::new(ctx),
            pause: false
        }
    }

    public fun get_pause_status(global_pause_status: &GlobalPauseStatus): bool {
        global_pause_status.pause
    }

    public fun set_status_and_emit_event(global_pause_status: &mut GlobalPauseStatus, status: bool, ctx: &mut TxContext) {
        global_pause_status.pause = status;

        event::emit(SetPauseEvent{
            sender: tx_context::sender(ctx),
            status
        });
    }
}