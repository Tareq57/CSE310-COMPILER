%{
#include<bits/stdc++.h>
#include "1905071.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <string.h>

using namespace std;
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
#define st_string stack<string>
#define pdi pair<double, pll>
#define inf 1e10
#define minf -1e15
#define pi 3.14159265
#define mod 1000000007

bool DEBUG = false;
int yyparse(void);
int yylex(void);
extern FILE *yyin;
//FILE *input_file;

ofstream error_file;
ofstream output_file;
ofstream parse_tree_file;
ofstream opt_file;
ofstream asm_file;
ofstream temp_file;

st_string ifLab1 ; 
st_string ifLab2 ; 
st_string elseLab ; 
bool inIfAlready = false ;


SymbolTable table(11);
extern ll line_count;
extern ll error_count;
ll Idd=1;
string currType = "";
SymbolInfo* currFunc;
SymbolInfo* currSymbol;
vector<SymbolInfo*> tempList;
vector<SymbolInfo*> list ;
ll current_offset=0;
ll current_parameter_offset=2; 
ll currParamLen = 0 ; 
ll labelCount = 1 ; 
ll tempCount = 0 ; 
ll functionParameterCnt=0;

bool check = false;
bool isGlobalSpace=true;

bool isArgumentPassing=false;
bool noPop=false;
bool isSemicolom="false";

string notLabel="";
string currFuncName = "" ; 
string currFuncLabel= "";
string whileLabel1= "";
string whileLabel2= "";
// ICG function start
int getCurrentOffset(){
	current_offset = current_offset + 2 ; 
	return current_offset ; 
}

void setCurrentOffset(ll ofset){
	current_offset = ofset ; 
}
void resetCurrentOffset() {
	current_offset = 0 ; 
}

void setCurrParameterOffset(ll ofset){
	current_parameter_offset=ofset;
}
void resetCurrParameterOffset(){
	current_parameter_offset = 2 ; 
}

ll getCurrParameterOffset(){
	// current_parameter_offset+=2;
	return current_parameter_offset;
}

void Init()
{
	asm_file<<".MODEL SMALL\n.STACK 100H\n\n.DATA\n\tCR EQU 0DH\n\tLF EQU 0AH"<<endl<<"\tnumber DB"<<" 00000$"<<endl;  
}

void optimizeCode()
{   
	ll peephole = 1;
	string str ; 
	ifstream file;
	file.open("1905071_asm.txt");
	vector <vector<string> > Lines ; 
	// opt_file<<"eirdfsjokml"<<endl;
	while (getline(file , str)) {
		vector <string> words ; 
		string item = "" ; 
        for (ll i = 0 ;  i < str.length() ;  i++) {
        if (str[i] == ' ' || str[i] == '\t') {
			
            if (item != "") {
                words.pb(item) ; 
                item = "" ; 
            }
        }
        else { 
            item += str[i] ; 
        }
    }

    if (item != "") {
        words.pb(item) ; 
    } 
		if(words.size() != 0){
			Lines.pb(words) ; 
		}
	}
 
	for (ll i = 1 ;  i<Lines.size() ;  i++){ 
		vector <string> first_line = Lines[i-1] ; 
		vector <string> second_line =Lines[i] ; 
		if (first_line[0] == "PUSH" && second_line[0] == "POP" && first_line[1] == second_line[1]){
			i++ ; 
			opt_file << " ; peephole " << peephole << ": PUSH POP removed\n";
			peephole++;
			continue ; 

		} else if (first_line[0] == "PUSH" && second_line[0] == "POP"){
			// i++ ; 
			opt_file << "MOV " << second_line[1]  << " , " << first_line[1] << " ; peephole " << peephole << ": PUSH POP to MOV\n" ; 
			peephole++;
			continue ; 
		}
		
		// for 2nd or more pass
		if (first_line[0] == "MOV"){	
			if (first_line[1] == first_line[3]){
				// MOV BX , BX
				// i++ ; 
				opt_file << " ; peephole " << peephole << ": MOV to same loaction removed below\n";
				peephole++;
				continue ; 
			} 
			if (second_line[0] == "MOV"){
				if (first_line[1] == second_line[3] && first_line[3] == second_line[1]) {
					// MOV AX , BX
					// MOV BX , AX 
					i++ ; 
					opt_file << "MOV " << first_line[1]  << " , " << first_line[3] << " ; peephole " << peephole << ": redundant MOV removed\n" ; 
					continue ; 
				} else if (first_line[1] == second_line[1]){
					// MOV AX , BX
					// MOV AX , CX 
					// omit the first line
					i++ ; 
					opt_file << "MOV " << second_line[1]  << " , " << second_line[3] << " ; peephole " << peephole << ": omitted first MOV redundant MOV removed \n"; 
					continue ; 
					
				}
				

			}
		}
		for (ll j = 0 ;  j<Lines[i].size() ;  j++){
			opt_file << Lines[i][j] << " " ; 
		}
		opt_file << endl ; 
		if (i == Lines.size() - 2) {
			for (ll j = 0 ;  j<Lines[i+1].size() ;  j++){
				opt_file << Lines[i+1][j] << " " ; 
			}
		}
			
	}
}

char *newLabel() {
	char *lb= new char[4] ; 
	strcpy(lb ,"L") ; 
	char b[3] ; 
	sprintf(b ,"%ld" , labelCount) ; 
	labelCount++ ; 
	strcat(lb ,b) ; 
	return lb ; 
}

char *newTemp() {
	char *t= new char[4] ; 
	strcpy(t ,"t") ; 
	char b[3] ; 
	sprintf(b ,"%ld" , tempCount) ; 
	tempCount++ ; 
	strcat(t ,b) ; 
	return t ; 
}

void Ending() {
string str="new_line proc\n"
"push ax\n"
"push dx\n"
"mov ah,2\n"
"mov dl,cr\n"
"int 21h\n"
"mov ah,2\n"
"mov dl,lf\n"
"int 21h\n"
"pop dx\n"
    "pop ax\n"
    "ret\n"
"new_line endp\n"
"print_output proc  ;print what is in ax\n"
    "push ax\n"
    "push bx\n"
    "push cx\n"
    "push dx\n"
    "push si\n"
    "lea si,number\n"
    "mov bx,10\n"
    "add si,4\n"
    "cmp ax,0\n"
    "jnge negate\n"
    "print:\n"
    "xor dx,dx\n"
    "div bx\n"
    "mov [si],dl\n"
    "add [si],'0'\n"
    "dec si\n"
    "cmp ax,0\n"
    "jne print\n"
    "inc si\n"
    "lea dx,si\n"
    "mov ah,9\n"
    "int 21h\n"
    "pop si\n"
    "pop dx\n"
    "pop cx\n"
    "pop bx\n"
    "pop ax\n"
    "ret\n"
    "negate:\n"
    "push ax\n"
    "mov ah,2\n"
    "mov dl,'-'\n"
    "int 21h\n"
    "pop ax\n"
    "neg ax\n"
    "jmp print\n"
"print_output endp\n"
"END main";
asm_file<<str;
}



// ICG function end


void single_string(string str)
{
	output_file<<str<<endl;
}
void Redefinition_error(string str)
{
	error_file<<"Line# "<<line_count<<": Redefinition of parameter '"<<str<<"'"<<endl;
	error_count++;
}
void ConflictingType_err(string str)
{
	error_file<<"Line# "<<line_count<<": Conflicting types for '"<<str<<"'"<<endl;
	error_count++;
}
void Redeclaration_error(string str)
{
	error_file<<"Line# "<<line_count<<": '"<<str<<"' redeclared as different kind of symbol"<<endl;
	error_count++;
}
void Void_declaration_error(string str)
{
	error_file<<"Line# "<<line_count<<": Variable or field '"<<str<<"' declared void"<<endl;
	error_count++;
}
void Type_mismatch_argument_error(string str, int num)
{
	error_file<<"Line# "<<line_count<<": Type mismatch for argument "<<num<<" of '"<<str<<"'"<<endl;
	error_count++;
}
void Too_few_argument_error(string str)
{
	error_file<<"Line# "<<line_count<<": Too few arguments to function '"<<str<<"'"<<endl;
	error_count++;
}
void Too_many_argument_error(string str)
{
	error_file<<"Line# "<<line_count<<": Too many arguments to function '"<<str<<"'"<<endl;
	error_count++;
}
void Undeclared_variable(string str)
{
	error_file<<"Line# "<<line_count<<": Undeclared variable '"<<str<<"'"<<endl;
	error_count++;
}
void Undeclared_function(string str)
{
	error_file<<"Line# "<<line_count<<": Undeclared function '"<<str<<"'"<<endl;
	error_count++;
}
void Not_array_error(string str)
{
	error_file<<"Line# "<<line_count<<": '"<<str<<"' is not an array"<<endl;
	error_count++;
}
void Array_Subscript_error()
{
	error_file<<"Line# "<<line_count<<": Array subscript is not an integer"<<endl;
	error_count++;
}
void Void_expression_error()
{
	error_file<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
	error_count++;
}
void Possible_data_loss()
{
	error_file<<"Line# "<<line_count<<": Warning: possible loss of data in assignment of FLOAT to INT"<<endl;
	error_count++;
}
void DivisionByZero()
{
	error_file<<"Line# "<<line_count<<": Warning: division by zero i=0f=1Const=0"<<endl;
	error_count++;
}
void MustBeInteger()
{
	error_file<<"Line# "<<line_count<<": Operands of modulus must be integers"<<endl;
	error_count++;
}
void MustBeFloat()
{
	error_file<<"Line# "<<line_count<<": Operands of modulus must be floats"<<endl;
	error_count++;
}


void yyerror(char *s)
{
	error_file << "Line# " << line_count << ": yyerror" <<endl;
	error_count++;
}


%}

