---
layout: post
title: "SSL/TLS en Java – Partie 1"
date: 2011-07-02 21:45
comments: true
categories: [HTTP, HTTPS, java, SSL, TLS]
---
J’ai pensé appeler cet article «_Pourquoi SSL ne marche pas ?_». En effet j’ai lu beaucoup de questions sur des forums posées par des développeurs qui n’arrivaient pas à faire fonctionner SSL entre le serveur et les clients ; le plus souvent le développeur ne sait pas très bien comment fonctionne le protocole et il n’arrive pas à diagnostiquer les problèmes ; j’espère que cette série article aidera ceux qui se battent encore avec les erreurs du type `alert=42` (si si, je vous assure que c’est une vraie erreur :)).

<!-- more -->

SSL en quelques mot
===================

D’abord un peu de vocabulaire, on lis souvent SSL, TLS ou encore SSL/TLS. Pour faire court, tout ça c’est la même chose. Pour entrer un peu dans les détails, SSL a été inventé par Netscape qui publia SSL 2.0 en 1995 puis SSL 3.0 en 1996. Puis ce fut le [TLS Working Group](http://datatracker.ietf.org/wg/tls/) membre de l’IETF qui repris le standard en publiant TLS 1.0 (aussi appelé SSL 3.1) en 1999, TLS 1.1 en 2006 et TLS 1.2 en 2008. Pour la petite histoire, SSL apparait toujours dans TLS car la structure de données contenant le numéro de version du protocole vaut 3.1 pour TLS 1.0, 3.2 pour TLS 1.1 et 3.3 pour TLS 1.2.

Mais finalement à quoi ça sert exactement ? SSL fournit un canal sécurisé entre un client et un serveur en fournissant les services suivants :

- chiffrement des messages
- intégrité des message (utilisation d’un [_Message Authentication Code_](http://fr.wikipedia.org/wiki/Code_d%27authentification_de_message))
- authentification du serveur (basée sur des certificats X.509)
- authentification du client (optionnelle)

À noter que, _stricto sensu_, le serveur n’est pas obligé de s’authentifier auprès du client et que l’usage de certificats X.509 n’est pas obligatoire. Cependant il s’agit de cas d’utilisation marginaux.

Un peu de Java
==============

Le support de SSL en Java a d’abord été fournit sous forme d’une extension la _Java Secure Socket Extension_ ou JSSE ; à partir de Java 1.4, la JSSE a été incluse dans la bibliothèque standard. L’API de la JSSE est couverte par les packages java suivants : javax.net, javax.net.ssl et javax.security.cert.

Alors, comment s’en sert on ? L’API JSSE a introduit la classe javax.net.ssl.SSLSocket, une sous-classe de java.net.Socket qui encapsule toute la complexité du protocole SSL. On ne peut pas instancier directement de `SSLSocket` car son constructeur est _protected_, il faut aller passer par une autre class de la JSSE `javax.net.ssl.SSLSocketFactory`.

{% codeblock lang:java %}
SocketFactory sf = SSLContext.getDefault().getSocketFactory();
Socket socket = sf.createSocket("www.example.com", 443);
{% endcodeblock %}

Sur le web on va plutôt utiliser le [protocole HTTP/S](http://fr.wikipedia.org/wiki/Https#HTTPS) ; la JSSE fournit le handler `javax.net.ssl.HttpsURLConnection` qui permet de gérer ces URL en `https://`. L’utilisation devient alors complètement transparente :

{% codeblock lang:java %}
URL url = new URL("https://www.example.com");
URLConnection conn = url.openConnection();
System.out.println(conn instanceof HttpsURLConnection); // affiche "true"
{% endcodeblock %}

Voilà un schéma tiré de la documentation officielle d’Oracle qui montre les relations entre les classes de la JSSE.

{% img center /images/posts/jsseclasses-20110702.jpg %}

La classe centrale est [SSLContext](http://download.oracle.com/javase/6/docs/api/javax/net/ssl/SSLContext.html) et c’est par cette classe que passe la configuration de SSL. Le code va alors ressembler à ça :

{% codeblock lang:java %}
SSLContext ctx = SSLContext.getInstance("TLS");
/* ici on configure le contexte SSL */
// ctx.init(... parameters ...);
SSLSocketFactory sf = ctx.getSSLSocketFactory();
/* on configure la socket factory utilisée pour les connexions aux URLs en https:// */
HttpsURLConnection.setDefaultSSLSocketFactory(sf);
{% endcodeblock %}

Question de confiance
=====================

Avec SSL tout est une question de confiance. Lors du _handshake_ le serveur envoie son certificat (pour être plus précis, une chaîne de certificat qui contient également toutes les autorités de certification intermédiaires) au client qui doit le valider. La validation de ce certificat implique de relier la chaîne de certificats du serveur à une racine de confiance (ou _trust anchor_).

La bibliothèque standard Java est livrée avec une liste de d’autorités racines qui se trouve un fichier de type `KeyStore`. Sur ma machine (un Mac) le fichier se trouve là :
`/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home/lib/security/cacerts`

On peut obtenir la liste de ces autorités avec l’outil `keytool`

{% codeblock %}
keytool -list -keystore cacerts
{% endcodeblock %}

Ici le mot de passe demandé ne sert qu’à vérifier l’intégrité du fichier, il n’y a pas de clés dont il faut protéger la confidentialité ; et par défaut le mot de passe est changeit.

Cependant il peut arriver que le serveur contacté n’ait pas de certificat signé par une autorité reconnue (test, application sur un intranet, pas d’argent pour s’acheter un certificat…). Arrive alors inéluctablement cette erreur :

{% codeblock %}
Exception in thread "main" javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
{% endcodeblock %}

Que s’est il passé ? Le message de l’erreur nous indique qu’il a été impossible de trouver un chemin de certificats valide pour le certificat du serveur.

Le mécanisme de validation d’une chaîne de certificat est accessible via un `TrustManager`, et la classe `TrustManagerFactory` permet d’en créer une instance. Pour régler notre problème il faut donc un `TrustManager` qui prenne en compte notre nouvelle autorité racine.

Première solution, ajouter l’autorité au fichier `cacerts`. Dans ce cas l’autorité racine pourra être utilisée par le `TrustManager` par défaut. Pas terrible pour faire des tests mais c’est une solution envisageable quand on a une PKI interne.

Seconde solution : utiliser un `TrustManager` dédié qui fait confiance à notre nouvelle autorité. D’abord il faut créer un `KeyStore` contenant notre racine. Cela se fait simplement avec `keytool` :

{% codeblock %}
keytool -importcert -trustcacerts -noprompt -alias myTrustAnchor -file /path/to/my/root.crt -keystore /path/to/my/keystore
{% endcodeblock %}

L’option `-trustcacerts` permet de créer une entrée de type `TrustedCertificateEntry` dans le _key store_.

Ensuite, il existe deux options. Soit on demande au `TrustManager` par défaut d’utiliser notre _key store_ ; dans ce cas on le déclare en passant une variable d’environnement à la JVM :

{% codeblock %}
java -Djavax.net.ssl.trustStore=/path/to/my/keystore -jar ...
{% endcodeblock %}

Seconde solution, on instancie un TrustManager configuré avec notre key store de façon programmatique :

{% codeblock lang:java%}
/* instancier le KeyStore */
KeyStore ks = KeyStore.getInstance("JKS");
ks.load(new FileInputStream("/path/to/my/keystore"), null);
/* initialiser une TrustManagerFactory avec ce KeyStore */
TrustManagerFactory tmf = TrustManagerFactory.getInstance("PKIX");
tmf.init(ks);
/* créer un SSLContext utilisant cette TrustManagerFactory */
SSLContext ctx = SSLContext.getInstance("TLS");
ctx.init(null, tmf.getTrustManagers(), null);
{% endcodeblock %}

Prenez le contrôle
==================

Jusqu’à présent on a pu configurer la source des racines de confiance ; on peut donc utiliser des certificats émis par n’importe qui. Mais alors que vous venez de finir cette configuration voilà une nouvelle erreur :

{% codeblock %}
Exception in thread "main" javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path validation failed: java.security.cert.CertPathValidatorException: revocation statut check failed: no CRL found
{% endcodeblock %}

Et oui, le certificat auto-signé que vous aviez bricolé sur le coin d’une console ne contient pas les informations permettant de le valider ; en l'occurence impossible ici de déterminer si ce certificat a été révoqué ou non. Le problème est que le comportement par défaut du `TrustManager` et de rejeter tout certificat dont le statut de révocation n’a pu être établi.

Pour passer outre ce comportement et pouvoir utiliser notre certificat de test il faudrait pouvoir désactiver cette vérification du statut de révocation du certificat dans le `TrustManager`. L’API permet une configuration plus fine des paramètres de validation, cela passe par la classe [PKIXBuilderParameters](http://download.oracle.com/javase/6/docs/api/java/security/cert/PKIXBuilderParameters.html).

`PKIXBuilderParameters` permet de configurer le comportement de la validation de chaînes de certificats en lui passant un certain nombre de paramètres parmi lesquels :

- la liste des racines de confiance (sous forme d’un `KeyStore` ou d’un `Set` de ``TrustAnchor`)
- la date à laquelle on fait la validation (par défaut, la validation est faite à la date courante)
- si on doit vérifier le statut de révocation des certificats
- des magasins de certificats et de listes de révocation supplémentaires au cas où (par exemple un serveur LDAP ou seraient publiées des listes de révocation)
- et d’autres…

Comment régler notre problème de vérification du statut de révocation ? En construisant un `PKIXBuilderParameters` qui ne fait pas cette validation :

{% codeblock lang:java %}
KeyStore st = KeyStore.getInstance("JKS");
/* ... */
PKIXBuilderParameters params = new PKIXBuilderParameters(ks, null);
/* désactivation la révocation */
params.setRevocationEnabled(false);
TrustManagerFactory tmf = TrustManagerFactory.getInstance("PKIX");
tmf.init(new CertPathTrustManagerParameters(params));
SSLContext ctx = SSLContext.getInstance("TLS");
ctx.init(null, tmf.getTrustManagers(), null);
{% endcodeblock %}

Dans cet exemple la vérification du statut de révocation a été désactivée ; c’est acceptable dans le cas d’un test mais fortement déconseillé dans un contexte de production. Dans le cas courant l’algorithme de validation va chercher dans le certificat l’URL où il peut télécharger la liste de révocation de l’autorité qui a émis ce certificat. La liste de révocation (CRL pour _Certificate Revocation List_ en anglais) contient, pour simplifier, la liste des numéros de série des certificats qui n’ont pas encore expirés mais qui ont été révoqués par leur porteur. Pour certaines autorités émettant beaucoup de certificats ces CRL peuvent atteindre plusieurs Mo, voire plusieurs dizaines de Mo.

Pour réduire la consommation de bande passante, le standard OCSP (_Online Certificate Status Protocol_, spécifié dans la [RFC 2560](http://tools.ietf.org/html/rfc2560)) a été inventé. Il s’agit d’un protocole qui permet de demander à une serveur (habituellement appelé _répondeur OCSP_) de façon interactive le statut de révocation d’un unique certificat. La réponse peut être « valide », « invalide » ou « inconnu » (comprendre que le serveur n’a pas l’information pour répondre).

Par défaut OCSP n’est pas utilisé pour la validation. Pour l’activer il faut soit modifier le fichier `java.security`, soit l’activer de façon programmatique dans le code :

{% codeblock lang:java %}
Security.setProperty("ocsp.enabled", "true");
{% endcodeblock %}

Si OCSP est activé alors l’algorithme de validation essaie d’abord de l’utiliser et repasse sur les CRL en cas d’échec, par exemple si le certificat n’indique pas de répondeur OCSP à contacter. Il est également possible de préciser l’une URL d’un répondeur OCSP à toujours contacter ; cela peut être utile dans le cas d’un répondeur OCSP installé en proxy dans une entreprise.

{% codeblock lang:java %}
Security.setProperty("ocsp.responderURL", "http://ocsp.example.net");
{% endcodeblock %}

Conclusion temporaire
=====================

J’ai fait le tour, un peu succinctement j’avoue, sur la validation du certificat du serveur. Mais il reste beaucoup à dire sur SSL : authentification du client, les _ciphers suites_, d’autres APIs… Ce sera l’objet d'une seconde partie.

