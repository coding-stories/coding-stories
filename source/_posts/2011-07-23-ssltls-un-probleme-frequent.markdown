---
layout: post
title: "SSL/TLS : un problème fréquent"
date: 2011-07-23 16:59
comments: true
categories: [HTTPS, java, SSL, TLS]
---
Je viens de lire un post très intéressant sur le blog de [Ippon Technologies](http://www.ippon.fr/) qui met en lumière l’importance de la notion de chaîne de certificats.

Le [standard X.509](http://fr.wikipedia.org/wiki/X.509) est basé sur un modèle de confiance pyramidal :

{% img center /images/posts/X509TrustModel-20110723.png %}

En haut ce sont les racines de confiance (_trust anchors_), en bas les certificats des utilisateurs finaux (_end entity_) et au milieu on trouve les certificats des autorités de certification intermédiaires. Il faut garder à l’esprit que celui qui valide un certificat ne possède en général que la racine de confiance ; mais pour effectuer la validation il faut disposer de la chaîne de certificats au complet, c’est à dire le certificat final avec l’ensemble des certificats des autorités intermédiaires. Moralité : un certificat seul ne sert à rien, il faut toujours considérer la chaîne dans son ensemble.

L’article sur le blog de Ippon : <http://blog.ippon.fr/2011/07/23/pourquoi-firefox-ou-java-ne-reconnaissent-pas-ce-certificat-ssl-si-cherement-payee/>
