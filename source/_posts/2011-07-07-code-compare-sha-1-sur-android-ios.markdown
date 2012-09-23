---
layout: post
title: "Code comparé : SHA-1 sur Android &amp; iOS"
date: 2011-07-07 17:57
comments: true
categories:
---
Problème : on dispose d’un bloc de données dont on désire calculer l’empreinte SHA-1. Deux solutions, sur Android et iOS.

Android
=======

{% codeblock lang:java %}
import java.security.MessageDigest;
/* ... */
public static byte[] computeSHA1(byte[] input) {
    MessageDigest dg = MessageDigest.getInstance("SHA-1");
    return dg.digest(input);
}
{% endcodeblock %}

iOS
===

{% codeblock lang:objc %}
#import <CommonCrypto/CommonDigest.h>
/* ... */
+ (NSData*) computeSHA1:(NSData*)input
{
    unsigned char output[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([input bytes], (CC_LONG)[input length], output);
    return [NSData dataWithBytes:output length:CC_SHA1_DIGEST_LENGTH];
}
{% endcodeblock %}
