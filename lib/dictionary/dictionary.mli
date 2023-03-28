type dictionary =
  | Node of string * (char * dictionary) list
      (** Dictionary implemented as a multiway tree. *)

val add : string -> dictionary -> dictionary
(** [add w d] returns [d] where [w] is added. *)

val print : dictionary -> unit
(** [print d] print [d]. *)

val load : string -> dictionary
(** [load file_name] returns a dictionary containing words from file [file_name]. *)
