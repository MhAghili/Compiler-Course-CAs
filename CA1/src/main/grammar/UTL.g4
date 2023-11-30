grammar UTL;


program : statement+;

statement
    : varDeclaration
    | methodDeclaration
    | arrDeclaration
    | ifStatement
    | whileStatement
    | forStatement
    | tryCatchStatement
    | scheduleStatement
    | printStatement
    | functionCall SEMICOLON {System.out.println("FunctionCall");}
    | assignment
    | varuse
    | break_continue
    | exceptionDec
    | throwExcep
    | return
    ;

return
    :RETURN expr? SEMICOLON
    ;
throwExcep:
    THROW (ID | exception_func) SEMICOLON
    ;

exceptionDec:
    EXCEPTION
    name = ID {System.out.println("VarDec:" + $name.text); }
    (ASSIGN (exception_func) {System.out.println("Operator:="); })?
    SEMICOLON
    ;

break_continue:
    BREAK {System.out.println("Control:break");} SEMICOLON
    |CONTINUE{System.out.println("Control:continue");} SEMICOLON
    ;

varuse:
    ID expr SEMICOLON
    |ID DOT preDefined_var LPAR funcArg? RPAR SEMICOLON
    ;


orderDeclaration
    :ORDER
     LPAR
     orderArgs
     RPAR
    ;

orderArgs
    :BUY (COMMA expr)*
    |SELL (COMMA expr)*
    |expr (COMMA expr)*
    ;


varDeclaration
    : varMethod
      type
      name = ID { System.out.println("VarDec:" + $name.text); }
      (ASSIGN (expr | orderDeclaration | tradeClassInstance | observeDec) { System.out.println("Operator:="); })?
      SEMICOLON
    ;

arrDeclaration
    : varMethod
      type
      (LBRACKET expr RBRACKET name = ID  {System.out.println("ArrayDec:" + $name.text + ":" + $expr.text);})?
      (ASSIGN (expr | orderDeclaration | tradeClassInstance | candleDec) { System.out.println("Operator:="); })?
      SEMICOLON
    ;

candleDec:
    GETCANDLE
    LPAR
    expr
    RPAR
    ;

observeDec:
     OBSERVE
     LPAR
     expr
     RPAR
     ;

exception_func:
    EXCEPTION LPAR name = INT_VAL { System.out.println("ErrorControl:"+ $name.text); } COMMA STRING_VAL RPAR
    ;

tradeClassInstance:
    ID DOT preDefined_var;

preDefined_var
    : BID
    | ASK
    |DIGITS
    |CANDLE
    |CLOSE
    |OPEN
    |TYPE
    ;



array_predefined_var
    :TIME
    |OPEN
    |CLOSE
    |HIGH
    |LOW
    |VOLUME
    ;

varMethod
    : STATIC
    | SHARED
    | //ep
    ;

methodDeclaration
    :type
     funcdec_name
     LPAR
     parameterList?
     RPAR
     (THROW exceptionType)?
     methodBody
    ;

pre_def_func

    : REFRESHRATE
    | CONNECT
    | GETCANDLE

    ;

funcdec_name
    : ONINIT
    | ONSTART
    | MAIN
    | name = ID {System.out.println("MethodDec:" + $name.text);}
;

parameterList
    : parameter (COMMA parameter)*
    ;

parameter
    : type ID
    ;

methodBody
    : LBRACE statement* RBRACE
    ;

ifStatement
    : IF { System.out.println("Conditional:if");}
    LPAR
    condition
    RPAR
    ifBody

    ;

ifBody
      : LBRACE? statement* RBRACE? (ELSE{ System.out.println("Conditional:else");} LBRACE? statement* RBRACE?)?
      ;

whileStatement
    : WHILE{System.out.println("Loop:while");} LPAR condition RPAR LBRACE statement* RBRACE
    ;

forStatement
    : FOR{{System.out.println("Loop:for");}} LPAR forInit? forCondition? SEMICOLON forUpdate* RPAR LBRACE statement* RBRACE
    ;

