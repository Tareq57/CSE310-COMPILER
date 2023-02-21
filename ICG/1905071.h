// BISMILLAH
// RABBI JIDNI ILMA
#include <bits/stdc++.h>
#include <fstream>
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
#define pdi pair<double, pll>
#define inf 1e10
#define minf -1e15
#define pi 3.14159265
#define mod 1000000007
extern ofstream output_file;
extern ll Idd;
// symbol info class
class SymbolInfo
{
public:
    string name, type;
    SymbolInfo *next;
    ll hash_idx, hash_pos;
    string retType;
    string type_specifier;
    string varType;
    vector<SymbolInfo *> paramiterList;
    vector<SymbolInfo *> childList;
    vector<SymbolInfo *> childParse;
    ll start_line, end_line;
    bool isFunction;
    bool isDef;
    bool isArray;
    bool isTerminal = false;
    bool isLocal = false;
    ll offset;

    // constructor
    SymbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        next = NULL;
    }
    SymbolInfo()
    {
        next = NULL;
    }
    // getter and setter function
    string getName()
    {
        return name;
    }
    void setisLocal(bool gg)
    {
        isLocal = gg;
    }
    bool getisLocal()
    {
        return isLocal;
    }
    void set_isTerminal(bool terminal)
    {
        isTerminal = terminal;
    }
    void setOffset(ll offset)
    {
        this->offset = offset;
    }
    ll getOffset()
    {
        return offset;
    }
    bool get_isTerminal()
    {
        return isTerminal;
    }
    void AddChildParse(SymbolInfo *sym)
    {
        childParse.pb(sym);
    }
    vector<SymbolInfo *> getChildrenParseList()
    {
        return childParse;
    }
    void set_start_line(ll p)
    {
        start_line = p;
    }
    ll get_start_line()
    {
        return start_line;
    }
    void set_end_line(ll p)
    {
        end_line = p;
    }
    ll get_end_line()
    {
        return end_line;
    }
    string getTypeSpecifier()
    {
        return type_specifier;
    }
    void setTypeSpecifier(string str)
    {
        type_specifier = str;
    }
    string getType()
    {
        return type;
    }
    SymbolInfo *getNext()
    {
        return next;
    }
    void AddChild(SymbolInfo *sym)
    {
        childList.pb(sym);
    }
    vector<SymbolInfo *> getChildrenList()
    {
        return childList;
    }
    void make_copy(SymbolInfo *sym)
    {
        this->name = sym->getName();
        this->type = sym->getType();
        this->hash_idx = sym->hash_idx;
        this->hash_pos = sym->hash_pos;
        this->retType = sym->retType;
        this->type_specifier = sym->type_specifier;
        this->varType = sym->varType;
        this->paramiterList = sym->paramiterList;
        this->childList = sym->childList;
        this->start_line = sym->start_line;
        this->end_line = sym->end_line;
        this->isFunction = sym->isFunction;
        this->isDef = sym->isDef;
        this->isArray = sym->isArray;
    }
    void set_ret_type(string retType)
    {
        this->retType = retType;
    }
    string get_ret_type()
    {
        return retType;
    }
    void set_var_type(string varType)
    {
        this->varType = varType;
    }
    string get_var_type()
    {
        return varType;
    }
    void set_param_list(vector<SymbolInfo *> paramiterList)
    {
        this->paramiterList = paramiterList;
    }
    vector<SymbolInfo *> get_param_list()
    {
        return paramiterList;
    }
    void set_Function_check(bool ok1)
    {
        isFunction = ok1;
    }
    bool get_Function_check()
    {
        return isFunction;
    }
    void set_Def(bool ok1)
    {
        isDef = ok1;
    }
    bool get_Def()
    {
        return isDef;
    }
    void set_Array(bool ok1)
    {
        isArray = ok1;
    }
    bool get_Array()
    {
        return isArray;
    }
    ull getHashIdx()
    {
        return hash_idx;
    }
    ull getHashPos()
    {
        return hash_pos;
    }
    void setName(string name)
    {
        this->name = name;
    }
    void setType(string type)
    {
        this->type = type;
    }
    void setNext(SymbolInfo *next)
    {
        this->next = next;
    }
    void setHashIdx(ll hash_idx)
    {
        this->hash_idx = hash_idx;
    }
    void setHashPos(ll hash_pos)
    {
        this->hash_pos = hash_pos;
    }
    // deconstructor
    ~SymbolInfo()
    {
        // delete next;
        // for(ll i=0;i<paramiterList.size();i++)
        // {
        //     delete paramiterList[i];
        // }
        // for(ll i=0;i<childList.size();i++)
        // {
        //     delete childList[i];
        // }
        // for(ll i=0;i<childParse.size();i++)
        // {
        //     delete childParse[i];
        // }
    }
};
// ScopeTable Class
class ScopeTable
{
private:
    ll id;
    ll hash_size;
    ScopeTable *children;
    SymbolInfo **HashTable;
    ScopeTable *parent_scope;

public:
    // constructor
    ScopeTable(ll size, ScopeTable *parent_scope)
    {
        children = 0;
        this->parent_scope = parent_scope;
        hash_size = size;
        HashTable = new SymbolInfo *[hash_size];
        for (ll i = 0; i < hash_size; i++)
        {
            HashTable[i] = NULL;
        }
        id = Idd;
        Idd++;
        children = NULL;
    }
    // setter and getter
    void set_parent_scope(ScopeTable *parent_scope)
    {
        this->parent_scope = parent_scope;
    }
    ScopeTable *get_parent_scope()
    {
        return parent_scope;
    }
    ll get_id()
    {
        return id;
    }
    void set_id()
    {
        id = Idd + parent_scope->get_id();
    }
    // implementing hash
    ll SDBMhash(string name)
    {
        ll hash = 0;
        ll length = name.length();
        for (ll i = 0; i < length; i++)
        {
            hash = (name[i]) + (hash << 6) + (hash << 16) - hash;
        }
        return hash % hash_size;
    }
    // Inserting symbol into hash table
    void Insert(SymbolInfo *symbol)
    {
        ll idx = SDBMhash(symbol->getName());
        ll curr_pos = 1;
        if (HashTable[idx] == NULL)
        {
            symbol->setHashIdx(idx);
            symbol->setHashPos(curr_pos);
            HashTable[idx] = symbol;
        }
        else
        {
            curr_pos++;
            SymbolInfo *curr = HashTable[idx];
            while (curr->getNext() != NULL)
            {
                curr = curr->getNext();
                curr_pos++;
            }
            // cout<<curr->getName()<<","<<curr->getType()<<endl;
            curr->setNext(symbol);
            curr->setHashIdx(idx);
            curr->setHashPos(curr_pos);
            // cout<<curr->getNext()->getName()<<endl;
        }
        // output_file<< "      Inserted in ScopeTable# " << id << " at position " << idx + 1 << ", " << curr_pos << endl;
    }
    // Searching symbol into hash table
    SymbolInfo *LookUp(string name)
    {
        ll idx = SDBMhash(name);
        SymbolInfo *curr = HashTable[idx];
        ll count = 1;
        while (curr != NULL)
        {
            if (curr->getName() == name)
            {

                curr->setHashIdx(idx);
                curr->setHashPos(count);
                return curr;
            }
            curr = curr->getNext();
            count++;
        }
        return NULL;
    }

