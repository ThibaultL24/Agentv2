Bonjour moussaillon(ne) et bienvenue sur mon premier article sur Medium !
Ici, je vous explique comment installer la gem Stripe sur une application Rails et l’utiliser avec pour exemple un utilisateur, un produit, et une commande.
Cet article est en deux parties, la partie installation avec création du minimum nécessaire pour tester Stripe, puis un exemple avec une situation plus concrète.

Amusez-vous bien !

Pour ce tutoriel, je me suis basé sur le tutoriel en anglais disponible sur le site de Stripe.

Configuration
Avant tout, je vous présente ci-dessous les versions de Ruby et Rails sur lesquelles se base mon tutoriel :

Ruby : 2.7.1
Rails : 5.2.4.4
Les premiers pas
1_Créez une app rails à l’aide de la commande suivante :

$ rails new -d postgresql app_tuto_stripe

2_Déplacez-vous dans le dossier de l’application que vous venez de créer.
La partie -d postresql permet d’utiliser une base de donnée PostgreSQL (pour en savoir plus, rendez-vous sur PostgreSQL).

3_Pour créer votre base de données, lancez un $ rails db:create.

4_Dans le Gemfile, ajoutez les lignes suivantes :

gem 'dotenv-rails'
gem 'stripe'
gem 'table_print' 
stripe : permet d’effectuer un paiement ;
table_print : permet de faciliter la lecture de vos tables dans la console rails ;
dotenv-rails : permet d’utiliser des informations importantes depuis un fichier externe.
5_Pour installer ces gems, lancez un $ bundle install.

Installer stripe
Oui je sais, vous avez déjà installé la gem, mais malheureusement cela ne suffit pas ! Il faut préparer le terrain en ajoutant encore quelque lignes de code afin de pouvoir utiliser la gem plus concrètement.

Configurer l’application
1_Créez un fichier stripe.rb dans config/initializers et ajoutez-y les lignes suivantes :

Rails.configuration.stripe = {
  :publishable_key => ENV['PUBLISHABLE_KEY'],
  :secret_key      => ENV['SECRET_KEY']
}
Stripe.api_key = Rails.configuration.stripe[:secret_key]
2_Créez cette fois un fichier .env dans la racine de votre projet.

3_Pour que Git ignore ce fichier, dans le fichier .gitignore, ajoutez la ligne .env.

4_ Pour vous assurer que votre fichier est bien ignoré par git, remplissez le fichier .env avec du texte au hasard et lancez un $ git status . Si le fichier .env apparaît dans la liste, cela signifie que Git ne l’a pas ignoré.

ATTENTION : Si vous ne réalisez pas ces deux dernières étapes, vos clés se retrouveront en ligne et seront accessibles au public !

5_Dans le fichier .env, ajoutez les lignes suivantes :

PUBLISHABLE_KEY=pk_test_TYooMQauvdEDq54NiTphI7jx
SECRET_KEY=sk_test_4eC39HqLyjWDarjtT1zdp7dc
Ces clés sont des clés de test. Si elles ne fonctionnent pas, créez un compte sur le site de Stripe et générez vos propres clés de test.

Créer le CONTROLLER de commande
Entrez la commande :

$ rails g controller Orders new create

Cette commande va générer un CONTROLLER orders avec les actions/méthodes new et create ainsi que leur views.

Changer les routes
1_Ouvrez le fichier config/routes et supprimez les lignes :

get 'orders/new'
get 'orders/create'
2_À la place, ajoutez les lignes suivantes :

root 'orders#new'
resources :orders, only: [:new, :create]
Modifier le CONTROLLER
1_Ouvrez le fichier app/controllers/orders_controller.rb.

2_Dans la méthode create , ajoutez les lignes suivantes :

