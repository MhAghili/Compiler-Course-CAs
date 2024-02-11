package main.visitor.codeGenerator;

import main.ast.node.Program;
import main.ast.node.declaration.*;
import main.ast.node.expression.*;
import main.ast.node.statement.*;
import main.ast.type.Type;
import main.ast.type.complexType.TradeType;
import main.ast.type.primitiveType.BoolType;
import main.compileError.CompileError;
import main.compileError.type.ConditionTypeNotBool;
import main.symbolTable.SymbolTable;
import main.symbolTable.itemException.ItemNotFoundException;
import main.symbolTable.symbolTableItems.*;
import main.visitor.Visitor;
import main.ast.node.expression.BinaryExpression;
import main.ast.node.expression.FunctionCall;
import main.ast.node.expression.Identifier;
import main.ast.node.expression.operators.BinaryOperator;
import main.ast.node.expression.values.BoolValue;
import main.ast.node.expression.values.FloatValue;
import main.ast.node.expression.values.IntValue;
import main.ast.node.expression.values.StringValue;
import main.ast.type.*;
import main.ast.type.primitiveType.FloatType;
import main.ast.type.primitiveType.IntType;
import main.ast.type.primitiveType.StringType;
import main.compileError.*;
import main.compileError.type.UnsupportedOperandType;
import main.symbolTable.itemException.ItemAlreadyExistsException;
import main.symbolTable.itemException.ItemNotFoundException;
import main.symbolTable.symbolTableItems.FunctionItem;
import main.symbolTable.symbolTableItems.SymbolTableItem;
import main.symbolTable.symbolTableItems.VariableItem;
import main.visitor.*;
import main.ast.node.declaration.*;
import main.ast.node.statement.ForStmt;
import main.ast.node.statement.Statement;
import main.ast.type.complexType.TradeType;
import main.compileError.CompileError;
import main.compileError.name.*;
import main.symbolTable.SymbolTable;
import main.symbolTable.itemException.ItemAlreadyExistsException;
import main.symbolTable.itemException.ItemNotFoundException;
import main.symbolTable.symbolTableItems.*;
import main.visitor.Visitor;
import main.visitor.typeAnalyzer.*;

import java.util.ArrayList;

import java.io.*;

public class CodeGenerator extends Visitor<String> {
    TypeChecker expressionTypeChecker;
    private String outputPath;
    private FileWriter currentFile;
    private MethodDeclaration currentMethod;

    public CodeGenerator(Graph<String> classHierarchy) {
        this.expressionTypeChecker = new TypeChecker();
        this.prepareOutputFolder();
    }

    private void prepareOutputFolder() {
        this.outputPath = "output/";
        String jasminPath = "utilities/jarFiles/jasmin.jar";
        String listClassPath = "utilities/codeGenerationUtilityClasses/List.j";
        String fptrClassPath = "utilities/codeGenerationUtilityClasses/Fptr.j";
        try {
            File directory = new File(this.outputPath);
            File[] files = directory.listFiles();
            if (files != null)
                for (File file : files)
                    file.delete();
            directory.mkdir();
        } catch (SecurityException e) { }
        copyFile(jasminPath, this.outputPath + "jasmin.jar");
        copyFile(listClassPath, this.outputPath + "List.j");
        copyFile(fptrClassPath, this.outputPath + "Fptr.j");
    }

    private void copyFile(String toBeCopied, String toBePasted) {
        try {
            File readingFile = new File(toBeCopied);
            File writingFile = new File(toBePasted);
            InputStream readingFileStream = new FileInputStream(readingFile);
            OutputStream writingFileStream = new FileOutputStream(writingFile);
            byte[] buffer = new byte[1024];
            int readLength;
            while ((readLength = readingFileStream.read(buffer)) > 0)
                writingFileStream.write(buffer, 0, readLength);
            readingFileStream.close();
            writingFileStream.close();
        } catch (IOException e) { }
    }

    private void createFile(String name) {
        try {
            String path = this.outputPath + name + ".j";
            File file = new File(path);
            file.createNewFile();
            FileWriter fileWriter = new FileWriter(path);
            this.currentFile = fileWriter;
        } catch (IOException e) {}
    }

