mod test_tournament_system {
    use contracts::modules::tournaments::TournamentSystem::{ITournamentSystemDispatcher, ITournamentSystemDispatcherTrait};
    use starknet::ContractAddress;
    use snforge_std::{ContractClassTrait, DeclareResultTrait, declare, start_cheat_caller_address};

    fn OWNER() -> ContractAddress {
        'OWNER'.try_into().unwrap()
    }

    fn deploy_tournament_system() -> ITournamentSystemDispatcher {
        let contract = declare("TournamentSystem").unwrap().contract_class();

        let mut calldata: Array<felt252> = array![];

        let (contract_address, _) = contract.deploy(@calldata).unwrap();
        let tournament_system = ITournamentSystemDispatcher { contract_address };

        tournament_system
    }

    #[test]
    fn test_create_tournament() {
        let tournament_system = deploy_tournament_system();

        let tournament_name = 'Test Tournament';
        let tournament_description: Option<felt252> = Option::Some('This is a test tournament');
        let tournament_start_date = 1716796800;
        let tournament_end_date = 1716796800;
        let tournament_entry_fee = 1000000000000000000;
        let tournament_max_players = 10;
        let tournament_is_public = true;
        let tournament_creator_address = OWNER();

        start_cheat_caller_address(tournament_system.contract_address, OWNER());
        tournament_system.create_tournament(
            tournament_name,
            tournament_description,
            tournament_start_date,
            tournament_end_date,
            tournament_entry_fee,
            tournament_max_players,
            tournament_is_public,
            tournament_creator_address
        );
    }
}
