let game_duration = 180.0 
let solutions_duration = 35.0 

let points =
  [| 0; 0; 0; 1; 1; 2; 4; 8; 16; 32; 64; 128; 256; 512; 1024; 2048; 4096 |]

let min_number_of_solutions_for_a_grid = 0
and max_number_of_solutions_for_a_grid = 400

let dictionary = "dictionaries/fr.txt"
let max_number_of_clients = 300
let max_number_of_games_with_score_0 = 3