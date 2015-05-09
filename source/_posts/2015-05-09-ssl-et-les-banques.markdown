---
layout: post
title: "SSL et les banques"
date: 2015-05-09 11:46
comments: true
css: ssl-security
categories: [SSL, TLS, security]
---

Il y a quelques jours l'expert en sécurité Troy Hunt [publiait sur son blog](http://www.troyhunt.com/2015/05/do-you-really-want-bank-grade-security.html) un état des lieux de l'utilisation de SSL par les banques australiennes.

Et qu'en est-il des banques françaises ? En utilisant le service [SSL Labs](https://www.ssllabs.com/) de Qualys, voici les résultats obtenus.

<!-- more -->

<table style="border:none;">
    <tr style="font-size: small; border:none;">
        <th class="rotate"/>
        <th class="rotate"><div><span>Note</span></div></th>
        <th class="rotate"><div><span>SSL v3</span></div></th>
        <th class="rotate"><div><span>Certificats SHA-1</span></div></th>
        <th class="rotate"><div><span>TLS 1.2</span></div></th>
        <th class="rotate"><div><span>RC4</span></div></th>
        <th class="rotate"><div><span>Perfect Forward Secrecy</span></div></th>
        <th class="rotate"><div><span>Vulnérabilité POODLE</span></div></th>
        <th class="rotate"><div><span>Vulnérabilité Heartbleed</span></div></th>
        <th class="rotate"><div><span>Certificat EV</span></div></th>
        <th class="rotate"><div><span>Certificate Transparency</span></div></th>
    </tr>
    <tr>
        <td class="name A"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.ibps.rivesparis.banquepopulaire.fr&hideResults=on">www.ibps.rivesparis.banquepopulaire.fr</a></td>
        <td class="grade A">A</td>
        <td data-feature="SSL 3" class="pass"></td>
        <td data-feature="SHA-1" class="fail"></td>
        <td data-feature="TLS 1.2" class="pass"></td>
        <td data-feature="RC4" class="pass"></td>
        <td data-feature="PFS" class="pass"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info no"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name A"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=secure.ingdirect.fr&hideResults=on">secure.ingdirect.fr</a></td>
        <td class="grade A">A-</td>
        <td data-feature="SSL 3" class="pass"></td>
        <td data-feature="SHA-1" class="fail"></td>
        <td data-feature="TLS 1.2" class="pass"></td>
        <td data-feature="RC4" class="pass"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info yes"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name A"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=boursorama.com&s=83.231.216.140&hideResults=on">www.boursorama.com</a></td>
        <td class="grade A">A-</td>
        <td data-feature="SSL 3" class="pass"></td>
        <td data-feature="SHA-1" class="pass">*</td>
        <td data-feature="TLS 1.2" class="pass"></td>
        <td data-feature="RC4" class="pass"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info yes"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name B"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.axa.fr&s=174.35.7.31&hideResults=on">www.axa.fr</a></td>
        <td class="grade B">B</td>
        <td data-feature="SSL 3" class="pass"></td>
        <td data-feature="SHA-1" class="pass">**</td>
        <td data-feature="TLS 1.2" class="pass"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info no"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name B"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.hellobank.fr&hideResults=on">www.hellobank.com</a></td>
        <td class="grade B">B</td>
        <td data-feature="SSL 3" class="pass"></td>
        <td data-feature="SHA-1" class="pass"></td>
        <td data-feature="TLS 1.2" class="pass"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info no"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name B"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.ca-paris.fr&hideResults=on">www.ca-paris.fr</a></td>
        <td class="grade B">B</td>
        <td data-feature="SSL 3" class="pass"></td>
        <td data-feature="SHA-1" class="pass">**</td>
        <td data-feature="TLS 1.2" class="fail"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info yes"></td>
        <td data-feature="Transparency" class="info yes"></td>
    </tr>
    <tr>
        <td class="name B"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.cic.fr&s=145.226.109.155&hideResults=on">www.cic.fr</a></td>
        <td class="grade B">B</td>
        <td data-feature="SSL 3" class="pass"></td>
        <td data-feature="SHA-1" class="pass"></td>
        <td data-feature="TLS 1.2" class="fail"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info yes"></td>
        <td data-feature="Transparency" class="info yes"></td>
    </tr>
    <tr>
        <td class="name B"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.secure.bnpparibas.net&s=159.50.16.33&hideResults=on">www.secure.bnpparibas.net</a></td>
        <td class="grade B">B</td>
        <td data-feature="SSL 3" class="pass"></td>
        <td data-feature="SHA-1" class="fail"></td>
        <td data-feature="TLS 1.2" class="pass"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info no"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name B"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.caisse-epargne.fr&s=91.135.188.224&hideResults=on">www.caisse-epargne.fr</a></td>
        <td class="grade B">B</td>
        <td data-feature="SSL 3" class="pass"></td>
        <td data-feature="SHA-1" class="fail"></td>
        <td data-feature="TLS 1.2" class="pass"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info no"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name B"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.monabanq.com&s=145.226.99.116&hideResults=on">www.monabanq.com</a></td>
        <td class="grade B">B</td>
        <td data-feature="SSL 3" class="pass"></td>
        <td data-feature="SHA-1" class="fail"></td>
        <td data-feature="TLS 1.2" class="fail"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info no"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name B"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.macif.fr&hideResults=on">www.macif.fr</a></td>
        <td class="grade B">B</td>
        <td data-feature="SSL 3" class="fail"></td>
        <td data-feature="SHA-1" class="pass"></td>
        <td data-feature="TLS 1.2" class="fail"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info yes"></td>
        <td data-feature="Transparency" class="info yes"></td>
    </tr>
    <tr>
        <td class="name B"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.hsbc.fr&s=91.214.6.232">www.hsbc.fr</a></td>
        <td class="grade B">B</td>
        <td data-feature="SSL 3" class="fail"></td>
        <td data-feature="SHA-1" class="pass">**</td>
        <td data-feature="TLS 1.2" class="fail"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info yes"></td>
        <td data-feature="Transparency" class="info yes"></td>
    </tr>
    <tr>
        <td class="name B"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=particuliers.secure.lcl.fr&hideResults=on">particuliers.secure.lcl.fr</a></td>
        <td class="grade B">B</td>
        <td data-feature="SSL 3" class="pass"></td>
        <td data-feature="SHA-1" class="fail"></td>
        <td data-feature="TLS 1.2" class="fail"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info yes"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name B"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=creditmutuel.fr&s=145.226.45.139&hideResults=on">www.creditmutuel.fr</a></td>
        <td class="grade B">B</td>
        <td data-feature="SSL 3" class="pass"></td>
        <td data-feature="SHA-1" class="fail"></td>
        <td data-feature="TLS 1.2" class="fail"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info no"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name C"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.fortuneo.fr&s=194.51.217.72&hideResults=on">www.fortuneo.fr</a></td>
        <td class="grade C">C</td>
        <td data-feature="SSL 3" class="fail"></td>
        <td data-feature="SHA-1" class="pass">**</td>
        <td data-feature="TLS 1.2" class="fail"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="fail"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info no"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name C"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.societegenerale.fr&hideResults=on">www.societegenerale.fr</a></td>
        <td class="grade C">C</td>
        <td data-feature="SSL 3" class="fail"></td>
        <td data-feature="SHA-1" class="fail"></td>
        <td data-feature="TLS 1.2" class="pass"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="fail"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info no"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name C"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.allianzbanque.fr&hideResults=on">www.allianzbanque.fr</a></td>
        <td class="grade C">C</td>
        <td data-feature="SSL 3" class="fail"></td>
        <td data-feature="SHA-1" class="fail"></td>
        <td data-feature="TLS 1.2" class="fail"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="fail"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info yes"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name C"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.credit-du-nord.fr&hideResults=on">www.credit-du-nord.fr</a></td>
        <td class="grade C">C</td>
        <td data-feature="SSL 3" class="fail"></td>
        <td data-feature="SHA-1" class="fail"></td>
        <td data-feature="TLS 1.2" class="fail"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="fail"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info no"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name F"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=espaceclient.groupama.fr&hideResults=on">espaceclient.groupama.fr</a></td>
        <td class="grade F">F</td>
        <td data-feature="SSL 3" class="fail"></td>
        <td data-feature="SHA-1" class="fail"></td>
        <td data-feature="TLS 1.2" class="fail"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="pass"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info no"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
    <tr>
        <td class="name F"><a href="https://www.ssllabs.com/ssltest/analyze.html?d=www.labanquepostale.fr&hideResults=on">www.labanquepostale.fr</a></td>
        <td class="grade F">F</td>
        <td data-feature="SSL 3" class="fail"></td>
        <td data-feature="SHA-1" class="fail"></td>
        <td data-feature="TLS 1.2" class="pass"></td>
        <td data-feature="RC4" class="fail"></td>
        <td data-feature="PFS" class="fail"></td>
        <td data-feature="POODLE" class="fail"></td>
        <td data-feature="Heartbleed"class="pass"></td>
        <td data-feature="EV" class="info yes"></td>
        <td data-feature="Transparency" class="info no"></td>
    </tr>
</table>

<div style="font-size: x-small;">
* un certificat intermédiaire utilise SHA-1
<br/>
** Le certificat de l'autorité racine utilise SHA-1
</div>

Quelques remarques complémentaires :

D'abord, en faisant ce test, j'ai été surpris de découvrir que nombreuses banques ne servaient pas leur page d'accueil directement en HTTPS.

Ensuite bravo aux équipes IT de la Banque populaire, de ING Direct et de Boursorama pour leur note A.

Enfin, concernant les notes C et F, elles sont principalement dues à des serveurs vulnérables à l'attaque [POODLE](https://fr.wikipedia.org/wiki/POODLE) (sauf Groupama, vulnérable à [une attaque sur la renégociation TLS](https://community.qualys.com/blogs/securitylabs/2009/11/05/ssl-and-tls-authentication-gap-vulnerability-discovered?_ga=1.245541639.2029124093.1429356581)). Il n'y a sans doute pas de vrai risque d'attaque car les banques disposent d'autres mécanismes de protection. Toutefois cela ne donne pas une bonne image et n'incite pas à la confiance - et moi-même étant client de la Banque Postale, je m'interroge.