forInit
    : varDeclaration
    ;

forCondition
    : condition
    ;

forUpdate
    : expr
    ;

tryCatchStatement
    : TRY LBRACE statement+ RBRACE CATCH exceptionType ID LBRACE statement* RBRACE
    ;

scheduleStatement
    : SCHEDULE{System.out.println("ConcurrencyControl:Schedule");}  schedule_expr (PREORDER | PARALLEL) schedule_expr SEMICOLON
    ;

schedule_expr
    :LPAR?(tradeExpression? (PREORDER | PARALLEL)? tradeExpression?)RPAR?
    ;


printStatement
    : PRINT{{System.out.println("Built-in:print");}} LPAR expr RPAR SEMICOLON
    ;

condition
    : expr
    ;

assignment
    : (ID | arrayAccess) ASSIGN{{ System.out.println("Operator:="); }} (array_assign|expr )  SEMICOLON
    ;

array_assign:
    arrayAccess DOT array_predefined_var;


functionCall
    : (pre_def_func|ID) LPAR funcArg? RPAR
;

funcArg
    :expr (COMMA expr)*
    ;

type
    : INT
    | FLOAT
    | DOUBLE
    | BOOL
    | STRING
    | VOID
    | ASK
    | BID
    | CANDLE
    | DIGITS
    | TIME
    | TRADE
    | ORDER
    ;

exceptionType
    : EXCEPTION
    ;

expr
    : expr_logic_or
    ;

expr_logic_or
    : expr_logic_and expr_logic_or_
    ;

expr_logic_or_
    : OR expr_logic_and expr_logic_or_ { System.out.println("Operator:||"); }
    | // epsilon
    ;

expr_logic_and
    : expr_rel_eq_neq expr_logic_and_
    ;

expr_logic_and_
    : AND expr_rel_eq_neq expr_logic_and_ { System.out.println("Operator:&&"); }
    | // epsilon
    ;

expr_rel_eq_neq
    : expr_rel_cmp expr_rel_eq_neq_
    ;

expr_rel_eq_neq_
    : EQL expr_rel_cmp expr_rel_eq_neq_ { System.out.println("Operator:=="); }
    | NEQ expr_rel_cmp expr_rel_eq_neq_ { System.out.println("Operator:!="); }
    | // epsilon
    ;

expr_rel_cmp
    : expr_arith_plus_minus expr_rel_cmp_
    ;

expr_rel_cmp_
    : GTR expr_arith_plus_minus expr_rel_cmp_ { System.out.println("Operator:>"); }
    | GEQ expr_arith_plus_minus expr_rel_cmp_ { System.out.println("Operator:>="); }
    | LES expr_arith_plus_minus expr_rel_cmp_ { System.out.println("Operator:<"); }
    | LEQ expr_arith_plus_minus expr_rel_cmp_ { System.out.println("Operator:<="); }
    | // epsilon
    ;

expr_arith_plus_minus
    : expr_arith_mult_div_mod expr_arith_plus_minus_
    ;

expr_arith_plus_minus_
    : PLUS expr_arith_mult_div_mod expr_arith_plus_minus_ { System.out.println("Operator:+"); }
    | MINUS expr_arith_mult_div_mod expr_arith_plus_minus_ { System.out.println("Operator:-"); }
    | // epsilon
    ;

expr_arith_mult_div_mod
    : expr_unary_plus_minus_not expr_arith_mult_div_mod_
    ;

expr_arith_mult_div_mod_
    : MULT expr_unary_plus_minus_not expr_arith_mult_div_mod_ { System.out.println("Operator:*"); }
    | DIV expr_unary_plus_minus_not expr_arith_mult_div_mod_ { System.out.println("Operator:/"); }
    | MOD expr_unary_plus_minus_not expr_arith_mult_div_mod_ { System.out.println("Operator:%"); }
    | // epsilon
    ;

