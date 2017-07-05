open Big_int

(* Lwt version of Exenum.tester 
 * Not lwt-exceptions compliant: some exceptions may get lost. *)
val lwt_tester : 'a Exenum.t -> ?from:big_int -> ?upto:big_int -> ?verbose_period:int -> ?tos:('a -> string) -> len:int -> ('a -> unit Lwt.t) -> unit Lwt.t
