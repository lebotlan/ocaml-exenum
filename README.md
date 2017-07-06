# ocaml-exenum

exenum is an OCaml library that helps building exhaustive or semi-exhaustive data sets, typically for intensive unit testing.

## Install

Install with [opam](https://opam.ocaml.org/): `opam install exenum`

## API Documentation

To come sooner or later...

## Overview

We consider a simple example. 

* Assume that, for testing purposes, we need many values of type int list.
```ocaml
open Exenum

(* Build a new enumeration of type int list. *)
let enum_intlist = e_list e_int
```
* Because pretty-printing matters, we take the time to define string_of_intlist:
```ocaml
(* Helper function that builds a string from a list of items *)
let sep map sp l = List.fold_left (fun acu x -> if acu = "" then map x else acu ^ sp ^ (map x)) "" l

let string_of_intlist l = "[" ^ (sep string_of_int ", " l) ^ "]"
```
* We ask Exenum to show a few values of this enumeration:
```ocaml
let () = show enum_intlist string_of_intlist 0 11
```
```
Value #0 is []
Value #1 is [2]
Value #2 is [-1]
Value #3 is [1]
Value #4 is [0]
Value #5 is [-2]
Value #6 is [3, 2]
Value #7 is [-3]
Value #8 is [3]
Value #9 is [-1, 0]
Value #10 is [1, 1]
```
* We are curious. What are values at a very large index?
```ocaml
let index = Big_int.power_int_positive_int 10 200 (* Indeed, this is 10^200. *)
let () = bigshow enum_intlist string_of_intlist index 2
```
```
Value #0 is [-91, 83, -78, -59, -21, 45, -97, 79, 40, 50, 30, 46, -80, -45, 57, 70, -35, -71, 47, -29, -78, 58, -68, -12, -47, -32, -16, 36, 57, -51, 19, -33, -58, -37, 56, 38, 62, 2, 66, -65, -34, 36, 28, 46, 44, 53, 6, 10, 26, -54, -18, 35, 32, 40, 49, -2, -33, -42, -12, -26, -18, 8, 33, 41, 1, 29, -26, 8, 29, 5, 28, -7, -5, 32, -10, 17, 10, -9, 17, 5, 19, 21, -15, 20, 14, -18, 8, 3, -16, -4, 7, 8, 11, -6, -3, -1, 6, 2, -7, -2, -2, 1, 0, -1]
Value #1 is [91, 33, 73, 53, 43, 12, -32, 53, -66, -69, -81, -17, -72, -86, -87, -41, 52, 54, 43, -19, -76, 24, -52, -77, -77, 0, -37, 69, 1, -5, -40, 16, -19, 68, 4, 11, -64, 15, -62, -58, 45, -49, -20, 46, -2, -45, -24, 56, -21, 41, -2, -14, 13, -5, 13, 10, 2, 41, -40, 27, -19, -20, -33, 1, -11, 29, -16, -12, -14, -3, 19, 8, 25, -11, -13, -11, 23, -24, -20, -5, -23, 24, -22, 8, -2, 9, 14, -7, 2, 2, 15, 11, -7, -1, 5, 7, 5, 5, 4, 4, 3, -1, 3, -2]
```
* Notice how these two values, which are adjacent in the enumeration, are purposely significantly different.
* Computing values at a large index is quick (the complexity is basically logarithmic with respect to the index).



