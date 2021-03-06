// compilar con la orden:     bison -d grammar.y      luego    flex tokens.l
%{
#include "nodo.h"

extern elnodo * procedimientos[127]; //cambiar esta forma
extern int idx_prc;

extern elnodo * pila_programas[32];
 extern int idx_prg;

 extern int nro_decimales;
 extern long memoria;


#include "stdio.h"
 
#define MSDOS
//char constantes[127][127];
//char variables[127][127];
%}

%union {
 elnodo * nodo;
}


%start ROOT

%token STOP 
%token ABRIR CERRAR MOSTRAR VACIAR
%token LLAMAR PROC END PROCNAME GRAFICOS DIM LINEA CIRCULO CONVERTIR EVALUAR
%token EQ
%token TERMINAR DECIMALES VENTANA FIN BOTON MENSAJE ETIQUETA TEXTO
%token NE
%token LT
%token LE
%token GT
%token GE
%token PLUS
%token MINUS
%token MULT
%token DIVIDE
%token RPAREN
%token LPAREN
%token ASSIGN
%token SEMICOLON
%token COMMA
%token IF
%token THEN
%token ELSE
%token FI
%token WHILE
%token FOR
%token TO
%token DO
%token OD
%token PRINT
%token LEER BORRAR
%token NUMBER
%token NAME SNAME 
%token LITERAL DOBLECOMILLA OR AND CONTINUAR SALIR
%type <nodo> stmtseq statement  expr2 expr3 expr4 expression   procedimiento  procedimientos  lista_expr lista_expr2 GRAFICOS DIM LINEA CIRCULO
%type <nodo> designator LITERAL sdesignator SNAME NUMBER NAME proc_designator PROCNAME defventana defcontroles lista_controles
%type <nodo> CONVERTIR EVALUAR STOP ABRIR  CERRAR MOSTRAR OR AND CONTINUAR SALIR
%%

ROOT:
   stmtseq    {  pila_programas[idx_prg] = ($1); /* stmtseq */ ;  idx_prg++ ; }
|  stmtseq TERMINAR procedimientos {
  	printf("se ha reducido el programa por la regla de la linea 66 de grammar.y\n");
 	pila_programas[idx_prg] = ($1); /* stmtseq */ ;  idx_prg++; }
;

procedimientos:
   procedimiento   { $$ =  $1  ;  /* un procedimiento  */ }
|  procedimientos procedimiento { $$ =  $2 ; /*varios procedim.*/ }
;

statement:
  designator EQ expression { $$ = nodo2(asigna_num, $1, $3); /*asignacion*/} 
| sdesignator EQ LITERAL  { $$ = nodo2(asigna_alfa, $1, $3); /*asign literal*/} 
| sdesignator PLUS EQ sdesignator  { $$ = nodo2(sumar_alfa, $1, $4); /*suma alfa*/} 
| DIM designator NUMBER  { $$ = nodo2(dimensionar, $2, $3); /*dimensionar un vector entero */ }
| designator '[' expression ']' EQ expression { $$ = nodo3(asigna_vector, $1, $3, $6 );  }
| LLAMAR proc_designator   {  $$ = nodo1(llamar, $2) ;/*llamar proced.*/} 
| DECIMALES NUMBER  { $$ = nodo1(decimales, $2 ) ; } 
| PRINT lista_expr  { $$ = nodo1(imprimir_varios,  $2); /*imprimir lista expr*/} 
| IF expression THEN stmtseq ELSE stmtseq FI { $$ = nodo3(si, $2, $4, $6); /*if con else */}
| IF expression THEN stmtseq FI { $$ = nodo2(si, $2, $4); /*if sin else*/}
| WHILE expression DO stmtseq OD { $$ = nodo2(mientras, $2, $4); /*while*/}
| FOR designator EQ expression TO expression DO stmtseq OD {$$ = nodo4(desde, $2, $4, $6, $8); /*for*/}
| VENTANA defventana END VENTANA { $$ = $2 ; }
| VENTANA designator NUMBER NUMBER  { $$ = nodo3(crear_ventana, $2, $3, $4) ;  }
| LEER VENTANA designator LITERAL { $$=nodo1(mostrar_ventana, $3) ;  } 
| LLAMAR VENTANA designator { $$=nodo1(mostrar_ventanas, $3) ;  } 
| designator VENTANA LITERAL { $$=nodo2(cambiar_titulo, $1, $3) ;  } 
| designator BOTON LITERAL proc_designator NUMBER NUMBER { $$=nodo5(guardar_boton, $1, $3, $4, $5, $6) ;  } 
| designator ETIQUETA LITERAL NUMBER NUMBER { $$=nodo4(guardar_etiqueta, $1, $3, $4, $5) ;  } 
| designator TEXTO SNAME expr2 COMMA expr2 { $$=nodo4(guardar_texto, $1, $3, $4, $6) ;  } 
| MENSAJE lista_expr  { $$ = nodo1(mensaje,  $2); /*imprimir lista expr*/}
| LLAMAR LITERAL {   $$ = nodo1(interpreta, $2);  }  /*los siguientes... 18 de Enero de 2014 */
| GRAFICOS proc_designator designator designator designator { $$ = nodo4(graficos, $2, $3, $4, $5);   }  /* proc  boton x y */
| LINEA expr2 COMMA expr2 COMMA expr2 COMMA expr2 { $$ = nodo4(dibuja_linea, $2, $4, $6, $8) ; }  /* dibuja una linea en la ventana grafica */
| CIRCULO expr2 COMMA expr2 COMMA expr2 { $$ = nodo3(dibuja_circulo, $2, $4, $6) ; } 
| CONVERTIR sdesignator designator {$$=nodo2(convertir_texto_a_numero, $2, $3);}
| CONVERTIR designator sdesignator {$$=nodo2(convertir_numero_a_texto, $2, $3);}
| EVALUAR LITERAL  {  $$ = nodo1(interpreta, $2 );  } 
| STOP { $$=nodo1(stop, $1); }
| ABRIR sdesignator designator { $$=nodo2(abrir, $2, $3); }
| CERRAR designator { $$=nodo1(cerrar, $2); }
| LEER designator   { $$ = nodo1(leer,  $2) ; /*leer variable numerica*/}
| LEER  '#' designator sdesignator designator { $$=nodo3(leer_archivo, $3, $4, $5); }
| LEER sdesignator  { $$ = nodo1(leertexto,  $2) ; /*leer variable alfa*/}
| MOSTRAR sdesignator { $$=nodo1(mostrar, $2); }
| VACIAR sdesignator { $$=nodo1(vaciar, $2); }
| CONTINUAR { $$=nodo1(continuar, $1); }
| SALIR { $$=nodo1(salir, $1); }
;

