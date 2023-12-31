type effect =
  | Update of (nat -> int -> int -> unit)
  | Lookup of (nat -> int -> int)
  | Mem of (nat -> int -> bool)
  | BoolGen of (unit -> bool)

(* open db may fail *)

(* Unintialialised < 0 *)
(* SQLiteConnected = 0 *)
(* SQLitePS Binding = 1 *)
(* SQLitePS Bound = 2 *)

let open_db (sqlite : nat) (db_id : int) : bool =
  if perform (Mem (sqlite, db_id)) then
    let (status : int) = perform (Lookup (sqlite, db_id)) in
    if status < 0 then
      let (dummy0 : unit) = perform (Update (sqlite, db_id, 0)) in
      true
    else false
  else if perform (BoolGen ()) then
    let (dummy0 : unit) = perform (Update (sqlite, db_id, 0)) in
    true
  else false

let[@assert] open_db ?l:(sqlite = (true : [%v: nat]))
    ?l:(db_int = (true : [%v: int])) =
  {
    pre =
      (starA anyA;
       Update
         ((((v0 == sqlite && v1 == db_int && v2 < 0 : [%v0: nat]) : [%v1: int])
            : [%v2: int])
           : [%v: unit]);
       starA
         (anyA
         - Update
             ((((v0 == sqlite && v1 == db_int : [%v0: nat]) : [%v1: int])
                : [%v2: int])
               : [%v: unit])));
    post =
      ((starA
          (anyA
          - Update
              ((((true : [%v0: nat]) : [%v1: int]) : [%v2: int]) : [%v: unit]));
        (Update
           ((((v0 == sqlite && v1 == db_int && v2 == 0 : [%v0: nat])
               : [%v1: int])
              : [%v2: int])
             : [%v: unit]);
         Ret (v0 : [%v0: bool]))
        || Ret (not v0 : [%v0: bool])) : bool);
  }
