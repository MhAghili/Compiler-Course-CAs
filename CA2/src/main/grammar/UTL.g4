grammar UTL;

@header{
    import main.ast.node.*;
    import main.ast.node.declaration.*;
    import main.ast.node.statement.*;
    import main.ast.node.expression.*;
    import main.ast.node.expression.operators.*;
    import main.ast.node.expression.values.*;
    import main.ast.type.primitiveType.*;
    import main.ast.type.complexType.*;
    import main.ast.type.*;
}
// Parser rules
// do not change first rule (program) name
program returns [Program pro] : {$pro = new Program(); $pro.setLine(0);}
    ( varDeclaration { $pro.addVar($varDeclaration.varDecRet); }
    | functionDeclaration { $pro.addFunction($functionDeclaration.funcDecRet); }
    | initDeclaration { $pro.addInit($initDeclaration.initDecRet); }
    | startDeclaration { $pro.addStart($startDeclaration.startDecRet); }
    )* mainDeclaration { $pro.setMain($mainDeclaration.mainDecRet); }
    ;


statement returns [Statement statementRet] :
          ( varDeclaration { $statementRet = $varDeclaration.varDecRet; }
          | functionDeclaration { $statementRet = $functionDeclaration.funcDecRet; }
          | assignStatement { $statementRet = $assignStatement.assignStmtRet; }
          | continueBreakStatement { $statementRet = $continueBreakStatement.continueBreakStmtRet; }
          | returnStatement { $statementRet = $returnStatement.returnStmtRet; }
          | ifStatement { $statementRet = $ifStatement.ifStmtRet; }
          | whileStatement { $statementRet = $whileStatement.whileStmtRet; }
          | forStatement { $statementRet = $forStatement.forStmtRet; }
          | tryCatchStatement { $statementRet = $tryCatchStatement.tryCatchStmtRet; }
          | throwStatement { $statementRet = $throwStatement.throwStmtRet; }
          | expression SEMICOLON { $statementRet = $expression.expressionRet; }
          );

varDeclaration returns [VarDeclaration varDecRet] : { $varDecRet = new VarDeclaration(); }
    allType { $varDecRet.setType($allType.allTypeRet); }
    (LBRACK INT_LITERAL RBRACK { $varDecRet.setLength($INT_LITERAL.int); })?
    ID (ASSIGN expression)? SEMICOLON { $varDecRet.setName($ID.text); $varDecRet.setLine($ID.line); };

functionDeclaration returns [FunctionDeclaration funcDecRet] : { $funcDecRet = new FunctionDeclaration(); }
    primitiveType { $funcDecRet.setReturnType($primitiveType.primitiveTypeRet); }
    ID { $funcDecRet.setName($ID.text); $funcDecRet.setLine($ID.line); }
    LPAREN (allType (LBRACK INT_LITERAL RBRACK)? ID { $funcDecRet.addArg($allType.allTypeRet, $ID.text); }
    (COMMA allType (LBRACK INT_LITERAL RBRACK)? ID { $funcDecRet.addArg($allType.allTypeRet, $ID.text); })*)?
    RPAREN (THROW EXCEPTION)? (LBRACE (statement { $funcDecRet.addStatement($statement.statementRet); })* RBRACE
    | statement { $funcDecRet.addStatement($statement.statementRet); });


assignStatement returns [Assign assignStmtRet] : { $assignStmtRet = new Assign(); }
    ID (LBRACK expression RBRACK)? assign { $assignStmtRet.setAssignType($assign.assignRet); }
    expression SEMICOLON { $assignStmtRet.setLine($ID.line); };

mainDeclaration returns [MainDeclaration mainDecRet] : { $mainDecRet = new MainDeclaration(); }
    VOID MAIN LPAREN RPAREN (LBRACE (statement { $mainDecRet.addStatement($statement.statementRet); })* RBRACE
    | statement { $mainDecRet.addStatement($statement.statementRet); });

