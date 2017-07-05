
(* 
 * Set, polymorphic version. 
 * Adapted from set.ml in the ocaml distribution. 
 *)


(* This is the original copyright: *)

(***********************************************************************)
(*                                                                     *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../LICENSE.     *)
(*                                                                     *)
(***********************************************************************)

(* $Id: set.mli 6974 2005-07-21 14:52:45Z doligez $ *)

(** Sets over ordered types.

   This module implements the set data structure, given a total ordering
   function over the set elements. All operations over sets
   are purely applicative (no side-effects).
   The implementation uses balanced binary trees, and is therefore
   reasonably efficient: insertion and membership take time
   logarithmic in the size of the set, for instance.
*)

type 'a t

type 'a cmp = 'a -> 'a -> int
(** It is necessary to provide a comparison function to build a new set. 
 *  Binary operators on sets check that both arguments use the same comparison function,
 *  otherwise, a failure is raised. *)

val empty: 'a cmp -> 'a t
(** The empty set. *)

val is_empty: 'a t -> bool
(** Test whether a set is empty or not. *)

val mem: 'a -> 'a t -> bool
(** [mem x s] tests whether [x] belongs to the set [s]. *)

val find: 'a -> 'a t -> 'a
(** [find x s] finds an element y in s which is equal to x.
    raise [Not_found] if no such element is in the set. *)

val add: 'a -> 'a t -> 'a t
(** [add x s] returns a set containing all elements of [s],
    plus [x]. If [x] was already in [s], [s] is returned unchanged. *)

val singleton: 'a cmp -> 'a -> 'a t
(** [singleton x] returns the one-element set containing only [x]. *)

val remove: 'a -> 'a t -> 'a t
(** [remove x s] returns a set containing all elements of [s],
    except [x]. If [x] was not in [s], [s] is returned unchanged. *)

val union: 'a t -> 'a t -> 'a t
(** Set union. *)

val inter: 'a t -> 'a t -> 'a t
(** Set intersection. *)

(** Set difference. *)
val diff: 'a t -> 'a t -> 'a t

val compare: 'a t -> 'a t -> int
(** Total ordering between sets. Can be used as the ordering function
    for doing sets of sets. *)

val equal: 'a t -> 'a t -> bool
(** [equal s1 s2] tests whether the sets [s1] and [s2] are
    equal, that is, contain equal elements. *)

val subset: 'a t -> 'a t -> bool
(** [subset s1 s2] tests whether the set [s1] is a subset of
    the set [s2]. *)
    
val iter: ('a -> unit) -> 'a t -> unit
(** [iter f s] applies [f] in turn to all elements of [s].
    The elements of [s] are presented to [f] in increasing order
    with respect to the ordering over the type of the elements. *)
    
val fold: ('a -> 'b -> 'b) -> 'a t -> 'b -> 'b
(** [fold f s a] computes [(f xN ... (f x2 (f x1 a))...)],
    where [x1 ... xN] are the elements of [s], in increasing order. *)
    
val for_all: ('a -> bool) -> 'a t -> bool
(** [for_all p s] checks if all elements of the set
    satisfy the predicate [p]. *)
    
val exists: ('a -> bool) -> 'a t -> bool
(** [exists p s] checks if at least one element of
    the set satisfies the predicate [p]. *)
    
val filter: ('a -> bool) -> 'a t -> 'a t
(** [filter p s] returns the set of all elements in [s]
    that satisfy predicate [p]. *)
    
val partition: ('a -> bool) -> 'a t -> 'a t * 'a t
(** [partition p s] returns a pair of sets [(s1, s2)], where
    [s1] is the set of all the elements of [s] that satisfy the
    predicate [p], and [s2] is the set of all the elements of
    [s] that do not satisfy [p]. *)
    
val cardinal: 'a t -> int
(** Return the number of elements of a set. *)
    
val elements: 'a t -> 'a list
(** Return the list of all elements of the given set.
    The returned list is sorted in increasing order with respect
    to the ordering [Ord.compare], where [Ord] is the argument
    given to {!Set.Make}. *)
    
val min_elt: 'a t -> 'a
(** Return the smallest element of the given set
    (with respect to the [Ord.compare] ordering), or raise
    [Not_found] if the set is empty. *)
    
val max_elt: 'a t -> 'a
(** Same as {!Set.S.min_elt}, but returns the largest element of the
    given set. *)
    
val choose: 'a t -> 'a
(** Return one element of the given set, or raise [Not_found] if
    the set is empty. Which element is chosen is unspecified,
    but equal elements will be chosen for equal sets. *)
    
val split: 'a -> 'a t -> 'a t * bool * 'a t
(** [split x s] returns a triple [(l, present, r)], where
    [l] is the set of elements of [s] that are
    strictly less than [x];
    [r] is the set of elements of [s] that are
    strictly greater than [x];
    [present] is [false] if [s] contains no element equal to [x],
    or [true] if [s] contains an element equal to [x]. *)