# Before the rescue, at the beginning of the method
@stripe_amount = 500
begin
  customer = Stripe::Customer.create({
  email: params[:stripeEmail],
  source: params[:stripeToken],
  })
  charge = Stripe::Charge.create({
  customer: customer.id,
  amount: @stripe_amount,
  description: "Achat d'un produit",
  currency: 'eur',
  })
rescue Stripe::CardError => e
  flash[:error] = e.message
  redirect_to new_order_path
end
# After the rescue, if the payment succeeded
Ce code crée un client Stripe, avec plusieurs paramètres dont l’email et le stripeToken. Le stripeToken concerne les informations liées à la carte bleue et permet de les garder en mémoire.
Ensuite, si le paiement fonctionne, ce code crée un charge avec :

customer qui représente le client avec les infos précédemment données ;
amount qui représente le montant de la transaction, en centimes. Pour un paiement de 5€, il faut indiquer à Stripe une valeur de 500 ;
description qui représente la description associée à cette transaction ;
currency qui représente la monnaie utilisée dans la transaction.
En cas d’échec de paiement, les erreurs sont stockées dans e puis renvoyées dans le flash vers la page de paiement new_order_path.

Par rapport au tutoriel de Stripe, j’ai ajouté un begin avant le rescue et un end après . Ces éléments permettent d’effectuer une action avant et après la transaction. Pour cela, ajoutez les lignes de codes avant le begin du rescueou après le end du rescue. Cela est utile lorsque vous souhaitez par exemple, enregistrer cette commande en base de données, vider un panier, ou autre !

Sans la présence de begin et end, rails considère le début du rescue à la ligne def create et son end au prochain end (ici, celui de la méthode create).

Modifier les VIEWS
Maintenant, place à la partie front de Stripe. Nous pourrons enfin observer à quoi ressemble cette gem !

1_Dans la VIEW orders/new.html.erb, ajoutez les lignes suivantes :

<%= form_tag orders_path do %>
<article>
  <% if flash[:error].present? %>
    <div id="error_explanation">
      <p><%= flash[:error] %></p>
    </div>
  <% end %>
  <label class="amount">
    <span>Amount: $5.00</span>
  </label>
</article>
<script src="https://checkout.stripe.com/checkout.js" class="stripe-button"
    data-key="<%= Rails.configuration.stripe[:publishable_key] %>"
    data-description="Achat d'un produit"
    data-amount="500"
    data-locale="auto">
</script>
<% end %>
Si le flash contient une ou plusieurs erreurs, ce code les affiche sur l’écran de l’utilisateur.
S’en suit l’affichage du montant du paiement, ici “$5.00” (nous verrons plus tard comment changer cette valeur et sa monnaie).
Enfin, un script qui affiche un bouton, et contient diverses informations :

Une clé data-key dont l’authenticité est vérifiée par Stripe lors du paiement ;
Une description data-description qui est le titre du formulaire de paiement ;
Un montant data-amount qui est affiché dans le formulaire de paiement ;
La variable data-locale est la langue dans laquelle le formulaire de paiement est présenté. La valeur par défaut de cette variable est auto, qui correspond à la langue locale de l’ordinateur de l’utilisateur. Pour changer de langue, remplacez cette valeur par la langue correspondante, par exemple "fr" pour le Français.
Qu’est-ce que le formulaire de paiement, me direz-vous ? Et bien c’est celui qui s’affiche après avoir cliqué sur le bouton de paiement. Il demande à l’utilisateur de renseigner son email, son numéro de carte bleue, la date d’expiration ainsi que le code de vérification à 3 chiffres de la carte.

2_Dans la VIEW orders/create.html.erb, ajoutez la ligne suivante :

<h2>Thanks, you paid <strong>$5.00</strong>!</h2>
Cette VIEW s’affiche si le paiement est réussi.

Tester sur un serveur local
Ça y est, vous pouvez enfin voir à quoi ressemble tout ceci autrement que comme des lignes de code dans tous les sens !

1_Pour cela, lancez un serveur local avec la commande :

