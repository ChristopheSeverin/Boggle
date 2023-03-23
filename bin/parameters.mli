val game_duration : float
(** A game lasts [game_duration] seconds. *)

val solutions_duration : float
(** Solutions are displayed [solutions_duration] seconds. *)

val points : int array
(** Words of length [i] brings [points.(i)] points. *)

val min_number_of_solutions_for_a_grid : int
(** Minimum number of solutions that a grid must contain to be considered. 
    {b Warning}: too high value causes the grid producer to loop, it depends on your dictionary. *)

val max_number_of_solutions_for_a_grid : int
(** Maximal number of solutions a grid should contain to be considered. *)

val dictionary : string 
(** Dictionary file name with its path from the root. 
    {b Warning}: client side of this project do not handles non-latin characters. *)

val max_number_of_clients : int 
(** Maximal number of clients allowed to play simultaneously. *)

val max_number_of_games_with_score_0 : int 
(** Client are disconnected after [max_number_of_games_with_score_0] game with 0 points. *)