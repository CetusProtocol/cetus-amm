module cetus_amm::amm_config {
     use sui::object::{Self, UID, ID};
    struct GlobalPauseStatus has key {
        id: UID,
        pause: bool,
    }
}