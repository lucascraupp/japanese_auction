item("how_to_get_a_top_grade_in_SMA.pdf").
initial_price(50).
price_step(5).
registration_window(3000).
round_timeout(2000).

// ---------- Disparo automático ----------
!start.

+!start[source(self)] : initial_price(P0) & item(I) & registration_window(W)
   <- +current_price(P0);
      .print("Abrindo leilão de ", I, " a R$: ", P0);
      .broadcast(tell, open_auction(I, P0));
      .wait(W);
      !close_registration.

+register(_)[source(B)]
   <- .print("Registrado: ", B).

+stay(I, P, R)[source(B)]
   <- +stayed_in_round(B, R);
      -stay(I, P, R)[source(B)].

+!close_registration[source(self)] : not register(_)
   <- .print("Nenhum inscrito");
      !abort_auction(no_bidders).

+!close_registration[source(self)]
   <- .findall(B, register(_)[source(B)], L);
      .print("Inscritos: ", L);
      for (.member(B, L)) { 
         +active(B); 
         +last_active(B);
      }
      !start_round(1).

+!start_round(R)[source(self)] : item(I) & current_price(P) & round_timeout(T)
   <- .abolish(stayed_in_round(_, _));
      .print("Rodada ", R, " — preço R$ ", P);
      .broadcast(tell, current_price(I, P, R));
      .wait(T);
      !end_round(R).

+!end_round(R)[source(self)] : current_price(P)
   <- for (active(B) & not stayed_in_round(B, R)) {
         -active(B);
      }
      .findall(B, active(B), Stayers);
      .length(Stayers, K);
      .print("Rodada ", R, " encerrada. Stays: ", Stayers);
      !decide(R, K, Stayers).

+!decide(R, K, Stayers)[source(self)] : K >= 2 & current_price(P) & price_step(S)
   <- .abolish(last_active(_));
      for (.member(B, Stayers)) { 
         +last_active(B); 
      }
      NewP = P + S;
      -+current_price(NewP);
      Next = R + 1;
      !start_round(Next).

+!decide(_, 1, [Winner|_])[source(self)] : current_price(P)
   <- !declare_winner(Winner, P).

+!decide(_, 0, _)[source(self)] <- !tiebreak.

+!tiebreak[source(self)] : current_price(P) & price_step(S)
   <- .findall(B, last_active(B), Tied);
      .length(Tied, M);
      .random(X);
      Idx = math.floor(X * M);
      .nth(Idx, Tied, Winner);
      PrevP = P - S;
      .print("Empate entre ", Tied, ". Sorteado: ", Winner);
      !declare_winner(Winner, PrevP).

+!declare_winner(W, P)[source(self)] : item(I)
   <- .broadcast(tell, winner(I, W, P));
      .print("VENCEDOR: ", W, " a R$ ", P).

+!abort_auction(Reason)[source(self)] : item(I)
   <- .broadcast(tell, auction_failed(I, Reason));
      .print("Leilão abortado: ", Reason).
