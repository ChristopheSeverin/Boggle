let secured id s m =
  Lwt.catch (fun () -> Dream.send s m) (fun _ -> Client.remove id s)

let to_all message =
  List.map (fun (id, (s, _, _, _)) -> secured id s message) (Client.list ())
  |> Lwt.join

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
    List.fold_left
      (fun l (client_id, (_, _, p, _)) -> insert_rank (p, client_id) l)
      [] (Client.list ())
  in
  let rank_word =
    List.fold_left
      (fun s (p, sp) ->
        if s = "" then Printf.sprintf "r%d:%s" p sp
        else s ^ Printf.sprintf " %d:%s" p sp)
      "" rank_list
  in
  to_all rank_word

let solutions () =
  let solutions_string =
    let module M = Map.Make (String) in
    let solutions_map =
      Hashtbl.fold
        (fun w w_unicode res -> M.add w w_unicode res)
        Game.solutions M.empty
    in
    M.fold (fun _ w_unicode res -> res ^ " " ^ w_unicode) solutions_map ""
  in
  let max_points =
    Hashtbl.fold
      (fun w _ res -> res + Parameters.points.(String.length w))
      Game.solutions 0
  in
  let message = Printf.sprintf "s%d" max_points ^ solutions_string in
  to_all message

let send_game_status game_on grid time client_id client =
  (* Send game status to the new client *)
  if game_on then
    secured client_id client
      (Printf.sprintf "n%d 1 %s %.0f" client_id grid
         (Parameters.game_duration -. Unix.time () +. time))
  else
    secured client_id client
      (Printf.sprintf "n%d 0 %s %.0f" client_id grid
         (Parameters.solutions_duration -. Unix.time () +. time))
