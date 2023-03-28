val get_id : Dream.websocket -> int
val remove : int -> Dream.websocket -> unit Lwt.t
val replace : int -> Dream.websocket * string list * int * int -> unit
val find : int -> Dream.websocket * string list * int * int
val list : unit -> (int * (Dream.websocket * string list * int * int)) list
val disconnect_inactive : unit -> unit Lwt.t
val erase_scores : unit -> unit
val rank : int -> int
