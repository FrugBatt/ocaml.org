---
packages: []
discussion: |
  - **Understanding `Unix.localtime` and `Unix.time`:** The `Unix.localtime` function converts a timestamp obtained from `Unix.time` (which returns the current time since the Unix epoch) into a local time, represented by a `tm` structure. This structure includes fields like `tm_year`, `tm_mon`, and `tm_mday` for year, month, and day, respectively.
  - **Month and Year Adjustments:** In OCaml's `Unix` module, the month is zero-indexed (0 for January, 11 for December), and the year is the number of years since 1900. Don't forget to adjust these values to get a human-readable date.
  - **Alternative Libraries:** For more complex date-time operations, consider using external libraries like `calendar` or `timedesc`, which offer more functionalities like time zone handling and date arithmetic.
---

(* The `unix` library, which ships with OCaml's standard library,
  provides functions to work with dates and times. *)
let today = Unix.localtime (Unix.time ());;
let day = today.Unix.tm_mday;;

(* Months are numbered 0 to 11. *)
let month = today.Unix.tm_mon + 1;;

(* Years are counted starting from 1900. *)
let year = today.Unix.tm_year + 1900;;

Printf.printf "The current date is %04d-%02d-%02d\n"
    year month day;;
