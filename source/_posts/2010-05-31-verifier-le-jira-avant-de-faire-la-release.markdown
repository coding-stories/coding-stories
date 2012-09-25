---
layout: post
title: "Vérifier le JIRA avant de faire la release"
date: 2010-05-31 15:30
comments: true
categories: [jira, maven, maven-enforcer-plugin, maven-release-plugin]
---

Quand je coiffe ma casquette de _release manager_ je dois m’assurer que le logiciel que je prépare à affubler d’un joli numéro de version est prêt. Le code n’est pas tout ; il existe une multitude de petits détails à vérifier pour satisfaire les critères de qualité demandés : les tests (unitaires, d’intégration) passent ils ? Le _coding style_ a-t-il été bien respecté ? Les dépendences sont-elles à jour ? Je me suis donc fait une _release checklist_ qui détaille point par point toutes ces tâches.

Automatisez !
=============

En bon informaticien pragmatique je connais le bug de l’interface chaise-clavier : tout ce qui est fait à la main est une intarissable source de problèmes et il m’arrive parfois de faire une bêtise, ce qui a le don de me mettre de fort mauvaise humeur.

Comme je suis -fainéant- consciencieux, je cherche donc à automatiser le maximum de tâches. Dans ma checklist se trouve le point suivant : S’assurer que tous les tickets dans le JIRA sont fermés. Mon objectif : annuler le lancement de la release quand cette condition n’est pas remplie.

JIRA par RPC
============

Dans une premier temps il faut accéder à JIRA pour récupérer la liste des issues qui nous intéressent. Pour cela JIRA met à disposition deux interfaces RPC : XML-RPC et SOAP. On utilisera SOAP, non pas par plaisir car je trouve XML-RPC beaucoup plus simple, mais parce que l’API disponible par XML-RPC est moins riche et surtout ne fournit pas la méthode dont on a besoin.

Le descripteur WSDL est normalement servit par JIRA. En supposant que JIRA est installé à l’URL « `http://jira.chelonix.com/ » alors le WSDL peut être téléchargé à l’URL suivante :

`http://jira.chelonix.com/rpc/soap/jirasoapservice-v2?wsdl`

