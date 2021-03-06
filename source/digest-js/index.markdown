---
layout: page
title: "digest.js"
date: 2012-09-27 01:30
comments: false
sharing: true
footer: true
---

Overview
========

**digest.js** is a javascript library implementing cryptographic digest, HMAC algorithms and Password-based Key Derivation Function.

**digest.js** is designed for modern web browsers and requires the [W3C Typed Arrays](http://www.khronos.org/registry/typedarray/specs/latest/) support. digest.js has been successfully tested with these web browsers:

+ Chrome 11
+ Firefox 4 (WARNING: since Firefox does not support the `Dataview` API, you should use the [David Flanagan's emulation](https://github.com/davidflanagan/DataView.js))
+ Safari 5.1

### Supported algorithms:

+ digest
  + MD5
  + SHA-1
  + SHA-256
+ Message Authentication Code (MAC)
  + HMAC/MD5
  + HMAC/SHA-1
  + HMAC/SHA-256
+ Password-Based Key Derivation Function (PBKDF)
  + PBKDF1/SHA1
  + PBKDF1/MD5
  + PBKDF2/HMAC/SHA1
  + PBKDF2/HMAC/SHA-256


API Usage
=========

Digest
------

1. Initialize a digest object

{% codeblock lang:javascript %}
var dg = new Digest.SHA1();
{% endcodeblock %}

2. Update some data

{% codeblock lang:javascript %}
var data = new ArrayBuffer(3);
var buf = new Uint8Array(data);
buf[0] = 0x61; /* a */
buf[1] = 0x62; /* b */
buf[2] = 0x63; /* c */
dg.update(data);
{% endcodeblock %}

3. Finalize

{% codeblock lang:javascript %}
var result = dg.finalize();
{% endcodeblock %}

It is also possible to digest some data at once:

{% codeblock lang:javascript %}
var dg = new Digest.SHA1();
var result = dg.digest("abc");
{% endcodeblock %}

MAC
---

1. Initialize a MAC object

{% codeblock lang:javascript %}
var mac = new Digest.HMAC_SHA1();
{% endcodeblock %}

2. Set the key

{% codeblock lang:javascript %}
mac.setKey("KeyInPlainText");
{% endcodeblock %}

3. Update some data

{% codeblock lang:javascript %}
var data = new ArrayBuffer(50);
var buf = new Uint8Array(data);
for (var i = 0; i < 50; i++) {
    buf[i] = 0xdd;
}
mac.update(data);
{% endcodeblock %}

4. Finalize

{% codeblock lang:javascript %}
var result = mac.finalize();
{% endcodeblock %}

PBKDF
-----

1. Initialize a PBKDF object with the iteration count

{% codeblock lang:javascript %}
var pbkdf = new Digest.PBKDF_HMAC_SHA1(2048);
{% endcodeblock %}

2. Derive key with the password, salt and desired key length (in bytes)

{% codeblock lang:javascript %}
var key = pbkdf.deriveKey("password", "salt", 24);
{% endcodeblock %}


Misc
----

After the `finalize`, `digest` or `mac` methods have been called, the digest or mac object is automatically reset and can be reused.

The `update`, `digest` and `mac` methods accept these data types:

+ `ArrayBuffer`
+ `String` (US-ASCII encoding)
+ `byte` (i.e. a number in the range 0-255)

The MAC `setKey` method accepts these data types:

+ `ArrayBuffer`
+ `String` (US-ASCII encoding)

The PBKDF `deriveKey` method accepts these data types for password and salt:

+ `ArrayBuffer`
+ `String` (US-ASCII encoding)


License
=======
**digest.js** is released under the terms of the [GNU GENERAL PUBLIC LICENSE Version 3](http://www.gnu.org/licenses/gpl.html)