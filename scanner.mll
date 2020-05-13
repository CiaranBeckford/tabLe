(* Ocamllex scanner for MicroC *)

{ open Microcparse }

let digit = ['0' - '9']
let digits = digit+
let letter = ['a'-'z' 'A'-'Z']



rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "~"     { comment lexbuf }           (* Comments *)
| '('      { LPAREN }
| ')'      { RPAREN }
| '{'      { LBRACE }
| '}'      { RBRACE }
| ';'      { SEMI }
(* COMMA *)
| ','      { COMMA }
| '+'      { PLUS }
| '-'      { MINUS }
| '*'      { MULT }
| '/'      { DIV }
| '='      { ASSIGN }
| '%'      { MOD }
| "=="     { EQ }
| "!="     { NEQ }
| '<'      { LT }
| '>'      { GT }
| "<="     { LTE }
| ">="     { GTE }
| "&&"     { AND }
| "||"     { OR }
| "if"     { IF }
| "else"   { ELSE }
| "while"  { WHILE }
(* RETURN *)
| "return" { RETURN }
| "int"    { INT }
| "float"  { FLOAT }
| "bool"   { BOOL }
| "string" { STRING }
| "null"   { NULL }
| '"' ([^'"']* as s) '"'{ SLIT((s)) }
| "true"   { BLIT(true)  }
| "false"  { BLIT(false) }
| "def"    { FUNC }
| digits as lem  { LITERAL(int_of_string lem) }
| digits '.'  digit*  ( ['e' 'E'] ['+' '-']? digits )? as lem { FLIT(lem) }
| letter (digit | letter | '_')* as lem { ID(lem) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and comment = parse
  "~" { token lexbuf }
| _    { comment lexbuf }
