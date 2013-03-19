---
layout: post
title: "The Secret of Monkey Island dans le navigateur"
date: 2013-03-19 07:15
comments: true
categories: [dart, dartlang, SCUMM, ScummVM, SCUMMDart]
---

Il y a environ un an, pour apprendre Dart, je me suis lancé dans un projet un peu fou : réécrire un moteur [SCUM](http://en.wikipedia.org/wiki/SCUMM) en Dart en portant le code source du projet open-source [ScummVM](https://github.com/scummvm/scummvm). L'objectif est de pouvoir jouer à Monkey Island (version française CD, SCUMM version 5) directement dans le navigateur.

J'ai fait une longue pause en attendant que le langage se stabilise et j'ai repris le code récemment. Voilà une courte vidéo (désolé pour la faible qualité, c'est mon premier post sur youtube) qui montre ce qui fonctionne pour le moment (pour faire court, le générique du jeu).

{% youtube UkZ6v8LHbaU %}

Sur la vidéo on voit qu'il reste quelques problèmes :

- un problème de palette de couleur pour les crédits : ils sont écrits en bleu, ils devraient être magenta ;
- c'est (très) lent. À mon avis, ce problème est lié à Dartium ou au debugger du Dart Editor. Après compilation avec dart2js ça semble beaucoup plus rapide mais le Javascript produit contient des erreurs.

Le code n'est pas encore publié mais sera rapidement [disponible sur GitHub](https://github.com/jcsirot/SCUMM-Dart) où pour le moment est hébergé l'ancienne version.