continueBreakStatement returns [ContinueBreak continueBreakStmtRet] : { $continueBreakStmtRet = new ContinueBreak(); }
    (BREAK | CONTINUE) SEMICOLON { $continueBreakStmtRet.setLine($continueBreakStmtRet.line); };

returnStatement returns [Return returnStmtRet] : { $returnStmtRet = new Return(); }
    RETURN expression SEMICOLON { $returnStmtRet.setLine($RETURN.line); };

tryCatchStatement returns [TryCatchStmt tryCatchStmtRet] :
    TRY (LBRACE (statement { $tryCatchStmtRet.addThenStatement($statement.statementRet); })* RBRACE | statement)
    (CATCH EXCEPTION ID (LBRACE (statement { $tryCatchStmtRet.addElseStatement($statement.statementRet); })* RBRACE | statement))?;

forStatement returns [For forStmtRet] : { $forStmtRet = new For(); }
    FOR LPAREN statement expression SEMICOLON expression? RPAREN
    (LBRACE (statement { $forStmtRet.addStatement($statement.statementRet); })* RBRACE
    | statement { $forStmtRet.addStatement($statement.statementRet); });

initDeclaration returns [InitDeclaration initDecRet] : { $initDecRet = new InitDeclaration(); }
    VOID ONINIT LPAREN TRADE ID RPAREN (THROW EXCEPTION)? (LBRACE (statement { $initDecRet.addStatement($statement.statementRet); })* RBRACE
    | statement { $initDecRet.addStatement($statement.statementRet); });


startDeclaration returns [StartDeclaration startDecRet] : { $startDecRet = new StartDeclaration(); }
    VOID ONSTART LPAREN TRADE ID RPAREN (THROW EXCEPTION)? (LBRACE (statement { $startDecRet.addStatement($statement.statementRet); })* RBRACE
    | statement { $startDecRet.addStatement($statement.statementRet); });


ifStatement returns [If ifStmtRet] : { $ifStmtRet = new If(); }
    IF LPAREN expression RPAREN (LBRACE (statement { $ifStmtRet.addIfBody($statement.statementRet); })* RBRACE
    | statement { $ifStmtRet.addIfBody($statement.statementRet); })
    (ELSE (LBRACE (statement { $ifStmtRet.addElseBody($statement.statementRet); })* RBRACE
    | statement { $ifStmtRet.addElseBody($statement.statementRet); }))?;

whileStatement returns [While whileStmtRet] : { $whileStmtRet = new While(); }
    WHILE LPAREN expression RPAREN (LBRACE (statement { $whileStmtRet.addBody($statement.statementRet); })* RBRACE
    | statement { $whileStmtRet.addBody($statement.statementRet); });

throwStatement returns [Throw throwStmtRet] : { $throwStmtRet = new Throw(); }
    THROW expression SEMICOLON { $throwStmtRet.setLine($THROW.line); };

functionCall returns [FunctionCall functionCallRet] : { $functionCallRet = new FunctionCall(); }
    (espetialFunction | complexType | ID) LPAREN (expression (COMMA expression)*)? RPAREN;

methodCall returns [MethodCall methodCallRet] : { $methodCallRet = new MethodCall(); }
    ID (LBRACK expression RBRACK)? DOT espetialMethod LPAREN (expression (COMMA expression)*)? RPAREN;