    bool Delete(string name)
    {
        ll idx = SDBMhash(name);
        SymbolInfo *curr = HashTable[idx];
        // If there is no symbol after curr
        if (LookUp(name) != NULL)
        {
            if (curr->getNext() == NULL)
            {
                delete curr;
                HashTable[idx] = NULL;
                return true;
            }
            // When there are symbol after curr
            SymbolInfo *parent = HashTable[idx];
            ll count = 0;
            while (curr->getName() != name && curr->getNext() != NULL)
            {
                parent = curr;
                curr = curr->getNext();
                count++;
            }
            if (curr->getName() == name && curr->getNext() != NULL)
            {
                if (count == 0)
                {
                    HashTable[idx] = curr->getNext();
                }
                parent->setNext(curr->getNext());
                curr->setNext(NULL);

                delete curr;
            }
            else
            {
                parent->setNext(NULL);
                curr->setNext(NULL);
                delete curr;
            }

            return true;
        }
        else
        {
            // cout << "      Not found in the current ScopeTable" << endl;
            return false;
        }
    }
    // print all the symbol of current ScopeTable
    void Print()
    {
        for (ll i = 0; i < hash_size; i++)
        {
            SymbolInfo *curr = HashTable[i];
            if (curr == NULL)
                continue;
            output_file << "\t" << i + 1 << "--> ";
            while (curr != NULL)
            {
                output_file << "<" << curr->getName() << ", ";
                if (curr->get_Function_check())
                {
                    output_file << "FUNCTION, " << curr->get_ret_type() << ">";
                    curr = curr->getNext();
                    continue;
                }
                if (curr->get_Array())
                {
                    output_file << "ARRAY,";
                }
                output_file << curr->get_var_type() << ">";
                curr = curr->getNext();
            }
            output_file << endl;
        }
    }
    // Destructor
    ~ScopeTable()
    {
        for (ll i = 0; i < hash_size; i++)
        {
            SymbolInfo *temp = HashTable[i];
            while (temp)
            {
                SymbolInfo *currNext = temp->getNext();
                delete temp;
                temp = currNext;
            }
        }
        delete[] HashTable;
    }
};

