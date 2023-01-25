let game_on = ref false
let game_duration = 180.0 (* in seconds *)
let solutions_duration = 35.0 (* in seconds *)
let time = ref (Unix.time ())
let max_number_of_clients = 100
let max_number_of_games_with_score_0 = 3 (* Client disconnected after that *)

(* Clients' data : id -> (socket, words found, score, nb of consecutives games with score 0) *)
let clients : (int, Dream.websocket * string list * int * int) Hashtbl.t =
  Hashtbl.create 100

let get_id =
  let rec find_valid_id n =
    if n > max_number_of_clients then find_valid_id 1
    else if Hashtbl.mem clients n then find_valid_id (n + 1)
    else n
  in
  let last_client_id = ref 0 in
  fun websocket ->
    if Hashtbl.length clients < max_number_of_clients then (
      last_client_id := find_valid_id (!last_client_id + 1);
      Hashtbl.replace clients !last_client_id (websocket, [], 0, 0);
      !last_client_id)
    else 0

let remove_client client_id client =
  Hashtbl.remove clients client_id;
  Dream.close_websocket client

let disconnect_inactive_clients () =
  let clients_to_be_removed =
    Hashtbl.fold
      (fun i (s, _, _, n) l ->
        if n >= max_number_of_games_with_score_0 then (i, s) :: l else l)
      clients []
  in
  List.map (fun (i, s) -> remove_client i s) clients_to_be_removed |> Lwt.join

let erase_scores () =
  Hashtbl.filter_map_inplace
    (fun _ (s, _, pt, n) -> Some (s, [], 0, if pt = 0 then n + 1 else 0))
    clients

let rank p =
  Hashtbl.fold
    (fun _ (_, _, pt, _) res -> if pt > p then res + 1 else res)
    clients 1

let send_game_status client_id client =
  (* Send game status to the new client *)
  if !game_on then
    Dream.send client
      (Printf.sprintf "n%d 1 %s %.0f" client_id !Boggle.grid
         (game_duration -. Unix.time () +. !time))
  else
    Dream.send client
      (Printf.sprintf "n%d 0 %s %.0f" client_id !Boggle.grid
         (solutions_duration -. Unix.time () +. !time))

(* Check if the data send by user is a credible word *)
let is_a_credible_word w =
  String.fold_left
    (fun a c ->
      a && Char.code 'A' <= Char.code c && Char.code c <= Char.code 'Z')
    (3 <= String.length w && String.length w <= 16)
    w

let handle_client client =
  let client_id = get_id client in
  (* Handle its websockets *)
  let rec handle_socket () =
    match%lwt Dream.receive client with
    | Some word when is_a_credible_word word ->
        if !game_on then
          let s, client_sol, p, nb0 = Hashtbl.find clients client_id in
          if List.mem word client_sol then
            let%lwt () = Dream.send client ("2" ^ word) in
            handle_socket ()
          else if List.mem word !Boggle.solutions then (
            Hashtbl.replace clients client_id
              ( s,
                word :: client_sol,
                p + Boggle.points.(String.length word),
                nb0 );
            let%lwt () = Dream.send client ("1" ^ word) in
            handle_socket ())
          else
            let%lwt () = Dream.send client ("0" ^ word) in
            handle_socket ()
        else handle_socket ()
    | _ (* Disconnected client or corrupted data *) ->
        remove_client client_id client
  in
  if client_id > 0 then
    let%lwt () = send_game_status client_id client in
    handle_socket ()
  else Dream.close_websocket client

let rec games () =
  (* Create a game *)
  Boggle.new_grid ();
  erase_scores ();
  let%lwt () = disconnect_inactive_clients () in
  time := Unix.time ();
  game_on := true;
  let%lwt () = Send.to_all ("g" ^ !Boggle.grid) clients in
  (* Game start *)
  let%lwt () = Lwt_unix.sleep game_duration in
  (* End of game *)
  game_on := false;
  time := Unix.time ();
  let%lwt () = Send.solutions clients in
  let%lwt () = Send.rank clients in
  (* Show solutions and ranking *)
  let%lwt () = Lwt_unix.sleep solutions_duration in
  games ()

let () =
  Dream.log "Server start";
  Lwt.async games;
  Dream.run ~interface:"0.0.0.0" ~port:8080
  @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/" (Dream.from_filesystem "static" "main.html");
         Dream.get "/regles" (Dream.from_filesystem "static" "regles.html");
         Dream.get "/static/**" (Dream.static "./static");
         Dream.get "/websocket" (fun _ -> Dream.websocket handle_client);
       ]
