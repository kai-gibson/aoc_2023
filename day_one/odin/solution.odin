package day_one

import "core:fmt"
import "core:os"
import "core:strings"
import "core:text/regex"
import "core:strconv"
import "core:unicode"
import "core:unicode/utf8"
import "base:runtime"

DigitPairs :: [dynamic][2]rune

sum_pairs :: proc(pairs :^DigitPairs) -> (sum :int) {
  for &pair in pairs {
    parsed_int, ok := strconv.parse_int(utf8.runes_to_string(pair[:])) 

    if ok do sum += parsed_int
  }

  return sum
}

problem_one :: proc() -> (cal_sum :int, ok :bool) { 
  file_data, success := os.read_entire_file("input.txt")
  if !success do return

  lines, err := strings.split_lines(transmute(string)file_data)
  if err != nil do return

  digit_pairs :[dynamic]([2]rune)
  defer delete(digit_pairs)

  max := 5
  // create a list of two char strings with the first and last digit on each
  // line
  for line in lines {
    first_digit, last_digit :rune

    for chr in line {
      if unicode.is_digit(chr) {
        if first_digit == 0 do first_digit = chr; else do last_digit = chr
      }
    }

    if last_digit == 0 do last_digit = first_digit
    append(&digit_pairs, [2]rune{first_digit, last_digit})
  }

  return sum_pairs(&digit_pairs), true
}

str_to_int :: proc(str :string) -> (val :int, success :bool) {
  switch str {
  case "one":
    return 1, true
  case "two":
    return 2, true
  case "three":
    return 3, true
  case "four":
    return 4, true
  case "five":
    return 5, true
  case "six":
    return 6, true
  case "seven":
    return 7, true
  case "eight":
    return 8, true
  case "nine":
    return 9, true
  case:
    return strconv.parse_int(str) 
  }
}

problem_two :: proc() -> (sum :int, ok :bool) { 
  file_data, success := os.read_entire_file("input.txt")
  if !success do return 

  lines, err := strings.split_lines(transmute(string)file_data)
  if err != nil do return

  for line in lines {
    if line == "" do continue
    first_digit, last_digit :rune

    rgx, err := regex.create(
      `(\d|one|two|three|four|five|six|seven|eight|nine)`, {.Global})

    if err != nil {
      fmt.eprintln("error creating regex")
      return
    }

    defer regex.destroy(rgx)

    first_str, last_str :string

    //fmt.println("line: ", line)

    matching := true
    slice_from := 0

    for matching {
      //fmt.println("slice_from: ", line[slice_from:])

      capture, success := regex.match_and_allocate_capture(rgx,
        line[slice_from:])
      defer regex.destroy_capture(capture)

      if !success {
        //fmt.println("no matches left")
        matching = false
        break
      }

      //fmt.println("captures: ", capture.groups)

      if first_str == "" {
        first_str = capture.groups[0]
      } else {
        last_str = capture.groups[0]
      }

      slice_from += capture.pos[0][1]
    }

    if last_str == "" do last_str = first_str

    first, last :int
    first, ok = str_to_int(first_str)
    if !ok do return sum, false

    last, ok = str_to_int(last_str)
    if !ok do return sum, false

    //fmt.println("first:", first, "last:", last)
    pair :[2]rune = {rune(first) + '0', rune(last) + '0'}

    parsed_int, ok := strconv.parse_int(utf8.runes_to_string(pair[:])) 
    if !ok do return 0, false

    //fmt.println("int: ", parsed_int)

    sum += parsed_int
  }

  return sum, true
}

main :: proc() {
  sum, ok := problem_one()
  if !ok do fmt.println("error"); else do fmt.printfln("result: {}", sum)

  sum, ok = problem_two()
  if !ok do fmt.println("error"); else do fmt.printfln("result: {}", sum)
}
