// ============================================================
//  Auctioneer (versão AE — coordena o leilão via artefato)
// ============================================================
item("how_to_get_a_top_grade_in_SMA.pdf").
initial_price(50).
price_step(5).
registration_window(3000).
round_timeout(2000).

!start.

+!start : item(I) & initial_price(P0) & price_step(S) & registration_window(W)
   <- makeArtifact("auction_house", "auction.AuctionHouse", [I, P0, S], ArtId);
      focus(ArtId);
      .print("Artefato AuctionHouse criado para item ", I, " a R$ ", P0);
      openRegistration;
      .wait(W);
      !close_registration.

+!close_registration
   <- closeRegistration(N, _Bidders);
      if (N == 0) {
         .print("Leilão encerrado sem inscritos.");
      } else {
         !run_round(1);
      }.

+!run_round(R) : round_timeout(T)
   <- startRound(R);
      .wait(T);
      endRound(Status, Result);
      !handle(R, Status, Result).

+!handle(R, "continue", _)
   <- Next = R + 1;
      !run_round(Next).

+!handle(_, "winner", Winner) : current_price(P)
   <- declareWinner(Winner, P).

+!handle(_, "tie", Winner) : current_price(P)
   <- declareWinner(Winner, P).

// observa propriedade do artefato para confirmar
+winner(B, P)
   <- .print("Auctioneer confirmou vencedor: ", B, " a R$ ", P).

+phase("aborted")
   <- .print("Auctioneer notado: leilão abortado.").
