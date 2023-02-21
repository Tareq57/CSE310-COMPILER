%option noyywrap

%x STRING
%x SINGLE_COMMENT
%x MULTI_COMMENT

%{
#include<bits/stdc++.h>
#include "1905071.h"
#include <fstream>
using namespace std;
#include "y.tab.h"
#define ll long long
#define pb push_back
#define mp make_pair
#define ull unsigned long long
#define vll vector<long long>
#define pll pair<long long, long long>
#define f first
#define s second
#define up upper_bound
#define lp lower_bound
#define pq priority_queue
#define pdi pair<double, pll>
#define inf 1e10
#define minf -1e15
#define pi 3.14159265
#define mod 1000000007


extern YYSTYPE yylval;

ll line_count=1;
ll error_count=0;
ll cnt=0;
string comment;
string str,str_token;
ll ok =0;


//SymbolTable table(10);
//ofstream output_token("1905071_token.txt");



string get_upper(string text)
{
    for(ll i=0;i<text.size();i++)
    {
        text[i]=toupper(text[i]);
    }
    return text;
}
void KeyWords()
{
    string keyword = yytext;
    //output_token << "<" << get_upper(yytext) <<", "<<yytext<< ">\n";
    output_file<<"Line# "<<line_count <<": Token "<<"<"<<get_upper(yytext)<<"> Lexeme "<<yytext<<" found"<<endl;
}

void ConstInt()
{
   // output_token << "<CONST_INT, " << yytext << ">\n";
    output_file<<"Line# "<<line_count <<": Token "<<"<CONST_INT> Lexeme "<<yytext<<" found"<<endl;
   
}
void ConstFloat()
{
   // output_token << "<CONST_FLOAT, " << yytext << ">\n";
    output_file<<"Line# "<<line_count <<": Token "<<"<CONST_FLOAT> Lexeme "<<yytext<<" found"<<endl;
 
    
}
void ConstChar()
{
    string text(yytext);
    string Character= text.substr(1,1);
    //output_token << "<CONST_CHAR, " << Character << ">\n";
    output_file<<"Line# "<<line_count <<": Token "<<"<CONST_CHAR> Lexeme "<<Character<<" found"<<endl;

}
void ExtraConstChar(){
	string str = "";
    string text(yytext);
	if (text=="'\\n'"){
		str=str+"\n";
	}
    if (text=="'\\t'"){
		str=str+"\t";
	}
    if (text=="'\\\\'"){
		str=str+"\\";
	}
    if (text=="'\\''"){
		str=str+"\'";
	}
    if (text=="'\\a'"){
		str=str+"\a";
	}
    if (text=="'\\f'"){
		str=str+"\f";
	}
    if (text=="'\\r'"){
		str=str+"\r";
	}
    if (text=="'\\b'"){
		str=str+"\b";
	}
    if (text=="'\\v'"){
		str=str+"\v";
	}
    if (text=="'\\0'"){
		str=str+"\0";
	}
	
		
	//output_token << "<CONST_CHAR, " << str << ">\n";
	output_file << "Line# " << line_count << ": Token <CONST_CHAR> Lexeme \tfound\n";

}

void Operator(string op,string symbol) {
	//output_token << "<" << op <<", " << symbol << ">\n";
    output_file<<"Line# "<<line_count <<": Token <"<<op<<"> Lexeme "<<symbol<<" found"<<endl;
}

void Identifier(){
		
	//output_token << "<ID, " << yytext << ">\n";
    output_file<<"Line# "<<line_count <<": Token "<<"<ID> Lexeme "<<yytext<<" found"<<endl;
	// if(table.Insert(new SymbolInfo(yytext, "ID")))
	// 	table.PrintAllScopeTable();
	
}
void Single_String(){
	string text(yytext);
	//output_token << "<SINGLE LINE STRING, " << str_token << ">\n";
    output_file<<"Line# "<<line_count <<": Token "<<"<SINGLE LINE STRING> Lexeme "<<str<<" found"<<endl;
}
void MULTI_String(){
	string text(yytext);
	//output_token << "<MULTI LINE STRING, " << str_token << ">\n";
    output_file<<"Line# "<<line_count <<": Token "<<"<MULTI LINE STRING> Lexeme "<<str<<" found"<<endl;
}
void Single_Comment()
{
    output_file<<"Line# "<<line_count <<": Token " <<"<SINGLE LINE COMMENT>"<<" Lexeme "<<comment<<" found"<<endl;
}
void Multi_Comment()
{
    output_file<<"Line# "<<line_count <<": Token " <<"<MULTI LINE COMMENT>"<<" Lexeme "<<comment<<" found"<<endl;
}

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z_]
DIGIT [0-9]
NEWLINE \n
FLOAT {DIGIT}*(\.)?{DIGIT}+(E[+-]?{DIGIT}+)?
ANY_CHARACTER_EXCEPT_BACKSLASH([ -~]{-}['\\])
OBSOLETEOP [\*+/-]
OBSOLETESP (" "|\t)


%%

{NEWLINE} {
    line_count++;
}
{WHITESPACE} {}

\/\* {

    comment = "/*";
    cnt=0;
    BEGIN MULTI_COMMENT;
}
<MULTI_COMMENT>\*\/ {
    comment+="*/";
    Multi_Comment();
    line_count+=cnt;
    BEGIN INITIAL;
}
<MULTI_COMMENT>\n {
    comment+="\n";
    //comment+="  ";
    cnt++;
}
<MULTI_COMMENT>\r {
    comment+="\r";
}
<MULTI_COMMENT>. {
    comment+=yytext[0];
}

<MULTI_COMMENT><<EOF>> {
    error_count++;
    line_count +=cnt;	
    output_file<<"Error at line# "<<line_count <<": UNFINISHED_COMMENT "<<comment<<"\n";
	BEGIN INITIAL;
}

\/\/ {
    cnt = 0;
    comment = "//";
    BEGIN SINGLE_COMMENT;
}


<SINGLE_COMMENT>[\r]?\n {
    cnt++;
    Single_Comment();
    line_count+=cnt;
    BEGIN INITIAL;
}

<SINGLE_COMMENT><<EOF>> {
    error_count++;
    output_file<<"Error at line# "<<line_count <<": UNFINISHED_COMMENT "<<comment<<"\n";
     line_count +=cnt;	
	BEGIN INITIAL;
}

<SINGLE_COMMENT>\\\r\n {
    cnt++;
    comment+="\\\r\n";
}

<SINGLE_COMMENT>\\\n {
    cnt++;
    comment+="\\\n";
}

<SINGLE_COMMENT>\\ {
    comment+="\\";
}

<SINGLE_COMMENT>. {
    comment+=yytext[0];
}



{DIGIT}+ {
    ConstInt();
    yylval.symbol= new  SymbolInfo(yytext,"CONST_INT");
    yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
    return CONST_INT;
    }
{FLOAT} {
    ConstFloat();
    yylval.symbol= new  SymbolInfo(yytext,"CONST_FLOAT");
    yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
    return CONST_FLOAT;
    }
({DIGIT}+\.{DIGIT}+\.{DIGIT}+)+  {
    output_file << "Error at line# " << line_count << ": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;
	error_count++;
}
({DIGIT}*([Ee][+-]?{DIGIT})+(\.{DIGIT})+)|({DIGIT}\.)+ {
    output_file << "Error at line# " << line_count << ": ILLFORMED_NUMBER "<<yytext<<endl;;
	error_count++;
}

'\\n'|'\\t'|'\\\\'|'\\''|'\\a'|'\\f'|'\\r'|'\\b'|'\\v'|'\\0' {ExtraConstChar();}
'' {
    output_file << "Error at line# " << line_count << ": EMPTY_CONST_CHAR "<<yytext<<endl;
	error_count++;
}	
'{ANY_CHARACTER_EXCEPT_BACKSLASH}{2,}'		{
    output_file << "Error at line# " << line_count << ": MULTICHAR_CONST_CHAR "<<yytext<<endl;;
    error_count++;
}
'{ANY_CHARACTER_EXCEPT_BACKSLASH}*|('(\\[\\fnarbtv0\"\'])*)	{
    string text(yytext);
    string ch= text.substr(0,text.size()-1);
    output_file << "Error at line# " << line_count << ": UNFINISHED_CONST_CHAR "<<ch<<endl;
    error_count++;
    //Operator("SEMICOLON",";");
}
'{ANY_CHARACTER_EXCEPT_BACKSLASH}' 	{ConstChar();
}


\" {

   cnt = 0;
   ok=0;
   str = "\"";
   str_token="";
   //str_token = "\"";
   BEGIN STRING;
}

<STRING>\"  {
   // str_token=str_token+"\"";
    str=str+"\"";
    if(ok==0)
    Single_String();
    else
    MULTI_String();

    line_count=line_count+cnt;
    BEGIN INITIAL;
}

<STRING>\\\r\n  {
    str=str+"\\\r\n";
    cnt++;
}
<STRING>\\\n  {
    str=str+"\\\n";
    //str_token=str_token+"  ";
    cnt++;
    //str=str+" ";
    ok=1;
}

<STRING>[\r]?\n {
    error_count++;
    if(ok==1)
    line_count=line_count+cnt;
    output_file<<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<str<<"\n";
    if(ok==1)line_count++;
    if(ok==0)
    line_count=line_count+cnt+1;
    BEGIN INITIAL;
}
<STRING><<EOF>> {
    error_count++;
    output_file<<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<str<<"\n";
    if(ok==0)
    line_count++;
    BEGIN INITIAL;
}

<STRING>\\n {
    str=str+"\\n";
    //str_token=str_token+"\n";


    
}
<STRING>\\t {
    str=str+"\\t";
    //str=str+"\t";
    str_token=str_token+"\t";
}
<STRING>\\\\ {
    str_token=str_token+"\\";
   // ok=1;
}
<STRING>\\\" {
    str=str+"\\\"";
    str_token=str_token+"\"";
    //ok=1;
}
<STRING>\\a {
    str=str+"\\a";
    str_token=str_token+"\a";
}
<STRING>\\r {
    str=str+"\\r";
    str_token=str_token+"\r";
}
<STRING>\\b {
    str=str+"\\b";
    str_token=str_token+"\b";
}
<STRING>\\v {
    str=str+"\\v";
    str_token=str_token+"\v";
}
<STRING>\\0 {
    str=str+"\\0";
    str_token=str_token+"\0";
   // ok=1;
}
<STRING>. {
    str=str+yytext[0];
    str_token=str_token+yytext[0];
}
int {
     KeyWords();
        yylval.symbol= new  SymbolInfo(yytext, "INT");
	    //yylval.symbol = yylval.symbol;
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
        return INT; 
}
if {
    KeyWords();
    yylval.symbol= new  SymbolInfo(yytext, "IF");
	    //yylval.symbol = yylval.symbol;
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
         yylval.symbol->set_isTerminal(true);
         return IF;
}
for {
    KeyWords();
     yylval.symbol= new  SymbolInfo(yytext, "FOR");
	   // yylval.symbol = yylval.symbol;
        yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return FOR;
}
println {
    KeyWords();
     yylval.symbol= new  SymbolInfo(yytext, "PRINTLN");
	   // yylval.symbol = yylval.symbol;
        yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return PRINTLN;
}
do {
    KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "DO");
	   // yylval.symbol = yylval.symbol;
        yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return DO;

}
float {
    KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "FLOAT");
	   // yylval.symbol = yylval.symbol;
        yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return FLOAT;
}
void {
    KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "VOID");
	   // yylval.symbol = yylval.symbol;
        yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return VOID;
}
switch {
    KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "SWITCH");
	   // yylval.symbol = yylval.symbol;
        yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return SWITCH;
}
default { 
    KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "DEFAULT");
	   // yylval.symbol = yylval.symbol;
        yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return DEFAULT;
}
else {
    KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "ELSE");
	   // yylval.symbol = yylval.symbol;
        yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return ELSE;
}
while {
    KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "WHILE");
	   // yylval.symbol = yylval.symbol;
        yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return WHILE;
}
break {
    KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "BREAK");
	   // yylval.symbol = yylval.symbol;
        yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return BREAK;
}
char {
    KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "CHAR");
	   // yylval.symbol = yylval.symbol; yylval.symbol->set_
        yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return CHAR;
}
double {
    KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "DOUBLE");
	   // yylval.symbol = yylval.symbol;
           yylval.symbol->set_isTerminal(true);
       
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return DOUBLE;
}
return {
KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "RETURN");
	   // yylval.symbol = yylval.symbol;
           yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return RETURN;
}
case {
    KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "CASE");
	   // yylval.symbol = yylval.symbol;
       yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return CASE;
}
continue {
    KeyWords();
yylval.symbol= new  SymbolInfo(yytext, "CONTINUE");
	   // yylval.symbol = yylval.symbol;
       yylval.symbol->set_isTerminal(true);
       yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        return CONTINUE;
}


