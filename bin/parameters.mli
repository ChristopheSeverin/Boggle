val game_duration : float
(** A game lasts [game_duration] seconds *)
val solutions_duration : float
(** Solutions are displayed [solutions_duration] seconds *)

val points : int array
(** Words of length [i] brings [points.(i)] points *)

val min_number_of_solutions_for_a_grid : int
val max_number_of_solutions_for_a_grid : int

val dictionary : string (** dictionary file name *)
val max_number_of_clients : int (** Maximal number of clients allowed to play simultaneously *)
val max_number_of_games_with_score_0 : int 
(** Client are disconnected after [max_number_of_games_with_score_0] game with 0 points *)