(* Grid described as a graph (adjacency lists) *)
let neighbour =
  [|
    [ 1; 4; 5 ];
    [ 0; 2; 4; 5; 6 ];
    [ 1; 3; 5; 6; 7 ];
    [ 2; 6; 7 ];
    (*  *)
    [ 0; 1; 5; 8; 9 ];
    [ 0; 1; 2; 4; 6; 8; 9; 10 ];
    [ 1; 2; 3; 5; 7; 9; 10; 11 ];
    [ 2; 3; 6; 10; 11 ];
    (*  *)
    [ 4; 5; 9; 12; 13 ];
    [ 4; 5; 6; 8; 10; 12; 13; 14 ];
    [ 5; 6; 7; 9; 11; 13; 14; 15 ];
    [ 6; 7; 10; 14; 15 ];
    (*  *)
    [ 8; 9; 13 ];
    [ 8; 9; 10; 12; 14 ];
    [ 9; 10; 11; 13; 15 ];
    [ 10; 11; 14 ];
  |]

let positions c grid =
  snd
    (String.fold_left
       (fun (i, res) grid_c -> (i + 1, if grid_c = c then i :: res else res))
       (0, []) grid)

let rec solve_grid ?(paths = []) ?(w = "") (Dictionary.Node (b, l)) grid =
  List.fold_left
    (fun sol (c, d) ->
      let paths_wc =
        let positions_of_c = positions c grid in
        if w = "" then List.map (fun i -> [ i ]) positions_of_c
        else
          let paths_from_path_for_wc path =
            List.fold_left
              (fun res i ->
                if
                  (not (List.mem i path)) && List.mem i neighbour.(List.hd path)
                then (i :: path) :: res
                else res)
              [] positions_of_c
          in
          List.fold_left
            (fun accu path -> accu @ paths_from_path_for_wc path)
            [] paths
      in
      if paths_wc = [] then sol
      else
        sol @ solve_grid ~paths:paths_wc ~w:(Printf.sprintf "%s%c" w c) d grid)
    (if b then [ w ] else [])
    l

let solutions d g = solve_grid d g

let create dictionary min_solutions_for_a_grid max_solutions_for_a_grid =
  let d = Dictionary.load dictionary
  and random_letter = Letter.random_letter dictionary in
  let rec produce_grid_and_sol () =
    let grid = String.init 16 (fun _ -> random_letter ()) in
    let sol = solutions d grid in
    if
      List.length sol < min_solutions_for_a_grid
      || max_solutions_for_a_grid < List.length sol
    then (
      Dream.log "Rejected grid : %s" grid;
      produce_grid_and_sol ())
    else (
      Dream.log "Grid : %s" grid;
      (grid, sol))
  in
  produce_grid_and_sol
