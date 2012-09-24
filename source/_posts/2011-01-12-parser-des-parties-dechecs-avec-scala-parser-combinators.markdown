---
layout: post
title: "Parser des parties d’échecs avec Scala Parser Combinators"
date: 2011-01-12 07:51
comments: true
categories: [chess, PGN, scala]
---

Un morceau de code scala écrit il y a quelques mois quand j’ai commencé à jouer avec scala. Il utilise l’API [parser combinators](http://www.scala-lang.org/api/current/scala/util/parsing/combinator/Parsers.html) de scala pour décoder des parties d’échecs au format [PGN].

{% gist 774261 PGNParser.scala %}
