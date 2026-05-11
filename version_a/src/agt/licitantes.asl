+!start : maximum_price(Max) & item(I)
    <- .print("Desejo ", I, " por no máximo R$ ", Max).

+open_auction(I, P0)[source(AH)] : item(I) & maximum_price(Max) & P0 <= Max
    <-  .send(AH, tell, register);
        +in_auction.

+current_price(I, P, R)[source(AH)] : item(I) & maximum_price(Max) & P <= Max
    <- .send(AH, tell, stay(I, P, R)).

+current_price(I, P, R)[source(AH)] : item(I) & maximum_price(Max) & P > Max
    <- -in_auction.

+winner(I, Winner, Price)[source(AH)]
    <- .my_name(Me);
       if (Winner == Me) {
           .print("Venci o leilão de ", I, "! Comprei por R$ ", Price);
       }.