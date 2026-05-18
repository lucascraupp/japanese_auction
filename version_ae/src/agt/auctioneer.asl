// ============================================================
//  Auctioneer (versão AE — opera o artefato AuctionHouse já
//  pré-instanciado pelo ambiente, no workspace `w`).
// ============================================================

!start_agents.

+!start : registration_window(W)
   <- .print("Operando o artefato AuctionHouse.");
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

+winner(B, P).

+phase("aborted")
   <- .print("Auctioneer notado: leilão abortado.").


// ---------- Criação dos agentes bidder ----------

+!start_agents : bidder(N) 
   <- !attach;
      .print("Criando ", N, " bidders...");
      ?current_price(P0);
      .print("Preço inicial: R$ ", P0);
      !create_bidder(N, P0);
      .broadcast(achieve, start);
      !start.

+!create_bidder(N, P0): N > 0
   <- !create_bidder(N-1, P0);
      ?variation_max_price(V);
      Max = P0 + math.floor(math.random(V));
      .concat("bidder_", N, Name);
      .create_agent(Name, "bidder.asl");
      .send(Name, tell, max_price(Max));
      .print("Criando bidder com limite de R$ ", Max).

+!create_bidder(0, P0).
