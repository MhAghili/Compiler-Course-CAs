grammar UTL;

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
ID : [a-z][a-zA-Z0-9_]*;
INT_VAL : [0-9]+;
FLOAT_VAL : [0-9]+ '.' [0-9]+;
STRING_VAL : '"' ~('\r' | '\n' | '"')* '"';
DOUBLE_VAL: [0-9]+ '.' [0-9]+;


// Parenthesis

LPAR: '(';
RPAR: ')';

// Brackets (array element access)

LBRACKET: '[';
RBRACKET: ']';

// Arithmetic Operators

NOT:   '!';
PLUS:  '+';
MINUS: '-';
MULT:  '*';
DIV:   '/';
MOD:   '%';

// Relational Operators

GEQ: '>=';
LEQ: '<=';
GTR: '>';
LES: '<';
EQL: '==';
NEQ: '!=';

// Logical Operators

AND: '&&';
OR:  '||';

// Other Operators

ASSIGN: '=';

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

// paarser rules
program : statement+;

