---
layout: post
title: "Mocker un serveur de mail avec Dumbster et JUnit"
date: 2012-08-05 20:29
comments: true
categories: [java, junit, mock, qualite, test]
---

Récemment, en écrivant des tests d’intégration j’ai rencontré un cas d’utilisation qui arrive fréquemment : un utilisateur s’inscrit à un service Web, un courriel lui est envoyé, il contient une URL permettant de confirmer son inscription. La question est comment tester ça automatiquement, par exemple dans un test [Selenium](http://seleniumhq.org/) ?

<!--more-->

La solution technique
=====================

Première idée : créer un compte mail dédié pour ce test qu’on va interroger avec une bibliothèque comme [javamail](http://www.oracle.com/technetwork/java/javamail/index.html). Cette solution présente toutefois quelques problèmes. D’abord il va falloir maintenir cette boîte mail dans le temps. Ensuite si le serveur SMTP ou le serveur POP/IMAP est indisponible le test va échouer. Et que va-t-il se passer si deux tests sont lancés en même temps ? Finalement une solution qui me semble bien fragile.

Seconde idée : _mocker_ un serveur SMTP qu’on ne lance que le temps du test. Après quelques rapides recherches j’ai trouvé [Dumbster](http://quintanasoft.com/dumbster/), un serveur qui répond aux requêtes SMTP mais sans relayer les messages envoyés. Ceux-ci sont stockés et peuvent ensuite être examinés.

Intégration avec JUnit
======================

Pour intégrer Dumbster avec JUnit, j’ai écrit une [_TestRule_](http://kentbeck.github.com/junit/javadoc/latest/org/junit/rules/TestRule.html). Les `TestRule` de JUnit sont des classes qui permettent de modifier la façon dont une méthode de test (ou un ensemble de méthodes) va se comporter en exécutant du code avant ou après le test. C’est un moyen très pratique de factoriser des comportements qu’on est amené à utiliser souvent dans les tests : par exemple [_TemporaryFolder_](http://kentbeck.github.com/junit/javadoc/latest/org/junit/rules/TemporaryFolder.html) permet de créer des répertoires et des fichiers temporaire et de les supprimer à la fin du test, [_Timeout_](http://kentbeck.github.com/junit/javadoc/latest/org/junit/rules/Timeout.html) s’assure que les tests ne dépasseront une durée maximale donnée…

Pour le mock de serveur, j’ai créé une classe `MockSMTPRule` qui étend la classe abstraite [_ExternalResource_](http://kentbeck.github.com/junit/javadoc/latest/org/junit/rules/ExternalResource.html). Cette classe fournit deux méthodes `before` et `after` qui s’exécutent respectivement avant et après la méthode de test ; parfait donc pour gérer des ressources externe au test.

{% codeblock lang:java %}
public class MockSMTPRule extends ExternalResource
{
     public SimpleSmtpServer server;

    /** Lance le serveur SMTP sur le port 2525 avant le test */
    protected void before() throws Throwable
    {
        super.before();
        server = SimpleSmtpServer.start(2525);
    }

    /** Arrête le serveur une fois le test terminé */
    protected void after()
    {
        server.stop();
        super.after();
    }
}
{% endcodeblock %}

Il faudra également configurer l’application web pour utiliser le serveur qui sera lancé sur localhost, port 2525.

Ensuite, utiliser cette `TestRule` dans un test est extrêmement simple. Il suffit de créer une variable d’instance publique dans la classe de test et de la préfixer avec l’annotation `@Rule`.

{% codeblock lang:java %}
public class RegistrationTest extends JUnit4TestBase
{
    @Rule
    public MockSMTPRule smtp = new MockSMTPRule();

    /** Test the registration */
    @Test
    public void should_send_confirmation_email()
    {
        /* Ouvrir la page à tester */
        openPage("http://localhost:8080/register/");
        /* Saisir les informations sur le nouvel utilisateur */
        /* ... */
        /* On teste qu'un mail a été reçu */
        assertEquals(1, smtp.server.getReceivedEmailSize());
        SmtpMessage msg = (SmtpMessage) smtp.server.getReceivedEmail().next();
        /* On teste les champs To, From et Subject */
        assertEquals("[Service Trop Bien] Confirmation de votre inscription", msg.getHeaderValue("Subject"));
        assertEquals("john@example.com", msg.getHeaderValue("To"));
        assertEquals("no-reply@servicetropbien.com", msg.getHeaderValue("From"));
        /* On teste le corps du mail */
        assertTrue(msg.getBody().contains("Bienvenue"));
    }
}
{% endcodeblock %}

Le code complet de la classe est ici : <https://gist.github.com/3246719>


