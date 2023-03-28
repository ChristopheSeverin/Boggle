(lang dune 3.7)

(name boggle)

(generate_opam_files true)

(source
 (github ChristopheSeverin/Boggle))

(authors "Christophe")

(maintainers "Christophe")

(license LICENSE)

(documentation https://github.com/ChristopheSeverin/Boggle/blob/master/README.md)

(package
 (name boggle)
 (synopsis "Online duplicate Boggle")
 (description "All players compete on the same online Boggle grid")
 (depends ocaml dream lwt dune unidecode))
