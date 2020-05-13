/* Ocamlyacc parser for tabLe */

%{
open Ast
%}

%token SEMI LT GT LPAREN RPAREN LBRACE RBRACE
%token EQ NEQ LTE GTE AND OR
%token IF ELSE WHILE
/* return, COMMA token */
%token FUNC RETURN COMMA INT BOOL FLOAT STRING NULL
%token PLUS MINUS MULT DIV MOD ASSIGN
%token <int> LITERAL
%token <bool> BLIT
%token <string> ID FLIT SLIT
%token EOF

%start program
%type <Ast.program> program

%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left MULT DIV MOD

%%

/* add function declarations*/
program:
  decls EOF { $1}

decls:
   /* nothing */ { ([], [])               }
 | vdecl SEMI decls { (($1 :: fst $3), snd $3) }
 | fdecl decls { (fst $2, ($1 :: snd $2)) }

vdecl_list:
  /*nothing*/ { [] }
  | vdecl SEMI vdecl_list  {  $1 :: $3 }

/* int x */
vdecl:
  typ ID { ($1, $2) }

typ:
    INT    { Int   }
  | BOOL   { Bool  }
  | FLOAT  { Float }
  | STRING { String }
  | NULL   { Null }

/* fdecl */
fdecl:
  FUNC vdecl LT formals_opt GT LBRACE vdecl_list stmt_list RBRACE
  {
    {
      rtyp=fst $2;
      fname=snd $2;
      formals=$4;
      locals=$7;
      body=$8
    }
  }

/* formals_opt */
formals_opt:
  /*nothing*/ { []  }
  | formals_list { $1 }

formals_list:
  vdecl { [$1] }
  | vdecl COMMA formals_list { $1::$3 }

stmt_list:
  /* nothing */ { [] }
  | stmt stmt_list  { $1::$2 }

stmt:
    expr SEMI                               { Expr $1      }
  | LBRACE stmt_list RBRACE                 { Block $2 }
  /* if (condition) { block1} else {block2} */
  /* if (condition) stmt else stmt */
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7) }
  | WHILE LPAREN expr RPAREN stmt           { While ($3, $5)  }
  /* return */
  | RETURN expr SEMI                        { Return $2      }

expr:
    LITERAL          { Literal($1)            }
  | FLIT	           { Fliteral($1)           }
  | BLIT             { BoolLit($1)            }
  | SLIT             { StringLit($1)          }
  | ID               { Id($1)                 }
  | expr PLUS   expr { Binop($1, Add,   $3)   }
  | expr MINUS  expr { Binop($1, Sub,   $3)   }
  | expr MULT expr   { Binop($1, Mult,   $3)  }
  | expr DIV expr    { Binop($1, Div,   $3)   }
  | expr MOD expr    { Binop($1, Mod,   $3)   }
  | expr EQ     expr { Binop($1, Equal, $3)   }
  | expr NEQ    expr { Binop($1, Neq, $3)     }
  | expr LT     expr { Binop($1, Less,  $3)   }
  | expr AND    expr { Binop($1, And,   $3)   }
  | expr OR     expr { Binop($1, Or,    $3)   }
  | ID ASSIGN expr   { Assign($1, $3)         }
  | LT expr GT       { $2                     }
  /* call */
  | ID LT args_opt GT  { Call ($1, $3)  }

/* args_opt*/
args_opt:
  /*nothing*/ { [] }
  | args { $1 }

args:
  expr  { [$1] }
  | expr COMMA args { $1::$3 }
