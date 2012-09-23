---
layout: post
title: "Améliorer la sécurité du développement avec Git"
date: 2011-11-21 09:01
comments: true
categories: [DVCS, git, security]
---
Quand on développe un produit de sécurité (firewall, VPN, application de chiffrement…) on cherche a donner confiance dans son produit et on est bien souvent amené pour cela à passer des certifications ([CSPN](http://www.ssi.gouv.fr/fr/certification-qualification/cspn/), [Critères Communs](http://www.commoncriteriaportal.org/), etc) et à ainsi prouver qu’on applique de «bonnes pratiques» de matière développement : gestion des bugs, tests, utilisation d’un SCM. Un point important est de montrer que le code source du produit est maîtrisé, c’est à dire qu’aucune modification, intentionnelle ou non, ne peut être intégrée au produit sans avoir été validé. Et pour cela [Git](http://git-scm.com/) est un outil qui peut réellement aider.

<!-- more -->

Subversion, probablement le SCM le plus utilisé aujourd’hui, impose un modèle de développement centralisé. Tous les développeurs poussent leurs modifications vers un unique dépôt central partagé. Ce modèle a plusieurs inconvénients quand on désire tracer les modifications dans la base de code.

D’abord il faut donner aux développeurs des droits d’accès suffisamment fins pour qu’ils puissent _commiter_ dans le dépôt, sans pour autant les autoriser à avoir accès à toute la base de code, tant en écriture qu’en lecture. Ensuite il faut suivre les modifications apportées au code par les équipes de développement. Il est possible de développer les nouvelles fonctionnalités ou corriger les bugs dans des branches, avec tous les problèmes de _merge_ qui peuvent survenir. On peut également forcer l’utilisation du numéros de référence d’un ticket du _bugtracker_ dans les messages de commits. Dans ce cas il faudra bien sûr compter avec les erreurs sur le numéro du ticket ou les oublis mais également avec la relecture de complexes et multiples _diff_… Et je ne parle pas de l’historique du dépôt qui devient simplement illisible.

Avec Git, le problème du workflow disparaît car vous pouvez l’adapter à votre façon de développer. On peut illustrer ça avec l’exemple du [modèle de développement du noyau Linux](http://fr.wikipedia.org/wiki/Processus_de_d%C3%A9veloppement_de_Linux) (schéma ci-dessous) : un développeur privilégié (le dictateur) est autorisé à écrire dans le dépôt de référence (_blessed repository_). Les développeurs clonent ce dépôt, et poussent leurs patchs vers des «développeurs de confiance» (les lieutenants). Les lieutenants valident ces modifications, le dictateur peut alors venir les chercher auprès des lieutenants. Le dictateur décide alors d’intégrer ou non ces modifications dans le dépôt de référence.

{% img center /images/posts/workflow-git-20111121.png %}

En outre, avec Git finis les multiples _commits_ pour implémenter une fonctionnalité : grâce au merge de branches et au rebase, le développeur est en mesure de ne livrer qu’un unique _commit_. De cette façon l’historique du dépôt est clair et propre mais surtout cela simplifie énormément la revue de code.

Pour finir j’ajoute également que Git permet de signer les _tags_ permettant ainsi de garantir l’origine de toutes les modifications du code importées dans le dépôt de référence.

En conclusion je terminerai sur le fait que ce que je raconte ici sur Git est également vrai pour d’autres DVCS tels que [Mercurial](http://mercurial.selenic.com/) ou [Bazaar](http://bazaar.canonical.com/) (à vérifier tout de même pour la signature des tags).

Quelques références :

- [A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/)
- [Pourquoi Git est Meilleur Que X](http://fr.whygitisbetterthanx.com/) (d’où est issu le schéma d’exemple de workflow)
- [Processus de développement de Linux](http://fr.wikipedia.org/wiki/Processus_de_d%C3%A9veloppement_de_Linux)
