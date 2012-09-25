---
layout: post
title: "Authentification LDAP avec Play! framework"
date: 2010-11-03 22:42
comments: true
categories: [framework, java, ldap, play, spring]
---

Il y a quelques semaines j’ai profité de l’écriture d’une petite application web, un outil interne dans ma boîte, pour essayer [Play! framework](http://www.playframework.org/). Chez nous l’authentification passant par un serveur LDAP centralisé, j’ai cherché à interfacer ce type d’authentification avec Play!

<!-- more -->

Le module Secure
================

C’est un module _built-in_ de Play! qui fournit un cadre pour l’authentification. Toutes les informations sont sur la [page de documentation du module](http://www.playframework.org/documentation/1.1/secure).

Il faut d’abord importer le module dans le fichier `application.conf`.

{% codeblock %}
# The secure module
module.secure=${play.path}/modules/secure
{% endcodeblock %}

Puis il faut importer les routes définies par le module Secure dans le fichier conf/routes

{% codeblock %}
# Import Secure routes
*      /                module:secure
{% endcodeblock %}

Cette ligne permet d’associer les routes `/login` et `/logout sur le contrôleur Secure.

On va ensuite sécuriser le contrôleur de l’application :

{% codeblock lang:java %}
package controllers;

import models.*;
import play.mvc.*;

@With(Secure.class) /* L'accès à ce contrôler nécessite une authentification */
public class Application extends Controller
{
    public static void index()
    {
        /* Render page */
    }
}
{% endcodeblock %}

Accéder à l’annuaire LDAP avec Spring LDAP
==========================================

Pour accéder à un LDAP en java il existe l’API JNDI mais je lui préfère [Spring LDAP](http://www.springsource.org/ldap). Pour ce que je veux faire cette API est plus simple à utiliser.

Pour utiliser Spring LDAP on va d’abord installer le module Spring pour Play!

{% codeblock %}
[jcs:~]$ play install spring
~        _            _
~  _ __ | | __ _ _  _| |
~ | '_ \| |/ _' | || |_|
~ |  __/|_|\____|\__ (_)
~ |_|            |__/
~
~ play! 1.1RC3, http://www.playframework.org
~
~ Will install spring-head
~ This module is compatible with: 1.0.1
~ Do you want to install this version (y/n)? y
~ Installing module spring-head...
~
~ Fetching http://www.playframework.org/modules/spring-head.zip
~ [--------------------------100%-------------------------] 625.0 KiB/s
~ Unzipping...
~
~ Module spring-head is installed!
~ You can now use it by add adding this line to application.conf file:
~
~ module.spring=${play.path}/modules/spring-head
~
{% endcodeblock %}

Après avoir importé le module Spring dans le fichier `application.conf, il faut ajouter dans le répertoire `/lib` les dépendances pour accéder à Spring LDAP. Je les ai téléchargées depuis le _repostiory_ maven central.

- [spring-ldap-1.3.0.RELEASE-all.jar](http://repo2.maven.org/maven2/org/springframework/ldap/spring-ldap/1.3.0.RELEASE/spring-ldap-1.3.0.RELEASE-all.jar)
- [spring-dao-2.0.8.jar](http://repo2.maven.org/maven2/org/springframework/spring-dao/2.0.8/spring-dao-2.0.8.jar)

Ensuite on va écrire un fichier `application-context.xml (à placer dans le répertoire `conf/) afin de créer, à la sauce Spring, les objets dont on aura besoin.

{% codeblock lang:xml %}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE beans PUBLIC "-//SPRING//DTD BEAN//EN" "http://www.springsource.org/dtd/spring-beans-2.0.dtd">
<beans>
  <bean id="contextSource" class="org.springframework.ldap.core.support.LdapContextSource">
    <property name="url" value="ldap://ldap.example.com" />
    <property name="base" value="dc=example,dc=com" />
  </bean>
  <bean id="ldapTemplate" class="org.springframework.ldap.core.LdapTemplate">
    <constructor-arg ref="contextSource" />
  </bean>
</beans>
{% endcodeblock %}

Ce fichier permet d’initialiser un contexte Spring et de créer deux objets :

- un `LdapContextSource où j’ai défini 2 paramètres : l’URL et la base (le Dinstinguished Name de la racine de l’arbre du LDAP). Le paramètre base est optionnel et dépend évidemment de la structure du LDAP contacté.
- un `LdapTemplate` : c’est l’objet qui va être injecté dans notre contrôleur Play!. Il prend le `LdapContextSource` en paramètre dans son constructeur (le tag `constructor-arg` est à mon avis plutôt explicite).

Personnaliser le mécanisme d’authentification
=============================================

Par défaut, le module Secure accepte n’importe quel couple login/mot de passe. En suivant la documentation, on écrit un nouveau contrôleur afin de personnaliser le mécanisme d’authentification.

{% codeblock lang:java %}
package controllers;

public class Security extends Secure.Security
{
    static boolean authenticate(String username, String password)
    {
        return true;
    }
}
{% endcodeblock %}

Certes pour le moment ce n’est pas mieux, l’authentification laisse encore passer tout le monde ; mais on va rapidement arranger ça.

Tout d’abord on ajoute une variable de type `LdapTemplate` qui sera injectée par le framework Spring en utilisant l’annotation `@Inject. Ensuite il n’y a plus qu’à faire un appel à [LdapTemplate.authenticate(...)](http://static.springsource.org/spring-ldap/docs/1.3.0.RELEASE/apidocs/org/springframework/ldap/core/LdapTemplate.html#authenticate(javax.naming.Name, java.lang.String, java.lang.String)) pour effectuer l’authentification.

{% codeblock lang:java %}
package controllers;

import javax.inject.Inject;
import org.springframework.ldap.core.DistinguishedName;
import org.springframework.ldap.core.LdapTemplate;
import org.springframework.ldap.filter.EqualsFilter;

public class Security extends Secure.Security
{
    @Inject private static LdapTemplate ldap;

    static boolean authenticate(String username, String password)
    {
        EqualsFilter filter = new EqualsFilter("uid", username);
        return ldap.authenticate(DistinguishedName.EMPTY_PATH, filter.encode(), password);
    }
}
{% endcodeblock %}

Les paramètres passés à `authenticate` sont à adapter selon les besoins :

- Le premier paramètre est la base de recherche des utilisateurs. Ici je fais une recherche globale sur le LDAP voilà pourquoi je passe un nom vide.
- Le deuxième paramètre est le filtre de recherche des utilisateurs. Dans mon LDAP, ce filtre est le traditionnel `uid=user_name`. Là aussi à adapter selon les cas ; je conseille la lecture de la javadoc de [org.springframework.ldap.filter.Filter](http://static.springsource.org/spring-ldap/docs/1.3.0.RELEASE/apidocs/index.html?org/springframework/ldap/filter/Filter.html) et ses sous-classes.

Et ensuite ?
============

Voilà c’est terminé, et j’avoue avoir été surpris par le peu de code nécessaire pour avoir quelque chose qui fonctionne. Il reste toutefois des choses à faire : utiliser les protocoles `https` et `ldaps` pour authentifier les serveur et éviter que les mots de passe se baladent en clair sur le réseau, ou encore lier des rôles des utilisateurs (avec l’annotation `@Check` décrite dans la documentation du module Secure) à des attributs de l’utilisateur récupérés dans le LDAP…

Si vous avez d’autres idées ou des remarques, n’hésitez pas à laisser un commentaire.
