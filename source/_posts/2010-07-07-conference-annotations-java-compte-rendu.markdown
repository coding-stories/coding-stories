---
layout: post
title: "Conférence annotations java – compte rendu"
date: 2010-07-07 07:39
comments: true
categories: [conference, java]
---

La conférence _Annotations Java_ animée par Olivier Croisier, expert java et auteur du blog [The Coders Breakfast](http://thecodersbreakfast.net/), s’est tenue le 29 juin dernier a eu lieu la dans les locaux de [Zénika](http://www.zenika.com/).

Les annotations, je pensais bien connaitre… J’avais tort.

Après s’être présenté et avoir présenté Zénika, Olivier commence par un rappel historique : en matière de méta-programmation, il existait déjà l’API [Doclets](http://java.sun.com/j2se/1.5.0/docs/guide/javadoc/) qui permet d’ajouter ses propres tags dans les commentaires du code. Les développeurs ont vite détourné cette fonctionnalité, souvent pour permettre la génération automatique de code. A partir de Java 5 sont apparues les annotations.

Dans la bibliothèque Java standard on trouve finalement assez peu d’annotations : `@Override`, `@SuppressWarnings` et `@Deprecated` ainsi que quelques unes dans le package `java.lang.annotation` (des _meta-annotations_, c’est à dire des annotations que l’on place sur d’autres annotations comme `Target` ou `Retention). Avec Java 6, on en voit arriver d’autres dans les packages `javax.annotation` ou `javax.xml.bind.annotation`. Mais ce sont surtout les frameworks et autres standards qui font la part belle aux annotations : Hibernate, JPA, JDO, Spring, Guice, J2EE6... Le plus souvent il s'agit de remplacer de longs fichiers de description en XML.

Ensuite Olivier nous a présenté la syntaxe et les règles d'usage des annotations : elles peuvent se placer partout et si on les voit souvent sur des classes, des interfaces ou des méthodes, il est aussi possible d'annoter les packages en utilisant un fichier [package-info.java](http://java.sun.com/docs/books/jls/third_edition/html/packages.html), les constructeurs, les champs et également les paramètres de méthodes. Les annotations peuvent être paramétrées et ces paramètres peuvent avoir des valeurs par défaut. Valeurs par défaut qui peuvent même être des expressions si tant est que cette expression est résolue à la compilation. Toutefois il existe deux limites : les paramètres des annotations ne peuvent être null (pourquoi ? Personne ne semble vraiment savoir) et on ne peut annoter un élément qu'avec une seule annotation d'un même type. Mais il exste une astuce pour contourner le problème : écrire des annotations qui prennent un tableau d'annotations en paramètre.

Puis on passe au développement d'annotations personnalisées.

{% codeblock lang:java %}
public @interface MyAnnotation {
    String aString() default "FooBar";
    int aInteger() default 21 + 21;
}

@MyAnnotation(aString="An arbitrary String", aInteger=27)
public class MyAnnotedClass {
    /* .... */
}
{% endcodeblock %}

Quand on a un unique paramètre dans l'annotation on peut simplifier un peu la syntaxe en nommant ce paramètre `value` :

{% codeblock lang:java %}
public @interface MyAnnotation {
    String value();
}

@MyAnnotation("Hello world")
public class MyAnnotedClass {
    /* .... */
}
{% endcodeblock %}

On peut également annoter nos propres annotations avec les meta-annotations définies dans la bibliothèque standard :

- `Target` indique sur quels éléments on peut placer l'annotation (classes, méthodes...). Par défaut on peut mettre une annotation partout.
- `Retention` indique la durée de vie de l'annotation : présence uniquement dans le code source, dans le bytecode de la classe ou également au runtime.
- `Documented` indique si l'annotation apparaitra dans la javadoc.
- `Inherited indique si l'annotation est héritée par les sous-classes des classes ou elle est définie. Limitation : on ne peut pas hériter d'une annotation placée sur un interface en implémentant cette interface.

Finalement Olivier est passé à des exemples concrets d'utilisation des annotations.

D'abord à la compilation, les annotations permettent d'étendre les fonctionnalités du compilateur Java. Java 6 propose un mécanisme appelé _Pluggable Annotation Processing_ qui permet de brancher ses propres modules dans le compilateur. Cela se passe dans les packages `javax.annotation` et `javax.annotation.processing`. Il suffit d'écire une implémentation de la classe `javax.annotation.processing.Processor` (ou étendre `AbstractProcessor`) et de la mettre dans le classpath du compilateur (les implementations de `Processor` sont découvertes par le compilateur en utilisant le [mécanisme de chargement de service](http://www/docs/java/docs-1.6.0/api/index.html?java/util/ServiceLoader.html)). L'interface `Processor` permet d'accéder à l'[AST](http://fr.wikipedia.org/wiki/Abstract_syntax_tree) du code en cours de compilation. Une utilisation possible est la vérification programmatique de règles de design : s'assurer par exemple que toutes les classes d'un package annoté implémentent `Serializable` ou encore que toutes les classes annotées par un `@Loadable` possède bien une méthode `load avec les bons paramètres.

Toutefois cette approche d'extension du compilateur a ses limites : il n'est pas possible de modifier le code existant (on ne peut qu'en générer) et certains bugs pouvant être bloquant trainent depuis longtemps (cela semble corrigé dans Java 7).

Second exemple, en runtime cette fois, la recherche d'annotations par introspection. Pour cela il ne faut pas oublier d'ajouter la méta-annotation `@Rentention(RententionPolicy.RUNTIME)` pour que celle-ci survive à l'exécution dans la JVM. Les cas d'utilisation tournent cette fois plus vers la programmation orientée _POJO_ (plus besoin d'implémenter telle interface, on appelle les méthodes par introspection en recherchant celles qui sont annotées), le mapping d'objets java vers autre chose (par exemple java vers base de données avec JPA ou JDO) ou encore la configuration des frameworks (`@Inject dans Guice par exemple).

En guise de dessert, Olivier nous a proposé une jolie demo d'injection d'annotation en runtime dans une classe. Il s'agit surtout d'une _proof of concept_ et, de son propre aveux, il n'a pas trouvé de vrai use case à cela.

Les slides de la présentation et les exemples de code sont disponibles sur le [blog de Zenika](http://blog.zenika.com/index.php?post/2010/07/05/Conf%C3%A9rence:-Les-annotations-enfin-expliqu%C3%A9es-simplement).

