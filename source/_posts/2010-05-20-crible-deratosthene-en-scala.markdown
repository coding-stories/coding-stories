---
layout: post
title: "Crible d’Ératosthène en Scala"
date: 2010-05-20 15:50
comments: true
categories: [scala]
---

Le [crible d’Ératosthène](http://fr.wikipedia.org/wiki/Crible_d) est un grand classique des langages fonctionnels :

{% codeblock lang:scala %}
def primes (end: Int): Seq[Int] = {
  def sieve (list: Seq[Int]): Seq[Int] = {
    list match {
      case Nil => List()
      case x :: xs => List(x) ++ sieve(xs.filter(_ % x != 0))
    }
  }
  sieve(List.range(2, end))
}
{% endcodeblock %}

Faisons un test :

{% codeblock lang:scala %}
scala> primes(100)
res0: Seq[Int] = List(2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97)
{% endcodeblock %}
