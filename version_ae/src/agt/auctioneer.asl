// ============================================================
//  Auctioneer (versão AE — opera o artefato AuctionHouse já
//  pré-instanciado pelo ambiente, no workspace `w`).
// ============================================================
registration_window(3000).
round_timeout(2000).

!start.

+!start : registration_window(W)
   <- !attach;
      .print("Operando o artefato AuctionHouse.");
      openRegistration;
      .wait(W);
      !close_registration.

+!attach
   <- .wait(300);
      joinWorkspace("w", WspId);
      lookupArtifact("auction_house", AID);
      focus(AID).

-!attach
   <- .wait(300);
      !attach.

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

+winner(B, P)
   <- .print("Auctioneer confirmou vencedor: ", B, " a R$ ", P).

+phase("aborted")
   <- .print("Auctioneer notado: leilão abortado.").
