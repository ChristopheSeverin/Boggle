val solutions : (string, string) Hashtbl.t
(** [solutions] is a hashtable that contains current solutions in format (Parameters.to_upper_case word, word) *)

val create : unit -> string
(** [create ()] returns a function to create grid and update [solutions]. *)
