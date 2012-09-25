---
layout: post
title: "Signer les JARs avec maven"
date: 2010-09-02 23:09
comments: true
categories: [java, maven, maven-jarsigner-plugin, maven-release-plugin]
---

Après avoir vu cette [question](http://stackoverflow.com/questions/3598424/jar-signing-strategy-in-maven-projects) sur stackoverflow j’ai pensé que présenter la façon dont je gère la signature de code avec maven pouvait en intéresser certains.

<!-- more -->

Utiliser deux _keystores_
=========================

Tout d’abord il s’agit de produire un keystore pour le développement ; soit un certificat auto-signée, soit un certificat émis par une PKI interne à votre organisation si d’aventure vous en disposez une. Appelons le `dev.keystore. Ce keystore va être enregistré dans le SCM et de cette façon le serveur d’intégration continue pourra signer les builds de développement.

Le deuxième keystore contiendra la clé de production, c’est-à-dire un certificat signé par une autorité de certification délivrant des certificats de signature de code. Comptez entre 100 et 300€/an. Appelons le `prod.keystore. Idéalement ce keystore sera conservé en sécurité et protégé par un mot de passe sûr, connu uniquement des personnes autorisées (par exemple le responsable des releases).

Pour les détails de la génération de la clé et l’obtention d’un certificat je vous laisse regarder la [documentation de keytool](http://download.oracle.com/javase/6/docs/technotes/tools/solaris/keytool.html).

Configurer maven
================

Le plugin maven-jarsigner-plugin comme son nom l’indique permet de signer des jar. Comme il est lié par défaut à la phase _package_ de maven il sera appelé automatiquement une fois le jar généré. Configurons-le.

{% codeblock lang:xml %}
  <build>
    <plugins>
      <plugin>
        <artifactId>maven-jarsigner-plugin</artifactId>
        <version>1.2</version>
        <executions>
          <execution>
            <goals>
              <goal>sign</goal>
            </goals>
          </execution>
        </executions>
        <configuration>
          <keystore>${keystore.path}</keystore>
          <storetype>${keystore.type}</storetype>
          <alias>${keystore.alias}</alias>
          <storepass>${keystore.store.password}</storepass>
          <keypass>${keystore.key.password}</keypass>
        </configuration>
      </plugin>
    <plugins>
  <build>
  ...
  <properties>
    <keystore.path>dev.keystore</keystore.path>
    <keystore.type>JKS</keystore.type>
    <keystore.alias>signingKey</keystore.alias>
    <keystore.password>changeit</keystore.password>
    <keystore.store.password>${keystore.password}</keystore.store.password>
    <keystore.key.password>${keystore.password}</keystore.key.password>
  </properties>
{% endcodeblock %}

Ensuite dans le fichier `${HOME}/.m2/settings.xml` on définit un profil codesigning :

{% codeblock lang:xml %}
<settings>
  <profiles>
    <profile>
      <id>codesigning</id>
      <properties>
        <keystore.path>~/private/prod.keystore</keystore.path>
        <keystore.alias>codesigning</keystore.alias>
        <keystore.type>JKS</keystore.type>
        <keystore.store.password>${keystore.password}</keystore.store.password>
        <keystore.key.password>${keystore.password}</keystore.key.password>
        <keystore.password>aVeryStringPassword</keystore.password>
      </properties>
    </profile>
  </profiles>
</settings>
{% endcodeblock %}

Désormais pour signer avec la clé de production il suffit de lancer maven avec le bon profil.

{% codeblock %}
mvn clean install -Pcodesigning
{% endcodeblock %}

Si vous être parano, il est possible de ne pas mettre le mot de passe dans le fichier `settings.xml`. Dans ce cas on le passe à maven en paramètre.

{% codeblock %}
mvn clean install -Pcodesigning -Dkeystore.password=aVeryStringPassword
{% endcodeblock %}

Faire une release
=================

La version stable du produit se doit d’être signée par la clé de production. Pour cela on passe le profil au plugin release :

{% codeblock %}
mvn release:perform -Darguments="-Pcodesigning -Dkeystore.password=aVeryStringPassword"
{% endcodeblock %}

Et comme je trouve cette syntaxe peu agréable à utiliser, j’ai configuré le plugin dans le `pom.xml`.

{% codeblock lang:xml %}
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-release-plugin</artifactId>
  <version>2.0</version>
  <configuration>
    <arguments>-Pcodesigning -Dkeystore.password=${keystore.password}</arguments>
    <goals>deploy</goals>
    <useReleaseProfile>false</useReleaseProfile>
  </configuration>
</plugin>
{% endcodeblock %}

de cette façon on peut se contenter d’appeler cette commande :

{% codeblock %}
mvn release:perform -Dkeystore.password=aVeryStringPassword
{% endcodeblock %}