(** Dictionary implemented as a multiway tree *)
type dictionary = Node of bool * (char * dictionary) list

val add : string -> dictionary -> dictionary
(** [add w d] returns [d] where [w] is added *)

val print : dictionary -> unit
(** [print d] print [d] *)

val load : string -> dictionary
(** [load file_name] returns a dictionary containing words from file [file_name] *)