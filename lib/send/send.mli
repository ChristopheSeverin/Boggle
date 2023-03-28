val secured : int -> Dream.websocket -> string -> unit Lwt.t
val to_all : string -> unit Lwt.t
val rank : unit -> unit Lwt.t
val solutions : unit -> unit Lwt.t

val send_game_status :
  bool -> string -> float -> int -> Dream.websocket -> unit Lwt.t
