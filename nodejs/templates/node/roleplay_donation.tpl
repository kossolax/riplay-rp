<div class="container-fluid">
        <div class="row">
                <center>
                        <img src="/images/paypal2.png" width="200" style="padding-top: 40px"/>
                <br clear="all">
                <div style="padding-top: 40px;padding-right: 250px;padding-left: 250px;font-size:15px;">
                        La validation s'effectue automatiquement à la fin de votre paiement.
                         <div style="padding-top: 10px">
                        Cependant, des vérifications sur votre identité peuvent vous-être demandée afin de vérifier que vous êtes bien
                        le propriétaire de votre compte PayPal.
                        </div>
                        <div style="color:red; padding-top: 10px">Merci de bien vouloir prendre connaissance de notre règlement et politique des donations en cliquant <a href="https://forum.riplay.fr/index.php?/forum/69-r%C3%A8glement-politique-des-donations/">ici</a></font>
                </div>
                </center>
                <br clear="all">
                <center style="padding-top: 20px">
                        <h2>Montant:</h2>
                </center>
                <form id="ppBtnForm" action="https://www.paypal.com/cgi-bin/webscr" method="POST">
                        <input type="hidden" name="cbt" value="">
                        <input type="hidden" name="cmd" value="_xclick">
                        <input type="hidden" name="receiver_email" value="donations@riplay.fr">
                        <input type="hidden" name="business" value="donations@riplay.fr">
                        <input type="hidden" name="quantity" value="1">
                        <input type="hidden" name="item_name" value="Achat de {{(ppAmount*0.966-0.35)*1000}}$RP">

                        <div class="row">
                                <div class="form-inline text-center">
                                        <input autocomplete="off" class="form-control" type="number" name="amount" value="{{ppAmount}}" ng-model="ppAmount" min="1" ng-min="1"/>
                                       
                                        <input class="form-control" type="submit" value="Envoyer {{ppAmount}}€ pour recevoir {{(ppAmount*0.966-0.35)*1000}} $RP" />
                                </div>
                        </div>
                        <input type="hidden" name="return" value="https://rpweb.riplay.fr/index.php?page=money&paypal_done=1">
                        <input type="hidden" name="cancel_return" value="https://rpweb.riplay.fr/index.php?page=money&paypal_cancel=1">
                        <input type="hidden" name="on1" value="SteamID">
                        <input type="hidden" name="os1" maxlength="200" value="{{steamid}}">
                        <input type="hidden" name="notify_url" value="https://rpweb.riplay.fr/ipn.php">
                        <input type="hidden" name="currency_code" value="EUR">
                        <input type="hidden" name="lc" value="FR">
                </form>
        </div>
        <div class="row">
            <center style="padding-top: 25px">
                <h2>Le montant minimum d’entrée est de : <b><span style="color: #15A4EB">{{needed}}€</span></b></h2>
            </center>

                <table class="table" style="width: 500px; margin-left: auto; margin-right: auto; margin-top: 40px;">
                  <thead>
                    <tr>
                        <th>Position:</th>
                        <th>Joueur:</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr ng-repeat="item in data">
                      <td style="font-weight: bold;">
                        #{{item.pos}}
                      </td>
                      <td>
                      <a href="https://steamcommunity.com/profiles/{{item.steamid}}">{{item.name}}</a>
                        </td>
                    </tr>
                  </tbody>
                </table>
        </div>
</div>