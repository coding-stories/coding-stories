---
layout: post
title: "Couverture des tests d’intégration avec JaCoCo, Maven et Sonar"
date: 2012-01-23 07:16
comments: true
categories: [cobertura, code coverage, JaCoCo, maven, maven-failsafe-plugin, maven-jacoco-plugin, sonar, test]
---

Sur certains de mes projets maven j’aimerai pouvoir séparer les tests unitaires des tests d’intégration. Les tests d’intégration sont souvent moins stables, pas toujours reproductibles et ils prennent souvent trop de temps pour être exécutés par les développeurs à chaque compilation.

<!-- more -->

Déplacer les tests dans un module dédié
=======================================

Première chose à faire, créer un module dédié dans le projet maven pour y mettre uniquement les tests d’intégration. Voilà la structure globale du projet :

{% img center project-layout1-20120123.png 'Project Layout' %}

Ensuite pour empêcher que le module `libfoo-it` ne se lance à chaque compilation on crée un profil maven dédié aux test d’intégration dans le fichier `pom.xml` principal.

{% codeblock lang:xml %}
<profiles>
  <profile>
    <id>run-its</id>
    <modules>
      <module>libfoo-it</module>
    </modules>
  </profile>
</profiles>
{% endcodeblock %}

Utiliser maven-failsafe-plugin
==============================