expression returns [Expression expressionRet] locals [UnaryOperator op1, BinaryOperator op2, int Line] :
             value { $expressionRet = $value.valueRet; }
           | lexpr=expression DOT espetialVariable { $expressionRet = new MethodCall($lexpr.expressionRet, $espetialVariable.espetialVariableRet); }
           | lexpr=expression (INC{$op1 = UnaryOperator.INC; $Line = $INC.line;} | DEC{$op1 = UnaryOperator.DEC; $Line = $DEC.line;}) { $expressionRet = new UnaryExpression($op1, $lexpr.expressionRet); $expressionRet.setLine($Line); }
           | (NOT {$op1 = UnaryOperator.NOT; $Line = $NOT.line;} | MINUS {$op1 = UnaryOperator.MINUS; $Line = $MINUS.line;} | BIT_NOT {$op1 = UnaryOperator.BIT_NOT; $Line = $BIT_NOT.line;} | INC {$op1 = UnaryOperator.INC; $Line = $INC.line;} | DEC{$op1 = UnaryOperator.DEC; $Line = $DEC.line;}) lexpr=expression { $expressionRet = new UnaryExpression($op1, $lexpr.expressionRet); $expressionRet.setLine($Line); }
           | lexpr=expression (MULT {$op2 = BinaryOperator.MULT; $Line = $MULT.line;} | DIV {$op2 = BinaryOperator.DIV; $Line = $DIV.line;} | MOD {$op2 = BinaryOperator.MOD; $Line = $MOD.line;}) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression (PLUS {$op2 = BinaryOperator.PLUS; $Line = $PLUS.line;} | MINUS {$op2 = BinaryOperator.MINUS; $Line = $MINUS.line;}) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression (L_SHIFT {$op2 = BinaryOperator.L_SHIFT; $Line = $L_SHIFT.line;} | R_SHIFT {$op2 = BinaryOperator.R_SHIFT; $Line = $R_SHIFT.line;}) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression (LT {$op2 = BinaryOperator.LT; $Line = $LT.line;} | GT {$op2 = BinaryOperator.GT; $Line = $GT.line;}) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression (EQ {$op2 = BinaryOperator.EQ; $Line = $EQ.line;} | NEQ {$op2 = BinaryOperator.NEQ; $Line = $NEQ.line;}) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression (BIT_AND {$op2 = BinaryOperator.BIT_AND; $Line = $BIT_AND.line;} | BIT_OR {$op2 = BinaryOperator.BIT_OR; $Line = $BIT_OR.line;} | BIT_XOR {$op2 = BinaryOperator.BIT_XOR; $Line = $BIT_XOR.line;}) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression AND {$op2 = BinaryOperator.AND; $Line = $AND.line;} rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression OR {$op2 = BinaryOperator.OR; $Line = $OR.line;} rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | ID {boolean temp = false;}(LBRACK lexpr=expression RBRACK {temp = true;})? { if(temp) $expressionRet = new ArrayIdentifier($ID.text, $lexpr.expressionRet); else $expressionRet = new Identifier($ID.text); $expressionRet.setLine($ID.line); }
           | LPAREN lexpr=expression RPAREN { $expressionRet = $lexpr.expressionRet; }
           | functionCall { $expressionRet =  $functionCall.functionCallRet; }
           | methodCall { $expressionRet = $methodCall.methodCallRet; };

value returns [Value valueRet] : { $valueRet = new Value(); }
    (
        INT_LITERAL { $valueRet.setValue($INT_LITERAL.int); }
        |
        FLOAT_LITERAL { $valueRet.setValue($FLOAT_LITERAL.text); } // float or text
        |
        STRING_LITERAL { $valueRet.setValue($STRING_LITERAL.text); }
        |
        SELL { $valueRet.setValue($SELL.text); }
        |
        BUY { $valueRet.setValue($BUY.text); }
    );


primitiveType returns [PrimitiveType primitiveTypeRet] : { $primitiveTypeRet = new PrimitiveType(); }
    (FLOAT | DOUBLE | INT | BOOL | STRING | VOID) { $primitiveTypeRet.setType($primitiveTypeRet.text); };

complexType returns [ComplexType complexTypeRet] : { $complexTypeRet = new ComplexType(); }
    (ORDER | TRADE | CANDLE | EXCEPTION) { $complexTypeRet.setType($complexTypeRet.text); };

