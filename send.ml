let to_all message clients =
  Hashtbl.fold (fun _ (s, _, _, _) l -> Dream.send s message :: l) clients []
  |> Lwt.join

let rank clients =
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
  let rank_word =
    List.fold_left
      (fun s (p, sp) ->
        if s = "" then Printf.sprintf "r%d:%s" p sp
        else s ^ Printf.sprintf " %d:%s" p sp)
      "" rank_list
  in
  to_all rank_word clients

let solutions clients =
  let solutions = String.concat " " !Boggle.solutions in
  let message = Printf.sprintf "s%d " !Boggle.max_grid_points ^ solutions in
  to_all message clients
