(* Dictionary : Multiway Tree *)
type dictionary = Node of string * (char * dictionary) list

let rec add_aux i unicode_word word (Node (unicode_w, l) as dic) =
  if i = String.length word then
    Node
      ( (if String.uppercase_ascii unicode_w = word then unicode_w
         else unicode_word),
        l )
  else Node (unicode_w, insert i unicode_word word l dic)

and insert i unicode_word word list dic =
  let wi = word.[i] in
  match list with
  | [] -> [ (wi, add_aux (i + 1) unicode_word word (Node ("", []))) ]
  | (c, d) :: l ->
      if c > wi then (c, d) :: insert i unicode_word word l dic
      else if c = wi then (c, add_aux (i + 1) unicode_word word d) :: l
      else (wi, add_aux (i + 1) unicode_word word (Node ("", []))) :: list

let add w_unicode d =
  let w = Parameters.to_upper_case w_unicode in
  if
    Parameters.min_word_length <= String.length w
    && String.length w <= Parameters.max_word_length
  then add_aux 0 w_unicode w d
  else d

let rec print dic =
  match dic with
  | Node ("", []) -> failwith "Inconsistent dictionary"
  | Node (word, []) -> Printf.printf "%s\n" word
  | Node (word, l) ->
      if word <> "" then Printf.printf "%s\n" word;
      List.iter (fun (_, d) -> print d) l

let load dictionary_file =
  let dic = ref (Node ("", [])) in
  let file = open_in dictionary_file in
  let () =
    try
      while true do
        let line = input_line file in
        dic := add line !dic
      done
    with _ -> close_in file
  in
  !dic
