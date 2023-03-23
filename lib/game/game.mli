val solutions : Dictionary.dictionary -> string -> string list
(** [solutions d g] returns a list of words from [d] feasible in [g]. 
    It internally finds all the possible paths in the grid that produces a given solution. *)

val create : string -> int -> int -> unit -> string * string list
(** [create file_name min_solutions_for_a_grid max_solutions_for_a_grid] returns a function to create grid and its solutions. *)