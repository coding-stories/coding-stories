---
layout: post
title: "Les classes internes ou la tambouille du compilateur Java"
date: 2011-12-26 23:54
comments: true
categories: [bytecode, compiler, java]
---
Il y a quelques mois Olivier Croisier a publié sur son blog [The Coder’s Breakfast](http://thecodersbreakfast.net/) (que tout développeur Java se doit de suivre) un article intitulé [Inner classes and the myth of the default constructor](Inner classes and the myth of the default constructor). Dans cet article il est question des classes internes et des constructeurs « cachés » ajoutés lors de la phase de compilation.

<!--more-->

Prenons ce morceau de code :

{% codeblock lang:java %}
public class Outer
{
    public Outer() {
        new Inner();
    }
    public class Inner {}
}
{% endcodeblock %}

Et regardons le bytecode des constructeurs généré par le compilateur :

{% codeblock %}
// Outer.class
**** <init> () -> void
    0: aload $0
    1: invokespecial java/lang/Object.<init> {() -> void}
    4: new Outer$Inner
    7: dup
    8: aload $0
    9: invokespecial Outer$Inner.<init> {(Outer) -> void}
   12: pop
   13: return

// Outer$Inner.class
**** <init> (Outer) -> void
    0: aload $0
    1: aload $1
    2: putfield Outer$Inner.this$0 {Outer}
    5: aload $0
    6: invokespecial java/lang/Object.<init> {() -> void}
    9: return
{% endcodeblock %}

La class `Inner` s’est vue ajouter un constructeur qui prend un paramètre de type `Outer` et quand `Outer` appelle ce constructeur il passe this en paramètre (l’instruction `aload $0` charge `this` sur la pile juste avant l’appel du constructeur).

En fait la classe interne est vue comme n’importe quelle autre classe. Pour lui permettre d’accès à la classe englobante il lui faut un pointeur vers l’instance de cette classe. Ce pointeur lui est passé en paramètre dans un constructeur ajouté à la compilation.

Allons un peu plus loin. Si la classe interne n’est pas différente des autres classes alors que ce passe-t-il quand la classe englobante veut accéder à une méthode `private` de la classe interne ?

{% codeblock lang:java %}
public class Outer
{
    public Outer() {
        Inner inner = new Inner();
        inner.hello();
    }
    public class Inner {
        private void hello() {
            System.out.println("Hello World");
        }
    }
}
{% endcodeblock %}

Et le bytecode :

{% codeblock %}
// Outer.class
**** <init> () -> void
    0: aload $0
    1: invokespecial java/lang/Object.<init> {() -> void}
    4: new Outer$Inner
    7: dup
    8: aload $0
    9: invokespecial Outer$Inner.<init> {(Outer) -> void}
   12: astore $1
   13: aload $1
   14: invokestatic Outer$Inner.access$000 {(Outer$Inner) -> void}
   17: return

// Outer$Inner.class
**** <init> (Outer) -> void
    0: aload $0
    1: aload $1
    2: putfield Outer$Inner.this$0 {Outer}
    5: aload $0
    6: invokespecial java/lang/Object.<init> {() -> void}
    9: return

**** hello () -> void
    0: getstatic java/lang/System.out {java.io.PrintStream}
    3: ldc "Hello World"
    5: invokevirtual java/io/PrintStream.println {(java.lang.String) -> void}
    8: return

**** access$000 (Outer$Inner) -> void
    0: aload $0
    1: invokespecial Outer$Inner.hello {() -> void}
    4: return
{% endcodeblock %}

La méthode `hello` est privée et donc Outer ne peut pas l'appeler directement. Dans ce le compilateur a ajouté une méthode package statique void `access$000(Inner)` qui sert alors de proxy. Cette méthode se contente alors de rediriger l'appel vers le méthode `hello`. Dans le code de l'appelant l'appel à la méthode privée est simplement remplacé par un appel à la méthode statique correspondante.

Dans le cas de l'accès à un champ privé, le résultat est très similaire :

{% codeblock lang:java %}
public class Outer
{
    public Outer() {
        Inner inner = new Inner();
        String hello = inner.hello;
    }
    public class Inner {
        private String hello = "Hello World";
    }
}
{% endcodeblock %}

{% codeblock %}
// Outer.class
**** <init> () -> void
    0: aload $0
    1: invokespecial java/lang/Object.<init> {() -> void}
    4: new Outer$Inner
    7: dup
    8: aload $0
    9: invokespecial Outer$Inner.<init> {(Outer) -> void}
   12: astore $1
   13: aload $1
   14: invokestatic Outer$Inner.access$000 {(Outer$Inner) -> java.lang.String}
   17: astore $2
   18: return

// Outer$Inner.class
**** <init> (Outer) -> void
    0: aload $0
    1: aload $1
    2: putfield Outer$Inner.this$0 {Outer}
    5: aload $0
    6: invokespecial java/lang/Object.<init> {() -> void}
    9: aload $0
   10: ldc "Hello World"
   12: putfield Outer$Inner.hello {java.lang.String}
   15: return

**** access$000 (Outer$Inner) -> java.lang.String
    0: aload $0
    1: getfield Outer$Inner.hello {java.lang.String}
    4: areturn
{% endcodeblock %}

Dans ce cas aussi, l'accès au champ privé `hello` n'est pas possible directement. Le compiltateur a donc ajouté une méthode package statique `String access$000(Inner)` qui lit le champ (opcode `getfield`) et le renvoie à l'appelant.

Et dans le cas d'un constructeur privé ? Vat-t-on se retrouver avec une méthode statique de type _factory_ qui va instancier l'object qu'on cherche à construire ? Non, ici le compilateur opte pour une autre stratégie :

{% codeblock lang:java %}
public class Outer
{
public class Outer
{
    public Outer() {
        Inner inner = new Inner();
    }
    public class Inner {
        private Inner() {}
    }
}
{% endcodeblock %}

{% codeblock %}
// Outer.class
**** <init> () -> void
    0: aload $0
    1: invokespecial java/lang/Object.<init> {() -> void}
    4: new Outer$Inner
    7: dup
    8: aload $0
    9: aconst_null
   10: invokespecial Outer$Inner.<init> {(Outer, Outer$1) -> void}
   13: astore $1
   14: return

// Outer$Inner.class
**** <init> (Outer) -> void
    0: aload $0
    1: aload $1
    2: putfield Outer$Inner.this$0 {Outer}
    5: aload $0
    6: invokespecial java/lang/Object.<init> {() -> void}
    9: return

**** <init> (Outer, Outer$1) -> void
    0: aload $0
    1: aload $1
    2: invokespecial Outer$Inner.<init> {(Outer) -> void}
    5: return
{% endcodeblock %}

Le compilateur ajoute un second constructeur qui prend deux paramètres : le pointeur vers l'instance de la classe englobante et un paramètre de type `Outer$1`. Quelle est ce type ? Il s'agit d'une interface sans méthode créée automatiquement à la compilation. Cette interface sert simplement différencier les deux constructeurs (le second constructeur se contente d'appeler le premier). Lors de l'appel de ce constructeur ce second paramètre est mis à null (`null` est chargé sur la pile par l'opcode `aconst_null`).

Le problème principal de ces différentes _ruses_ du compilateur est que cela peut rendre les stacktraces difficilement lisibles si on fait un usage immodéré des classes internes. Il vaut mieux également éviter d'appeler des méthodes privées depuis la classe englobante. L'analyseur de code [PMD](http://pmd.sourceforge.net/) définit d'ailleurs une règle [AccessorClassGeneration](http://pmd.sourceforge.net/rules/design.html) qui lève une alerte quand un constructeur privé est appelé depuis la classe englobante.

Et que se passe-t-il si on tente d'accéder à une méthode privée de la classe englobante depuis la classe interne ? Je vous laisse expérimenter :D.
