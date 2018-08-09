
(* 
 * Set, polymorphic version. 
 * Adapted from set.ml in the ocaml distribution. 
 *)

(* This is the original copyright: *)

(***********************************************************************)
(*                                                                     *)
(*                           Objective Caml                            *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../LICENSE.     *)
(*                                                                     *)
(***********************************************************************)

(* $Id: set.ml 6694 2004-11-25 00:06:06Z doligez $ *)

(* Sets over ordered types *)

type 'a cmp = 'a -> 'a -> int

type 'a tree = Empty | Node of 'a tree * 'a * 'a tree * int

type 'a t = {
    cmp : 'a cmp ;
    tree : 'a tree ;
  }

let check_cmp msg s1 s2 =
  if s1.cmp != s2.cmp then failwith (Printf.sprintf "Setp.%s: arguments have different comparison functions." msg)
  else s1.cmp

(* Sets are represented by balanced binary trees (the heights of the
   children differ by at most 2 *)

let height = function
    Empty -> 0
  | Node(_, _, _, h) -> h

(* Creates a new node with left son l, value v and right son r.
   We must have all elements of l < v < all elements of r.
   l and r must be balanced and | height l - height r | <= 2.
   Inline expansion of height for better speed. *)

let create l v r =
  let hl = match l with Empty -> 0 | Node(_,_,_,h) -> h in
  let hr = match r with Empty -> 0 | Node(_,_,_,h) -> h in
  Node(l, v, r, (if hl >= hr then hl + 1 else hr + 1))

(* Same as create, but performs one step of rebalancing if necessary.
   Assumes l and r balanced and | height l - height r | <= 3.
   Inline expansion of create for better speed in the most frequent case
   where no rebalancing is required. *)

let bal l v r =
  let hl = match l with Empty -> 0 | Node(_,_,_,h) -> h in
  let hr = match r with Empty -> 0 | Node(_,_,_,h) -> h in
  if hl > hr + 2 then begin
    match l with
      Empty -> invalid_arg "Set.bal"
    | Node(ll, lv, lr, _) ->
        if height ll >= height lr then
          create ll lv (create lr v r)
        else begin
          match lr with
            Empty -> invalid_arg "Set.bal"
          | Node(lrl, lrv, lrr, _)->
              create (create ll lv lrl) lrv (create lrr v r)
        end
  end else if hr > hl + 2 then begin
    match r with
      Empty -> invalid_arg "Set.bal"
    | Node(rl, rv, rr, _) ->
        if height rr >= height rl then
          create (create l v rl) rv rr
        else begin
          match rl with
            Empty -> invalid_arg "Set.bal"
          | Node(rll, rlv, rlr, _) ->
              create (create l v rll) rlv (create rlr rv rr)
        end
  end else
    Node(l, v, r, (if hl >= hr then hl + 1 else hr + 1))
      
(* Insertion of one element *)
      
let rec add cmp x = function
    Empty -> Node(Empty, x, Empty, 1)
  | Node(l, v, r, _) as t ->
      let c = cmp x v in
      if c = 0 then t else
      if c < 0 then bal (add cmp x l) v r else bal l v (add cmp x r)
	
(* Same as create and bal, but no assumptions are made on the
   relative heights of l and r. *)
	
let rec join cmp l v r =
  match (l, r) with
    (Empty, _) -> add cmp v r
  | (_, Empty) -> add cmp v l
  | (Node(ll, lv, lr, lh), Node(rl, rv, rr, rh)) ->
      if lh > rh + 2 then bal ll lv (join cmp lr v r) else
      if rh > lh + 2 then bal (join cmp l v rl) rv rr else
      create l v r
	
(* Smallest and greatest element of a set *)
	
let rec min_elt = function
    Empty -> raise Not_found
  | Node(Empty, v, _, _) -> v
  | Node(l, _, _, _) -> min_elt l

let rec max_elt = function
    Empty -> raise Not_found
  | Node(_, v, Empty, _) -> v
  | Node(_, _, r, _) -> max_elt r
	
(* Remove the smallest element of the given set *)

let rec remove_min_elt = function
    Empty -> invalid_arg "Set.remove_min_elt"
  | Node(Empty, _, r, _) -> r
  | Node(l, v, r, _) -> bal (remove_min_elt l) v r
	
(* Merge two trees l and r into one.
   All elements of l must precede the elements of r.
   Assume | height l - height r | <= 2. *)
	
let merge t1 t2 =
  match (t1, t2) with
    (Empty, t) -> t
  | (t, Empty) -> t
  | (_, _) -> bal t1 (min_elt t2) (remove_min_elt t2)
	
(* Merge two trees l and r into one.
   All elements of l must precede the elements of r.
   No assumption on the heights of l and r. *)
	
let concat cmp t1 t2 =
  match (t1, t2) with
    (Empty, t) -> t
  | (t, Empty) -> t
  | (_, _) -> join cmp t1 (min_elt t2) (remove_min_elt t2)
	
(* Splitting.  split x s returns a triple (l, present, r) where
   - l is the set of elements of s that are < x
   - r is the set of elements of s that are > x
   - present is false if s contains no element equal to x,
   or true if s contains an element equal to x. *)
	
let rec split cmp x = function
    Empty ->
      (Empty, false, Empty)
  | Node(l, v, r, _) ->
      let c = cmp x v in
      if c = 0 then (l, true, r)
      else if c < 0 then
        let (ll, pres, rl) = split cmp x l in (ll, pres, join cmp rl v r)
      else
        let (lr, pres, rr) = split cmp x r in (join cmp l v lr, pres, rr)
	  
(* Implementation of the set operations *)
	  
let empty cmp = { cmp ; tree = Empty }
    
let is_empty s = match s.tree with Empty -> true | _ -> false
    
let rec mem cmp x = function
    Empty -> false
  | Node(l, v, r, _) ->
      let c = cmp x v in
      c = 0 || mem cmp x (if c < 0 then l else r)
       
let rec find cmp x = function
  | Empty -> raise Not_found
  | Node (l, v, r, _) ->
      let c = cmp x v in
      if c = 0 then v else find cmp x (if c < 0 then l else r)

let singleton cmp x = { cmp ; tree = Node(Empty, x, Empty, 1) }

let rec remove cmp x = function
    Empty -> Empty
  | Node(l, v, r, _) ->
      let c = cmp x v in
      if c = 0 then merge l r else
      if c < 0 then bal (remove cmp x l) v r else bal l v (remove cmp x r)
	
let rec union cmp s1 s2 =
  match (s1, s2) with
    (Empty, t2) -> t2
  | (t1, Empty) -> t1
  | (Node(l1, v1, r1, h1), Node(l2, v2, r2, h2)) ->
      if h1 >= h2 then
        if h2 = 1 then add cmp v2 s1 else begin
          let (l2, _, r2) = split cmp v1 s2 in
          join cmp (union cmp l1 l2) v1 (union cmp r1 r2)
        end
      else
        if h1 = 1 then add cmp v1 s2 else begin
          let (l1, _, r1) = split cmp v2 s1 in
          join cmp (union cmp l1 l2) v2 (union cmp r1 r2)
        end
	  
let rec inter cmp s1 s2 =
  match (s1, s2) with
    (Empty, _) -> Empty
  | (_, Empty) -> Empty
  | (Node(l1, v1, r1, _), t2) ->
      match split cmp v1 t2 with
        (l2, false, r2) ->
          concat cmp (inter cmp l1 l2) (inter cmp r1 r2)
      | (l2, true, r2) ->
          join cmp (inter cmp l1 l2) v1 (inter cmp r1 r2)
	    
let rec diff cmp s1 s2 =
  match (s1, s2) with
    (Empty, _) -> Empty
  | (t1, Empty) -> t1
  | (Node(l1, v1, r1, _), t2) ->
      match split cmp v1 t2 with
        (l2, false, r2) ->
          join cmp (diff cmp l1 l2) v1 (diff cmp r1 r2)
      | (l2, true, r2) ->
          concat cmp (diff cmp l1 l2) (diff cmp r1 r2)
	    
type 'a enumeration = End | More of 'a * 'a tree * 'a enumeration

let rec cons_enum s e =
  match s with
    Empty -> e
  | Node(l, v, r, _) -> cons_enum l (More(v, r, e))
	
let rec compare_aux cmp e1 e2 =
  match (e1, e2) with
    (End, End) -> 0
  | (End, _)  -> -1
  | (_, End) -> 1
  | (More(v1, r1, e1), More(v2, r2, e2)) ->
      let c = cmp v1 v2 in
      if c <> 0
      then c
      else compare_aux cmp (cons_enum r1 e1) (cons_enum r2 e2)
	  
let compare s1 s2 =
  let cmp = check_cmp "compare" s1 s2 in
  compare_aux cmp (cons_enum s1.tree End) (cons_enum s2.tree End)
    
let equal s1 s2 = compare s1 s2 = 0
    
let rec subset cmp s1 s2 =
  match (s1, s2) with
    Empty, _ ->
      true
  | _, Empty ->
      false
  | Node (l1, v1, r1, _), (Node (l2, v2, r2, _) as t2) ->
      let c = cmp v1 v2 in
      if c = 0 then
        subset cmp l1 l2 && subset cmp r1 r2
      else if c < 0 then
        subset cmp (Node (l1, v1, Empty, 0)) l2 && subset cmp r1 t2
      else
        subset cmp (Node (Empty, v1, r1, 0)) r2 && subset cmp l1 t2
	  
let rec iter f = function
    Empty -> ()
  | Node(l, v, r, _) -> iter f l; f v; iter f r
	
let rec fold f s accu =
  match s with
    Empty -> accu
  | Node(l, v, r, _) -> fold f r (f v (fold f l accu))
	
let rec for_all p = function
    Empty -> true
  | Node(l, v, r, _) -> p v && for_all p l && for_all p r
	
let rec exists p = function
    Empty -> false
  | Node(l, v, r, _) -> p v || exists p l || exists p r
      
let filter cmp p s =
  let rec filt accu = function
    | Empty -> accu
    | Node(l, v, r, _) ->
        filt (filt (if p v then add cmp v accu else accu) l) r in
  filt Empty s
    
let partition cmp p s =
  let rec part (t, f as accu) = function
    | Empty -> accu
    | Node(l, v, r, _) ->
        part (part (if p v then (add cmp v t, f) else (t, add cmp v f)) l) r in
  part (Empty, Empty) s
    
let rec cardinal = function
    Empty -> 0
  | Node(l, _, r, _) -> cardinal l + 1 + cardinal r
	
let rec elements_aux accu = function
    Empty -> accu
  | Node(l, v, r, _) -> elements_aux (v :: elements_aux accu r) l
	
let elements s =
  elements_aux [] s


let mem x s = mem s.cmp x s.tree
let find x s = find s.cmp x s.tree

let add x s = { cmp = s.cmp ; tree = add s.cmp x s.tree }
let remove x s = { cmp = s.cmp ; tree = remove s.cmp x s.tree }

(* It is not worth factorizing the following few definitions...for the moment. *)
let union s1 s2 = { cmp = check_cmp "union" s1 s2 ; tree = union s1.cmp s1.tree s2.tree }
let inter s1 s2 = { cmp = check_cmp "inter" s1 s2 ; tree = inter s1.cmp s1.tree s2.tree }
let diff  s1 s2 = { cmp = check_cmp "diff" s1 s2 ; tree = diff s1.cmp s1.tree s2.tree }
    
let subset s1 s2 = subset (check_cmp "subset" s1 s2) s1.tree s2.tree

let iter f s = iter f s.tree
let fold f s a = fold f s.tree a
let for_all f s = for_all f s.tree
let exists f s = exists f s.tree
let filter f s = { cmp = s.cmp ; tree = filter s.cmp f s.tree }
let partition f s = 
  let (tree1, tree2) = partition s.cmp f s.tree in
  { cmp = s.cmp ; tree = tree1 }, { cmp = s.cmp ; tree = tree2 }

let split x s =
  let (tree1, flag, tree2) = split s.cmp x s.tree in
  { cmp = s.cmp ; tree = tree1 }, flag, { cmp = s.cmp ; tree = tree2 }

let cardinal s = cardinal s.tree
let elements s = elements s.tree

let min_elt s = min_elt s.tree
let max_elt s = max_elt s.tree

let choose = min_elt
