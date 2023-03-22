let secured id s m =
  Lwt.catch
    (fun () -> Dream.send s m)
    (fun _ ->
      Hashtbl.remove Client.clients id;
      Dream.close_websocket s)

let to_all message =
  let clients_list =
    Hashtbl.fold (fun id (s, _, _, _) l -> (id, s) :: l) Client.clients []
  in
  List.map (fun (id, s) -> secured id s message) clients_list |> Lwt.join

let rank () =
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
      Client.clients []
  in
  let rank_word =
    List.fold_left
      (fun s (p, sp) ->
        if s = "" then Printf.sprintf "r%d:%s" p sp
        else s ^ Printf.sprintf " %d:%s" p sp)
      "" rank_list
  in
  to_all rank_word

let solutions solutions points =
  let solutions_string = String.concat " " solutions in
  let max_points =
    List.fold_left (fun res w -> res + points.(String.length w)) 0 solutions
  in
  let message = Printf.sprintf "s%d " max_points ^ solutions_string in
  to_all message

let send_game_status game_on grid game_duration solutions_duration time
    client_id client =
  (* Send game status to the new client *)
  if game_on then
    secured client_id client
      (Printf.sprintf "n%d 1 %s %.0f" client_id grid
         (game_duration -. Unix.time () +. time))
  else
    secured client_id client
      (Printf.sprintf "n%d 0 %s %.0f" client_id grid
         (solutions_duration -. Unix.time () +. time))
