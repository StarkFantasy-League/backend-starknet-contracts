use starknet::ContractAddress;

#[starknet::interface]
pub trait ITournamentSystem<ContractState> {
    fn create_tournament(
        ref self: ContractState,
        name: felt252,
        description: Option<felt252>,
        start_date: u64,
        end_date: u64,
        entry_fee: u128,
        max_players: u32,
        is_public: bool,
        creator_address: ContractAddress,
    );
}

#[starknet::contract]
mod TournamentSystem {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{
        Map, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess, StoragePathEntry, Vec, MutableVecTrait
    };
    use starknet::event::EventEmitter;

    #[derive(Drop, PartialEq, Clone, starknet::Store)]
    struct Tournament {
        id: u256,
        name: felt252,
        description: Option<felt252>,
        start_date: u64,
        end_date: u64,
        entry_fee: u128,
        max_players: u32,
        is_public: bool,
        creator_address: ContractAddress
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    struct TournamentCreated {
        id: u256,
        name: felt252,
    }

    #[storage]
    struct Storage {
        owner: ContractAddress,
        tournament_id: u256,
        tournaments: Map<u256, Tournament>,
        creator: Map<ContractAddress, Vec<u256>>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        TournamentCreated: TournamentCreated,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.tournament_id.write(1);
        self.owner.write(get_caller_address());
    }

    #[abi(embed_v0)]
    impl TournamentSystemImpl of super::ITournamentSystem<ContractState> {

        fn create_tournament(
            ref self: ContractState, 
            name: felt252, 
            description: Option<felt252>, 
            start_date: u64, 
            end_date: u64, 
            entry_fee: u128, 
            max_players: u32, 
            is_public: bool, 
            creator_address: ContractAddress
        ) {
            // Write the tournament to the storage
            let tournament = Tournament {
                id: self.tournament_id.read(),
                name,
                description,
                start_date,
                end_date,
                entry_fee,
                max_players,
                is_public,
                creator_address
            };
            self.tournaments.write(tournament.id.clone(), tournament.clone());
            self.tournament_id.write(tournament.id.clone() + 1);

            // Add the tournament to the creator's list
            let creator_tournaments = self.creator.entry(creator_address);
            creator_tournaments.push(tournament.id);
            self.creator.entry(get_caller_address()).push(tournament.id);

            // Emit the tournament created event
            self.emit(
                TournamentCreated {
                    id: tournament.id.clone(),
                    name: tournament.name.clone()
                }
            );
        }
    }

}