allType returns [AllType allTypeRet] : { $allTypeRet = new AllType(); }
    (primitiveType | complexType) { $allTypeRet.setType($allTypeRet.text); };

espetialFunction returns [EspetialFunction espetialFunctionRet] : { $espetialFunctionRet = new EspetialFunction(); }
    (REFRESH_RATE | CONNECT | OBSERVE | GET_CANDLE | TERMINATE | PRINT) { $espetialFunctionRet.setType($espetialFunctionRet.text); };

espetialVariable returns [EspetialVariable espetialVariableRet] : { $espetialVariableRet = new EspetialVariable(); }
    (ASK | BID | TIME | HIGH | LOW | DIGITS | VOLUME | TYPE | TEXT | OPEN | CLOSE) { $espetialVariableRet.setType($espetialVariableRet.text); };

espetialMethod returns [EspetialMethod espetialMethodRet] : { $espetialMethodRet = new EspetialMethod(); }
    (OPEN | CLOSE) { $espetialMethodRet.setType($espetialMethodRet.text); };

assign returns [Assign assignRet] : { $assignRet = new Assign(); }
    (ASSIGN | ADD_ASSIGN | SUB_ASSIGN | MUL_ASSIGN | DIV_ASSIGN | MOD_ASSIGN) { $assignRet.setAssignType($assignRet.text); };




// Lexer rules
SPACES : [ \t\r\n]+ -> skip;
SEMICOLON : ';';
COMMA : ',';
COLON : ':';
DOT: '.';
LPAREN : '(';
RPAREN : ')';
LBRACE : '{';
RBRACE : '}';
LBRACK : '[';
RBRACK : ']';

PLUS : '+';
MINUS : '-';
MULT : '*';
DIV : '/';
MOD : '%';

AND : '&&';
OR: '||';
NOT: '!';

BIT_AND : '&';
BIT_OR : '|';
BIT_XOR : '^';
L_SHIFT : '<<';
R_SHIFT : '>>';
BIT_NOT : '~';

LT : '<';
GT : '>';
EQ : '==';
NEQ : '!=';

INC : '++';
DEC : '--';

ASSIGN : '=';
ADD_ASSIGN: '+=';
SUB_ASSIGN: '-=';
MUL_ASSIGN: '*=';
DIV_ASSIGN: '/=';
MOD_ASSIGN: '%=';

TRY : 'try';
THROW : 'throw';
CATCH : 'catch';
IF : 'if';
ELSE : 'else';
FOR: 'for';
WHILE : 'while';
BREAK : 'break';
CONTINUE : 'continue';
RETURN : 'return';

MAIN : 'Main';
ONINIT : 'OnInit';
ONSTART : 'OnStart';

FLOAT : 'float';
DOUBLE : 'double';
STRING: 'string';
BOOL: 'bool';
VOID: 'void';
INT : 'int';

BUY : 'BUY';
SELL : 'SELL';

ASK : 'Ask';
BID : 'Bid';
TIME : 'Time';
HIGH : 'High';
LOW : 'Low';
DIGITS : 'Digits';
VOLUME : 'Volume';
TYPE: 'Type';
TEXT: 'Text';
OPEN : 'Open';
CLOSE : 'Close';

TRADE: 'Trade';
ORDER: 'Order';
CANDLE: 'Candle';
EXCEPTION: 'Exception';

REFRESH_RATE : 'RefreshRate';
GET_CANDLE : 'GetCandle';
TERMINATE : 'Terminate';
CONNECT : 'Connect';
OBSERVE : 'Observe';
PRINT : 'Print';

ID : [a-zA-Z_][a-zA-Z_0-9]*;

INT_LITERAL : [1-9][0-9]* | '0';
FLOAT_LITERAL : [0-9]* '.' [0-9]+;
STRING_LITERAL : '"' (~["])* '"';

COMMENT: (('//' ~('\r'|'\n')*) | ('/*' .*? '*/')) -> skip;
