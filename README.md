# Marple

The source code of Marple is under `marple` folder. There are `4` dependent repos: utils, utillib, normal5ty (repo define basic types), ocaml5_parser (a copy of OCaml5's paper).

A brief overview of the files in `marple` folder.

* `data/`: the benchmarks as we provided in the supplemental materials.
* `syntax/` and `language/`: the AST of the languages used in **Marple**; `syntax/rty.ml` defines HATs.
* `bin/main.ml`: the main entry point of **Marple**.
* `meta-config.json`: the configuration file.
* `typecheck/` and `auxtyping/`: type check and auxiliary functions.
  + `typecheck/bidirectional.ml`: bidirectional type check.
* `subtyping/`: subtyping check.
* `desymbolic/`: convert SFAs into FAs via alphabet transformation.
* `smtquery/`: SMT solver beckend.
* `ntypecheck/` and `normalization/`: basic type check and normalizing the code into MNF.
* `frontend/`: the **Marple** parser, a modified OCaml parser.
* `formalization/`: the Coq proofs of our core language, as we provided in the supplemental materials.
  + `poirot-SM.pdf`: the supplemental materials.
* `env/`: the universal environment of **Marple** which is loaded from the configuration files.
* `scripts/`: various Python scripts for collecting and displaying experimental results.