defventana:
  LITERAL {  $$ = nodo1(ventana, $1) ;  } 
| LITERAL defcontroles { $$=$2; } 
;

defcontroles:
  lista_controles { $$=$1 ; } 
| defcontroles COMMA lista_controles { $$ = nodo2( secuencia_controles, $1, $3); } 
;

lista_controles:
  BOTON LITERAL { $$ = nodo1(guardar_boton, $2) ; } 

lista_expr:
  lista_expr2  { $$=$1 ; /*lista expr*/ }
| lista_expr COMMA lista_expr2 { $$=nodo2 (secuencia, $1, $3)  ; /*varias lista expr, separadas por coma*/ }
;

lista_expr2:
  expression   { $$=nodo1(imprimir_expresion, $1); /*lista expresion2*/}
| LITERAL      { $$=nodo1(imprimir_literal, $1 ); /* un literal*/}
| sdesignator  { $$=nodo1(imprimir_var_alfa, $1); /* una variable literal*/}

;

stmtseq:
  stmtseq statement { $$ = nodo2(secuencia, $1, $2); /*una seq de comandos*/}
| statement { $$ = $1; /*un comando*/}
;

expression:
  expr2 { $$ = $1; /* expresion2*/} 
| expr2 EQ expr2 { $$ = nodo2(igualque,      $1, $3); /*igualdad*/}
| expr2 NE expr2 { $$ = nodo2(noigualque,    $1, $3); /*no igual*/}
| expr2 LT expr2 { $$ = nodo2(menorque,      $1, $3); /*menor que*/}
| expr2 LE expr2 { $$ = nodo2(menorigualque, $1, $3); /*menor o igual que*/}
| expr2 GT expr2 { $$ = nodo2(mayorque,      $1, $3); /*mayor que*/}
| expr2 GE expr2 { $$ = nodo2(mayorigualque, $1, $3); /*mayor o igual que*/}
| sdesignator EQ LITERAL { $$ = nodo2(comparaliteral, $1, $3) ; /*asigna literal*/}
;

expr2:
  expr3 { $$ = $1; /* expr2*/}
| expr2 PLUS expr3 { $$ = nodo2(suma, $1, $3); /*suma*/}
| expr2 MINUS expr3 { $$ = nodo2(resta, $1, $3); /*resta*/}
| expr2 OR expr3 { $$ = nodo2(or, $1, $3); /*or*/}
| expr2 AND expr3  { $$ = nodo2(and, $1, $3); /*and*/}
;

expr3:
  expr4 { $$ = $1; }
| expr3 MULT expr4 { $$ = nodo2(multiplica, $1, $3); /*multiplicar*/}
| expr3 DIVIDE expr4 { $$ = nodo2 (divide, $1, $3); /*dividir*/}
;

expr4:
  PLUS expr4 { $$ = $2; /*positivo*/}
| MINUS expr4 { $$ = nodo1(negativo, $2); /*negativo*/}
| LPAREN expression RPAREN { $$ = $2; /*expr enter parentesis*/}
| NUMBER { $$ =  $1; /*numero*/}
| designator { $$ = $1; /*designador variable*/}
| designator '[' expression ']' { $$ = nodo2(evalua_vector, $1, $3);   }
;

sdesignator:
  SNAME { $$ = $1; /*designador string*/}

designator:
  NAME { $$ = $1;  /* nombre designador */ }
;
proc_designator:
  NAME { $$ =  $1 ;  /*designador proced.*/ }


procedimiento:
   PROC proc_designator stmtseq END { 
			$$ = nodo2(procedimiento, $2, $3) ;/*un procedimiento*/
                        procedimientos[(int) $2->num] = $3   ;   /* revisar este metodo */
			idx_prc++;
			}
%%