// Symbol Table Class
class SymbolTable
{
private:
    ll size;
    ScopeTable *curr;

public:
    SymbolTable(ll size)
    {
        this->size = size;
        curr = new ScopeTable(size, NULL);
        // output_file << "      ScopeTable# " << curr->get_id() << " created" << endl;
    }
    void EnterScope()
    {

        curr = new ScopeTable(size, curr);
        // output_file << "      ScopeTable# " << curr->get_id() << " created" << endl;
    }
    void ExitScope()
    {
        if (curr != NULL)
        {
            if (curr->get_parent_scope() == NULL)
            {

                delete curr;
                // output_file<<"        "<<"ScopeTable# "<<curr->get_id()<<" cannot be removed"<<endl;
                // PrintAllScopeTable();
            }
            else
            {
                // output_file<<"      "<<"ScopeTable# "<<curr->get_id()<<" removed"<<endl;
                ScopeTable *parentScope = curr->get_parent_scope();
                delete curr;
                curr = parentScope;
            }
        }
    }
    bool LookUpAll(string name)
    {
        ScopeTable *scope = curr;
        while (scope)
        {
            SymbolInfo *curr_symbol = scope->LookUp(name);
            if (curr_symbol != NULL)
            {
                return true;
            }
            scope = scope->get_parent_scope();
        }
        return false;
    }
    SymbolInfo *getSymbolInfo(string name)
    {
        if (!LookUpAll(name))
            return NULL;
        ScopeTable *scope = curr;
        while (scope)
        {
            SymbolInfo *curr_symbol = scope->LookUp(name);
            if (curr_symbol != NULL)
            {
                return curr_symbol;
            }
            scope = scope->get_parent_scope();
        }
    }
    bool Insert(SymbolInfo *symbol)
    {
        if (curr == NULL)
        {
            curr = new ScopeTable(size, NULL);
        }
        if (curr->LookUp(symbol->getName()) == NULL)
        {
            curr->Insert(symbol);
            return true;
        }
        // output_file<<"\t"<<symbol->getName()<<" already exisits in the current ScopeTable"<<endl;
        return false;
    }
    bool Remove(string name)
    {
        SymbolInfo *symbol = curr->LookUp(name);
        if (curr->Delete(name))
        {
            //   output_file<<"\tDeleted '"<<name<<"' from ScopeTable# "<<curr->get_id()<<" at position "<<symbol->getHashIdx()+1<<","<<symbol->getHashPos()<<endl;
            return true;
        }
        // output_file<<"\tNot found in the current ScopeTable" << endl;
        return false;
    }
    bool LookUp(string name)
    {
        ScopeTable *scope = curr;
        while (scope != NULL)
        {
            SymbolInfo *symbol = scope->LookUp(name);
            if (symbol == NULL)
            {
                scope = scope->get_parent_scope();
            }
            else
            {
                //       output_file << "\t'" << name << "' "
                //          << "found in ScopeTable# " << scope->get_id() << " at position " << symbol->getHashIdx() + 1 << ", " << symbol->getHashPos() << endl;
                return true;
            }
        }
        // output_file << "\t'" << name << "' "
        //    << "not found in any of the ScopeTables" << endl;
        return false;
    }
    void PrintCurrentScopeTable()
    {
        if (curr != NULL)
        {
            output_file << "\tScopeTable# " << curr->get_id() << endl;
            curr->Print();
        }
    }
    bool getCurrentScope()
    {
        if (curr != NULL)
            return true;

        return false;
    }
    void PrintAllScopeTable()
    {
        ScopeTable *temp = curr;
        while (temp != NULL)
        {
            output_file << "\tScopeTable# " << temp->get_id() << endl;
            temp->Print();
            temp = temp->get_parent_scope();
        }
    }
    ~SymbolTable()
    {
        while (curr != NULL)
        {
            // output_file<<"      "<<"ScopeTable# "<<curr->get_id()<<" removed"<<endl;

            ScopeTable *parent = curr->get_parent_scope();
            delete curr;
            curr = parent;
        }
    }
};