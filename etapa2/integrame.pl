:- ensure_loaded('checker.pl').

test_mode(detailed).

% Considerăm următoarele reprezentări:
%
% O integramă este reprezentată prin structura (compusul)
% integ(H, W, Lista, Vocab), unde:
% H este înălțimea integramei
% W este lățimea integramei
% Lista este o listă de tupluri (Poz, Valoare), unde
%   Poz este un tuplu (R, C) conținând rândul și coloana (0-based)
%   Valoare este una dintre:
%     x - dacă celula este neagră (nu poate fi completată cu litere)
%     o literă, dacă celula este completată cu o literă
%     o listă de întrebări, reprezentate ca tupluri (Text, Dir, ID), cu
%       Text - un srting, textul întrebării
%       Dir - una dintre valorile j sau d, indicând direcția întrebării
%       ID - un identificator numeric al întrebării
% Vocab este o listă de stringuri reprezentând cuvinte disponibile
% pentru a rezolva întrebarea.
%
% În ieșirea predicatului intrebări, o întrebare este reprezentată ca
% ((R, C), Text, Dir, ID), unde
% R este rândul căsuței cu întrebarea (0-based)
% C este coloana căsuței cu întrebarea (0-based)
% Text este textul întrebării (un string)
% Dir este j sau d, reprezentând direcția în care trebuie să fie plasat
% răspunsul (jos sau dreapta)
% ID este un identificator numeric al întrebării.

% Puteți vizualiza integramele cu:
% integrama(0, W), print_integrama(W).
% integrama(1, W), print_integrama(W).
% integrama(2, W), print_integrama(W).
% integrama(3, W), print_integrama(W).
%
% Testați cu
% vmtest.
% Testați teste individuale (vedeți predicatul tt din checker.pl) cu
% vmtest(Test).
% de exemplu cu vmtest(intrebari).


% intrebari/2
% intrebari(integ(+H, +W, +Lista, +Vocab), -Lista_intrebari)
% Este adevărat atunci când Lista_intrebari este o lista de tupluri
% ((R, C), Text, Dir, ID), fiecare tuplu corespunzând unei întrebări din
% integramă (rândul, coloana, textul întrebării, direcția (j/d),
% identificatorul).
% BONUS: intrebari are o singură soluție (o singură listă) pentru o
% anumită integramă.
intrebari(integ(H, W, [((R,C),[(Text, Dir, Id)|T])|TLista], Vocab), [((R,C),Text, Dir, Id)|Lista_intrebari]) :- intrebari(integ(H, W, [((R,C),T)|TLista], Vocab), Lista_intrebari), !.
intrebari(integ(H, W, [((_, _), _)|TLista], Vocab), Lista_intrebari) :- intrebari(integ(H, W, TLista, Vocab), Lista_intrebari).
intrebari(integ(_, _, [], _), []).
% id_intrebare/2
% id_intrebare(+Integ, ?Intrebare, ?Q_ID)
% Este adevărat dacă în integrama reprezentată ca integ(...), Intrebare
% este un text iar Q_ID este un identificator care corespund aceleași
% întrebări.
id_intrebare(integ(_, _, [((_,_),[(Text, _, Id)|_])|_], _), Text, Id).
id_intrebare(integ(H, W, [((R,C),[_|T])|TLista], Vocab), Intrebare, Id) :- id_intrebare(integ(H, W, [((R,C), T)|TLista], Vocab), Intrebare, Id).
id_intrebare(integ(H, W, [((_,_),_)|TLista], Vocab), Intrebare, Id) :- id_intrebare(integ(H, W, TLista, Vocab), Intrebare, Id).

% completare/3
% completare(+Integ, +Sol, -Integrama)
% Predicatul produce Integrama, o structură de forma integ(...),
% pornind de la Integ, în care au fost completate celule conform cu
% soluția Sol.
% Soluția este reprezentată ca o listă de perechi (Întrebare, Răspuns),
% unde Întrebarea este textul unei întrebări, iar Răspuns este un cuvând
% de completat; ambele sunt stringuri.
% De exemplu, o soluție parțială pentru integrama 0 poate fi:
% [('Din care plouă', 'NOR'), ('Al doilea număr', 'DOI')]
% BONUS: lungime_spatiu are o singură soluție pentru o anumită
% întrebare.
% Puteți testa manual predicatul cu o interogare de forma:
% integrama(0, W), solutie(0, Sol), completare(W, Sol, W2),
%   print_integrama(W2).

completare(integ(H, W, L, V), Sol, integ(H, W, L2, V)) :- intrebari(integ(H,W,L,V),Lista), help_function2(Lista, Sol, ListaF), flatten(ListaF, ListaF2), remove_dups(ListaF2, ListaF3), append(L, ListaF3, L2).

remove_dups([], []).
remove_dups([First | Rest], NewRest) :- member(First, Rest), remove_dups(Rest, NewRest).
remove_dups([First | Rest], [First | NewRest]) :- not(member(First, Rest)), remove_dups(Rest, NewRest).