{LETTER}({LETTER}|{DIGIT})* 	{Identifier();
 yylval.symbol= new  SymbolInfo(yytext,"ID");
 yylval.symbol->set_start_line(line_count);
 yylval.symbol->set_isTerminal(true);
        yylval.symbol->set_end_line(line_count);
    return ID;
}
{DIGIT}+({LETTER}|{DIGIT})* 	{
    output_file << "Error at line# " << line_count << ": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;
	error_count++;
}
"+" {
    string op=yytext;
    Operator("ADDOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "ADDOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return ADDOP;
}
"-" {
 string op=yytext;
    Operator("ADDOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "ADDOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return ADDOP;
}
"*" {
 string op=yytext;
    Operator("MULOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "MULOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_isTerminal(true);
        yylval.symbol->set_end_line(line_count);
	    return MULOP;
} 
"/" {
 string op=yytext;
    Operator("MULOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "MULOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return MULOP;
} 
"%" {
 string op=yytext;
    Operator("MULOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "MULOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return MULOP;
} 
"++" {
 string op=yytext;
    Operator("INCOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "INCOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return INCOP;
} 
"--" {
 string op=yytext;
    Operator("DECOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "DECOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return DECOP;
} 
"<=" {
 string op=yytext;
    Operator("RELOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "RELOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return RELOP;
} 
">=" {
 string op=yytext;
    Operator("RELOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "RELOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return RELOP;
} 
"=="  {
     string op=yytext;
    Operator("RELOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "RELOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return RELOP;
} 
"!=" {
 string op=yytext;
    Operator("RELOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "RELOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return RELOP;
} 
"<" {
 string op=yytext;
    Operator("RELOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "RELOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return RELOP;
} 
">" {
 string op=yytext;
    Operator("RELOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "RELOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return RELOP;
} 
">>" {
string op=yytext;
    Operator("RELOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "RELOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return RELOP;
} 
"<<" {
 string op=yytext;
    Operator("RELOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "RELOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return RELOP;
} 
"=" {
 string op=yytext;
    Operator("ASSIGNOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "ASSIGNOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return ASSIGNOP;
} 
"&&" {
 string op=yytext;
    Operator("LOGICOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "LOGICOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return LOGICOP;
} 
"||" {
 string op=yytext;
    Operator("LOGICOP",op);
        yylval.symbol= new  SymbolInfo(yytext, "LOGICOP");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return LOGICOP;
} 
"!" {
 string op=yytext;
    Operator("NOT",op);
        yylval.symbol= new  SymbolInfo(yytext, "NOT");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return NOT;
} 
"(" {
 string op=yytext;
    Operator("LPAREN",op);
        yylval.symbol= new  SymbolInfo(yytext, "LPAREN");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return LPAREN;
} 
")" {
 string op=yytext;
    Operator("RPAREN",op);
        yylval.symbol= new  SymbolInfo(yytext, "RPAREN");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return RPAREN;
} 
"{" {
 string op=yytext;
    Operator("LCURL",op);
        yylval.symbol= new  SymbolInfo(yytext, "LCURL");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return LCURL;
} 
"}" {
 string op=yytext;
    Operator("RCURL",op);
        yylval.symbol= new  SymbolInfo(yytext, "RCURL");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return RCURL;
} 
"[" {
 string op=yytext;
    Operator("LTHIRD",op);
        yylval.symbol= new  SymbolInfo(yytext, "LTHIRD");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return LTHIRD;
} 
"]" {
 string op=yytext;
    Operator("RTHIRD",op);
        yylval.symbol= new  SymbolInfo(yytext, "RTHIRD");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return RTHIRD;
} 
"," {
 string op=yytext;
    Operator("COMMA",op);
        yylval.symbol= new  SymbolInfo(yytext, "COMMA");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return COMMA;
} 
";"  {
 string op=yytext;
    Operator("SEMICOLON",op);
        yylval.symbol= new  SymbolInfo(yytext, "SEMICOLON");
        yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	    return SEMICOLON;
} 
({OBSOLETEOP}{OBSOLETESP}*=)({OBSOLETEOP}*{OBSOLETESP}*[=]*)* {
	output_file << "Error at line " << line_count << ": " << "syntax error" << endl << endl;
	//error_file << "Error at line " << line_count << ": " << "syntax error" << endl << endl;
	error_count++;
	yylval.symbol= new  SymbolInfo("", "ERROR");
    yylval.symbol->set_start_line(line_count);
        yylval.symbol->set_end_line(line_count);
        yylval.symbol->set_isTerminal(true);
	return ERROR;
}

.   {
    output_file << "Error at line# " << line_count << ": UNRECOGNIZED_CHAR "<<yytext<<endl;
	error_count++;
}

			

%%

// int main(int argc, char** argv) {
// 	if(argc!=2){
// 		printf("Please provide input file name and try again\n");
// 		return 0;
// 	}
	
// 	FILE *fin=fopen(argv[1],"r");
// 	if(fin==NULL){
// 		printf("Cannot open specified file\n");
// 		return 0;
// 	}
	

// 	yyin= fin;
// 	yylex();
//     table.PrintAllScopeTable();
//     output_file<<"Total lines: "<<line_count<<endl<<"Total errors: "<<error_count;
//     fclose(yyin);
// 	output_file.close();
//     output_token.close();
// 	return 0;
// }
