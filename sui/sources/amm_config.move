module cetus_amm::amm_config {
    friend cetus_amm::amm_router;
    friend cetus_amm::amm_swap;

    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::event;
    use sui::transfer;

    const EPoolPause: u64 = 1;

    struct GlobalPauseStatus has key {
        id: UID,
        pause: bool,
    }

    struct SetPauseEvent has copy, drop {
        sender: address,
        status: bool
    }

    public(friend) fun new_global_pause_status_and_shared(ctx: &mut TxContext): ID {
        let global_paulse_status = GlobalPauseStatus {
            id: object::new(ctx),
            pause: false
        };

        let id = object::id(&global_paulse_status);
        transfer::share_object (global_paulse_status);
        id
    }

    fun get_pause_status(global_pause_status: &GlobalPauseStatus): bool {
        global_pause_status.pause
    }

    public(friend) fun set_status_and_emit_event(global_pause_status: &mut GlobalPauseStatus, status: bool, ctx: &mut TxContext) {
        global_pause_status.pause = status;

        event::emit(SetPauseEvent{
            sender: tx_context::sender(ctx),
            status
        });
    }

    public fun assert_pause(global_pause_status: &GlobalPauseStatus) {
        assert!(
            !get_pause_status(global_pause_status),
            EPoolPause);
    }
}