$ rails server , ou $ rails s pour ceux qui sont à l’aise.

2_Ouvrez l’URL local de rails par défaut : http://localhost:3000/ dans votre navigateur web préféré.

La page de paiement ressemble à ceci :

Bout de page web avec un texte par défaut, un montant et un bout de paiement.
3_Super ! Cliquez sur le bouton de paiement. Voici ce qui s’affiche :

Formulaire de paiement décrit précédemment, avec un titre, les renseignements demandés et un bouton de confirmation
Vous pouvez voir les différentes informations dont je vous ai parlé précédemment, notament le titre de ce formulaire.

4_Pour tester ce formulaire, compléter les champs avec les informations suivantes :

Email : test@test.test (ou t@t.t si vous n’avez pas le temps pour ces sottises) ;
Numéro de carte bleue 4242 4242 4242 4242 ;
Mois et année, qu’importe tant que c’est dans le futur ;
CVV, ce que vous voulez tant que ce sont 3 chiffres ;
Cochez la case se souvenir de moi si vous ne souhaitez pas recopier ces informations tests encore et encore (et croyez-moi, vous en aurez besoin lorsque vous testerez Stripe dans un projet).

Si vous voyez ce message, ne paniquez pas et cliquez sur le bouton de retour en haut à gauche ou appuyez sur Échap pour revenir en arrière, et continuez votre chemin :)

5_Cliquez sur le bouton de paiement et… Tada ! Vous voici sur la page de confirmation de paiement. Si ce n’est pas le cas, revoyez les étapes une à une, et vérifiez que vous n’avez rien oublié.

Voici le contenu de la page :

Page de confirmation de paiement avec le montant de la transaction
Super, tout fonctionne ! Mais cela ne suffit pas, car nous ne voulons pas payer en $ mais en €, avec un montant dynamique dépendant du prix du produit, etc… Alors suivez-moi dans la deuxième partie de ce tuto qui vous montre comment faire ça sur un cas simple !

Exemple d’utilisation
C’est le moment de bidouiller cette gem ! Je vous montre en quelques étapes comment faire.

Créer les tables
Table des utilisateurs
Dans le terminal, entrez dans la commande :

$ rails g model User email nickname

Celle-ci crée un MODEL User et une migration create_users avec un email email et un pseudo nickname en string.

Table des produits
Entrez la commande :

$ rails g model Product title price:decimal

Celle-ci crée un MODEL Product et une migration create_products avec un titre title en string et un prix price en decimal .

Lancer la migration
Vous êtes prêt pour lancer vos migrations ! Pour cela :

1_Lancez un $ rails db:migrate.

2_Lancez un $ rails db:migrate:status.

3_Vérifiez que les deux migrations sont en up.

Et pour les commandes, pas de table “order” ?
Bonne question moussaillon(ne) ! Pour ce tuto, je vais me contenter de montrer comment Stripe fonctionne de façon minimaliste avec seulement un utilisateur et un produit. Je ne fais pas de liens entre les tables de la base de données, donc nul besoin d’une table des commandes qui permettraient de se souvenir des commandes passées !

Créer les objets
1_Pour ouvrir la console de Rails, lancez la commande $ rails console

2_Pour créer un utilisateur, entrez cette ligne :

