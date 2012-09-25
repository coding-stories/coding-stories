---
layout: post
title: "Quicksort en Scala"
date: 2010-05-17 23:21
comments: true
categories: [scala]
---

Retour aux racines du génie logiciel : le tri. Tout développeur doit savoir écrire un tri en moins de 5 minutes.

Comment faire un quicksort en Scala ?

{% codeblock lang:scala %}
def sort (list : Seq[Int]) : Seq[Int] = {
  list match {
    case Nil => list
    case x :: xs => sort(xs.filter(_ < x)) ++ List(x) ++ sort(xs.filter(_ >= x))
  }
}
{% endcodeblock %}

Ça marche pour les int. Mais si je veux trier des float, des String, des Scoubidou ? Il faudrait généraliser la fonction. Pour cela il existe le trait `Ordered qui permet de définir une relation d’ordre total sur les éléments.

{% codeblock lang:scala %}
def sort [A <% Ordered[A]] (list:Seq[A]): Seq[A] = {
  list match {
    case Nil => list
    case x :: xs => sort(xs.filter(_ < x)) ++ List(x) ++ sort(xs.filter(_ >= x))
  }
}
{% endcodeblock %}

L’expression `[A <% Ordered[A]] est une _view bound_. Cela permet de définir une fonction polymorphique mais aussi fournit la conversion implicite du type A en Ordered[A]. En fait cette définition :

{% codeblock lang:scala %}
def sort [A <% Ordered[A]] (list:Seq[A]): Seq[A] = { /* ... */ }
{% endcodeblock %}

est équivalente à :

{% codeblock lang:scala %}
def sort [A] (list:Seq[A])(implicit conv: A => Ordered[A]): Seq[A] = { /* ... */ }
{% endcodeblock %}

Avantage : l’objet `scala.Predef` qui est tourjours chargé par Scala possède déjà plusieurs fonctions implicites de converstion par exemple `Int` vers `Ordered[Int]`.

Et si maintenant nous compararions nos scoubidous ?

{% codeblock lang:scala %}
case class Scoubidou(name: String)
val samy = Scoubidou("Samy")
val daphne = Scoubidou("Daphne")
sort(List(samy, daphne))

> error: no implicit argument matching parameter type (Scoubidou) => Ordered[Scoubidou] was found.
{% endcodeblock %}

Et oui, sort attend un `Ordered`. Bien sûr nous pourrions nous arranger pour que Scoubidou étende le trait Ordered mais parfois ce n’est simplement pas possible, par exemple parce que le type est fournit par une bibliothèque sur laquelle on n’a pas la main. Mais il est possible de définir une fonction implicite de conversion qui trie les Scoubidou selon l’ordre lexicographique (en clair on va déléguer l’appel à compare au champ name).

{% codeblock lang:scala %}
implicit def scoubidou2ordered (x: Scoubidou): Ordered[Scoubidou] = {
  new Ordered[Scoubidou] {
    def compare(that: Scoubidou): Int = {
      x.name.compare(that.name)
    }
  }
}
{% endcodeblock %}

et maintenant on peut trier la liste :

{% codeblock lang:scala %}
sort(List(samy, daphne))

> Seq[Scoubidou] = List(Scoubidou(Daphne), Scoubidou(Samy))
{% endcodeblock %}
