% taxi_lp = r"""
% ============================================
% taxi.lp — Codificación general del problema
% Usa los hechos de domain.lp:
%   rows/1, cols/1, cell/2, building/2, station/2,
%   taxi/1, taxi_pos/3, passenger/1, passenger_pos/3
% Planificación con horizonte maxT.
% ============================================

#const maxT = 8. % Revisar el valor correcto o investigar si se puede hacer más dinámico

time(0..maxT).
step(0..maxT-1). % La accion del paso S nos lleva del estado en tiempo S al estado en tiempo S+1


% --- Estados básicos ---

% Posición inicial de taxis y pasajeros (tiempo 0)
at_taxi(T,R,C,0)      :- taxi_pos(T,R,C).
at_passenger(P,R,C,0) :- passenger_pos(P,R,C).

% Nadie dentro de taxi al inicio
% (no hace falta hecho explícito: simplemente no hay in_taxi/4 en t=0), no haria falta poner in_taxi(P,T,0)

% --- Acciones posibles ---

dir(u;d;l;r). # crea hechos en ASP: dir(up). dir(d). dir(l). dir(r).

% Para cada taxi y cada paso, exactamente UNA acción:
1 { move(T,D,S) : dir(D)
  ; pick(T,S)
  ; drop(T,S)
  ; wait(T,S)
  } 1 :- taxi(T), step(S).

% --- Dinámica de los taxis (posición siguiente) ---

% Suc: S -> S1
succ(S,S1) :- step(S), S1 = S+1. #Para cada step(S) con S=0...maxT-1, se crea un succ(S,S+1), para expresar las transiciones en el tiempo

% Movimiento arriba
at_taxi(T,R1,C,S1) :-
    at_taxi(T,R,C,S),
    move(T,u,S),
    succ(S,S1), #S1 tiempo siguiente
    R1 = R-1, #una fila arriba
    R1 >= 0, #no salga del tablero por arriba
    cell(R1,C),
    not building(R1,C).

% Abajo
at_taxi(T,R1,C,S1) :-
    at_taxi(T,R,C,S),
    move(T,d,S),
    succ(S,S1),
    rows(N),
    R1 = R+1,
    R1 < N,
    cell(R1,C),
    not building(R1,C).

% Izquierda
at_taxi(T,R,C1,S1) :-
    at_taxi(T,R,C,S),
    move(T,l,S),
    succ(S,S1),
    C1 = C-1,
    C1 >= 0,
    cell(R,C1),
    not building(R,C1).

% Derecha
at_taxi(T,R,C1,S1) :-
    at_taxi(T,R,C,S),
    move(T,r,S),
    succ(S,S1),
    cols(M),
    C1 = C+1,
    C1 < M,
    cell(R,C1),
    not building(R,C1).

% Si no se mueve (wait/pick/drop), se queda donde estaba
at_taxi(T,R,C,S1) :-
    at_taxi(T,R,C,S),
    ( wait(T,S); pick(T,S); drop(T,S) ),
    succ(S,S1).

% Cada taxi tiene que estar en EXACTAMENTE una posición en cada tiempo
:- taxi(T), time(S), not 1 { at_taxi(T,R,C,S) : cell(R,C) } 1.

% No puede estar en un edificio (por si acaso)
:- at_taxi(T,R,C,S), building(R,C).  %un poco redundante

% --- Pasajeros: dentro/fuera del taxi ---

% Un pasajero queda 'ocupando' un taxi si está dentro

% Evitar que un taxi coja a alguien si ya lleva pasajero

% Acción de recoger: si taxi y pasajero están en misma celda y taxi libre


% Tras recoger, pasajero pasa a estar dentro en el siguiente paso


% Inercia: si está dentro y no es soltado, sigue dentro


% Cuando se suelta un pasajero, pasa a estar fuera en la celda del taxi


% Pasajero fuera: si estaba fuera y no ha sido recogido, se queda donde estaba


% --- Restricciones de ocupación (personas / taxis) ---

% Dos taxis no pueden compartir celda

% Dos pasajeros fuera no pueden compartir celda

% Pasajero fuera + taxi con ocupante en misma celda prohibido

% --- Prohibir intercambio de posición entre taxis en un paso ---


% --- Objetivo: al final (maxT), todos los pasajeros en estaciones y fuera de taxis ---

% Cada pasajero debe estar en alguna estación en tiempo maxT

% Ningún pasajero dentro de taxi en tiempo maxT

% --- Mostrar solo el plan (las acciones) ---

"""

with open("taxi.lp", "w", encoding="utf-8") as f:
    f.write(taxi_lp)

print("[OK] Creado taxi.lp")
!sed -n '1,60p' taxi.lp