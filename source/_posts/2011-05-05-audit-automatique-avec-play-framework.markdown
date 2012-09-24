---
layout: post
title: "Audit automatique avec Play Framework"
date: 2011-05-05 07:40
comments: true
categories: [code, framework, java, log, play]
---

J’aime beaucoup l’annotation @With de Play framework, elle permet d’étendre le comportement d’un _Controller_ en y ajoutant simplement des intercepteurs. Par exemple il est possible d’écrire un _Controller_ générique dont le travail est de logguer des appels et d’ajouter ce comportement sur d’autre _Controller_ avec une simple annotation.

<!-- more -->

On commence par définir une annotation qui servira à taguer les méthodes dont les appels seront loggués:

{% codeblock lang:java %}
package controllers;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Audit { }
{% endcodeblock %}

Ensuite on va rechercher toutes les méthodes taguées avec cette annotation et on ajoute une ligne de log contenant des informations pertinentes.


{% codeblock lang:java %}
package controllers;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import play.Logger;
import play.mvc.ActionInvoker;
import play.mvc.Finally;
import play.mvc.Controller;
import play.mvc.Http;
import play.utils.Java;

public class AuditTrail extends Controller
{
    @Finally
    static void log() throws Throwable {
        if (getActionAnnotation(Audit.class) != null) {
            audit();
        }
    }

    private static void audit() throws Throwable {
        /* Get the method name */
        Object[] action = ActionInvoker.getActionMethod(Http.Request.current().action);
        Class c = (Class)action[0];
        Method m = (Method)action[1];
        /* Get the method parameters name... */
        String[] names = Java.parameterNames(m);
        /* ... and the values */
        Object[] args = ActionInvoker.getActionMethodArgs(m, null);
        List<String> params = new ArrayList<String>();
            for (int i = 0; i < names.length; i++) {
                params.add(names[i] + "=" + args[i]);
        }
        /* Get the username if Secure module is used */
        String username = session.get("username");
        if (username == null) {
            username = "Anonymous User"
        }
        /* Log the action */
        Logger.info("<%s> called contoller action <%s.%s> with parameters <%s> at <%s>",
            username, c.getSimpleName(), m.getName(), params, new Date());
    }
}
{% endcodeblock %}

Enfin, pour utiliser notre _Audit Trail_, rien de plus simple, il suffit d’ajouter un `@With(AuditTrail.class)` sur un _Controller_ et d’annoter avec `@Audit les méthodes à auditer.


{% codeblock lang:java %}
@With({Secure.class, AuditTrail.class})
public class Issues extends Controller
{
    @Audit
    public static void showTicket(long ticketId) {
        /* Do some stuff */
        render(...);
    }
}
{% endcodeblock %}

Et dans les logs on pourra alors trouver une ligne qui ressemble à ça :


{% codeblock %}
17:45:53,867 INFO  ~ <johndoe> called contoller action <Issues.showTicket> with parameters <[ticketId: 11484]> at <Mon May 02 17:45:53 CEST 2011>
{% endcodeblock %}

Beaucoup d’améliorations sont possibles comme par exemple indiquer le Logger à utiliser comme paramètre de l’annotation `@Audit ou encore mettre les logs dans la base de donnée pour faire des recherches.

