let game_on = ref false
let game_duration = 50.0 (* in seconds *)
let solutions_duration = 40.0 (* in seconds *)
let time = ref (Unix.time ())
let max_number_of_clients = 5
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
  Hashtbl.iter
    (fun i (s, _, _, n) ->
      if n >= max_number_of_games_with_score_0 then ignore (remove_client i s))
    clients

let erase_scores () =
  Hashtbl.filter_map_inplace
    (fun _ (s, _, pt, n) -> Some (s, [], 0, if pt = 0 then n + 1 else 0))
    clients

(* Send data to clients *)
let send_to_all_clients message =
  Hashtbl.iter (fun _ (s, _, _, _) -> ignore (Dream.send s message)) clients

let send_grid () = send_to_all_clients ("g" ^ !Boggle.grid)

let send_rank () =
  let rec insert_rank (p, client_id) l_rank =
    let client_id_string = Printf.sprintf "%d" client_id in
    match l_rank with
    | [] -> [ (p, client_id_string) ]
    | (p1, s) :: l when p = p1 -> (p1, client_id_string ^ "," ^ s) :: l
    | (p1, s) :: l when p < p1 -> (p1, s) :: insert_rank (p, client_id) l
    (* p > p1 *)
    | _ -> (p, client_id_string) :: l_rank
  in
  let rank_list =
    Hashtbl.fold
      (fun client_id (_, _, p, _) l -> insert_rank (p, client_id) l)
      clients []
  in
  let rank =
    List.fold_left
      (fun s (p, sp) ->
        if s = "" then Printf.sprintf "r%d:%s" p sp
        else s ^ Printf.sprintf " %d:%s" p sp)
      "" rank_list
  in
  send_to_all_clients rank

let send_solutions () =
  let solutions = String.concat " " !Boggle.solutions in
  let message = Printf.sprintf "s%d " !Boggle.max_grid_points ^ solutions in
  send_to_all_clients message

(* Check if the data send by user is a credible word *)
let is_a_credible_word w =
  String.fold_left
    (fun a c ->
      a && Char.code 'A' <= Char.code c && Char.code c <= Char.code 'Z')
    (3 <= String.length w && String.length w <= 16)
    w

let send_game_status client_id client =
  (* Send game status to the new client *)
  if !game_on then
    ignore
      (Dream.send client
         (Printf.sprintf "n%d 1 %s %.0f" client_id !Boggle.grid
            (game_duration -. Unix.time () +. !time)))
  else
    ignore
      (Dream.send client
         (Printf.sprintf "n%d 0 %s %.0f" client_id !Boggle.grid
            (solutions_duration -. Unix.time () +. !time)))

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
  if client_id > 0 then (
    send_game_status client_id client;
    handle_socket ())
  else Dream.close_websocket client

let rec games () =
  (* Create a game *)
  Boggle.new_grid ();
  erase_scores ();
  disconnect_inactive_clients ();
  time := Unix.time ();
  game_on := true;
  send_grid ();
  (* Game start *)
  let%lwt () = Lwt_unix.sleep game_duration in
  (* End of game *)
  time := Unix.time ();
  game_on := false;
  send_solutions ();
  send_rank ();
  (* Show solutions and ranking *)
  let%lwt () = Lwt_unix.sleep solutions_duration in
  games ()

let () =
  Lwt.async (fun () -> games ());
  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/" (Dream.from_filesystem "static" "main.html");
         Dream.get "/regles" (Dream.from_filesystem "static" "regles.html");
         Dream.get "/static/**" (Dream.static "./static");
         Dream.get "/websocket" (fun _ -> Dream.websocket handle_client);
       ]