Pour utiliser l’API SOAP de JIRA il va falloir enrichir son pom.xml de quelques dépendances à la bibliothèque [Axis](http://ws.apache.org/axis/) de la fondation Apache.

{% codeblock lang:xml %}
    <!-- Axis dependencies -->
    <dependency>
      <groupId>axis</groupId>
      <artifactId>axis</artifactId>
      <version>1.3</version>
    </dependency>
    <dependency>
      <groupId>axis</groupId>
      <artifactId>axis-jaxrpc</artifactId>
      <version>1.3</version>
    </dependency>
    <dependency>
      <groupId>axis</groupId>
      <artifactId>axis-saaj</artifactId>
      <version>1.3</version>
    </dependency>
    <dependency>
      <groupId>axis</groupId>
      <artifactId>axis-wsdl4j</artifactId>
      <version>1.5.1</version>
    </dependency>
{% endcodeblock %}

Toujours dans le `pom.xml` on ajoute un appel au plugin axistools-maven-plugin. Lors de la phase _generate-sources_, le fichier WSDL va être utilisé pour auto-générer les classes du client SOAP.

{% codeblock lang:xml %}
  <build>
    <plugins>
      <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>axistools-maven-plugin</artifactId>
        <version>1.3</version>
        <dependencies>
          <dependency>
            <groupId>axis</groupId>
            <artifactId>axis</artifactId>
            <version>1.3</version>
          </dependency>
        </dependencies>
        <configuration>
          <wsdlFiles>
            <wsdlFile>jirasoapservice-v2.wsdl</wsdlFile>
          </wsdlFiles>
          <packageSpace>com.atlassian.jira.rpc.soap.client</packageSpace>
        </configuration>
        <executions>
          <execution>
            <id>wsdl2java-generation</id>
            <phase>generate-sources</phase>
            <goals>
              <goal>wsdl2java</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
{% endcodeblock %}

Le plugin s’attend à trouver le WSDL dans le répertoire `${basedir}/src/main/wsdl`. Pense à l’y mettre ou à modifier la propriété `sourceDirectory` dans la configuration du plugin.
Une fois que le projet a été configuré, il ne reste plus qu’à coder :

{% codeblock lang:java %}
package com.chelonix.jira.rpc.soap.client;

import com.atlassian.jira.rpc.exception.RemoteException;
import com.atlassian.jira.rpc.soap.client.JiraSoapService;
import com.atlassian.jira.rpc.soap.client.JiraSoapServiceService;
import com.atlassian.jira.rpc.soap.client.JiraSoapServiceServiceLocator;
import com.atlassian.jira.rpc.soap.client.RemoteIssue;
import java.net.URL;

/**
 * A JIRA SOAP client checking for opened issues for a project/version couple.
 */
public class IssueChecker
{
    private static final String URL = "http://jira.chelonix.com/rpc/soap/jirasoapservice-v2";

    public static void main(String[] args)
    {
        try {
            IssueCherker checker = new IssueChecker();
            RemoteIssue[] issues = checker.check(args[0], args[1]);
            for (RemoteIssue issue: issues) {
                System.out.printf("Opened issue: %s", issue.getKey());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private JiraSoapService jiraSoapService;

    public IssueChecker() throws Exception
    {
        JiraSoapServiceService jiraSoapServiceLocator =
            new JiraSoapServiceServiceLocator();
        jiraSoapService = jiraSoapServiceLocator.getJirasoapserviceV2(new URL(URL));
    }

    public RemoteIssue[] check(String projectKey, String version) throws RemoteException
        String token = jiraSoapService.login("login", "password");
        String query = MessageFormat.format(
            "project=''{0}'' AND FixVersion=''{1}'' AND status!=''Closed''",
            project, version);
        return jiraSoapService.getIssuesFromJqlSearch(token, query, 100);
    }
}
{% endcodeblock %}

Pour plus de détails, la documentation des services RPC de JIRA est là : <http://confluence.atlassian.com/display/JIRA/JIRA+RPC+Services>

Créer des règles…
=================

Maintenant qu’on peut savoir s’il reste des issues ouvertes pour un projet/version donné, il faut faire en sorte que l’appel `mvn release:prepare` échoue quand c’est le cas. Pour cela on va utiliser le plugin [maven-enforcer-plugin](http://maven.apache.org/plugins/maven-enforcer-plugin/). Ce plugin permet de subordonner la compilation à la vérification d’un certain nombre de contraintes telles que la version de maven, la version du JDK, la présence de certains fichiers, etc.

Le plugin permet également d’ajouter ses propres règles. On peut donc en créer une se basant sur la classe `IssueChecker`.

D’abord on ajoute quelques dépendances au pom.xml :

{% codeblock lang:xml %}
  <dependencies>
    <!-- Enforcer dependencies -->
    <dependency>
      <groupId>org.apache.maven.enforcer</groupId>
      <artifactId>enforcer-api</artifactId>
      <version>${api.version}</version>
    </dependency>
    <dependency>
      <groupId>org.apache.maven</groupId>
      <artifactId>maven-project</artifactId>
      <version>${maven.version}</version>
    </dependency>
    <dependency>
      <groupId>org.apache.maven</groupId>
      <artifactId>maven-core</artifactId>
      <version>${maven.version}</version>
    </dependency>
    <dependency>
      <groupId>org.apache.maven</groupId>
      <artifactId>maven-artifact</artifactId>
      <version>${maven.version}</version>
    </dependency>
    <dependency>
      <groupId>org.apache.maven</groupId>
      <artifactId>maven-plugin-api</artifactId>
      <version>${maven.version}</version>
    </dependency>
    <dependency>
      <groupId>org.codehaus.plexus</groupId>
      <artifactId>plexus-container-default</artifactId>
      <version>1.0-alpha-9</version>
    </dependency>
  </dependencies>
{% endcodeblock %}

Puis il faut écrire une implémentation de l’interface [EnforcerRule](http://maven.apache.org/enforcer/enforcer-api/apidocs/index.html) :

{% codeblock lang:java url link-text %}
package com.chelonix.maven.enforcer.rule;

import java.text.MessageFormat;
import com.atlassian.jira.rpc.exception.RemoteException;
import com.atlassian.jira.rpc.soap.client.RemoteIssue;
import org.apache.maven.enforcer.rule.api.EnforcerRule;
import org.apache.maven.enforcer.rule.api.EnforcerRuleException;
import org.apache.maven.enforcer.rule.api.EnforcerRuleHelper;
import org.codehaus.plexus.component.configurator.expression.ExpressionEvaluationException;

/**
 * Implementation of the EnforcerRule verifying whether there is any remaining unclosed issues.
 */
public class JiraOpenIssuesRule implements EnforcerRule
{
    private boolean shouldIfail = false;

    public void execute(EnforcerRuleHelper helper) throws EnforcerRuleException
    {
        try {
            MavenProject project = (MavenProject)helper.evaluate("${project}");
            String version = project.getVersion();
            String projectKey = (String)helper.evaluate("${jira.project.key}");
            IssueChecker checker = new IssueChecker();
            RemoteIssue[] issues = checker.check(projectKey, version);
            shouldIfail = issues.length > 0;
        } catch (ExpressionEvaluationException e) {
            throw new EnforcerRuleException("Unable to lookup an expression " +
                e.getMessage(), e);
        } catch (RemoteException re) {
            throw new EnforcerRuleException("SOAP Remote exception " +
                re.getMessage(), re);
        }
        if (this.shouldIfail) {
            throw new EnforcerRuleException("Remaining unclosed issues");
        }
    }

    public boolean isCacheable()
    {
        return false;
    }

    public boolean isResultValid(EnforcerRule er)
    {
        return false;
    }

    public String getCacheId()
    {
        return "";
    }
}
{% endcodeblock %}

Pensez à ajouter une propriété `jira.project.key` indiquant la clé du projet JIRA dans le `pom.xml` du projet dont on fait la release.

… Et les faire appliquer
========================

Finalement il n’y a plus qu’à appeler le plugin Enforcer lors de la release. Dans le `pom.xml` du projet à releaser on va ajouter le code suivant :

{% codeblock lang:xml %}
<build>
    <plugins>
    ...
        <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-release-plugin</artifactId>
          <version>2.0</version>
          <configuration>
            <preparationGoals>clean verify enforcer:enforce</preparationGoals>
            <arguments>-Prelease</arguments>
            <goals>deploy</goals>
            <autoVersionSubmodules>true</autoVersionSubmodules>
          </configuration>
        </plugin>
    ...
    <plugins>
<build>

<profile>
  <id>releaseVerify</id>
  <build>
    <plugins>
      <plugin>
        <artifactId>maven-enforcer-plugin</artifactId>
        <dependencies>
          <dependency>
            <groupId>com.chelonix.maven.enforcer</groupId>
            <artifactId>jira-rules</artifactId>
            <version>${jirarules.version}</version>
          </dependency>
        </dependencies>
        <configuration>
          <rules>
            <myCustomRule implementation="com.chelonix.maven.enforcer.rule.JiraOpenIssuesRule">
              <shouldIfail>false</shouldIfail>
            </myCustomRule>
          </rules>
        </configuration>
      </plugin>
    </plugins>
  </build>
</profile>
{% endcodeblock %}

Quelques remarques : j’ai créé un profil `releaseVerify` afin de définir des règles utilisées uniquement lors de la release. Ensuite j’ai ajouté l’appel `enforcer:enforce` au paramètre de configuration `preparationGoals. Ce paramètre permet de définir une liste de _goals_ à exécuter lors de `release:prepare`. Par défaut ce sont les goals `clean verify` qui sont exécutés. Enfin j’ai ajouté le paramètre arguments avec la valeur `-PreleaseVerify` pour forcer l’usage du profil.

Conclusion
==========

Désormais toute tentative de release avec des tickets encore ouverts dans le JIRA va échouer. Cela ne me dispense pas de faire la vérification mais me prémunit contre un éventuel oubli. Toutefois le code est encore loin d’être parfait (par exemple il y a un risque de NullPointerException quand `jira.project.key` n’est pas défini).


