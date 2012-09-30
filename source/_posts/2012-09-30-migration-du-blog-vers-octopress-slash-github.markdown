---
layout: post
title: "Migration du blog vers Octopress/Github"
date: 2012-09-30 07:34
comments: true
categories:
---

Voilà, succombant à l'effet de mode, j'ai moi aussi migré mon blog de Wordpress vers [Octopress](http://octopress.org/). Raz le bol de mon ancien hébergeur, des versions antédiluviennes de PHP, des mises à jour qui demandent un sacrifice rituel pour fonctionner et des tarifs exhorbitants. Désormais les pages sont statiques et c'est Github qui héberge.

Ce qui m'a plu dans Octopress c'est sa puissance associée à une grande simplicité. Les plugins fournis en standard couvrent déjà une grande palette des besoins, allant de la mise en forme des posts à l'intégration des média sociaux. Sans une grande connaissance de Ruby j'ai pu sans difficulté écire une micro extension permettant d'intégrer les présentations issues de Slideshare. J'ai également été très rapidement capable modifier le _template_ de base afin d'ajouter le support du bouton _Share_ de LinkedIn.

Le meilleur ce sont sûrement les quelques commandes bien pensées qui simplifient la vie du bloggueur : un coup de `rake new_post["…"]` et un nouveau template vierge est créé dans le répertoire contenant les posts. Je tape `rake generate` et le site est généré, `rake preview` le déploie sur un serveur web démarré pour l'occasion. Mais le plus fort est sans doute la commande `rake deploy` qui va magiquement générer puis publier le site sur github.

Après un weekend passé à migrer manuellement tous les posts (car aucun des outils de migration testés ne fonctionnait correctement), migrer les commentaires, migrer les quelques pages statiques, mettre à jour les DNS, _coding-stories.com_ a fait peau neuve. En espérant surtout trouver un peu plus de temps pour écrire.