%help_function2(Lista_intrebari, Lista_finala)
help_function2(_, [], []).
help_function2(Lista_intrebari, [(Text,Raspuns)|Sol], [Lista|Lista_finala]) :- include(lambda_f(Text),Lista_intrebari,SolDoarUnu), [Cap|_] = SolDoarUnu, ((R,C),_,Dir,_) = Cap, atom_chars(Raspuns, TextL), Dir == 'j', NewR is R+1, help_function(NewR,C,'j',TextL,Lista), help_function2(Lista_intrebari, Sol, Lista_finala).

help_function2(Lista_intrebari, [(Text,Raspuns)|Sol], [Lista|Lista_finala]) :- include(lambda_f(Text),Lista_intrebari,SolDoarUnu), [Cap|_] = SolDoarUnu, ((R,C),_,Dir,_) = Cap, atom_chars(Raspuns, TextL), Dir == 'd', NewC is C+1, help_function(R,NewC,'d',TextL,Lista), help_function2(Lista_intrebari, Sol, Lista_finala).

%help_function(R, C, Dir, Cuvant, Lista)
help_function(_, _, _, [], []).
help_function(R, C, 'j', [HC|TC], [((R,C), HC)|TL]) :- NewR is R+1, help_function(NewR, C, 'j', TC, TL).
help_function(R, C, 'd', [HC|TC], [((R,C), HC)|TL]) :- NewC is C+1, help_function(R, NewC, 'd', TC, TL).

lambda_f(Text, ((_,_), Text2, _, _)) :- Text == Text2.

% lungime_spatiu/3
% lungime_spatiu(integ(+H, +W, +Lista, +Vocab), +Intrebare, -Lungime)
% Returnează lungimea spațiului asociat întrebării date.
% Întrebarea este indicată prin textul ei. De exemplu:
% lungime_spatiu pentru integrama 0 și întrebarea 'Al doilea număr'
% trebuie să lege Lungime la 3.
% BONUS: lungime_spatiu are o singură soluție pentru o anumită
% întrebare.
% Puteți testa manual predicatul cu o interogare de forma:
% integrama(0, W), id_intrebare(W, Text, 3), lungime_spatiu(W, Text, X).

lungime_spatiu(Integ, Text, Lungime) :- intrebari(Integ, Lista_int), Lng is 0, helper_lungime(Integ, Lista_int, Text, Lng, Lungime).

helper_lungime(Integ, [((R,C),Text,Dir,_)|_], Text, Lungime, Lungime_f) :- Dir == 'j', NewR is R+1, NewL is Lungime, rec(Integ, NewR, C, Text, Dir, NewL, Lungime_f).
helper_lungime(Integ, [((R,C),Text,Dir,_)|_], Text, Lungime, Lungime_f) :- Dir == 'd', NewC is C+1, NewL is Lungime, rec(Integ, R, NewC, Text, Dir, NewL, Lungime_f).
helper_lungime(Integ, [_|Intrebari], Text, Lungime, Lungime_f) :- helper_lungime(Integ, Intrebari, Text, Lungime, Lungime_f).

rec(integ(H, W, L, V), R, C, Text, Dir, Lungime, Lungime_f) :- \+ member(((R,C),_), L), Dir == 'j', NewR is R+1, NewL is Lungime+1, rec(integ(H, W, L, V), NewR, C, Text, Dir, NewL, Lungime_f).
rec(integ(H, W, L, V), R, C, Text, Dir, Lungime, Lungime_f) :- \+ member(((R,C),_), L), Dir == 'd', NewC is C+1, NewL is Lungime+1, rec(integ(H, W, L, V), R, NewC, Text, Dir, NewL, Lungime_f).
rec(integ(_, _, L, _), R, C, _, _, Lungime, Lungime_f) :-member(((R,C), _),L), Lungime_f is Lungime.


% intersectie/5
% intersectie(integ(+H, +W, +Lista, +Voc), +I1, -Poz1, +I2, -Poz2)
% Pentru o integramă și două întrebări date prin textul lor (I1 și I2),
% al căror răspunsuri se intersectează, întoarce în Poz1 indicele din
% răspunsul la I1 la care este intersecția, și în Poz2 indicele din
% răspunsul la I2 la care este intersecția. Indecșii incep de la 0.
%
% De exemplu, în integrama 0:
%  █       █       2↓      3↓      █
%  █       0↓,1→   -       -       █intrebari(Integ, Lista_int),
%  4→      -       -       -       █
%  5→      -       -       -       █
%  █       █       █       █       █
%
%  Întrebările 'Primii 3 din artă' și 'Afirmativ' (3, respectiv 1) se
%  intersectează la pozițiile 0, respectiv 2 (va fi litera A, de la
%  ART, respectiv DA).

intersectie(integ(H,W,Lista,Voc), I1, Poz1, I2, Poz2) :- intrebari(integ(H,W,Lista,Voc), Lista_intrebari), helper_intersectie(integ(H, W, Lista, Voc), Lista_intrebari, I1, Poz1, I2, Poz2).

