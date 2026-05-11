# Japanese Auction — Trabalho de SMA

Implementação de um [Japanese Auction](https://en.wikipedia.org/wiki/Japanese_auction) em duas versões, usando JaCaMo (Jason + CArtAgO).

## Versões

- **`version_a/`** — apenas agentes Jason. Coordenação via mensagens (`.broadcast`, `.send`).
- **`version_ae/`** — agentes + ambiente instrumentado com artefato CArtAgO (`AuctionHouse`), declarado no `.jcm` dentro do workspace `w`

## Como rodar

Cada versão é um projeto Gradle independente:

```bash
cd version_a  && ./gradlew run
cd version_ae && ./gradlew run
```

## Parâmetros do leilão

| Parâmetro            | Valor   |
|----------------------|---------|
| Preço inicial        | R$ 50   |
| Incremento por rodada| R$ 5    |
| Janela de inscrição  | 3000 ms |
| Duração da rodada    | 2000 ms |

Em `version_a/` ficam todos no `.asl` do leiloeiro. Em `version_ae/` o preço inicial e o incremento são argumentos do artefato (no `.jcm`); janela e duração ficam no `.asl` do leiloeiro.

## Estrutura

```
version_a/
  src/agt/auction_house.asl     # leiloeiro (mensagens)
  src/agt/licitantes.asl         # licitantes
version_ae/
  src/env/auction/AuctionHouse.java   # artefato CArtAgO compartilhado
  src/agt/auctioneer.asl              # leiloeiro: opera o artefato
  src/agt/bidder.asl                  # licitante: observa props e chama operações
```