%union{
	SymbolInfo * symbol ;
}

%token <symbol>  IF ELSE FOR WHILE DO SWITCH BREAK CASE DEFAULT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP NOT CONST_INT DOUBLE CHAR MAIN CONST_FLOAT INCOP DECOP INT FLOAT VOID ID SEMICOLON COMMA ERROR CONTINUE
%token NEWLINE 
%type<symbol> type_specifier  
%type <symbol> start declaration_list var_declaration program unit func_declaration parameter_list func_definition compound_statement statements expression_statement statement variable expression logic_expression unary_expression factor term rel_expression simple_expression arguments argument_list notunIf
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : 
program {
	single_string("start : program"); 
	$$ = new SymbolInfo("start","Program");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	for(ll i=0;i<$1->getChildrenList().size();i++)
	{
		$$->AddChild($1->getChildrenList().at(i));
		// if($1->getChildrenList().at(i)!=NULL)
		// error_file<<$1->getChildrenL
	}
	$$->AddChildParse($1);
	// PrintTree($$,0);
}



program : 
program unit {
	$$ = new SymbolInfo("Program","Program unit");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("program : program unit");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
	  $$->AddChild($1->getChildrenList().at(i));
	}

	for(ll i = 0; i < $2->getChildrenList().size(); i++){
	  $$->AddChild($2->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
	$$->AddChildParse($2);
}
| unit {
	single_string("program : unit");
	$$ = new SymbolInfo("program","unit");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
	   $$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);

}
;
	
