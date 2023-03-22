let game_on = ref false
let grid = ref ""
let solutions = ref []
let time = ref (Unix.time ())

(* Check if the data send by user is a latin credible word *)
let is_a_credible_word w =
  String.fold_left
    (fun a c ->
       a && Char.code 'A' <= Char.code c && Char.code c <= Char.code 'Z')
    (3 <= String.length w && String.length w <= 16)
    w

let handle_client client =
  let client_id = Client.get_id Parameters.max_number_of_clients client in
  (* Handle its websockets *)
  let rec handle_socket () =
    match%lwt Dream.receive client with
    | Some word when is_a_credible_word word ->
      if !game_on then
        let s, client_sol, p, nb0 = Client.find client_id in
        if List.mem word client_sol then
          let%lwt () = Send.secured client_id client ("2" ^ word) in
          handle_socket ()
        else if List.mem word !solutions then (
          Client.replace client_id
            (s, word :: client_sol, p + Parameters.points.(String.length word), nb0);
          let%lwt () = Send.secured client_id client ("1" ^ word) in
          handle_socket ())
        else
          let%lwt () = Send.secured client_id client ("0" ^ word) in
          handle_socket ()
      else handle_socket ()
    | _ (* Disconnected client or corrupted data *) ->
      Client.remove client_id client
  in
  if client_id > 0 then
    let%lwt () =
      Send.send_game_status !game_on !grid Parameters.game_duration Parameters.solutions_duration
        !time client_id client
    in
    handle_socket ()
  else Dream.close_websocket client

let games =
  let game_generator =
    Game.create Parameters.dictionary Parameters.min_number_of_solutions_for_a_grid
      Parameters.max_number_of_solutions_for_a_grid
  in
  let rec endless_game () =
    (* Create a game *)
    let new_grid, new_solutions = game_generator () in
    grid := new_grid;
    solutions := new_solutions;
    Client.erase_scores ();
    let%lwt () =
      Client.disconnect_inactive_clients Parameters.max_number_of_games_with_score_0
    in
    time := Unix.time ();
    game_on := true;
    let%lwt () = Send.to_all ("g" ^ !grid) in
    (* Game start *)
    let%lwt () = Lwt_unix.sleep Parameters.game_duration in
    (* End of game *)
    game_on := false;
    time := Unix.time ();
    let%lwt () = Send.solutions !solutions Parameters.points in
    let%lwt () = Send.rank () in
    (* Show solutions and ranking *)
    let%lwt () = Lwt_unix.sleep Parameters.solutions_duration in
    endless_game ()
  in
  endless_game

let () =
  Lwt.async games;
  Dream.run ~interface:"0.0.0.0" ~port:8080
  @@ Dream.logger
  @@ Dream.router
    [
      Dream.get "/" (Dream.from_filesystem "static" "main.html");
      Dream.get "/regles" (Dream.from_filesystem "static" "regles.html");
      Dream.get "/static/**" (Dream.static "./static");
      Dream.get "/images/**" (Dream.static "./images");
      Dream.get "/websocket" (fun _ -> Dream.websocket handle_client);
    ]
