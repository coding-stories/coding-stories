---
layout: post
title: "Java 7 : les nouveautés côté sécurité"
date: 2011-07-14 17:35
comments: true
categories: [elliptic curve, ECC, java, java7, security, SSL, TLS]
---
La sortie de Java 7 est imminente et on a déjà beaucoup parlé des grandes nouveautés de cette version (multi-catch, opérateur diamant, Fork/Join, opcode _invokedynamic_…). Mais Java 7 arrive également des tas de petites améliorations, nouveautés et corrections de bugs. Voilà donc un petit résumé des principales nouveautés de Java 7, côté sécurité.

<!-- more -->

Cryptographie sur les Courbes Elliptiques
=========================================

Java 7 est désormais livré avec le provider `SunEC` (`sun.security.ec.SunEC`) dédie à la cryptographie sur courbes elliptiques et fournissant un support natif à travers la bibliothèque `sunecc`. Jusqu’à présent la cryptographie sur courbes elliptique n’était disponible que par le provider `SunPKCS11` sous réserve de posséder un dispositif supportant ces algorithmes (carte à puce…) ou en utilisant le provider [Bouncy Castle](http://www.bouncycastle.org/).

Par exemple, obtenir un objet `Signature` pour l’algorithme ECDSA se fait de la façon suivante :

{% codeblock lang:java %}
Signature sg = Signature.getInstance("SHA1withECDSA");
System.out.println(sg.getProvider()); // affiche "SunEC version 1.7"
{% endcodeblock %}

SSL/TLS
=======

Attaque contre les algorithmes en mode CBC
------------------------------------------

L’implémentation TLS 1.1 a été mise à jour pour se protéger contre l’attaque décrite dans ce [document](http://www.openssl.org/~bodo/tls-cbc.txt).

Contrôle de la session TLS
--------------------------

De nouvelles classes et méthodes donnent un contrôle plus fin sur la connection TLS :

- [X509ExtendedTrustManager](http://download.java.net/jdk7/docs/api/index.html?javax/net/ssl/X509ExtendedTrustManager.html) (une implémentation de `TrsutManager`) permet d’accéder aux paramètres de la connection TLS pendant le _handshake_.
- [SSLParameters.setEndpointIdentificationAlgorithm](http://download.java.net/jdk7/docs/api/javax/net/ssl/SSLParameters.html#setEndpointIdentificationAlgorithm(java.lang.String)) permet de définir un algorithme de vérification de l’identité du serveur lors du _handshake_. Dans les versions précédentes, cette vérification ne se faisait que pour le protocole HTTPS et passait par l’interface `HostnameVerifier`. Désormais on peut l’effectuer au niveau de la couche TLS ; la bibliothèque standard fournit deux algorithmes de vérification : `HTTPS` et `LDAPS`. Malheureusement il ne semble pas possible d’ajouter d’autres algorithmes de vérification.
- L’utilisation des algorithmes rendus obsolètes (et déconseillés) dans les [RFC 4346](http://www.ietf.org/rfc/rfc4346.txt), [RFC 5246](http://www.ietf.org/rfc/rfc5246.txt) et [RFC 5469](http://www.ietf.org/rfc/rfc5469.txt) est désormais désactivée par défaut.

Support de SNI
--------------

SNI (Server Name Indication) est une extension ajoutée au protocole TLS et définie dans la [RFC 6066](http://www.ietf.org/rfc/rfc6066.txt). Cette extension contient le nom du serveur auquel le client veut accéder dans le message _ClientHello_. De cette façon le serveur sait immédiatement quel nom a été demandé et peut donc choisir quel certificat envoyer au client. Cela permet de configurer des _VirtuatHosts_ en HTTPS comme on le fait en HTTP. Auparavant chaque serveur HTTPS devait posséder sa propre adresse IP.

Il est facile de vérifier si l’extension SNI est supportée en envoyant une requête à l’URL <https://sni.velox.ch> :

{% codeblock lang:java %}
public static void main(String[] args) throws Exception {
    URL url = new URL("https://alice.sni.velox.ch");
    HttpsURLConnection con = (HttpsURLConnection)url.openConnection();
    BufferedReader reader = new BufferedReader(new InputStreamReader(con.getInputStream()));
    FileWriter writer = new FileWriter("index.html");
    while (true) {
        String line = reader.readLine();
        if (line == null) break;
        writer.append(line);
    }
    writer.close();
}
{% endcodeblock %}

Ouvrez ensuite le fichier `index.html` dans votre navigateur. On change l’URL de la requête en `bob.sni.velox.ch` ; avec Java 7 cela fonctionne correctement mais Java 6 lève une exception :

{% codeblock %}
Exception in thread "main" javax.net.ssl.SSLHandshakeException: java.security.cert.CertificateException: No subject alternative DNS name matching bob.sni.velox.ch found.
{% endcodeblock %}

En effet, `bob.sni.velox.ch` est un hôte virtuel, si l’extension SNI n’est pas envoyée lors du _handshake_ alors le serveur utilise l’hôte par défaut qui est `alice.sni.velox.ch` ; avec java 6 le code client échoue car le nom de l'hôte ne correspond pas au nom dans le certificat, ce qui explique l’erreur obtenue.

Des questions, des remarques, des éclaircissements ? N’hésitez pas poster un commentaire.

