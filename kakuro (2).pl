:- use_module(library(clpfd)).
:- consult(spec).

kakuro :-
	
	%Constructs_a_matrix
	matrix(M), 

	%Gets_the_data_from_spec
	findall(WAR,across(WAR,_,_,_),W_across_r),	
	findall(WAC,across(_,WAC,_,_),W_across_c),
	findall(WAL,across(_,_,WAL,_),W_across_l),
	findall(WAS,across(_,_,_,WAS),W_across_s),
	findall(WDR,down(WDR,_,_,_),W_down_r),
	findall(WDC,down(_,WDC,_,_),W_down_c),
	findall(WDL,down(_,_,WDL,_),W_down_l),
	findall(WDS,down(_,_,_,WDS),W_down_s),
	findall(BR,black(BR,_),B_r),
	findall(BC,black(_,BC),B_c),
	
	%Sets_white_spaces_and_sets_the_domains_and_constrains_them
	setW(W_across_c,W_across_r,W_across_l,W_across_s,M,AW),%across 
	transpose(M, FM),%flips_matrix
	setW(W_down_r,W_down_c,W_down_l,W_down_s,FM,DW),%down
	
	%Sets_the_black_spaces 
	setB(B_c,B_r,M,B_S),
	B_S ins 0,
	
	%labeling
	labeling([],B_S),
    labelspace(AW),
	labelspace(DW),
	
	%display
	show(M),!.
%--------------------------------------------------------------------	
/*
 *Makes a matrix by creating a list of 12 lists.
 *Each of the 12 lists is filled with 12 free variables.
 */
matrix(M) :- length(M,12),makecolumns(M,_). %Makes_the_list_12_lists
	%fills_it with_12_lists_with_12_variables
	makecolumns([],_).
	makecolumns([H|T],N) :- length(A,12), H = A, makecolumns(T,[A|N]).
/*
 *Sets the spaces in the matrix to black spaces
 *by adding the positions on the list with nth1.
 *This will output a list of black spaces paired with
 *the variables in the matrix. 
 *C = column, R = row, M = Matrix, B_S = a black space.
 */
setB([],[],_,[]).
setB([C|T1],[R|T2],M,[B_S|NT]) :- nth1(R,M,X), nth1(C,X,B_S), setB(T1,T2,M,NT).
/*
*Sets the spaces in the matrix to white spaces
*by adding the positions on the list with nth1.
*Since every white space is just given a staring
*point and the length of contiguous white spaces
*a list is made of that length. with list we can
*add the domains and the contraints. Finally a 
*we can then output a list of white spaces for 
* across or down that is paired with the variables
* in the matrix with the domains and constraints set.
*RC1 = row or column(column if across or row if down)
*RC2 = row or column (row if across or column if down)
*L = length of a contiguous run,
*S = the sum of a contiguous run,
*M = Matrix, CWRL = a contiguous white run list
*/
setW([],[],[],[],_,[]).
setW([RC1|T1],[RC2|T2],[L|T3],[S|T4],M,[CWRL|NT]) :- 
	nth1(RC2,M,Z), %finds_in_matrix 
	length(CWRL,L), %makes_a_list_for_a_contiguous_run
	makewhiterun(RC1,Z,CWRL),%puts_the_matrix_variables_in_the_run 
	CWRL ins 1..9,%set_domains_for_run 
	all_different(CWRL),%set_constraints
	sum(CWRL,#=,S),%set_constraints_for_sum
	setW(T1,T2,T3,T4,M,NT).
		/*
		*Takes the list of the correct length for a 
		*white run and assignsthe variables of the 
		*matrix to it adding one to X to find the next
		*element in the matrix until the run is complete
		*X =  the position of the element in the matrix list
		*M = the matrix, the list is the result which is CWRL
		*/
		makewhiterun(_,_,[]).
		makewhiterun(X,M,[H|T]) :-  nth1(X,M,H), incr(X,Z),makewhiterun(Z,M,T).
			/*increase a value by one*/
			incr(X, Y) :- Y is X+1.
/*as we have a list of white space contiguous run lists
 *this predicate will label every list in the list.
 */
labelspace([]).
labelspace([H|T]) :- labeling([],H), labelspace(T).
/*
*formates the final output by first taking every 0
*and changing into a '*' then strips the brackets by
*writing the lists a strings, then adds a new line 
*after every list has been fully written.
*L = list that will be displayed by a line
*Ls = the list with the 0 as '*'
*/
show([]).
show([L|T]) :- star(L,LS), showS(LS), nl, show(T).
	/*
	*takes a list as an imput checks each element for 0
	*if an element is 0 it replaces that element with a '*'
	*in the new list. if the element is not 0  the new list 
	*will get the same element as the old list.
	*/
	star([],[]).
	star([H|T],[H1|T1]) :- H is 0 -> H1 = '*', star(T,T1) ;  H1 is H, star(T,T1).
	/*
	*takes each element and writes it as a String*/
	showS([]).
	showS([H|T]) :- write(H),showS(T). 