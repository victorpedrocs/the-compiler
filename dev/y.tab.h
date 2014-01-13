/* A Bison parser, made by GNU Bison 2.5.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2011 Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     TK_NUM = 258,
     TK_REAL = 259,
     TK_BOOL = 260,
     TK_CHAR = 261,
     TK_STRING = 262,
     TK_SOMA_SUB = 263,
     TK_MULT_DIV = 264,
     TK_OP_REL = 265,
     TK_OP_LOG = 266,
     TK_MAIN = 267,
     TK_ID = 268,
     TK_TIPO_INT = 269,
     TK_TIPO_REAL = 270,
     TK_TIPO_CHAR = 271,
     TK_TIPO_STRING = 272,
     TK_TIPO_BOOL = 273,
     TK_FIM = 274,
     TK_ERROR = 275
   };
#endif
/* Tokens.  */
#define TK_NUM 258
#define TK_REAL 259
#define TK_BOOL 260
#define TK_CHAR 261
#define TK_STRING 262
#define TK_SOMA_SUB 263
#define TK_MULT_DIV 264
#define TK_OP_REL 265
#define TK_OP_LOG 266
#define TK_MAIN 267
#define TK_ID 268
#define TK_TIPO_INT 269
#define TK_TIPO_REAL 270
#define TK_TIPO_CHAR 271
#define TK_TIPO_STRING 272
#define TK_TIPO_BOOL 273
#define TK_FIM 274
#define TK_ERROR 275




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


