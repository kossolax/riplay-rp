<div class="container-fluid">
        <div class="row">
            <center style="padding-top: 25px">
                <h2>Liste des filleuls<b></h2>
            </center>

                <table class="table" style="width: 500px; margin-left: auto; margin-right: auto; margin-top: 40px;">
                  <thead>
                    <tr>
                        <th>Pseudo:</th>
                        <th></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr ng-repeat="item in data">
                      <td>
                       <a href="https://rpweb.riplay.fr/#/user/{{item.steamid}}">{{item.name}}</a>
                      </td>
                      <td>
                        <div ng-show="item.approuved"><span style="color: green">Validé, récompense reçue</span></div>

                        <div ng-show="!item.approuved">
                            <div ng-show="item.canvalidate">
                                <button class="btn btn-success" ng-click="validate(item.steamid)">Récupérer ma récompense</button> <span style="color: red">{{errmessage}}</span>
                            </div>

                            <div ng-show="!item.canvalidate">
                                <div class="text-danger">{{ item.progress / 100 * 20 | number : 1 }} / 20 heures</div>
                            </div>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
        </div>
</div>
