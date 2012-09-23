---
layout: post
title: "Exclure certaines classes de la couverture des tests unitaires"
date: 2012-01-30 21:39
comments: true
categories: [cobertura, maven-cobertura-plugin, sonar, test]
---

Dans nos projets on rencontre souvent ce cas de figure : certaines portions de code se prêtent mal au test unitaire. Ce sont les interfaces graphiques, le code qui manipule des fichiers, les connexions réseaux… Cela peut poser problème lorsqu’on configure Sonar pour lever des alertes quand la couverture de code est trop faible.

<!--more-->

Le problème a déjà été posé car Il y a un ticket dans le JIRA de Sonar ([SONAR-766](http://jira.codehaus.org/browse/SONAR-766)). Quand il aura été résolu Sonar devrait permettre de configurer ce qui doit être exclu de l’analyse de couverture des tests.

En attendant comment faire ? En posant la question il y a quelques mois sur Twitter j’avais reçu une réponse de Damien Gouyette :

{% img center /images/posts/sonar-cobertura-tweet-20120130.png %}

J’ai fini par trouver le temps de tester et ça fonctionne ! Il est possible de régler ces règles d’exclusion en adaptant par la configuration du plugin cobertura dans le POM de notre projet :

{% codeblock lang:xml %}
<plugin>
  <groupId>org.codehaus.mojo</groupId>
  <artifactId>cobertura-maven-plugin</artifactId>
  <configuration>
    <instrumentation>
      <excludes>
        <exclude>com/mycompany/gui/**/*.class</exclude>
        <exclude>com/mycompany/nontestable/**/*.class</exclude>
      </excludes>
    </instrumentation>
  </configuration>
</plugin>
{% endcodeblock %}

De cette façon les classes correspondant au _pattern_ indiqué sont exclues de l’analyse par cobertura et ainsi ignorées par Sonar. Le taux de couverture est donc calculé sur le code considéré comme testable. La métrique devient alors beaucoup plus intéressante pour l’évaluation de la qualité globale du projet.

__Note__ : Attention, je parle bien sûr de test unitaire ; il ne faut pas confondre un code qui ne peut pas être testé unitairement avec un code pour lequel les tests sont possibles mais difficiles à écrire. En outre il est toujours possible de tester autrement, avec des tests d’intégration ou des tests de _user experience_ par exemple.