    private void addCommand(String command) {
        try {
            command = String.join("\n\t\t", command.split("\n"));
            if(command.startsWith("Label_"))
                this.currentFile.write("\t" + command + "\n");
            else if(command.startsWith("."))
                this.currentFile.write(command + "\n");
            else
                this.currentFile.write("\t\t" + command + "\n");
            this.currentFile.flush();
        } catch (IOException e) {}
    }

    private String makeTypeSignature(Type t) {
        if (t instanceof IntType) {
            return "I";
        } else if (t instanceof BoolType) {
            return "Z";
        } else if (t instanceof FloatType) {
            return "F";
        } else if (t instanceof StringType) {
            return "Ljava/lang/String;";
        } else if (t instanceof TradeType) {
            return "L" + ((TradeType) t).getTradeDeclaration().getTradeName().getName() + ";";
        } else {
            return "V";
        }
    }


    @Override
    public String visit(Program program) {
    for (TradeDeclaration tradeDeclaration : program.getTrades()) {
            tradeDeclaration.accept(this);
        }
        return null;
    }

    @Override
    public String visit(MethodDeclaration methodDeclaration) {
        this.createFile(methodDeclaration.getMethodName().getName());
        this.currentMethod = methodDeclaration;
        addCommand(".class public " + methodDeclaration.getMethodName().getName());
        addCommand(".super java/lang/Object");
        addCommand("");
        addCommand(".method public <init>()V");
        addCommand("aload_0");
        addCommand("invokenonvirtual java/lang/Object/<init>()V");
        addCommand("return");
        addCommand(".end method");
        addCommand("");
        addCommand(".method public " + methodDeclaration.getMethodName().getName());
        addCommand(".limit stack 128");
        addCommand(".limit locals 128");
        methodDeclaration.getBody().accept(this);
        addCommand("return");
        addCommand(".end method");
        return null;
    }

    @Override
    public String visit(VarDeclaration varDeclaration) {
        //
        return null;
    }

    @Override
    public String visit(AssignmentStmt assignmentStmt) {
        Type type = assignmentStmt.getlValue().accept(expressionTypeChecker);
        if (type instanceof IntType || type instanceof BoolType) {
            assignmentStmt.getrValue().accept(this);
            addCommand("istore " + assignmentStmt.getlValue().accept(expressionTypeChecker).getDescriptor());
        } else if (type instanceof FloatType) {
            assignmentStmt.getrValue().accept(this);
            addCommand("fstore " + assignmentStmt.getlValue().accept(expressionTypeChecker).getDescriptor());
        } else if (type instanceof StringType) {
            assignmentStmt.getrValue().accept(this);
            addCommand("astore " + assignmentStmt.getlValue().accept(expressionTypeChecker).getDescriptor());
        }
        return null;
    }

    @Override
    public String visit(BlockStmt blockStmt) {
        for (Statement statement : blockStmt.getStatements()) {
            statement.accept(this);
        }
        return null;
    }

    @Override
    public String visit(ConditionalStmt conditionalStmt) {
        conditionalStmt.getTrueBranch().accept(this);
        conditionalStmt.getFalseBranch().accept(this);
        return null;
    }

    @Override
    public String visit(MethodCallStmt methodCallStmt) {

        //

        return null;
    }

    @Override
    public String visit(PrintStmt print) {
        //
        return null;
    }


    @Override
    public String visit(ReturnStmt returnStmt) {
        Type type = returnStmt.getReturnedExpr().accept(expressionTypeChecker);
        if(type instanceof NullType) {
            addCommand("return");
        }
        else {
            returnStmt.getReturnedExpr().accept(this);
            addCommand("ireturn");
        }
        return null;
    }

    @Override
    public String visit(NullValue nullValue) {
        string commands = "aconst_null";

        addCommand(commands);
        return commands;
    }

    @Override
    public String visit(IntValue intValue) {

        string commands = "ldc " + intValue.getConstant();
        addCommand(commands);
        return commands;
    }

    @Override
    public String visit(BoolValue boolValue) {
        string commands = "";
        if (boolValue.getConstant()) {
            commands = "ldc 1";
            addCommand(commands);

        } else {
            commands = "ldc 0";
            addCommand(commands);
        }
        return commands;
    }

    @Override
    public String visit(StringValue stringValue) {
        String commands = "ldc" + stringValue.getConstant();
        addCommand(commands);

        return commands;
    }
}
