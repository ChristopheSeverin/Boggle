(* Clients' data : id -> (socket, words found, score, nb of consecutives games with score 0) *)
let clients : (int, Dream.websocket * string list * int * int) Hashtbl.t =
  Hashtbl.create 100
(* Accesses to clients must be synchronized *)

let get_id websocket =
  let rec find_valid_id n =
    if n > Parameters.max_number_of_clients then find_valid_id 1
    else if Hashtbl.mem clients n then find_valid_id (n + 1)
    else n
  in
  let last_client_id = ref 0 in
  if Hashtbl.length clients < Parameters.max_number_of_clients then (
    last_client_id := find_valid_id (!last_client_id + 1);
    Hashtbl.replace clients !last_client_id (websocket, [], 0, 0);
    !last_client_id)
  else 0

let remove client_id client =
  Hashtbl.remove clients client_id;
  Dream.close_websocket client

let replace = Hashtbl.replace clients
let find = Hashtbl.find clients
let list () = Hashtbl.fold (fun id data l -> (id, data) :: l) clients []

let disconnect_inactive () =
  let clients_to_be_removed =
    Hashtbl.fold
      (fun i (s, _, _, n) l ->
        if n >= Parameters.max_number_of_games_with_score_0 then (i, s) :: l
        else l)
      clients []
  in
  List.map (fun (i, s) -> remove i s) clients_to_be_removed |> Lwt.join

let erase_scores () =
  Hashtbl.filter_map_inplace
    (fun _ (s, _, pt, n) -> Some (s, [], 0, if pt = 0 then n + 1 else 0))
    clients

let rank p =
  Hashtbl.fold
    (fun _ (_, _, pt, _) res -> if pt > p then res + 1 else res)
    clients 1