unit : 
var_declaration {

	$$ = new SymbolInfo("unit","var_declaration");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("unit : var_declaration");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);

}
| func_declaration {
	single_string("unit : func_declaration"); 
	$$ = new SymbolInfo("unit","func_declaration");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	for (ll i = 0; i<$1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
}
| func_definition {
	single_string("unit : func_definition");
	$$ = new SymbolInfo("unit","func_definition");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	for (ll i = 0; i<$1->getChildrenList().size(); i++) {
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
		
}
;
     
func_declaration: 
type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
	single_string("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
	$$ = new SymbolInfo("func_declaration","type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
	$2->set_Function_check(true);
	$2->set_ret_type($1->getType());
	$2->set_param_list($4->getChildrenList());
	$$->set_start_line($3->get_start_line());
	$$->set_end_line($5->get_end_line());
	if(!table.Insert($2))
	{
		Redefinition_error($2->getName());
	}
	for(ll i = 0; i<$4->getChildrenList().size(); i++){
		if($4->getChildrenList().at(i)->getType() == "COMMA" || $4->getChildrenList().at(i)->getType() == "INT" || $4->getChildrenList().at(i)->getType() == "FLOAT" || $4->getChildrenList().at(i)->getType() == "VOID"){
			continue;
		}
		vector <string> paramList;
		paramList.pb($4->getChildrenList().at(i)->getName());
	}
	$$ = new SymbolInfo("func_declaration","type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($6->get_end_line());
	$$->AddChild($1);
	$$->AddChild($2);
	$$->AddChild($3);
	for(ll i = 0; i<$4->getChildrenList().size(); i++) {
		$$->AddChild($4->getChildrenList().at(i));
	}
	$$->AddChild($5);
	$$->AddChild($6);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
	$$->AddChildParse($4);
	$$->AddChildParse($5);
	$$->AddChildParse($6);
}
| type_specifier ID LPAREN RPAREN SEMICOLON {
	single_string("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
	$$ = new SymbolInfo("func_declaration","type_specifier ID LPAREN RPAREN SEMICOLON");
	$$->set_start_line($3->get_start_line());
	$$->set_end_line($4->get_end_line());
	$2->set_Function_check(true);
	$2->set_ret_type($1->getType());
	if(!table.Insert($2))
	{
		Redefinition_error($2->getName());
	}
	$$=new SymbolInfo("func_declaration","type_specifier ID LPAREN RPAREN SEMICOLON");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($5->get_end_line());
	$$->AddChild($1);
	$$->AddChild($2);
	$$->AddChild($3);
	$$->AddChild($4);
	$$->AddChild($5);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
	$$->AddChildParse($4);
	$$->AddChildParse($5);
}
;
		 
func_definition : 
type_specifier ID LPAREN parameter_list RPAREN {
	currFuncLabel = newLabel() ; 
	resetCurrentOffset() ; 
	if(isGlobalSpace)asm_file << ".CODE" << endl ; 
	asm_file << "\n\t" << $2->getName() << " PROC"<<endl ; 
	isGlobalSpace = false ; 
	if($2->getName() == "main"){
		asm_file << "\t\tmov AX , @DATA\n\t\tmov DS , AX"<<endl ;  
		asm_file << "\t\t"<< "PUSH BP"<<endl;
		asm_file<<"\t\t"<<"MOV BP,SP"<<endl;
	} else {
		asm_file<<"\t\tPUSH BP"<<endl;
		asm_file<<"\t\tMOV BP , SP"<<endl; 
		asm_file<<"\t\tPUSH AX"<<endl;
		asm_file<<"\t\tPUSH BX"<<endl;
		asm_file<<"\t\tPUSH CX"<<endl;
		asm_file<<"\t\tPUSHF"<<endl;
	}

	SymbolInfo * currSymbol = table.getSymbolInfo($2->getName());
	string functionName = $2->getName();
	if (table.LookUpAll($2->getName())) {
		if (!currSymbol->get_Function_check()) 
			Redeclaration_error($2->getName());	
		else {
			if (currSymbol->get_Def())
			{
                 Redefinition_error($2->getName());
				
			}
			else {
				if (currSymbol->get_ret_type() != $1->getType())
					{ConflictingType_err(functionName);}
				else if (currSymbol->get_param_list().size() != $4->getChildrenList().size())
				    {
						// ConflictingType_err($2->getName());
					}
			    else if( $4->getChildrenList().size() != 0) {
					for(ll i = 0; i<$4->getChildrenList().size(); i++) {
						if ($4->getChildrenList().at(i)->getType() == "ID" ||$4->getChildrenList().at(i)->getType() == "COMMA")
							continue;
						if (currSymbol->get_param_list().at(i)->getName() != $4->getChildrenList().at(i)->getName())
							Type_mismatch_argument_error(currSymbol->get_param_list().at(i)->getName(),i+1);
					}
				}
				string functionName = currSymbol->getName();
				string symbolType = currSymbol->getType();
				SymbolInfo * newSymbol = new SymbolInfo(functionName, symbolType);
				vector <SymbolInfo*> paramList = currSymbol->get_param_list();
				currSymbol->set_param_list(paramList);
				currSymbol->set_Def(true);
				currSymbol->set_Function_check(true);
				currFunc = table.getSymbolInfo(functionName);
				
			}
		}
	} 
	else 
	{
		for(ll i = 0; i<$4->getChildrenList().size(); i++)
		{
			if($4->getChildrenList().at(i)->getType() == "COMMA" || $4->getChildrenList().at(i)->getType() == "INT" || $4->getChildrenList().at(i)->getType() == "FLOAT" || $4->getChildrenList().at(i)->getType() == "VOID"){
				continue;
			}
			vector <string> paramList;
			paramList.pb($4->getChildrenList().at(i)->getName());
			for(ll j = 0; j<paramList.size() - 1; j++){
				if($4->getChildrenList().at(i)->getName() == paramList[j])
				{
					Redefinition_error($4->getChildrenList().at(i)->getName());
					
				}
			}
		}
		SymbolInfo * newSymbol = new SymbolInfo(functionName, "ID");
		vector <SymbolInfo*> paramList = $4->getChildrenList();
		newSymbol->set_param_list(paramList);
		newSymbol->set_Def(true);
		newSymbol->set_Function_check(true);
		newSymbol->set_ret_type($1->getType());
		table.Insert(newSymbol);
		currFunc = table.getSymbolInfo(functionName);
	}
	ll j = 0;
	for(ll i = 0; i<$4->getChildrenList().size(); i++) {
		if (i%3==0)
			j++;
		if ($4->getChildrenList().at(i)->getType() == "ERROR") {
			Type_mismatch_argument_error( $2->getName(),j);
		}
	}
	// adding the parameters to symbol table in either case
	// vector<SymbolInfo*> tempList;
	// error_file<<$4->getChildrenList().size()<<endl;
	// table.EnterScope();
	ll ooffset=4;
	for (ll i = $4->getChildrenList().size()-1; i>0; i-=3) {
		// if($4->getChildrenList().at(i)!=NULL)
		tempList.pb($4->getChildrenList().at(i));
		$4->getChildrenList().at(i)->setOffset(ooffset );
		ooffset+=2;
		$4->getChildrenList().at(i)->setisLocal(true);

		// table.Insert(tempList[i]);
	//	output_file<<tempList[i]->getName()<<" "<<tempList[i]->getType()<< endl;
	}
} 
compound_statement
{
	// table.PrintAllScopeTable();
	// output_file<<351<<"print scopetable"<<endl;
	
}
{
	single_string("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
	$$ = new SymbolInfo("func_definition","type_specifier ID LPAREN parameter_list RPAREN compound_statement");
	$$->set_start_line($3->get_start_line());
	$$->set_end_line($5->get_end_line());
	$$->AddChild($1);
	$$->AddChild($2);
	$$->AddChild($3);
	ll p=$4->getChildrenList().size();
	for (ll i = 0; i < p; i++){
		 $$->AddChild($4->getChildrenList().at(i));
	}
	$$->AddChild($5);
	for (ll i = 0; i < $7->getChildrenList().size(); i++){
		$$->AddChild($7->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
	$$->AddChildParse($4);
	$$->AddChildParse($5);
	if(currFunc->getName() == "main"){
		asm_file << 	"\t\t" << newLabel()<<  ": "<<endl ; 
		asm_file <<	"\t\tmov AH , 4Ch"<<endl ; 
		asm_file <<	"\t\tint 21h"<<endl ;  
		asm_file << "\tmain ENDP"<<endl<<endl ; 
	} else {  
		asm_file << "\t\t" << currFuncLabel << ":"<<endl ; 
		asm_file<<"\t\tMOV SP , BP"<<endl;
		asm_file<<"\t\tSUB SP , 8"<< endl;	
		asm_file<<"\t\tPOPF "<<endl;
		asm_file<<"\t\tPOP CX"<<endl;
		asm_file<<"\t\tPOP BX"<<endl;
		asm_file<<"\t\tPOP AX"<<endl;
		asm_file<<"\t\tPOP BP"<<endl ;  
		asm_file << "\t\tRET " << functionParameterCnt*2 << endl;
		asm_file << "\t" << $2->getName() << " ENDP"<<endl<<endl ; 
		currParamLen = 0 ;
		functionParameterCnt=0;
	}

	 tempList.clear();
	 resetCurrParameterOffset() ; 
	// table.ExitScope();
}
| type_specifier ID LPAREN RPAREN {
	currFuncLabel = newLabel() ; 
	resetCurrentOffset() ; 
	currFuncName = $2->getName() ; 
	
	if(isGlobalSpace)
		asm_file << ".CODE" << endl ; 
	asm_file << "\n\t" << $2->getName() << " PROC"<<endl ; 
	isGlobalSpace = false ; 
	if($2->getName() == "main"){
		asm_file << "\t\tmov AX , @DATA\n\t\tmov DS , AX"<<endl<< endl ; 
	} else {
		asm_file<<"\t\tPUSH BP"<<endl;
		asm_file<<"\t\tMOV BP , SP"<<endl;
		asm_file<<"\t\tPUSH AX"<<endl;
		asm_file<<"\t\tPUSH BX"<<endl;
		asm_file<<"\t\tPUSH CX"<<endl;
		asm_file<<"\t\tPUSHF"<<endl;
	} 


	string functionName = $2->getName();
	SymbolInfo * currSymbol = table.getSymbolInfo($2->getName());
	if (table.LookUpAll($2->getName())) {
		if (!currSymbol->get_Function_check())
		 {
			Undeclared_function($2->getName());
		}
		else
		{
			if (currSymbol->get_Def()==true)
			{
				Redefinition_error($2->getName());
			}
			else
			{
				if (!(currSymbol->get_ret_type() == $1->getType())){
					ConflictingType_err($1->getName());
					
				}
			}
		}
		currSymbol->set_Def(true);
		currSymbol->set_Function_check(true);
		currFunc = table.getSymbolInfo(functionName);
	} else {
		SymbolInfo * newSymbol = new SymbolInfo(functionName, "ID");
		newSymbol->set_Def(true);
		newSymbol->set_Function_check(true);
		newSymbol->set_ret_type($1->getType());
		table.Insert(newSymbol);
		currFunc = table.getSymbolInfo(functionName);
	}
}
 compound_statement {
	// table.PrintAllScopeTable();
} {
	single_string("func_definition : type_specifier ID LPAREN RPAREN compound_statement");
	$$=new SymbolInfo("func_definition","type_specifier ID LPAREN RPAREN compound_statement");
	$$->set_start_line($3->get_start_line());
	$$->set_end_line($4->get_end_line());
	$$->AddChild($1);
	$$->AddChild($2);
	$$->AddChild($3);
	$$->AddChild($4);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
	$$->AddChildParse($4);
	for (ll i = 0; i < $6->getChildrenList().size(); i++){
		$$->AddChild($6->getChildrenList().at(i));
	}
	if(currFunc->getName() == "main"){
		asm_file << "\t\t" << currFuncLabel << ": "<<endl ; 
		asm_file <<	"\t\tmov AH , 4Ch"<<endl ; 
		asm_file <<	"\t\tint 21h"<<endl ;  
		asm_file << "\tmain ENDP"<<endl<<endl ; 
	} else {  
		asm_file << "\t\t" << currFuncLabel << ":"<<endl ; 
		asm_file<<"\t\tMOV SP , BP"<<endl;
		asm_file<<"\t\tSUB SP , 8"<<endl;	
		asm_file<<"\t\tPOPF "<<endl;
		asm_file<<"\t\tPOP CX"<<endl;
		asm_file<<"\t\tPOP BX"<<endl;
		asm_file<<"\t\tPOP AX"<<endl;
		asm_file<<"\t\tPOP BP"<<endl<<endl ;  
		asm_file<<"\t\tRET 0"<<endl;  
		asm_file << "\t" << $2->getName() << " ENDP"<<endl<<endl ; 
	}
	resetCurrentOffset() ; 
// table.ExitScope();
 }
;
parameter_list  : 
parameter_list COMMA type_specifier ID {
	// ll  currparameterOffset = $1->getChildrenList().at(($1->getChildrenList().size()-1))->getOffset()+2 ; 
	// $4->setOffset(currparameterOffset) ;
	// $4->setisLocal(true);
	functionParameterCnt++;

	single_string("parameter_list : parameter_list COMMA type_specifier ID");
	$4->set_var_type($3->getType());
	// $4->setType($3->getType());
	$$ = new SymbolInfo("parameter_list","parameter_list COMMA type_specifier ID");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($4->get_end_line());
	for (int i = 0; i<$1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChild($2);
	$$->AddChild($3);
	$$->AddChild($4);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
	
}
| parameter_list COMMA type_specifier {
	single_string( "parameter_list : parameter_list COMMA type_specifier");
	$$ = new SymbolInfo("parameter_list","parameter_list COMMA type_specifier");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	for (int i = 0; i<$1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChild($2);
	$$->AddChild($3);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
}
| parameter_list COMMA type_specifier error {
	single_string("parameter_list : parameter_list COMMA type_specifier");
	$$ = new SymbolInfo("parameter_list","parameter_list COMMA type_specifier");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	for (ll i = 0; i<$1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChild($2);
	$$->AddChild($3);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
	SymbolInfo* errorSymbol = new SymbolInfo("", "ERROR");
	$$->AddChild(errorSymbol);
	yyclearin;
}
| type_specifier ID {

	// ll  currOffset = 4 ; 
	// $2->setOffset(currOffset) ;
	// $2->setisLocal(true);
	functionParameterCnt++;
	$2->set_var_type($1->getType());
	single_string("parameter_list : type_specifier ID");
	$$=new SymbolInfo("parameter_list","type_specifier ID");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($2->get_end_line());
	$$->AddChild($1);
	$$->AddChild($2);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
}
| type_specifier {
	single_string("parameter_list : type_specifier");
	$$ = new SymbolInfo("parameter_list","type_specifier");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	vector<SymbolInfo*> tempList;
	$$->AddChild($1);
	$$->AddChildParse($1);
}
| type_specifier error {
	single_string( "parameter_list : type_specifier" );
	$$ = new SymbolInfo("parameter_list","type_specifier");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	$$->AddChild($1);
	$$->AddChildParse($1);
	// output_file<<"vai re vai error"<<endl;
	// SymbolInfo* errorSymbol = new SymbolInfo("", "ERROR");
	// $$->AddChild(errorSymbol);
	yyclearin;
}
;
compound_statement : 
LCURL {
	isGlobalSpace = false ; 
	table.EnterScope();
	// output_file<<584<<" "<<tempList.size()<<"fd"<<endl;

	for (ll i = 0; i<tempList.size(); i++){
		if (tempList.at(i)->getType() != "ID" || tempList.at(i)->getType() == "ERROR") {
			continue;
		}
		if (table.Insert(tempList[i])==false){
			Redefinition_error( tempList.at(i)->getName());
		}	
	}
	tempList.clear();
} statements RCURL {
	$$ = new SymbolInfo("compound_statement","LCURL statements RCURL");
	single_string("compound_statement : LCURL statements RCURL");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	$$->AddChild($1);
	for(ll i = 0; i < $3->getChildrenList().size(); i++){
		$$->AddChild($3->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
	$$->AddChildParse($3);
	$$->AddChild($4);
	table.PrintAllScopeTable();
	table.ExitScope();
}
| LCURL {
	isGlobalSpace = false ; 
	// table.EnterScope();
} RCURL {
	$$ = new SymbolInfo("compound_statement", "LCURL RCURL");
	single_string("compound_statement : LCURL RCURL" );
	$$->set_start_line($1->get_start_line());
	// $$->set_end_line($3->get_end_line());
	cout<<$$->get_end_line()<<" "<<$$->get_start_line()<<endl;
	$$->AddChild($1);
	$$->AddChild($3);
	// table.PrintAllScopeTable();
	// table.ExitScope();
}
;
var_declaration : 
type_specifier declaration_list SEMICOLON {
	currType = $1->getType() ; 
	$$ = new SymbolInfo("var_declaration","type_specifier declaration_list SEMICOLON");
	single_string("var_declaration : type_specifier declaration_list SEMICOLON");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	if($1->getType() == "VOID"){
		Void_declaration_error($2->getChildrenList().at(0)->getName());
	}
	$$->AddChild($1);
	for(ll i = 0; i < $2->getChildrenList().size(); i++){
		$$->AddChild($2->getChildrenList().at(i));
		if ($2->getChildrenList().at(i)->getType() == "ERROR") {
			error_count++;
		}
	}
	$$->AddChild($3);
	//$$->set_param_list(list);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
}
;
 		 
type_specifier	: 
INT	{
	$$= new SymbolInfo("type_specifier","INT");
	$$->make_copy($1);
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	currType = "INT";
	single_string("type_specifier  : INT");
	// $$->AddChildParse($1);
}
// | FLOAT {
// 	$$= new SymbolInfo("type_specifier","FLOAT");
// 	$$->make_copy($1); 
// 	$$->set_start_line($1->get_start_line());
// 	$$->set_end_line($1->get_end_line());
// 	currType = "FLOAT";
// 	single_string("type_specifier  : FLOAT");
// 	// $$->AddChildParse($1);
// }
| VOID{
	$$= new SymbolInfo("type_specifier","VOID");
	$$->make_copy($1); 
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	currType="VOID";
	single_string("type_specifier  : VOID");
	// $$->AddChildParse($1);
}
// | DOUBLE{
// 	$$= new SymbolInfo("type_specifier","DOUBLE");
// 	$$->make_copy($1); 
// 	$$->set_start_line($1->get_start_line());
// 	$$->set_end_line($1->get_end_line());
// 	currType = "DOUBLE";
// 	single_string( "type_specifier  :DOUBLE");
// 	// $$->AddChildParse($1);
// }
;
 		
declaration_list :declaration_list COMMA ID {
	   if(DEBUG)
 		 table.PrintAllScopeTable();
		$3->set_var_type(currType);
		if(table.Insert($3)==false){
			ConflictingType_err($3->getName());
			
		}
	$$ = new SymbolInfo("declaration_list","declaration_list COMMA ID");
	single_string("declaration_list : declaration_list COMMA ID");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	for(ll i=0;i<$1->getChildrenList().size();i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChild($2);	
	$$->AddChild($3);
	$3->set_var_type(currType) ;
	if (isGlobalSpace==true){
			asm_file << "\t\t" << $3->getName() << " DW 1 DUP <0000H> "<<endl;  
			$3->setOffset(0);
	} 
	else 
	{
		ll  currOffset = getCurrentOffset() ; 
		$3->setOffset(current_offset) ; 
		asm_file<<"\t\t"<<"SUB SP,2"<<endl;
	}
}
| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
		$3->set_Array(true);
		$3->set_var_type(currType);
		if(table.Insert($3)==false){
			ConflictingType_err($3->getName());
			
		}
	$$ = new SymbolInfo("declaration_list","declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
    $$->set_start_line($1->get_start_line());
	$$->set_end_line($6->get_end_line());
	single_string("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
	for(ll i=0;i<$1->getChildrenList().size();i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChild($2);	// adding COMMA as well
	$$->AddChild($3);
	$$->AddChild($4);
	$$->AddChild($5);
	$$->AddChild($6);
	
	if (isGlobalSpace==true){
			asm_file << "\t" << $3->getName() << " DW " << $5->getName() << " DUP <0000H>"<<endl ; 
		
	} 
	$3->set_var_type(currType) ; 
	if(isGlobalSpace){
		// setting global variable
		$3->setOffset(0) ; 
	} else {
		$3->setOffset(getCurrentOffset()) ; 		
		int arrSize = stoi($3->getName()) ; 
		asm_file<<"\t\tSUB SP,"<<(arrSize*$1->getOffset())<<endl; 
		setCurrentOffset(current_offset + arrSize*2) ; 
	}
}
| ID {
	$1->set_var_type(currType);
		if(table.Insert($1)==false){
		    ConflictingType_err($1->getName());
			
		}
	$$ = new SymbolInfo("declaration_list","ID");
	single_string( "declaration_list : ID");
    $$->AddChild($1);
	if (isGlobalSpace==true){
			asm_file << "\t\t" << $1->getName() << " DW 1 DUP <0000H> "<<endl;  
			$1->setOffset(0);
	} 
	else 
	{
		ll  currOffset = getCurrentOffset() ; 
		$1->setOffset(current_offset) ; 
		asm_file<<"\t\t"<<"SUB SP,2"<<endl;
	}
}
| ID LTHIRD CONST_INT RTHIRD {
	$1->set_Array(true);
		if(table.Insert($1)==false){
			ConflictingType_err($1->getName());
			
		}
	$$ = new SymbolInfo("declaration_list","ID LTHIRD CONST_INT RTHIRD");
	single_string("declaration_list : ID LTHIRD CONST_INT RTHIRD");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($4->get_end_line());
	$$->AddChild($1);
	$$->AddChild($2);
	$$->AddChild($3);
	$$->AddChild($4);
	
	if (isGlobalSpace==true){
	     asm_file << "\t\t" << $1->getName() << " DW " << $3->getName() << " DUP (0000H)\t ;  line no " << line_count << " " << $1->getName() << " array declared"<<endl  ;
	}
	$1->set_var_type(currType) ; 
	if(isGlobalSpace){
		// setting global variable
		$1->setOffset(0) ; 
	} else {
		$1->setOffset(getCurrentOffset()) ; 
		int arrSize = stoi($3->getName()) ; 
		asm_file<<"\t\tSUB SP,"<<(arrSize*$1->getOffset())<<endl;
		setCurrentOffset(arrSize*2) ; 
 
	}
	$1->set_Array(true) ;
}
;
 		  
statements : 
statement {
	$$ = new SymbolInfo("statements","statement");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("statements : statement");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
}
| statements statement {
	$$ = new SymbolInfo("statements","statements statement");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string( "statements : statements statement" );
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	for(ll i = 0; i < $2->getChildrenList().size(); i++){

		$$->AddChild($2->getChildrenList().at(i));
		
	}
$$->AddChildParse($1);
	$$->AddChildParse($2);
}
; 


notunIf : IF LPAREN expression RPAREN {
	
	ifLab1.push(newLabel()) ; 
    asm_file<< "\t\tPOP AX"<<endl;
	asm_file<<"\t\tCMP AX , 0 "<<endl;	
	asm_file<< "\t\tJE " << ifLab1.top()<< endl; 
	$$ = new SymbolInfo ("notunIf"," IF LPAREN expression RPAREN");
	single_string("statement : IF LPAREN expression RPAREN statement");
	$$->AddChild($1) ; 
	$$->AddChild($2) ; 
	for(ll i = 0 ;  i < $3->getChildrenList().size() ; i++){ 
		$$->AddChild($3->getChildrenList().at(i)) ; 
	}
	$$->AddChild($4) ; 
}

statement : 
var_declaration {
	$$ = new SymbolInfo("statement","var_declaration");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("statement : var_declaration");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
}
| expression_statement {
	$$ = new SymbolInfo("statement","expression_statement");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("statement : expression_statement");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
}
| { 
	// table.EnterScope();
	}
	compound_statement {
	// table.PrintAllScopeTable();
} {
	single_string("statement : compound_statement");
	$$ = new SymbolInfo("statement","compound_statement");
	// $$->set_start_line($1->get_start_line());
	// $$->set_end_line($1->get_end_line());
	for(ll i = 0; i < $2->getChildrenList().size(); i++){
		$$->AddChild($2->getChildrenList().at(i));
	}
	$$->AddChildParse($2);
}

| notunIf statement %prec LOWER_THAN_ELSE {
	
	asm_file <<ifLab1.top() << ":"<<endl ; 
	ifLab1.pop() ; 
	$$ = new SymbolInfo ("statement"," IF LPAREN expression RPAREN statement LOWER_THAN_ELSE");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	for(ll i = 0; i < $2->getChildrenList().size(); i++){
		$$->AddChild($2->getChildrenList().at(i));
	}
}

| notunIf statement ELSE{
	ifLab2.push(newLabel()) ; 
	asm_file << "\t\tJMP " << ifLab2.top() << endl ; 
	asm_file << ifLab1.top() << ":" << endl;
	ifLab1.pop() ; 

} statement {
 
    asm_file << ifLab2.top() << ":" << endl;   
	ifLab2.pop() ;


	$$ = new SymbolInfo("statement","IF LPAREN expression RPAREN statement ELSE statement");
	single_string("statement : IF LPAREN expression RPAREN statement ELSE statement");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	for(ll i = 0; i < $2->getChildrenList().size(); i++){
		$$->AddChild($2->getChildrenList().at(i));
	}
	$$->AddChild($3);
	for(ll i = 0; i < $5->getChildrenList().size(); i++){
		$$->AddChild($5->getChildrenList().at(i));
	}
		
	
}
| WHILE LPAREN{
	whileLabel1 = newLabel() ; 
	asm_file <<  whileLabel1 << ":"<<endl; ; 
} expression RPAREN{ 
	whileLabel2 = newLabel() ; 
	asm_file << "\t\tPOP AX"<<endl ; 
	asm_file << "\t\tCMP AX , 0\n" ; 
	string whileLabel3=newLabel();
	asm_file << "\t\tJNE " << whileLabel3 << endl ;
	asm_file << "\t\tJMP " << whileLabel2 << endl ;
	asm_file<<whileLabel3<<":"<<endl; 
} statement {
	asm_file << "\t\tJMP " << whileLabel1 << endl ;
	asm_file << whileLabel2 << ":"<<endl; 

	$$ = new SymbolInfo("statement","WHILE LPAREN expression RPAREN statement");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($5->get_end_line());
	single_string("statement : WHILE LPAREN expression RPAREN statement");
	$$->AddChild($1);
	$$->AddChild($2);
    for(ll i=0;i<$4->getChildrenList().size();i++)
		$$->AddChild($4->getChildrenList().at(i));
	$$->AddChild($5);
	for(ll i = 0; i < $7->getChildrenList().size(); i++){
		$$->AddChild($7->getChildrenList().at(i));
	}
	
}
| PRINTLN LPAREN ID RPAREN SEMICOLON {
	
	currSymbol = table.getSymbolInfo($3->getName()) ; 
    if(currSymbol->getOffset() == 0){
		// it's a global variable
		// asm_file<<"L"<<labelCount<<":"<<endl;
		// labelCount++;
		asm_file<<"\t\t"<<"MOV AX,"<<currSymbol->getName()<<endl;
	} else {
		if(currSymbol->getisLocal()==false)
		asm_file << "\t\tMOV AX , [BP - " << currSymbol->getOffset() << "]"<<endl ; 
		else
		asm_file << "\t\tMOV AX , [BP + " << currSymbol->getOffset() << "]"<<endl ; 
	}
	asm_file<<"\t\tCALL print_output"<<endl<<"\t\tCALL new_line"<<endl;

	$$ = new SymbolInfo("statement","PRINTLN LPAREN ID RPAREN SEMICOLON");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($5->get_end_line());
	single_string("statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
	if (table.LookUpAll($3->getName())==false) {
		Undeclared_variable($3->getName());
	}
	$$->AddChild($1);
	$$->AddChild($2);
	$$->AddChild($3);
	$$->AddChild($4);
	$$->AddChild($5);
}
| RETURN expression SEMICOLON {
    asm_file << "\t\tPOP AX\t ;  line no " << line_count << " :  return value saved in DX"<<endl ; 
	asm_file <<	"\t\tMOV DX , AX"<<endl ; 
	asm_file <<	"\t\tJMP " << currFuncLabel <<endl ; 

	$$ = new SymbolInfo("statement","RETURN expression SEMICOLON");
	$$->AddChild($1);
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	single_string("statement : RETURN expression SEMICOLON");
	for(ll i = 0; i < $2->getChildrenList().size(); i++){
		$$->AddChild($2->getChildrenList().at(i));
	}
	$$->AddChild($3);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
}
;



expression_statement : 
SEMICOLON {
	$$ = new SymbolInfo("expression_statement","SEMICOLON");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("expression_statement : SEMICOLON");
	if(check==false){
		$$->AddChild($1);
	}
	$$->AddChildParse($1);
	
}	
| expression SEMICOLON {
	if(!noPop)
		asm_file << "\t\tPOP AX"<<endl; ; 

	$$ = new SymbolInfo("expression_statement","expression SEMICOLON");;
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("expression_statement : expression SEMICOLON");
	if(check==false){
		for(ll i = 0; i < $1->getChildrenList().size(); i++){
			$$->AddChild($1->getChildrenList().at(i));
		}
		$$->AddChild($2);
	}
	$$->AddChildParse($1);
	$$->AddChildParse($2);

}

;
variable : 
ID {

    currSymbol = table.getSymbolInfo($1->getName()) ; 
	$$ = new SymbolInfo("variable","ID");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	output_file << "variable : ID" <<endl;
	if(DEBUG==true)
		table.PrintAllScopeTable();
	if(!table.LookUp($1->getName())) {
		Undeclared_variable($1->getName());
	} 
	$$->AddChild($1);
	$$->AddChildParse($1);
}
| ID LTHIRD expression RTHIRD {

  currSymbol = table.getSymbolInfo($1->getName()) ; 
  currSymbol->set_Array(true);
	if (currSymbol->getOffset() == 0){
		asm_file << "\t\tPOP AX"<<endl; ; 
		asm_file << "\t\tSHL AX , 1"<<endl ; 
		asm_file << "\t\tMOV BX, " << currSymbol->getName()<<endl ;
		asm_file<<"\t\tSUB BX,AX"<<endl;
		asm_file<<"\t\tPUSH BX"<<endl;  
	} else {
		asm_file << "\t\tPOP AX"<<endl ; 
		asm_file << "\t\tSHL AX , 1"<<endl ;  
		asm_file<<"\t\tLEA BX, W.[BP-"<<currSymbol->getOffset()<<"]"<<endl;
		asm_file<<"\t\tSUB BX,AX"<<endl;
		asm_file<<"\t\tPUSH BX"<<endl;

	}

	$$ = new SymbolInfo("variable","ID LTHIRD expression RTHIRD");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($4->get_end_line());
	single_string("variable : ID LTHIRD expression RTHIRD");
	
	if(!(currSymbol != NULL)) {
		Undeclared_variable($1->getName());
	} else {
		if (currSymbol->get_Function_check()==true){
			ConflictingType_err($1->getName());
		}
		if (currSymbol->get_Array()==false){
			Not_array_error($1->getName());
		}
	}
	if(!($3->getChildrenList().at(0)->getType() == "CONST_INT")){
		Array_Subscript_error();
	}
	$$->AddChild($1);
	$$->AddChild($2);
	$$->AddChild($3->getChildrenList().at(0));
	$$->AddChild($4);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
	$$->AddChildParse($4);
}
;
expression : 
logic_expression {
	$$ = new SymbolInfo("expression","logic_expression");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	if (check==false)
		output_file << "expression : logic_expression" <<endl;
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		if (check==false){
			$$->AddChild($1->getChildrenList().at(i));
		}
	}
	$$->AddChildParse($1);

	

}
| variable ASSIGNOP logic_expression {

currSymbol = table.getSymbolInfo($1->getChildrenList().at(0)->getName()) ; 

	if(currSymbol->get_Array()) {
			asm_file << "\t\tPOP AX"<<endl;   
			asm_file << "\t\tPOP BX"<<endl; 
			// asm_file<<"\t\tPOP AX"<<endl;
			
			asm_file << "\t\tMOV [BX] , AX"<<endl;   
			
			// asm_file << "\t\tMOV AX , BX"<<endl ; 
			asm_file << "\t\tPUSH AX"<<endl ; 
	} else {
		asm_file<<"\t\tPOP AX"<<endl;
			if(currSymbol->getOffset() == 0){
				// it's a global variable
				asm_file << "\t\tMOV "<< currSymbol->getName() <<  ",AX "<<endl;
			} else {
				if(currSymbol->getisLocal()==false)
				asm_file << "\t\tMOV [BP - " << currSymbol->getOffset() << "] , AX"<<endl; 
				else
				asm_file << "\t\tMOV [BP + " << currSymbol->getOffset() << "] , AX"<<endl; 
			}
			asm_file << "\t\tPUSH AX"<<endl ; 
	}

	$$ = new SymbolInfo("expression","variable ASSIGNOP logic_expression");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	if (check==false)
		single_string("expression : variable ASSIGNOP logic_expression");
	for(ll i = 0; i < $3->getChildrenList().size(); i++) {   
		if(table.LookUpAll($3->getChildrenList().at(i)->getName()) && $3->getChildrenList().at(i)->getType() == "ID"){
			currSymbol = table.getSymbolInfo($3->getChildrenList().at(i)->getName());
			if(currSymbol->get_Function_check() && currSymbol->get_ret_type() == "VOID"){
				Void_expression_error();
			}
		}
	}
	if(table.LookUpAll($1->getChildrenList().at(0)->getName())==true) {
		SymbolInfo *currSymbol = table.getSymbolInfo($1->getChildrenList().at(0)->getName());
		if(!(currSymbol->get_var_type() != "INT")){
			for(ll i = 0; i < $3->getChildrenList().size(); i++){
				if($3->getChildrenList().at(i)->getName()=="%")
				 break;
				if($3->getChildrenList().at(i)->getType() == "CONST_FLOAT" || $3->getChildrenList().at(i)->get_var_type() == "FLOAT"){
				      Possible_data_loss();
				}
			}
		}
	}
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		if (check==false){
			$$->AddChild($1->getChildrenList().at(i));
		}
	}
	if (check==false){
		$$->AddChild($2);
	}
	for(ll i = 0; i < $3->getChildrenList().size(); i++){
		if (check==false){
			$$->AddChild($3->getChildrenList().at(i));
		}
	}
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
}
;
logic_expression : 
rel_expression {
	check = false;
	$$ = new SymbolInfo("logic_expression","rel_expression");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("logic_expression : rel_expression");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
}
| rel_expression LOGICOP rel_expression {
	check = false;
	$$ = new SymbolInfo("logic_expression","rel_expression LOGICOP rel_expression");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	single_string("logic_expression : rel_expression LOGICOP rel_expression");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChild($2);
	for(ll i = 0; i < $3->getChildrenList().size(); i++){
		$$->AddChild($3->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);

	string Label1 = newLabel() ; 
	string Label2 = newLabel() ; 
	if ($2->getName() == "&&") {
			asm_file << "\t\tPOP AX"<<endl ; 
			asm_file << "\t\tCMP AX , 0"<<endl ; 
			asm_file << "\t\tJE " << Label1 << endl ; 
			asm_file << "\t\tPOP AX"<<endl ; 
			asm_file << "\t\tCMP AX , 0"<<endl ; 
			asm_file << "\t\tJE " << Label1 << endl;  ; 
			asm_file << "\t\tPUSH 1"<<endl; ; 
			asm_file << "\t\tJMP " << Label2 <<endl ; 
			asm_file << Label1 << ":"<<endl ; 
			asm_file << "\t\tPUSH 0"<<endl ; 
			asm_file << Label2 <<":"<< endl ; 
		

	}


	if ($2->getName() == "||") {
		asm_file<< "\t\tPOP AX"<<endl;
		asm_file<< "\t\tMOV DX,AX"<<endl;
		asm_file<<"\t\tPOP AX"<<endl;
		asm_file<<"\t\tOR DX , AX"<<endl;
		asm_file<<"\t\tPUSH AX"<<endl ;  
		
	}
}
;
			
rel_expression : 
simple_expression {
	$$ = new SymbolInfo("rel_expression","simple_expression");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("rel_expression : simple_expression");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
}
| simple_expression RELOP simple_expression	{
	$$ = new SymbolInfo("rel_expression","simple_expression RELOP simple_expression");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	single_string("rel_expression : simple_expression RELOP simple_expression");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChild($2);
	for(ll i = 0; i < $3->getChildrenList().size(); i++){
		$$->AddChild($3->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);

	string str ; 
	if($2->getName() == "<="){
		str = "JGE" ; 
	} else if($2->getName() == ">="){
		str = "JLE" ; 
	} else if($2->getName() == "=="){
		str = "JE" ; 
	} else if($2->getName() == "!="){
		str = "JNE" ; 
	} else if($2->getName() == "<"){
		str = "JG" ; 
	} else if($2->getName() == ">"){
		str = "JL" ; 
	}
		asm_file << "\t\tPOP AX"<<endl; ;
		asm_file<<"\t\tMOV DX,AX"<<endl; 
		asm_file << "\t\tPOP AX"<<endl; ; 
		asm_file << "\t\tCMP DX , AX"<<endl; ; 
		string L1=newLabel();
		string L2=newLabel();
		asm_file<<"\t\t"<<str<<" "<<L1<<endl;
		asm_file << "\t\tPUSH 0"<<endl<<"\t\tJMP "<<L2<< endl; ; 
		asm_file <<L1<<":"<<endl<<"\t\tPUSH 1"<<endl; 
		asm_file<<L2<<":"<<endl; 
		// asm_file << "\t\tPUSH AX"<<endl<<endl ;
		 
		
	

}
;
				
simple_expression : 
term {
	$$ = new SymbolInfo("simple_expression","term");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("simple_expression : term");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
	// ll p= $1->getChildrenList().size();
	// output_file<<$1->getChildrenList().size();
	
	
}
| simple_expression ADDOP term {
	$$ = new SymbolInfo("simple_expression","simple_expression ADDOP term");;
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	single_string("simple_expression : simple_expression ADDOP term");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChild($2);
	for(ll i = 0; i < $3->getChildrenList().size(); i++){
		$$->AddChild($3->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
    // asm_file<<"\t\tMOV AX,"<<$3->getChildrenList().at(0)->getName()<<endl;
	// asm_file<<"\t\tMOV AX,"<<$1->getChildrenList().at(0)->getName()<<endl;
	asm_file<<"\t\tPOP AX"<<endl;
	asm_file<<"\t\tMOV DX,AX"<<endl;
	asm_file<<"\t\tPOP AX"<<endl;
	bool isAdd = false ; 
	if ($2->getName() == "+")isAdd = true ; 
	else isAdd = false ; 
	if(isAdd){
		asm_file << "\t\tADD AX , DX"<<endl ; 
			
	} else {
		asm_file << "\t\tSUB AX , DX"<<endl ;  
			
	}
	asm_file<<"\t\tPUSH AX"<<endl;

}
;		
term :	
unary_expression {
	$$ = new SymbolInfo("term","unary_expression");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("term : unary_expression");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
	// asm_file<<"\t\tMOV DX,AX"<<endl;
}
|  term MULOP unary_expression {
	$$ = new SymbolInfo("term","term MULOP unary_expression");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	single_string("term : term MULOP unary_expression");
	if($2->getName() == "%") {
		//$1->getChildrenList().at(0)->setType("CONST_INT");
		$3->getChildrenList().at(0)->setType("CONST_INT");
	}
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChild($2);
	for(ll i = 0; i < $3->getChildrenList().size(); i++){
		$$->AddChild($3->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);

		if($2->getName() == "*"){
			asm_file<<"\t\tPOP AX"<<endl;
			asm_file<<"\t\tMOV CX,AX"<<endl;
			asm_file<<"\t\tPOP AX"<<endl;
			asm_file<<"\t\tCWD\n\t\tMUL CX"<<endl;
			asm_file<<"\t\tPUSH AX"<<endl;
		} else if($2->getName() == "%"){
			asm_file << "\t\tPOP AX"<<endl ; 
			asm_file << "\t\tMOV CX , AX"<<endl; 
			asm_file << "\t\tXOR DX , DX"<<endl ; 
			asm_file << "\t\tPOP AX"<<endl ; 
			asm_file << "\t\tIDIV CX"<<endl ; 
			asm_file << "\t\tMOV AX , DX"<<endl ; 
			asm_file << "\t\tPUSH AX"<<endl<<endl ; 
			
		} else if($2->getName() == "/"){
			asm_file << "\t\tPOP AX"<<endl ; 
			asm_file << "\t\tMOV CX , AX"<<endl;  
			asm_file << "\t\tXOR DX , DX"<<endl ; 
			asm_file << "\t\tPOP AX"<<endl ; 
			asm_file << "\t\tIDIV CX"<<endl ; 
			// asm_file << "\t\tMOV BX , AX"<<endl ; 
			asm_file << "\t\tPUSH AX"<<endl<<endl ; 
		
		}

}
;
unary_expression : 
ADDOP unary_expression {
	$$ = new SymbolInfo("unary_expression","ADDOP unary_expression");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($2->get_end_line());
	single_string("unary_expression : ADDOP unary_expression");
	$$->AddChild($1);
	for(int i = 0; i < $2->getChildrenList().size(); i++){
		$$->AddChild($2->getChildrenList().at(i));
	}
	if($1->getName()=="-")
	{
		if(currSymbol->getisLocal()==false)
		asm_file<<"\t\tPUSH [BP-"<<currSymbol->getOffset()<<"]"<<endl;
		else
		asm_file<<"\t\tPUSH [BP+"<<currSymbol->getOffset()<<"]"<<endl;
			asm_file << "\t\tPOP AX"<<endl; 
			asm_file <<"\t\tMOV DX,0"<<endl;
			asm_file<<"\t\tSUB DX,AX"<<endl;
			asm_file<<"\t\tMOV AX,DX"<<endl;
			 asm_file << "\t\tPUSH AX"<<endl ;  
	}
	else
	{
		if(currSymbol->getisLocal()==false)
		asm_file<<"\t\tPUSH [BP-"<<currSymbol->getOffset()<<"]"<<endl;
		else
		asm_file<<"\t\tPUSH [BP+"<<currSymbol->getOffset()<<"]"<<endl;
		asm_file << "\t\tPOP AX"<<endl; 
		 asm_file << "\t\tPUSH AX"<<endl ;  
	}



}
| NOT unary_expression {
	$$ = new SymbolInfo("unary_expression","NOT unary_expression");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($2->get_end_line());
	single_string("unary_expression : NOT unary_expression");
	$$->AddChild($1);
	for(ll i = 0; i < $2->getChildrenList().size(); i++){
		$$->AddChild($2->getChildrenList().at(i));
	}
	notLabel = newLabel() ; 
	asm_file << "\t\tPOP AX"<<endl ; 
	asm_file << "\t\tCMP AX , 0"<<endl ; 
	asm_file << "\t\tMOV AX , 0"<<endl ; 
	asm_file << "\t\tJNE " << notLabel << endl ; 
	asm_file << "\t\tINC AX"<<endl; 
	asm_file << notLabel << ":"<<endl ; 
	asm_file << "\t\tPUSH AX"<<endl<<endl ; 

	
}
| factor {
	$$ = new SymbolInfo("unary_expression","factor");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("unary_expression : factor");
	for(int i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
}
;
	
factor : 
variable {
	$$ = new SymbolInfo("factor","variable");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("factor : variable");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChildParse($1);
	if(!isArgumentPassing)
	{
		if(currSymbol->get_Array()!=true){
			if(currSymbol->getOffset()==0)
		   {
			asm_file<<"\t\tPUSH "<<currSymbol->getName()<<endl;
			
		    }
		else
		   {
			
			if(currSymbol->getisLocal()==false)
			asm_file<<"\t\tPUSH [BP-"<<currSymbol->getOffset()<<"]"<<endl;
			else
			asm_file<<"\t\tPUSH [BP+"<<currSymbol->getOffset()<<"]"<<endl;
		   }
	    }
		else
		{
			// asm_file<<"\t\tPUSH BX"<<endl;
			asm_file<<"\t\tPOP BX"<<endl;
			asm_file<<"\t\tPUSH [BX]"<<endl;
			// if(currSymbol->getisLocal()==false)
			// asm_file<<"\t\tPUSH [BP-"<<currSymbol->getOffset()<<"]"<<endl;
			// else
			// asm_file<<"\t\tPUSH [BP+"<<currSymbol->getOffset()<<"]"<<endl;
		}

		
	}
	
}
| ID LPAREN argument_list RPAREN {
		asm_file << "\n\t\tCALL " << $1->getName() << "\t ;  line no " << line_count << ": function " << $1->getName() << " called"<<endl ; 
		asm_file << "\t\tMOV AX , DX\t ;  line no " << line_count << ": return result in DX"<<endl ; 
		asm_file << "\t\tPUSH AX"<<endl<<endl ;   
	


	$$ = new SymbolInfo("factor","ID LPAREN argument_list RPAREN");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($4->get_end_line());
	single_string( "factor : ID LPAREN argument_list RPAREN" );
	if (DEBUG==true){
		table.PrintAllScopeTable();
	}
	if(table.LookUpAll($1->getName())==false) {
		Undeclared_function($1->getName());
	} else {
		currSymbol = table.getSymbolInfo($1->getName());
		if (currSymbol->get_Function_check()==false) {
			Undeclared_function(currSymbol->getName());
		}
		vector <SymbolInfo*> paramList = currSymbol->get_param_list();
		vector <string> defined_Function_Paramiter_Type;
		for (ll i = 0; i<paramList.size(); i++){
			if (paramList.at(i)->getType() == "INT" || paramList.at(i)->getType() == "FLOAT"||paramList.at(i)->getType()=="VOID"||paramList.at(i)->getType()=="DOUBLE") {
				defined_Function_Paramiter_Type.pb(paramList.at(i)->getType());
			}
		}
		vector <string> argument_Type;
		for (ll i = 0; i<$3->getChildrenList().size(); i++){
			bool isFloat = false;
			while($3->getChildrenList().at(i)->getName() != ","){
				if ($3->getChildrenList().at(i)->getType() == "ID") {
					if ($3->getChildrenList().at(i)->get_var_type() == "FLOAT")
						isFloat = true;
				}
				else {
					if ($3->getChildrenList().at(i)->getType() == "CONST_FLOAT")
						isFloat = true;
				}
				i++;
				if (i >= $3->getChildrenList().size())
					break;
			}
			if (isFloat)
				argument_Type.pb("FLOAT");
			else 
				argument_Type.pb("INT");
				
		}
		if (argument_Type.size() > (defined_Function_Paramiter_Type.size())) {
			Too_many_argument_error($1->getName());
		}
		else if(argument_Type.size() < (defined_Function_Paramiter_Type.size()))
		{
			Too_few_argument_error($1->getName());
		} 
		else {
			for (ll i = 0; i<argument_Type.size(); i++){
				if (argument_Type[i] != defined_Function_Paramiter_Type[i]) {
					Type_mismatch_argument_error($1->getName(),i+1);
				}
			}
		}
	}
	$$->AddChild($1);
	$$->AddChild($2);
	for(ll i = 0; i < $3->getChildrenList().size(); i++){
		$$->AddChild($3->getChildrenList().at(i));
	}
	$$->AddChild($4);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
	$$->AddChildParse($4);
}
| ID LPAREN RPAREN{

	asm_file << "\t\tCALL " << $1->getName() <<endl ; 
	asm_file << "\t\tMOV AX , DX"<<endl; ; 
	asm_file << "\t\tPUSH AX"<<endl ; 

	$$ = new SymbolInfo("factor","ID LPAREN RPAREN");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	single_string( "factor : ID LPAREN RPAREN" );
	if (DEBUG==true){
		table.PrintAllScopeTable();
	}
	if(table.LookUpAll($1->getName())==false) {
		Undeclared_function($1->getName());
	} else {
		currSymbol = table.getSymbolInfo($1->getName());
		if (currSymbol->get_Function_check()==false) {
			Undeclared_function(currSymbol->getName());
		}
	}
	$$->AddChild($1);
	$$->AddChild($2);
	$$->AddChild($3);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
}
| LPAREN expression RPAREN {
	$$ = new SymbolInfo("factor","LPAREN expression RPAREN");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	single_string("factor : LPAREN expression RPAREN");
	$$->AddChild($1);
	for(ll i = 0; i < $2->getChildrenList().size(); i++){
		$$->AddChild($2->getChildrenList().at(i));
	}
	$$->AddChild($3);
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($3);
}
| CONST_INT {
	$$ = new SymbolInfo("factor","CONST_INT");
    $$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	output_file << "factor : CONST_INT" <<endl;
	$$->AddChild($1);
	if(!isArgumentPassing){
			// asm_file<<"L"<<labelCount<<":"<<endl;
			// labelCount++;
			asm_file << "\t\tPUSH " << $1->getName() << endl ; 
	}

	
}
| variable INCOP {
	$$ = new SymbolInfo("factor","variable INCOP");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($2->get_end_line());
	output_file << "factor : variable INCOP" <<endl;
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChild($2);
	if(currSymbol->get_Array()){
		    asm_file<<"\t\tPOP BX"<<endl;
			asm_file<<"\t\tPUSH [BX]"<<endl;
			asm_file<<"\t\tINC [BX]"<<endl;
	}
	else
	{
		if(currSymbol->getisLocal()==false)
			asm_file<<"\t\tPUSH [BP-"<<currSymbol->getOffset()<<"]"<<endl;
			else
			asm_file<<"\t\tPUSH [BP+"<<currSymbol->getOffset()<<"]"<<endl;
			asm_file << "\t\tPOP AX"<<endl; 
			 asm_file << "\t\tPUSH AX"<<endl ; 
			asm_file << "\t\tINC AX"<<endl ; 
			if(currSymbol->getisLocal()==false)
			{
				asm_file << "\t\tMOV [BP-"<< currSymbol->getOffset()<<"],AX"<<endl;
		        // asm_file<<"\t\tPUSH [BP-"<< currSymbol->getOffset()<<"]"<<endl;
			}
			else
			{
				asm_file << "\t\tMOV [BP+"<< currSymbol->getOffset()<<"],AX"<<endl;
		        // asm_file<<"\t\tPUSH [BP+"<< currSymbol->getOffset()<<"]"<<endl;
			}
	}
		
			
			 
		
	
}
| variable DECOP {
	$$ = new SymbolInfo("factor","variable DECOP");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($2->get_end_line());
	output_file << "factor : variable DECOP" <<endl;
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChild($2);
	if(currSymbol->get_Array())
	{
		 asm_file<<"\t\tPOP BX"<<endl;
			asm_file<<"\t\tPUSH [BX]"<<endl;
			asm_file<<"\t\tDEC [BX]"<<endl;
	}
	else
	{
		    if(currSymbol->getisLocal()==false)
			asm_file<<"\t\tPUSH [BP-"<<currSymbol->getOffset()<<"]"<<endl;
			else
			asm_file<<"\t\tPUSH [BP+"<<currSymbol->getOffset()<<"]"<<endl;
			asm_file << "\t\tPOP AX"<<endl; 
			 asm_file << "\t\tPUSH AX"<<endl ; 
			asm_file << "\t\tDEC AX"<<endl ; 
			if(currSymbol->getisLocal()==false)
			{
				asm_file << "\t\tMOV [BP-"<< currSymbol->getOffset()<<"],AX"<<endl;
		        // asm_file<<"\t\tPUSH [BP-"<< currSymbol->getOffset()<<"]"<<endl;
			}
			else
			{
				asm_file << "\t\tMOV [BP+"<< currSymbol->getOffset()<<"],AX"<<endl;
		        // asm_file<<"\t\tPUSH [BP+"<< currSymbol->getOffset()<<"]"<<endl;
			}
	}
			

		
			
			


		
	
}
;
argument_list : 
arguments {
	$$ = new SymbolInfo("argument_list","argument");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	output_file << "argument_list : arguments" <<endl;
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	
	$$->AddChildParse($1);
}
;
	
arguments : 
arguments COMMA logic_expression {
	$$ = new SymbolInfo("arguments","arguments COMMA logic_expression");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($3->get_end_line());
	single_string("arguments : arguments COMMA logic_expression");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	$$->AddChild($2);
	for(ll i = 0; i < $3->getChildrenList().size(); i++){
		$$->AddChild($3->getChildrenList().at(i));
	}
	
	$$->AddChildParse($1);
	$$->AddChildParse($2);
	$$->AddChildParse($1);
}
| logic_expression {
	$$ = new SymbolInfo("arguments","logic_expression");
	$$->set_start_line($1->get_start_line());
	$$->set_end_line($1->get_end_line());
	single_string("arguments : logic_expression");
	for(ll i = 0; i < $1->getChildrenList().size(); i++){
		$$->AddChild($1->getChildrenList().at(i));
	}
	
	$$->AddChildParse($1);
}
;
%%
int main(int argc,char *argv[]) {
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	yyin=fin;
	error_file.open("1905071_error.txt");
	output_file.open("1905071_log.txt");
	asm_file.open("1905071_asm.txt");
	temp_file.open("1905071_temp.txt");
	opt_file.open("1905071_optimized_code.txt");
	parse_tree_file.open("1905071_parse_tree.txt");
	vector <SymbolInfo*> tempList;
	Init();
	yyparse();
	Ending();
	output_file << "Total Lines: " << line_count<< endl<<"Total errors: " << error_count <<endl;
	output_file.close();
	error_file.close();
	asm_file.close();
	temp_file.close();
	parse_tree_file.close();
	optimizeCode();
	opt_file.close();
	fclose(yyin);
	return 0;
}