expr_unary_plus_minus_not
    : DOUBLE_PLUS  { System.out.println("Operator:++"); }
    | DOUBLE_MINUS  { System.out.println("Operator:--"); }
    | PLUS expr_other { System.out.println("Operator:+"); }
    | MINUS expr_other { System.out.println("Operator:-"); }
    | NOT expr_other { System.out.println("Operator:!"); }
    | expr_other
    ;

expr_other
    : LPAR expr RPAR
    | arrayAccess
    | functionCall
    | ID
    | classInstance
    | primitive_val
    ;


classInstance:
    (ID | exception_func ) DOT preDefined_var
    ;

arrayAccess
    : ID LBRACKET expr RBRACKET
    ;

tradeExpression
    : ID
    ;

primitive_val
    : INT_VAL
    | FLOAT_VAL
    | STRING_VAL
    | DOUBLE_VAL
    | BOOLEAN_VAL
    | ZERO
    ;



// Lexer rules

//keywords:

PARALLEL: 'parallel';
PREORDER:'preorder';
TERMINATE:'Terminate';
GETCANDLE:'GetCandle';
REFRESHRATE:'RefreshRate';
EXCEPTION: 'Exception';
CANDLE:'Candle';
ORDER:'Order';
TRADE:'Trade';
TEXT:'Text';
TIME:'Time';
OPEN:'Open';
CLOSE:'Close';
HIGH:'High';
LOW:'Low';
VOLUME:'Volume';
TYPE:'Type';
ASK:'Ask';
BID:'Bid';
SELL:'SELL';
BUY:'BUY';
DIGITS:'Digits';
MAIN:'Main';
SHARED:'shared';
STATIC:'static';
CATCH:'catch';
RETURN:'return';
THROW:'throw';
TRY:'try';
CONNECT : 'Connect';
OBSERVE : 'Observe';
ONSTART : 'OnStart';
ONINIT : 'OnInit';
SCHEDULE : '@schedule';
FOR : 'for';
WHILE : 'while';
IF : 'if';
ELSE : 'else';
BREAK : 'break';
CONTINUE : 'continue';
PRINT : 'Print';

// Type

VOID:'void';
INT:'int';
STRING:'string';
BOOL:'bool';
FLOAT:'float';
DOUBLE:'double';



// Type Val
ID : [a-zA-Z] [a-zA-Z0-9_]*;
INT_VAL : [0-9]+;
FLOAT_VAL : [0-9]+ '.' [0-9]+;
STRING_VAL : '"' ~('\r' | '\n' | '"')* '"';
DOUBLE_VAL: [0-9]+ '.' [0-9]+;
BOOLEAN_VAl: 'true' | 'false';
ZERO:'0';


// Parenthesis

LPAR: '(';
RPAR: ')';

// Brackets (array element access)

LBRACKET: '[';
RBRACKET: ']';

// Arithmetic Operators


PLUS:  '+';
MINUS: '-';
MULT:  '*';
DIV:   '/';
MOD:   '%';
DOUBLE_MINUS:   '--';
DOUBLE_PLUS: '++';

// Relational Operators

GTR: '>';
LES: '<';
EQL: '==';
NEQ: '!=';

// Logical Operators

NOT:   '!';
AND: '&&';
OR:  '||';

// Other Operators

BNOT: '~';
SHIFT_L:'<<';
SHIFT_R:'>>';
BAND:'&';
BOR:'|';
BXOR:'^';

// Assignment Operators

ASSIGN:'=';
ADD_ASSIGN:'+=';
MIN_ASSIGN:'-=';
MUL_ASSIGN:'*=';
DIV_ASSIGN:'/=';
MOD_ASSIGN:'%=';

// Symbols

LBRACE:    '{';
RBRACE:    '}';
COMMA:     ',';
DOT:       '.';
COLON:     ':';
SEMICOLON: ';';
QUESTION:  '?';

// Whitespace and comments
WS : [ \t\r\n]+ -> skip;
COMMENT : '//' ~[\r\n]* -> skip;
ML_COMMENT: '/*' .*? '*/' -> skip;
