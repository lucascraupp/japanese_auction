package auction;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;
import jason.asSyntax.Atom;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

/**
 * Artefato CArtAgO que coordena um Japanese Auction.
 * <p>
 * Propriedades observáveis:
 *   item(I), current_price(P), round(R), phase(P), winner(B, P)
 * <p>
 * Operações para bidders: register, stay, leave
 * Operações para auctioneer: openRegistration, closeRegistration,
 *   startRound, endRound, declareWinner, abort
 */
public class AuctionHouse extends Artifact {

    private final List<String> registered = new ArrayList<>();
    private final Set<String> active = new HashSet<>();
    private final Set<String> stayedThisRound = new HashSet<>();
    private final Set<String> lastActive = new HashSet<>();

    private int priceStep;
    private final Random rng = new Random();

    public void init(String itemName, int initialPrice, int step) {
        this.priceStep = step;
        defineObsProperty("item", itemName);
        defineObsProperty("current_price", initialPrice);
        defineObsProperty("round", 0);
        defineObsProperty("phase", "idle");
    }

    @OPERATION
    public void openRegistration() {
        getObsProperty("phase").updateValue("registration");
        log("Inscrições abertas.");
    }

    @OPERATION
    public void register() {
        String phase = getObsProperty("phase").stringValue();
        if (!"registration".equals(phase)) {
            failed("Inscrições não estão abertas (phase=" + phase + ")");
            return;
        }
        String agent = getOpUserName();
        if (registered.contains(agent)) {
            failed("Agente " + agent + " já registrado");
            return;
        }
        registered.add(agent);
        log("Registrado: " + agent);
    }

    @OPERATION
    public void closeRegistration(OpFeedbackParam<Integer> n,
                                  OpFeedbackParam<Object[]> bidders) {
        if (registered.isEmpty()) {
            getObsProperty("phase").updateValue("aborted");
            defineObsProperty("abort_reason", "no_bidders");
            n.set(0);
            bidders.set(new Object[0]);
            log("Nenhum inscrito — leilão abortado.");
            return;
        }
        active.clear();
        active.addAll(registered);
        lastActive.clear();
        lastActive.addAll(registered);
        n.set(registered.size());
        bidders.set(registered.toArray());
        log("Inscritos: " + registered);
    }

    @OPERATION
    public void startRound(int r) {
        stayedThisRound.clear();
        getObsProperty("round").updateValue(r);
        getObsProperty("phase").updateValue("running");
        log("Rodada " + r + " — preço R$ "
            + getObsProperty("current_price").intValue());
    }

    @OPERATION
    public void stay() {
        String agent = getOpUserName();
        String phase = getObsProperty("phase").stringValue();
        if (!"running".equals(phase)) {
            failed("Stay fora de rodada ativa (phase=" + phase + ")");
            return;
        }
        if (!active.contains(agent)) {
            failed("Agente " + agent + " não está mais ativo");
            return;
        }
        stayedThisRound.add(agent);
    }

    @OPERATION
    public void leave() {
        String agent = getOpUserName();
        active.remove(agent);
        log(agent + " saiu do leilão.");
    }

    /**
     * Encerra a rodada corrente e devolve o status:
     *   "continue" — 2+ ficaram, preço sobe
     *   "winner"   — 1 ficou; Result = nome do vencedor
     *   "tie"      — 0 ficaram; Result = lista do round anterior (empate)
     */
    @OPERATION
    public void endRound(OpFeedbackParam<String> status,
                         OpFeedbackParam<Object> result) {
        // quem não confirmou stay sai
        active.retainAll(stayedThisRound);
        int k = active.size();
        log("Rodada encerrada. Ficaram: " + active);
        if (k >= 2) {
            lastActive.clear();
            lastActive.addAll(active);
            int p = getObsProperty("current_price").intValue();
            getObsProperty("current_price").updateValue(p + priceStep);
            status.set("continue");
            result.set("");
        } else if (k == 1) {
            String winner = active.iterator().next();
            status.set("winner");
            result.set(winner);
        } else {
            // empate: ninguém continuou — sorteia entre os do round anterior
            List<String> tied = new ArrayList<>(lastActive);
            String winner = tied.get(rng.nextInt(tied.size()));
            // preço regride um passo (preço da rodada anterior)
            int p = getObsProperty("current_price").intValue();
            getObsProperty("current_price").updateValue(p - priceStep);
            status.set("tie");
            result.set(winner);
            log("Empate entre " + tied + ". Sorteado: " + winner);
        }
    }

    @OPERATION
    public void declareWinner(String bidder, int price) {
        Atom bidderAtom = new Atom(bidder);
        defineObsProperty("winner", bidderAtom, price);
        getObsProperty("phase").updateValue("closed");
        log("VENCEDOR: " + bidder + " a R$ " + price);
    }

    @OPERATION
    public void abort(String reason) {
        getObsProperty("phase").updateValue("aborted");
        if (!hasObsProperty("abort_reason")) {
            defineObsProperty("abort_reason", reason);
        } else {
            getObsProperty("abort_reason").updateValue(reason);
        }
        log("Leilão abortado: " + reason);
    }

}
