let char_frequencies dictionary_file =
  let file = open_in dictionary_file in
  let module M = Map.Make (Char) in
  let char_occurrence = ref M.empty in
  let () =
    try
      while true do
        let line_with_accent = input_line file in
        let line = Parameters.to_upper_case line_with_accent in
        char_occurrence :=
          String.fold_left
            (fun m c ->
              if M.mem c m then M.add c (M.find c m + 1) m else M.add c 1 m)
            !char_occurrence line
      done
    with _ -> close_in file
  in
  if M.is_empty !char_occurrence then
    failwith
      (Printf.sprintf "The dictionary %s cannot be empty" dictionary_file)
  else
    let total = M.fold (fun _ n i -> i + n) !char_occurrence 0 in
    M.map (fun i -> float_of_int i /. float_of_int total) !char_occurrence
    |> M.bindings
    |> List.sort (fun x y -> -Float.compare (snd x) (snd y))

let random_letter dictionary_file =
  let letter_freq = char_frequencies dictionary_file in
  Random.self_init ();
  fun () ->
    let n = Random.float 1.0 in
    let rec letter ?(cumul = 0.0) n = function
      | [] -> assert false
      | [ (c, _) ] -> c
      | (c, f) :: l ->
          if n <= cumul +. f then c else letter ~cumul:(cumul +. f) n l
    in
    letter n letter_freq