Le [plugin failsafe](http://maven.apache.org/plugins/maven-failsafe-plugin/) permet de lancer les test d’intégration lors d’un build maven tout comme le plugin surefire le fait avec les tests unitaires. Le plugin failsafe s’attache aux phases _integration-test_ et _verify_ du [cycle de vie du build](http://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html).

Comme il n’est pas possible de configurer plusieurs répertoires contenant les tests dans maven, la discrimination entre tests unitaires et d’intégration se fait sur le nom des classes. Il ne faudra donc pas oublier de nommer correctement ses classes de test.

Les _templates_ par défaut sont les suivants :

- __tests unitaires__ : **/*Test.java, **/Test*.java, **/*TestCase.java
- __tests d’intégration__ : **/*IT.java, **/IT*.java, **/*ITCase.java

On ajoute ensuite la configuration du plugin failsafe dans notre profil.

{% codeblock lang:xml %}
<profiles>
  <profile>
    <id>run-its</id>
    <modules>
      <module>libfoo-it</module>
    </modules>
    <build>
      <pluginManagement>
        <plugins>
          <plugin>
            <artifactId>maven-failsafe-plugin</artifactId>
            <version>2.11</version>
            <executions>
              <execution>
                <goals>
                  <goal>integration-test</goal>
                </goals>
              </execution>
            </executions>
          </plugin>
        </plugins>
      </pluginManagement>
    </build>
  </profile>
</profiles>
{% endcodeblock %}

Le POM du sous-projet libfoo-it est également à mettre à jour. De cette façon, petite optimisation, le plugin failsafe ne sera lancé que dans le module qui contient les tests d’intégration.

{% codeblock %}
[/~]$ mvn -Prun-its clean verify
{% endcodeblock %}

Couverture de code avec JaCoCo
==============================

Avoir des tests c’est bien, calculer la couverture de ces tests c’est mieux. Pour cela nous allons utiliser le moteur de couverture de code [JaCoCo](http://www.eclemma.org/jacoco/) (Java Code Coverage), plus adapté aux tests d’intégration que le bien connu Cobertura.

JaCoCo est fournit sous la forme d’un agent à lancer avec la JVM. Heureusement, il existe un plugin maven pour JaCoCo qui va nous aider à l’intégrer dans le build. Le plugin maven JaCoCo dispose d’un goal _prepare-agent_ qui va dans un premier temps télécharger l’agent et dans un second temps créer une variable maven contenant la configuration de l’agent qu’il suffira de passer en paramètre au plugin failsafe.

Voilà ce que donne la configuration du plugin (__Nota__: j’utilise la version 5.3 du plugin JaCoCo car les versions suivantes ne semblent pas fonctionner avec maven 2.2.1) :

{% codeblock lang:xml %}
<profiles>
  <profile>
    <id>run-its</id>
    <modules>
      <module>libfoo-it</module>
    </modules>
    <build>
      <pluginManagement>
        <plugins>
          <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>maven-jacoco-plugin</artifactId>
            <version>0.5.3.201107060350</version>
            <executions>
              <execution>
                <phase>pre-integration-test</phase>
                <goals>
                  <goal>prepare-agent</goal>
                </goals>
              </execution>
            </executions>
            <configuration>
              <propertyName>it.failsafe.argLine</propertyName>
              <destFile>${it.jacoco.destFile}</destFile>
            </configuration>
          </plugin>
          <plugin>
            <artifactId>maven-failsafe-plugin</artifactId>
            <version>2.11</version>
            <executions>
              <execution>
                <goals>
                  <goal>integration-test</goal>
                </goals>
              </execution>
            </executions>
            <configuration>
              <argLine>${it.failsafe.argLine}</argLine>
            </configuration>
          </plugin>
        </plugins>
      </pluginManagement>
    </build>
    <properties>
      <it.jacoco.destFile>${java.io.tmpdir}/jacoco-foo.dump</it.jacoco.destFile>
    </properties>
  </profile>
</profiles>
{% endcodeblock %}

Le plugin JaCoCo va générer la configuration de l’agent pour lancer les tests et la placer dans variable `it.failsafe.argLine`. Ensuite on configure le paramètre `argLine du plugin failsafe avec cette variable. On définit également le fichier qui va collecter les données de couverture (avec paramètre `destFile).

Il faut également mettre à jour le POM du module contenant les tests :

{% codeblock lang:xml %}
<build>
  <plugins>
    <plugin>
      <groupId>org.jacoco</groupId>
      <artifactId>maven-jacoco-plugin</artifactId>
    </plugin>
    <plugin>
      <artifactId>maven-failsafe-plugin</artifactId>
    </plugin>
  </plugins>
</build>
{% endcodeblock %}

Couverture avec Sonar
=====================

Maintenant que nous avons nos données de couverture dans un fichier, il serait intéressant de les faire digérés à Sonar lors de son analyse. Depuis la version 2.12, [Sonar](http://www.sonarsource.org/) est livré avec le plugin JaCoCo ; pour les précédentes il faudra l’installer depuis l’_update center_.

Le plugin JaCoCo de Sonar attend à trouver le chemin vers le fichier de collecte des données dans la variable `sonar.jacoco.itReportPath. Il est possible de configurer ce chemin dans l’interface web de Sonar (menu _settings_, catégorie _JaCoCo_, paramètre _File with execution data for integration tests_) mais cette variable peut également être configurée dans le POM.

Voilà donc la version définitive du profil :

{% codeblock lang:xml%}
<profiles>
  <profile>
    <id>run-its</id>
    <modules>
      <module>libfoo-it</module>
    </modules>
    <build>
      <pluginManagement>
        <plugins>
          <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>maven-jacoco-plugin</artifactId>
            <version>0.5.3.201107060350</version>
            <executions>
              <execution>
                <phase>pre-integration-test</phase>
                <goals>
                  <goal>prepare-agent</goal>
                </goals>
              </execution>
            </executions>
            <configuration>
              <propertyName>it.failsafe.argLine</propertyName>
              <destFile>${it.jacoco.destFile}</destFile>
            </configuration>
          </plugin>
          <plugin>
            <artifactId>maven-failsafe-plugin</artifactId>
            <version>2.11</version>
            <executions>
              <execution>
                <goals>
                  <goal>integration-test</goal>
                </goals>
              </execution>
            </executions>
            <configuration>
              <argLine>${it.failsafe.argLine}</argLine>
            </configuration>
          </plugin>
        </plugins>
      </pluginManagement>
    </build>
    <properties>
      <it.jacoco.destFile>${java.io.tmpdir}/jacoco-foo.dump</it.jacoco.destFile>
      <sonar.jacoco.itReportPath>${it.jacoco.destFile}</sonar.jacoco.itReportPath>
    </properties>
  </profile>
</profiles>
{% endcodeblock %}

Il ne reste plus qu’à lancer l’analyse avec Sonar :

{% codeblock %}
[/~]$ mvn -Prun-its clean verify sonar:sonar
{% endcodeblock %}

Finalement, après avoir ajouté le widget Integration test coverage dans le dashboard, on obtient ce résultat :

{% img center /images/posts/sonar-coverage-it-20120123.png 'Code coverage avec Sonar' %}

Pistes d’améliorations
======================

Cette solution est un peu brute de décoffrage et pour dire vrai entre le début de l’écriture de ce post et maintenant j’ai eu quelques idées pour l’améliorer :

- Passer la configuration du profil dans un super POM dont héritent tous les projets. En effet, mis à part le paramètre `destFile il n’y a rien de spécifique dans cette configuration. On pourrait même imaginer la génération d’un nom de fichier aléatoire à chaque lancement.
- Utiliser plusieurs modules de tests d’intégration. Pour cela il faut mettre le paramètre supplémentaire `append` à _true_ dans le plugin maven JaCoCo afin que les données d’exécution de tous les modules soient collectées dans le même fichier.

Et si vous avez d’autres idées, n’hésitez pas à les poster dans les commentaires.

