grammar UTL;


program : statement+;

statement
    : varDeclaration
    | methodDeclaration
    | ifStatement
    | whileStatement
    | forStatement
    | tryCatchStatement
    | scheduleStatement
    | printStatement
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
      (ASSIGN (expr | orderDeclaration) { System.out.println("Operator:="); })?
      SEMICOLON
    ;

varMethod
    : STATIC
    | SHARED
    | //ep
    ;

methodDeclaration
    :type
     funcName
     LPAR
     parameterList?
     RPAR
     (THROW exceptionType)?
     methodBody
    ;

funcName
    :ONINIT
    | ONSTART
    | ID
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
    : IF LPAR condition RPAR statement (ELSE statement)?
    ;

whileStatement
    : WHILE LPAR condition RPAR statement
    ;

forStatement
    : FOR LPAR forInit? SEMICOLON forCondition? SEMICOLON forUpdate? RPAR statement
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
    : TRY statement+ CATCH exceptionType LBRACE statement* RBRACE
    ;

scheduleStatement
    : SCHEDULE LPAR (tradeExpression (PREORDER | PARALLEL) tradeExpression)* RPAR
    ;

printStatement
    : PRINT LPAR expr RPAR SEMICOLON
    ;

condition
    : expr
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

//expression
//    : assignment
//    ;
//
//assignment
//    : leftHandSide (ASSIGN | ADD_ASSIGN | MIN_ASSIGN | MUL_ASSIGN | DIV_ASSIGN | MOD_ASSIGN)? expression
//    ;

expr
    : expr_logic_or
    ;

expr_logic_or
    : expr_logic_and expr_logic_or_
    ;

expr_logic_or_
    : OR expr_logic_and expr_logic_or_ { System.out.println("Operator: ||"); }
    | // epsilon
    ;

expr_logic_and
    : expr_rel_eq_neq expr_logic_and_
    ;

expr_logic_and_
    : AND expr_rel_eq_neq expr_logic_and_ { System.out.println("Operator: &&"); }
    | // epsilon
    ;

expr_rel_eq_neq
    : expr_rel_cmp expr_rel_eq_neq_
    ;

expr_rel_eq_neq_
    : EQL expr_rel_cmp expr_rel_eq_neq_ { System.out.println("Operator: =="); }
    | NEQ expr_rel_cmp expr_rel_eq_neq_ { System.out.println("Operator: !="); }
    | // epsilon
    ;

expr_rel_cmp
    : expr_arith_plus_minus expr_rel_cmp_
    ;

expr_rel_cmp_
    : GTR expr_arith_plus_minus expr_rel_cmp_ { System.out.println("Operator: >"); }
    | GEQ expr_arith_plus_minus expr_rel_cmp_ { System.out.println("Operator: >="); }
    | LES expr_arith_plus_minus expr_rel_cmp_ { System.out.println("Operator: <"); }
    | LEQ expr_arith_plus_minus expr_rel_cmp_ { System.out.println("Operator: <="); }
    | // epsilon
    ;

expr_arith_plus_minus
    : expr_arith_mult_div_mod expr_arith_plus_minus_
    ;

expr_arith_plus_minus_
    : PLUS expr_arith_mult_div_mod expr_arith_plus_minus_ { System.out.println("Operator: +"); }
    | MINUS expr_arith_mult_div_mod expr_arith_plus_minus_ { System.out.println("Operator: -"); }
    | // epsilon
    ;

expr_arith_mult_div_mod
    : expr_unary_plus_minus_not expr_arith_mult_div_mod_
    ;

expr_arith_mult_div_mod_
    : MULT expr_unary_plus_minus_not expr_arith_mult_div_mod_ { System.out.println("Operator: *"); }
    | DIV expr_unary_plus_minus_not expr_arith_mult_div_mod_ { System.out.println("Operator: /"); }
    | MOD expr_unary_plus_minus_not expr_arith_mult_div_mod_ { System.out.println("Operator: %"); }
    | // epsilon
    ;

expr_unary_plus_minus_not
    : PLUS expr_other { System.out.println("Operator: +"); }
    | MINUS expr_other { System.out.println("Operator: -"); }
    | NOT expr_other { System.out.println("Operator: !"); }
    | expr_other
    ;

expr_other
    : LPAR expr RPAR
    | arrayAccess
    | ID
    | primitive_val
    ;


//leftHandSide
//    : ID
//    | primitive_val
//    | arrayAccess
//
//    ;
//
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
PREORDER:'Preorder';
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
PRINT : 'print';

// Type

VOID:'void';
INT:'int';
STRING:'string';
BOOL:'bool';
FLOAT:'float';
DOUBLE:'double';



// Type Val
ID : [a-z] [a-zA-Z0-9_]*; // Updated rule to include digits after the first character
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