$ u = User.create(email: test@test.test", nickname: "Bloup")
3_Pour vérifier que l’utilisateur est enregistré dans la base de données, lancez $ tp u. Ceci s’affiche :

Base de données montrant le premier utilisateur avec les informations saisies précédemment
L’utilisateur est donc bien enregistré dans la base donnée !

4_Ensuite, pour créer un produit, entrez cette ligne :

$ p = Product.create(title: "Stripe test product", price : 12.34)
5_Pour vérifier que le produit est enregistré dans la base de données, lancez $ tp p. Ceci s’affiche :

Base de données montrant le premier produit avec les informations saisies précédemment
Idem pour le produit, super !

Créer les liens entre le CONTROLLER et les VIEWS
Modifier le CONTROLLER
Vous allez déclarer les informations de vos deux objets au CONTROLLER.

1_Retournez sur le fichier app/controllers/orders_controller.rb.

2_Au début de la méthode create (avant @stripe_amount), ajoutez les lignes suivantes :

@user = User.first
@product = Product.first
@amount = @product.price
3_À la ligne du @stripe_amount , remplacez la valeur 500 par (@amount * 100).to_i.

Votre méthode create ressemble donc à ceci :

Lignes de code contenu dans la méthode create
Dans l’ordre, nous avons :

@user qui est le premier (et seul) utilisateur accessible depuis la base de données des utilisateurs ;
@product qui est le premier (et seul) produit accessible depuis la base de données des produits ;
@amount qui est le prix du produit en décimal ;
@stripe_amount qui est le montant qui est utilisé par Stripe, transformé en nombre entier (avec le .to_i) pour pouvoir être traîté.
4_Copiez les 4 lignes que vous venez d’écrire et collez-les dans la méthode new comme ceci :


Tout est prêt pour votre CONTROLLER !

Modifier les VIEWS
1_Dans la VIEW new.html.erb, remplacez toutes les lignes par les suivantes :

<h1>Bienvenue sur ma page de paiement, <%= @user.nickname %> !</h1>
<p>Vous avez choisi le produit <%= @product.title %>.</p>
<%= form_tag orders_path do %>
  <article>
    <% if flash[:error].present? %>
      <div id="error_explanation">
        <p><%= flash[:error] %></p>
      </div>
    <% end %>
    <label class="amount">
      <span>Son prix est de : <%= @amount %> €</span>
    </label>
  </article>
  <br/>
  <script src="https://checkout.stripe.com/checkout.js" class="stripe-button"
  data-key="<%= Rails.configuration.stripe[:publishable_key] %>"
  data-description="Achat d'un produit"
  data-amount=<%= @stripe_amount %>
  data-currency="eur"
  data-locale="auto"></script>
<% end %>
Vous avez ainsi utilisé les informations envoyées par l’action new du CONTROLLER orders afin de les afficher sur la page !
Prêtez attention au script de Stripe, j’y ai ajouté la ligne data-currency="eur". Ce code permet de personnaliser la monnaie affichée dans le formulaire. Par défaut, Stripe utilise le $usd. Cette action est complémentaire à l’étape 2 de la partie “Installer Stripe/Modifier le CONTROLLER”.

2_Dans la VIEW create.html.erb, remplacez toutes les lignes par les suivantes :

<h1>Votre paiement est confirmé.</h1>
<h2>Merci <%= @user.nickname %> pour votre achat de <strong><%= @amount %> €</strong> !</h2>
<p>Un email vous a été envoyé à <%= @user.email %> avec le récapitulatif de votre commande.</p>
Plus qu’à tester ce qu’on vient d’implémenter !
1_C’est reparti, relancez le serveur avec un rails s (si vous l’avez fermé entre-temps) et retournez sur votre navigateur préféré pour y voir une page fraîchement modifiée ! Voici à quoi elle ressemble :

Page de paiement avec affiché le pseudo de l’utilisateur, le titre du produit, son prix et le bouton de paiement
2_Cliquez sur le bouton de paiement, complétez le formulaire et confirmer le paiement. Voici la page que vous voyez :

Page de confirmation de paiement
C’est bon, tout fonctionne !

J’espère que ce tutoriel vous a aidé et qu’il vous a plu !

Intégrer Stripe version 2019
Comment passer de la version Legacy à la version 2019 de Stripe.

1. Introduction
Vous avez branché Stripe avec succès sur votre app Rails ? Bien joué 🔥 !

Dans ce cas, sauf bug dans la Matrice, vous devriez aboutir à une interface de paiement qui se présente comme ceci :

Illustration Legacy

Avec ça, vous pouvez déjà vous amuser à faire tout un tas de fake paiements sur votre site et voir le chiffre d'affaires s'accumuler sur votre dashboard Stripe 💰

Tant que vous utiliserez les clefs d'API Stripe réservées au test, ce sera toujours des données bidons, mais c'est quand même déjà la classe à Dallas 😎

Ceci étant dit...

Ce que nous avons ici est la version de Stripe Checkout dite "Legacy", a.k.a à l'ancienne, pour le paiement en ligne.

Alors, dans les paragraphes qui suivent, je vous propose d'intégrer Stripe version 2019, pour que vous ayez des formulaires de paiement BG sur votre site !

2. Historique et contexte
Stripe Checkout Legacy...

À l'époque où c'est sorti, c'était sans nul doute un truc de dingos 🤯, qui a apporté au fur et à mesure une âpre concurrence au mastodonte Paypal pour le paiement en ligne.
Globalement, l'implémentation dans une app Rails est plutôt (très) accessible, ce qui est avantageux pour nous autres moussaillons de THP si tant est que l'on souhaite se familiariser avec l'univers des APIs.
Mais aujourd'hui, cette version pose 2 problèmes majeurs :

Niveau Webdesign, on ne va pas se mentir, ça semble un poil vieillot tout ça. Je ne juge pas hein... Mais un peu quand même 🙈 Plus sérieusement, vous pouvez faire le test avec vos proches, et voir comment ils perçoivent le paiement via le bouton bleu turquoise, en comparaison à d'autres standards plus actuels (Google Pay, Apple Pay etc.)

Bien plus touchy encore que le côté cosmétique, il se trouve que les formulaires Legacy ne sont plus conformes aux normes européennes en matière de paiement en ligne 😱 Concrètement, sur Legacy, vous n'avez pas "3D Secure" (vous savez, le texto / notification de votre banque avant la suite du paiement en ligne). Donc imaginons que demain un client européen de votre boutique en ligne passe par là, eh bien il est fort probable que ce soit directement sa banque qui fasse blocus lors de l'étape tant attendue du paiement.

La bonne nouvelle dans tout ça : Stripe a évidemment prévu le coup avec une nouvelle version BG comme tout pour vos paiements en ligne 😎 :

Illustration Legacy

3. La ressource
Intégrer Legacy sur Rails, c'est plutôt easy grâce au tutoriel de Stripe à ce sujet. Par contre, pour partir sur la version 2019, je ne vous cache pas que c'est beaucoup plus complicado de savoir même par où commencer...

confused Travolta

No worries ! On va se refaire tout le cheminement en souplesse et d'ici peu vous saurez comment Intégrer Stripe version BG en 30 minutes top chrono.

Parce qu'à un moment donné on va pas se laisser aller avec Legacy sur notre app, c'est la team Rails ici quand même 🔥

3.1. Pas à pas en vidéo
Voici d'abord un tutoriel vidéo qui reprend toute la logique, les pré-requis et les séquences concrètes de code qui vous permettront d'intégrer la nouvelle version :

IMAGE ALT TEXT HERE

I see you celles et ceux qui préfèrent l'écrit, ça arrive juste après 😇

3.2. Pré-requis
Globalement, on est quasi sur les mêmes pré-requis techniques que ceux qui servent à faire fonctionner Stripe Checkout Legacy... Avec quelques nouveautés tout de même, ce serait pas drôle sinon 😁

Bref, voici ce qu'il vous faut :

3.2.1. Avoir un compte Stripe (merci Captain Obvious ❤️)
3.2.2. Récupérer les clefs d'API
Si vous arrivez à ceci sur votre propre tableau de bord Stripe, c'est bon signe. Vous pouvez récupérer les 2 clefs d'API qui serviront à mettre en route l'engin de paiement sur votre app :

illustration dashboard Stripe

3.2.3. Nouveauté - Ajouter un nom public d'entreprise à votre compte Stripe
Oui, ça peut paraître chelou cette histoire, mais il faut impérativement le faire, car ce nom apparaîtra entre autres sur les formulaires de paiement nouvelle génération.
Tant que vous serez sur des paiements fictifs réalisés via les clefs API de test, je ne vois vraiment pas où seraient les conséquences juridiques ici. Bref, vous pouvez y aller, même avec un nom 100% certifié fake dédié au test 👌
Par contre, pour des paiements réels évidemment la situation ne sera pas la même 😬 Merci Captain Obvious, Epidode 2
Vous devriez trouver easy où effectuer cette configuration. En comparaison avec d'autres gros logiciels en ligne, le dashboard de Stripe est plutôt facile à lire. Mais parce que ça me fait plaisir, voici la manip si besoin.
3.2.4. Configurer un fichier .env
Bon, à ce stade vous connaissez la musique : vu qu'on est sur des infos assez sensibles avec les clefs d'API, mieux vaut les stocker en lieu sûr dans un fichier .env, avec le .gitignore qui va avec.
Si besoin, vous pouvez toujours revenir sur cette ressource en lien avec le projet Twitter pour un tuto complet sur "dotenv" et un rappel de son utilité.
3.2.5. Configurer l'initializer Stripe
Même démarche que pour Legacy : il s'agit de créer un fichier stripe.rb dans config/initializers. et d'y ajouter les lignes suivantes :
  Rails.configuration.stripe = {
    :publishable_key => ENV['PUBLISHABLE_KEY'],
    :secret_key      => ENV['SECRET_KEY']
  }Stripe.api_key = Rails.configuration.stripe[:secret_key]
Bien entendu, il faudra que les dénominations PUBLISHABLE_KEY et/ou SECRET_KEY matchent avec les noms que vous avez choisis dans votre fichier .env pour stocker les clefs d'API.
3.2.6. Ajouter la Gem "Stripe" dans votre Gemfile
On programme avec du Ruby, donc évidemment qu'il y a une Gem qui va avec 💎

3.2.7. Nouveauté - Appeler les scripts BG de Stripe dans votre code HTML
Et pour finir, on va appeler une librairie de ressources gérées directement par Stripe : des scripts JS en béton armé qui feront parfaitement le taff pour charger les formulaires de paiement en ligne BG sur votre page.

Rien de foufou à coder ici : dans app/views/layouts/application, vous pouvez juste ajouter ceci quelque part dans votre balise <head> :

<script src="https://js.stripe.com/v3/"></script>
Ca y est ! Tout est prêt pour brancher Stripe nouvelle génération sur votre app 😍
3.3. Implémentation d'un "One-Time-Payment"
Allez, après toute cette mise en place, on va (enfin !) pouvoir coder concrètement la mise en route de l'engin de paiement sur notre app Rails 🔥

3.3.1. Créer les routes vers la session de paiement
Dans le fichier config/routes.rb, ajouter les lignes suivantes :
scope '/checkout' do
    post 'create', to: 'checkout#create', as: 'checkout_create'
    get 'success', to: 'checkout#success', as: 'checkout_success'
    get 'cancel', to: 'checkout#cancel', as: 'checkout_cancel'
end
Que se passe-t-il avec ces lignes de code ?
La ligne post 'create' va représenter la demande concrète de création d'une session sécurisée de paiement Stripe. Schématiquement, cette requête POST est envoyée à notre serveur, qui "fait suivre" le tout à Stripe via des appels d'API, qui lui-même nous renverra du contenu à l'écran.
Le système de Stripe veut que lors d'une session de paiement, on indique 2 URLs de redirection : une URL success sur laquelle on atterrit lorsque la session arrive à son terme, et une URL cancel lorsque la session est annulée par le client ou que le paiement échoue.
Mais dis-donc Jamy, qu'est-ce que c'est que ce machin de scope '/checkout' ?
La notion de scope, tout comme celle de namespace, peut être vue comme un "pack" de routes qui sera accompagné de son ou ses controllers.
Si le sujet vous branche, je vous laisse apprécier la différence entre scope et namespace.
Ici, j'ai choisi le scope pour minimiser la quantité de code à produire. Avec cette configuration de routes et un seul et unique controller checkout, j'aurai tout ce qu'il me faut pour exécuter le paiement sur mon app.
Et pourquoi ne pas avoir utilisé ce bon vieux resources ici ?
Ca pourrait sembler être une bonne idée... Mais en fait pas tant que ça 😅
Je m'explique : dans mon scope checkout, j'ai déjà mes deux routes customisées successet cancel, qui sortent des clous si on utilise un resources.
Par ailleurs, en partant sur un resources, on crée par défaut des actions "edit", "update", "delete" etc. qui n'ont pas vraiment lieu d'être ici. Bon chance si vous voulez permettre à l'utilisateur d'éditer ses infos de paiement sur Stripe avec un combo edit/update 😅
Bref, la seule route du schéma de resources qui compte, c'est la ligne post 'create', donc autant s'en contenter !
3.3.2. Ajouter un bouton de paiement qui crée la session Stripe
À ce stade, vous avez sans doute déjà une view HTML disponible avec votre produit à payer, ou alors un "panier" composé de plusieurs produits, si vous êtes dans une logique de boutique en ligne.
Voici donc du code que vous pouvez ajouter en bas de votre page HTML pour intégrer un bouton de paiement créant la session Stripe :
<%= button_to "Passer commande (NEXT GEN)", checkout_create_path(total: MONTANT À PAYER), class: "btn btn-primary", remote: true %>
Quelques subtilités :
button_to permet d'exécuter sans problème la requête POST, a.k.a l'action de créer la session. For some reason, si on met un link_to ça ne fonctionnera pas 😭
Il est important ici de passer comme argument un MONTANT À PAYER.
Charge à chacun donc d'extraire le prix du produit/panier et de l'insérer ici.
Dans le contexte de la boutique en ligne, nous avions codé ceci : (total: @cart.total). Cela permettait de récupérer le montant final du panier de l'utilisateur, afin que le paiement soit basé sur un prix cohérent.
Si vous ne l'avez pas encore codé, en attendant, vous pouvez toujours écrire en dur : (total: 10). De cette façon, le produit vaudra 10 euros dans le paiement effectué sur le formumaire Stripe.
Enfin, remote: true est une requête AJAX, qui s'avèrera indispensable pour "injecter" du code Javascript dans notre page HTML. Et ce code Javascript... est tout simplement le formulaire de paiement Stripe lui-même ! Bref, impossible de s'en passer 😁
⚠️ ALERTE ERREUR COMMUNE
Il est possible que ton bouton ne fonctionne pas correctement, en effet en Rails 7, Ajax n'est plus, il est remplacé par Hotwire (qui est le nouveau Ajax) et son système Turbo, mais pourquoi le garder dans la ressource alors ? Car c'est toujours bon de savoir comment cela fonctionnait avant, si jamais on tombe sur un ancien code que l'on doit modifier, en temps qu'employé en entreprise ou que freelance !

Du coup au lieu d'utiliser un remote: true pour faire une requête AJAX, il te suffit de faire un data: {turbo: false} pour désactivé Turbo qui nous ennuie un peu sur cette requête. De ce fait ton button_to, devrais ressembler a cela :

<%= button_to "Passer commande (NEXT GEN)", checkout_create_path(total: MONTANT À PAYER, event_id: ID POUR LA METADATA), class: "btn btn-primary", data: {turbo: false} %>
En cas de souci, n'hésites pas à faire tes propres recherches sur Google, j'ai trouvé comment régler ce souci avec quelques recherches et en 5 minutes je suis arrivé sur ce post de stackoverflow.

3.3.3. Ecrire les méthodes du controller "checkout"
On commence avec un petit rails generate controller checkout pour avoir le fichier à disposition.
Et voici donc ce que vous pouvez ajouter dans app/controllers/checkout.rb :
class CheckoutController < ApplicationController
  def create
    @total = params[:total].to_d
    @event_id = params[:event_id]
    @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'eur',
            unit_amount: (@total*100).to_i,
            product_data: {
              name: 'Rails Stripe Checkout',
            },
          },
          quantity: 1
        },
        metadata: {
          event_id: @event_id
        },
      ],
      mode: 'payment',
      success_url: checkout_success_url + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: checkout_cancel_url
    )
    redirect_to @session.url, allow_other_host: true
  end

  def success
    @session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @payment_intent = Stripe::PaymentIntent.retrieve(@session.payment_intent)
    @event_id = @session.metadata.event_id
  end

  def cancel
  end