helper_intersectie(integ(H, W, L, Voc), [((R, C), I1, Dir, _)|Lista], I1, Poz1, I2, Poz2) :- Dir == 'j', lungime_spatiu(integ(H, W, L, Voc), I1, Lungime1), NewR is R+1, helper2_intersectie(integ(H, W, L, Voc), Lista, NewR, C, Lungime1, Poz1, I2, Poz2, Dir).

helper_intersectie(integ(H, W, L, Voc), [((R, C), I1, Dir, _)|Lista], I1, Poz1, I2, Poz2) :- Dir == 'd', lungime_spatiu(integ(H, W, L, Voc), I1, Lungime1), NewC is C+1, helper2_intersectie(integ(H, W, L, Voc), Lista, R, NewC, Lungime1, Poz1, I2, Poz2, Dir).

helper_intersectie(integ(H, W, L, Voc), [((R, C), I2, Dir, _)|Lista], I1, Poz1, I2, Poz2) :- Dir == 'd', lungime_spatiu(integ(H, W, L, Voc), I2, Lungime1), NewC is C+1, helper2_intersectie(integ(H, W, L, Voc), Lista, R, NewC, Lungime1, Poz2, I1, Poz1, Dir).

helper_intersectie(integ(H, W, L, Voc), [((R, C), I2, Dir, _)|Lista], I1, Poz1, I2, Poz2) :- Dir == 'j', lungime_spatiu(integ(H, W, L, Voc), I2, Lungime1), NewR is R+1, helper2_intersectie(integ(H, W, L, Voc), Lista, NewR, C, Lungime1, Poz2, I1, Poz1, Dir).

helper_intersectie(integ(H,W,L,Voc), [((_,_),_)|Lista], I1, Poz1, I2, Poz2) :- helper_intersectie(integ(H,W,L,Voc), Lista, I1, Poz1, I2, Poz2).


helper2_intersectie(integ(H, W, L, Voc), [((R2,C2), I2, Dir, _)|_], R, C, Lungime1, Poz1, I2, Poz2, Dir1) :- Dir == 'j', Dir1 == 'd', lungime_spatiu(integ(H,W,L,Voc), I2, Lungime2), NewR is R2+1, R2 < R, final(integ(H, W, L, Voc), R, C, NewR, C2, Lungime1, Lungime2, Dir1, Dir, Poz1, Poz2).

helper2_intersectie(integ(H, W, L, Voc), [((R2, C2), I2, Dir, _)|_], R, C, Lungime1, Poz1, I2, Poz2, Dir1) :- Dir == 'd', Dir1 == 'j', lungime_spatiu(integ(H,W,L,Voc), I2, Lungime2), NewC is C2+1, C2 < C, final(integ(H, W, L, Voc), R, C, R2, NewC, Lungime1, Lungime2, Dir1, Dir, Poz1, Poz2).

helper2_intersectie(integ(H, W, L, Voc), [_|Lista], R, C, Lungime1, Poz1, I2, Poz2, Dir1) :- helper2_intersectie(integ(H,W,L,Voc), Lista, R, C, Lungime1, Poz1, I2, Poz2, Dir1).

final(integ(_,_,_,_), R1, C1, R2, C2, L1, L2, Dir1, _, Poz1, Poz2) :- Dir1 == 'j', Poz2f is C1-C2, Poz1f is R2-R1, Poz1f < L1, !, Poz2f < L2, !, Poz1 is Poz1f, Poz2 is Poz2f.
final(integ(_,_,_,_), R1, C1, R2, C2, L1, L2, Dir1, _, Poz1, Poz2) :- Dir1 == 'd', Poz2f is R1-R2, Poz1f is C2-C1, Poz1f < L1, !, Poz2f < L2, !, Poz1 is Poz1f, Poz2 is Poz2f.




% solutii_posibile/2
% solutii_posibile(integ(+H, +W, +Lista, +Vocabular), -Solutii)
% Formează o listă Solutii, conținând perechi de forma
% (Întrebare, Cuvinte), unde
% Întrebare este textul unei întrebări din integramă, iar Cuvinte este o
% listă de cuvinte sunt din Vocabular și au lungimea corectă pentru a fi
% răspuns la întrebare. Solutii conține câte o pereche pentru fiecare
% întrebare din integramă.
% Cuvintele sunt reprezentate ca liste de stringuri, fiecare string
% având lungime 1 (o singură literă).
% De exemplu, pentru integrama 0, Solutii conține 6 perechi, două dintre
% ele fiind:
% ('Afirmativ', [['D', 'A'], ['N', 'U']])
% ('Din care plouă',
% [['N','O','R'],['A','R','T'],['U','I','T'],['D','O','I']])
solutii_posibile(_, _) :- false.

% rezolvare/2
% rezolvare(+Integ, -Solutie)
% Rezolvare produce în Solutie soluția integramei Integ. Soluția este
% reprezentată ca o listă de perechi de stringuri, fiecare pereche
% conținând textul unei întrebări și cuvântul (ca string) care este
% răspunsul la întrebare.
rezolvare(_, _) :- false.
