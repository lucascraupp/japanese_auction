// ============================================================
//  Bidder (versão AE — interage via artefato)
//  Crença max_price/1 é definida no .jcm para cada instância.
// ============================================================

!start.

+!start : .my_name(Me) & max_price(M)
   <- .print(Me, " entrando no leilão (teto R$ ", M, ")");
      +participating;
      !attach.

// busca e foca o artefato; tenta de novo se ainda não existe
+!attach
   <- .wait(300);
      lookupArtifact("auction_house", AID);
      focus(AID).

-!attach
   <- .wait(300);
      !attach.

// ---------- Reações às propriedades observáveis ----------

+phase("registration")
   <- register;
      .print("registrado.").

+round(R) : R > 0 & participating & current_price(P) & max_price(M) & P <= M
   <- .print("R", R, " preço R$ ", P, " <= teto R$ ", M, " -> STAY");
      stay.

+round(R) : R > 0 & participating & current_price(P) & max_price(M) & P > M
   <- .print("R", R, " preço R$ ", P, " > teto R$ ", M, " -> LEAVE");
      -participating;
      leave.

// ---------- Resultado ----------

+winner(Me, P) : .my_name(Me)
   <- .print("VENCI! Pago R$ ", P, " pelo item.").

+winner(B, P) : .my_name(Me) & B \== Me
   <- .print("Vencedor foi ", B, " a R$ ", P, ".").

+phase("aborted")
   <- .print("Leilão abortado.").