end
La méthode success n'est pas encore totalement fonctionnelle. À toi de la compléter en créant une Attendance dans celle-ci à la suite du code. Tu pourras ensuite faire la méthode cancel en suivant un procédé relativement similaire en t'aidant de la documentation officielle pour gérer les cas où il aurait un échec ou une annulation lors du paiement.

Quelques subtilités :
Notre montant total à payer, passé tout à l'heure en argument dans le bouton de paiement, est de retour ici : @total = params[:total].to_d.
Comme indiqué précédemment, le système Stripe demande de paramétrer des URLs de redirection success et cancel, que l'on retrouve codées dans la méthode "create".
Le code @session de la méthode "success" vise à extraire de l'info sur la session de paiement qui vient d'avoir lieu. Le code @payment_intent, quant à lui, vise à extraire le montant qui a réellement été payé par l'utilisateur. Logique, nous sommes sur la page success, donc forcément celà signifie que l'utilisateur aura bien payé son produit.
Mais dis-donc Jamy, pourquoi ne pas avoir mis de code @payment_intent dans la méthode "cancel", comme tu l'as fait dans la vidéo ?
En effet cher viewer, votre vision d'aigle m'impressionne ! Dans le pas à pas en vidéo, j'ai écrit dans la méthode "cancel" du code tout à fait équivalent à "success".
Et alors, c'était une bonne idée ? Oui, mais non 😱 !
Je m'explique : quand un utilisateur est redirigé sur "cancel", cela signifie :
Que le paiement a échoué lors de la session.
OU ALORS, qu'il a simplement appuyé sur un bouton "Annuler" qui apparaît quelque part sur le formulaire avant même de procéder au paiement... Et voilà précisément tout le problème de coder un @payment_intent ici : la session n'a jamais réellement commencé, donc votre programme ne va rien capter si on lui demande tout à coup de publier à l'écran un @payment_intent qui n'existe pas 😬
Bref, je vous laisse gérer cette méthode "cancel" du controller et y mettre du code plus adéquat si cela s'avère pertinent.
3.3.4. Ajouter du contenu dans les views "checkout"
Allez, on y est presque ! Il ne nous reste plus qu'à ajouter un peu de contenu dans un dossier app/views/checkout 🔥 Le code ci-dessous devrait parler de lui-même :

Fichier success.html.erb html <div class="container text-center my-5"> <h1>Succès</h1> <p>Nous avons bien reçu votre paiement de <%= number_to_currency(@payment_intent.amount_received / 100.0, unit: "€", separator: ",", delimiter: "", format: "%n %u") %>.</p> <p>Le statut de votre paiement est : <%= @payment_intent.status %>.</p> </div>
Fichier cancel.html.erb html <div class="container text-center my-5"> <h1>Echec</h1> <p>Le paiement n'a pas abouti.</p> </div> ---
Et voilà ! Vous pouvez tester : sauf bug majeur dans la Matrice, vous avez maintenant un engin de paiement Stripe nouvelle génération et fonctionnel branché sur votre app Rails 🎉🎉🎉