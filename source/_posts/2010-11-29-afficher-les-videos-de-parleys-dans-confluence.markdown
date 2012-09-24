---
layout: post
title: "Afficher les vidéos de Parleys dans Confluence"
date: 2010-11-29 07:55
comments: true
categories: [confluence, devoxx, parleys, web, wiki]
---

Comment faire quand on désire afficher du contenu multimedia (une vidéo par exemple) dans une page [Confluence](http://www.atlassian.com/software/confluence/) ?
Confluence fournit une la [balise wiki](http://confluence.atlassian.com/display/DOC/Embedding+Multimedia+Content) dédiée si la ressource à afficher est stockée localement (un attachement dans le wiki par exemple). Une autre solution c’est le plugin widget connector qui est compatible avec des services tels que youtube, vimeo, slideshare… Malheureusement aucune de ces solutions ne permet d’inclure une vidéo issue de [Parleys](http://www.parleys.com/).

<!-- more -->

Une macro utilisateur
=====================

Confluence permet des définir ses propres macros pour afficher du code HTML arbitraire dans une page du wiki. Cela permet par exemple de formater automatiquement des données ou, dans notre cas, d’insérer du contenu externe. Pour insérer la vidéo je vais écrire une __macro utilisateur__ ; ce type a de macro a l’avantage de pouvoir être saisie directement dans l’interface d’administration de Confluence.

Pour créer une nouvelle macro, dans le menu de gauche cliquez sur ‘__User Macros__‘ puis sur ‘__Create a User Macro__‘ au-dessus de la liste des macro existantes. Puis on configure la nouvelle macro :

- __Name__ : Parleys
- __Visibility__ : visible par tous
- __Title__ : parleys
- __Description__ : Embeds Parleys video
- __Categories__ : Contenu Externe
- __Macro Body Processing__ : No macro body (toutes les informations seront contenues dans les paramètres de la macro)
- __Output format__ : HTML

Le gabarit
==========

Dans la zone __template__ on commence par définir les paramètres de la macro. Ils sont au nombre de quatre : `id` (l’identifiant de la video), `width`, `height` et `allowFullScreen (si on active la fonction de passage en plein écran). Définir ces paramètres permet d’accéder à la macro depuis le navigateur de macros dans l’éditeur de page.

{% codeblock %}
## @param id:title=id|desc=The video identifier|required=true|multiple=false
## @param width:title=width|type=int|desc=The video width|required=false|multiple=false|default=474
## @param height:title=height|type=int|desc=The video height|required=false|multiple=false|default=443
## @param allowFullScreen:title=Allow full screen|type=boolean|desc=Allow full screen|required=false|multiple=false|default=true
{% endcodeblock %}

Ensuite on va définir des valeurs par défaut pour nos différents paramètres. Pour accéder au paramètre dont le nom est foo, on utilise la variable $paramfoo.

{% codeblock %}
#set($id= $paramid)
#set($width= $paramwidth)
#set($height= $paramheight)
#set($allowFullScreen= $paramallowFullScreen)

#if (!$width)
  #set ($width=474)
#end

#if (!$height)
  #set ($height=443)
#end

#if (!$allowFullScreen)
  #set ($allowFullScreen="true")
#end
{% endcodeblock %}

Et enfin il n’y a plus qu’à importer le code HTML fournit par Parleys en remplaçant les variables.

{% codeblock lang:html %}
<div>
  <object width="$width" height="$height">
    <param name="movie" value="http://www.parleys.com/share/parleysshare2.swf?pageId=$id"/>
    <param name="allowFullScreen" value="$allowFullScreen"/>
    <param name="pageId" value="$id"/>
    <embed src="http://www.parleys.com/share/parleysshare2.swf?pageId=$paramid"
          type="application/x-shockwave-flash"
          allowfullscreen="$allowFullScreen"
          width="$width" height="$height"/>
  </object>
</div>
{% endcodeblock %}

Utiliser la macro

Pour utiliser la macro, il suffit de l’appeler dans une page avec l’identifiant (obligatoire) de la vidéo.

{% codeblock %}
{parleys:id=1234}
{% endcodeblock %}

On peut aussi passer les paramètres supplémentaires en les séparant par des pipe

{% codeblock %}
{parleys:id=1234|width=237|height=221}
{% endcodeblock %}

À partir de Confluence 3.3.4, grâce à la définition des paramètres au début du template, il est possible d’accèder directement à la macro depuis le navigateur de macro et l’auto-complétion fonctionne dans le mode d’édition _Rich Text_.

