/********************************************************
 *               - Pseudo RoboCode Lexer -              *
 *                 J. Jossemar Cordero R.               *
 *              futuroing [at] gmail [dot] com          *
 ********************************************************/

// package compiler.lss;
// 
// import java_cup.runtime.Symbol;
// import compiler.Core;

%%
%class CScanner
%unicode
%cup
%line
%column
%full

%yylexthrow{
  Exception
%yylexthrow}

%eofval{
  return symbol(sym.EOF);
%eofval}

%{
  StringBuffer string = new StringBuffer();
  Core coreRef = null;
  
  /**
   * Constructor with Core reference
   * @param InputStream in	FileSource.
   * @param Core core	Core reference.
   */
  
  public CScanner ( java.io.InputStream in , Core core ){
    this(new java.io.InputStreamReader(in));
    coreRef = core;
  }
  
  /**
   * Constructor with Core reference
   * @param InputStream in	Reader stream source.
   * @param Core core	Core reference.
   */
  
  public CScanner ( java.io.Reader in , Core core ){
    this(in);
    coreRef = core;
  }

  /**
   * Factory Method for "place holder" terminals (tokens).
   * @param int type	Number that identify the recognized token (taken from sym class).
   * @return Symbol	Recognize token.
   */
  private Symbol symbol(int type) {
    return new Symbol( type, yyline, yycolumn, yytext() );
  }

  /**
   * Factory Method for terminals (tokens) with value.
   * @param int type		Number that identify the recognized token (taken from sym class).
   * @param Object value	Object that represent the value of the recognized token.
   * @return Symbol		Recognize token.
   */
  private Symbol symbol(int type, Object value) {
    return new Symbol(type, yyline, yycolumn, value);
  }

%}

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace     = {LineTerminator} | [ \t\f]

Identifier = [:jletter:] ([:jletterdigit:] | "_")*
_INT = 0 | [1-9][0-9]*

/*** Comments ***/
Comment = {TraditionalComment} | {EndOfLineComment} | {DocumentationComment}

TraditionalComment   = "/*" [^*] ~"*/" | "/*" "*"+ "/"
EndOfLineComment     = "//" {InputCharacter}* {LineTerminator}
DocumentationComment = "/**" {CommentContent} "*"+ "/"
CommentContent       = ( [^*] | \*+ [^/\*] )*

%state STRING_S
%state STRING_D

%%

<YYINITIAL> {
    
  /* Function*/
  "return"			{ return symbol(sym.KEYWORD_RETURN );	}

  /* Data type */
  "void"			{ return symbol(sym.TYPE_VOID); }
  "boolean"			{ return symbol(sym.TYPE_BOOL); }
  "int"				{ return symbol(sym.TYPE_INT ); }
  "float"			{ return symbol(sym.TYPE_FLOAT);}
  "char"			{ return symbol(sym.TYPE_CHAR); }
  "String"			{ return symbol(sym.TYPE_STRING); }
 
  /* Instructions */
  "if"			   	{ return symbol(sym.KEYWORD_IF); }
  "else"		   	{ return symbol(sym.KEYWORD_ELSE); }
  
  "switch"		  	{ return symbol(sym.KEYWORD_SWITCH);  }
  "case"		   	{ return symbol(sym.KEYWORD_CASE);    }
  "default"		 	{ return symbol(sym.KEYWORD_DEFAULT); }
  "break"		  	{ return symbol(sym.KEYWORD_BREAK);   }
  
  /* Operators */
  "&&"|"AND"			{ return symbol(sym.OP_AND); }
  "||"|"OR"			{ return symbol(sym.OP_OR); }
  "=="				{ return symbol(sym.OP_EQUAL); }
  "!="|"<>"			{ return symbol(sym.OP_EQUAL_NOT); }
  
  "!"|"NOT"			{ return symbol(sym.OP_NOT); }
  
  ";"     			{ return symbol(sym.SEMICOLOM); }
  ","			     	{ return symbol(sym.COMMA); } 
  ":"			     	{ return symbol(sym.COLOM); }
  "."			     	{ return symbol(sym.DOT);   }
  
  "="     			{ return symbol(sym.OP_ASIGN); }
  "+="     			{ return symbol(sym.OP_ASIGN_PLUS); }
  "-="     			{ return symbol(sym.OP_ASIGN_MINUS); }
  "*="     			{ return symbol(sym.OP_ASIGN_MUL); }
  "/="     			{ return symbol(sym.OP_ASIGN_DIV); }
  "%="     			{ return symbol(sym.OP_ASIGN_MOD); }
  
  "-"				{ return symbol(sym.OP_MINUS); }
  "+"				{ return symbol(sym.OP_PLUS); }
  "*"				{ return symbol(sym.OP_MUL); }
  "/"				{ return symbol(sym.OP_DIV); }
  "%"				{ return symbol(sym.OP_MOD); }
  
  "++"				{ return symbol(sym.OP_INC); }
  "--"				{ return symbol(sym.OP_DEC); }
  
  ">"			     	{ return symbol(sym.OP_GREATER); }
  "<"			     	{ return symbol(sym.OP_LESSER); }
  ">="			    	{ return symbol(sym.OP_GREATER_EQUAL); }
  "<="			    	{ return symbol(sym.OP_LESSER_EQUAL); }
  
  "{"  			   	{ return symbol(sym.CBRACE_L); }
  "}"			     	{ return symbol(sym.CBRACE_R); }
  "["				{ return symbol(sym.BRAKET_L); }
  "]"				{ return symbol(sym.BRAKET_R); }
  "("			     	{ return symbol(sym.BRACE_L); }
  ")"			     	{ return symbol(sym.BRACE_R); }
  
  /* Values */
  "true"		   	{ return symbol(sym.VALUE_BOOLEAN, new Boolean(true)); }
  "false"		   	{ return symbol(sym.VALUE_BOOLEAN, new Boolean(false)); }
  "null"			{ return symbol(sym.VALUE_NULL); }
  {_INT}		   	{ return symbol(sym.VALUE_INT  , Integer.parseInt(yytext())); }
  {_INT}"."{_INT}	   	{ return symbol(sym.VALUE_FLOAT, Float.parseFloat(yytext())); }
  
  { Identifier }		{ return symbol(sym.ID); }
  
  "\""				{ string.setLength(0); yybegin(STRING_D); }
  "'"				{ string.setLength(0); yybegin(STRING_S); }

  /* Ignored tokens */
  {Comment} | {WhiteSpace}	{ /* ignore */ }
}

/* Strings */
<STRING_D> {
  "\"" { yybegin(YYINITIAL); return symbol( sym.VALUE_STRING,  string.toString() ); }
  [^]  { string.append( yytext() ); }
}

<STRING_S>{
  "'"  { yybegin(YYINITIAL); return symbol( sym.VALUE_STRING,  string.toString() ); }
  [^]  { string.append( yytext() ); }
}

/* error fallback */
.|\n                           	{ throw new Exception ( "[Lexical Error] Illegal character <"+ yytext()+">" ); }